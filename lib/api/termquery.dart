import 'package:memoapp/api/model.dart';

bool isWord(String s) {
  if (s == null || s.isEmpty) {
    return false;
  }
  final exp = new RegExp(r"^\w+$");
  return exp.hasMatch(s);
}

enum KIND { term, termList, audioList, visualList }

class TermFilter {
  String searchString;
  List<TermInfo> tags;

  TermFilter(String searchString, {List<TermInfo> tags}) {
    this.searchString = (searchString ?? '').trim();
    this.tags = tags ?? new List<TermInfo>();
  }
}

class TermQuery {
  KIND kind = KIND.termList;
  String lang;
  String termUid; // for single term request
  TermFilter filter;
  Pagination range;
  bool detailed = false;
  bool onlyTags = false;
  var params = ["", ""];
  var relationMap = {
    'translated_as': {
      'label': 'Translations',
      'count': 'translated_as_count',
    },
    'definition': {
      'label': 'Definitions',
      'count': 'definition_count',
      'reverseEdge': 'definition_of',
    },
    'definition_of': {
      'label': 'Definition for',
      'count': 'definition_of_count',
    },
    'in': {
      'label': 'Used in',
      'count': 'in_count',
    },
    'related': {
      'label': 'Related Terms',
      'count': 'related_count',
    },
    'synonym': {
      'label': 'Synonyms',
      'count': 'synonym_count',
    },
    'antonym': {
      'label': 'Antonyms',
      'count': 'antonym_count',
    },
  };
  static var TAG = '''tag {
    uid
    text
    lang
    transcript@ru
    transcript@en
  }''';

  static var TERM_BODY = ''''{
    uid
    text
    lang
    transcript@ru
    transcript@en
    created_at
    created_by {
      uid
      name
    }
    ${TAG}
  }''';

  static var FILE_BODY = '''{
    uid
    url
    source
    content_type
    views: count(see)
    likes: count(like)
    dislikes: count(dislike)
    created_at
    created_by {
    uid
    name
  }
  ${TAG}
  }''';

  TermQuery(
      {this.kind = KIND.termList,
      this.lang,
      this.termUid,
      this.filter,
      this.range,
      this.detailed = false,
      this.onlyTags = false}) {
    if (this.filter == null) {
      this.filter = new TermFilter('');
    }
  }

  // TODO filter known words
  // TODO order audio, visual by popularity
  makeTermQuery() {
    //Выглядит правдоподобно
    if (kind == null || !KIND.values.contains(kind)) {
      throw new Exception("invalid kind ${kind.toString()}");
    }
    if (kind == KIND.term && termUid == null) {
      throw new Exception('termUid is required');
    }
    var hasTermType = 'has(Term)';

    var isTerm = kind == 'term';

    final matchFn =
        termUid != null && termUid.isNotEmpty ? 'uid($termUid)' : hasTermType;

    final isTermList = kind == KIND.termList;

    var hasTagType = isTermList && onlyTags ? 'has(Tag)' : '';

    final audioRange =
        kind == KIND.audioList ? '(${range.toString()})' : '(first: 1)';
    final visualRange =
        kind == KIND.visualList ? '(${range.toString()})' : '(first: 10)';
    final termRange = isTermList ? ', ${range.toString()}' : '';

    final brace = (String s) => '($s)';
    final searchFilter = makeSearchFilter();
    final langFilter = lang != null ? 'eq(lang, "${lang}")' : '';

    final tagFilter = filter.tags.isNotEmpty
        ? brace(filter.tags.map((t) => 'uid_in(tag, ${t.uid})').join(' or '))
        : '';

    final filterExpr = [
      hasTermType,
      hasTagType,
      langFilter,
      tagFilter,
      searchFilter
    ].where((s) => s != null && s.isNotEmpty).join(' and ');
    final termFilter = isTermList ? '@filter($filterExpr)' : '';

    const fileEdges = ['audio', 'visual'];
    var makeEdge = (String name) {
      var isFile = fileEdges.contains(name);
      var myrange = kind == name ? '(${range})' : '(first: 10)';
      var body = isFile ? FILE_BODY : TERM_BODY;
      return '${name} ${myrange} ${body}';
    };

    var args = params.map((k) => '${k}: string').join();
    //var totals = isTerm ? allEdgeKeys.map(k => makeTotal(k)).join('\n') : '';
    var paramQuery = args != null ? 'query terms(${args}) ' : '';
    print(paramQuery);

    //var allEdgeKeys = new Map.from(relationMap)..addAll(fileEdges);

    final visualInfo = """
          visual $visualRange {
          url
          source
          content_type
          views: count(see)
          likes: count(like)
          dislikes: count(dislike)
          created_at
          created_by {
            uid
            name
          }
        }""";
    final shortVisualInfo = """
          visual $visualRange {
          url
          source
          content_type
        }""";
    final termBody = """uid
          text
          lang  
          transcript@ru
          transcript@en
          $shortVisualInfo
          tag {
            uid
            text
            lang
            transcript@ru
            transcript@en
          }
          audio $audioRange {
            uid
            url
            source
            content_type
            views: count(see)
            likes: count(like)
            dislikes: count(dislike)
            
          }
          """;

    var bodyFromEdge = (String name, var val) {
      print(name);
      return '${name} {$termBody} ';
    };

    var detailedInfo = "";
    var concatEdges = detailed
        ? relationMap.forEach((k, v) => {detailedInfo += bodyFromEdge(k, v) + '\n'})
        : "";

    final q = """{
      terms(func: $matchFn$termRange) $termFilter {
        uid
        text
        lang
        transcript@ru
        transcript@en
        tag {
          uid
          text
          lang
          transcript@ru
          transcript@en
        }
        $detailedInfo
        $visualInfo
        
        audio $audioRange {
          uid
          url
          source
          content_type
          views: count(see)
          likes: count(like)
          dislikes: count(dislike)
          created_at
          created_by {
            uid
            name
          }
        }
        
      }
      count(func: $matchFn) $termFilter {
        total: count(${countBy()})
      }
    }""";
    return q;
  }

  String makeSearchFilter() {
    if (kind != KIND.termList) {
      return '';
    }

    final searchString = (filter.searchString ?? '').trim();

    if (searchString.isEmpty) {
      return '';
    }

    // too small word fails with 'regular expression is too wide-ranging and can't be executed efficiently'
    var useRegexp = isWord(searchString) && searchString.length >= 3;
    final regexp = useRegexp ? 'regexp(text, /$searchString.*/i)' : '';
    final anyoftext = 'anyoftext(text, "$searchString")';
    final exprs = [anyoftext, regexp].where((s) => s.isNotEmpty).toList();
    params[0] = searchString;
    if (useRegexp) {
      params[1] = '${searchString}.*';
    }

    if (exprs.length > 1) {
      return '(${exprs.join(' or ')})';
    }
    return exprs[0];
  }

  String countBy() {
    switch (kind) {
      case KIND.term:
        return 'uid';
      case KIND.termList:
        return 'uid';
      case KIND.audioList:
        return 'audio';
      case KIND.visualList:
        return 'visual';
    }
  }
}
