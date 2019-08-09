import 'package:memoapp/api/model.dart';

bool isWord(String s) {
  if (s == null || s.isEmpty) {
    return false;
  }
  final exp = new RegExp(r"^\w+$");
  return exp.hasMatch(s);
}

enum TermQueryKind { termList, audioList, visualList }

class TermFilter {
  String searchString;
  List<TermInfo> tags;

  TermFilter(String searchString, {List<TermInfo> tags}) {
    this.searchString = (searchString ?? '').trim();
    this.tags = tags ?? new List<TermInfo>();
  }
}

class TermQuery {
  TermQueryKind kind = TermQueryKind.termList;
  String firstLang;
  String termUid; // for single term request
  TermFilter filter;
  Pagination range;
  bool detailed = false;

  TermQuery(
      {this.kind,
      this.firstLang,
      this.termUid,
      this.filter,
      this.range,
      this.detailed = false}) {
    if (this.filter == null) {
      this.filter = new TermFilter('');
    }
  }

  // TODO filter known words
  // TODO order audio, visual by popularity
  makeQuery() {
    final matchFn =
        termUid != null && termUid.isNotEmpty ? 'uid($termUid)' : 'has(Term)';
    final isTermList = kind == TermQueryKind.termList;

    final audioRange = kind == TermQueryKind.audioList
        ? '(${range.toString()})'
        : '(first: 1)';
    final visualRange = kind == TermQueryKind.visualList
        ? '(${range.toString()})'
        : '(first: 10)';
    final termRange = isTermList ? ', ${range.toString()}' : '';

    final brace = (String s) => '($s)';
    final searchFilter = makeSearchFilter();
    final langFilter = 'not eq(lang, "$firstLang")';
    final tagFilter = filter.tags.isNotEmpty
        ? brace(filter.tags.map((t) => 'uid_in(tag, ${t.uid})').join(' or '))
        : '';

    final filterExpr = ['has(Term)', langFilter, tagFilter, searchFilter]
        .where((s) => s != null && s.isNotEmpty)
        .join(' and ');
    final termFilter = isTermList ? '@filter($filterExpr)' : '';

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

    final detailedInfo = detailed
        ? """
        translated_as {
          $termBody
        }
        in{
          $termBody
        }
        related{
          $termBody
        }
        def{
          $termBody
        }
        def_of{
          $termBody
        }"""
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
    if (kind != TermQueryKind.termList) {
      return '';
    }

    final str = (filter.searchString ?? '').trim();
    if (str.isEmpty) {
      return '';
    }

    // too small word fails with 'regular expression is too wide-ranging and can't be executed efficiently'
    final regexp =
        isWord(str) && str.length >= 3 ? 'regexp(text, /$str.*/i)' : '';
    final anyoftext = 'anyoftext(text, "$str")';
    final exprs = [anyoftext, regexp].where((s) => s.isNotEmpty).toList();
    if (exprs.length > 1) {
      return '(${exprs.join(' or ')})';
    }
    return exprs[0];
  }

  String countBy() {
    switch (kind) {
      case TermQueryKind.termList:
        return 'uid';
      case TermQueryKind.audioList:
        return 'audio';
      case TermQueryKind.visualList:
        return 'visual';
    }
  }
}
