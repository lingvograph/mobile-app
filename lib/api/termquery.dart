import 'package:memoapp/AppData.dart';
import 'package:memoapp/api/model.dart';

bool isWord(String s) {
  if (s == null || s.isEmpty) {
    return false;
  }
  final exp = new RegExp(r"^\w+$");
  return exp.hasMatch(s);
}

enum TermQueryKind { termList, audioList, visualList, tagsList}

class TermFilter {
  String searchString;
  List<Tag> tags;
  String searchedTag;
  TermFilter(String searchString, {this.tags}) {
    this.searchString = (searchString ?? '').trim();
  }
  TermFilter.byTag({this.searchedTag})
  {
    this.searchString = searchedTag;
  }
}

class TermQuery {
  TermQueryKind kind = TermQueryKind.termList;
  String firstLang;
  String termUid; // for single term request
  TermFilter filter;
  Pagination range;

  TermQuery(
      {this.kind, this.firstLang, this.termUid, this.filter, this.range}) {}

  // TODO filter known words
  // TODO order audio, visual by popularity
  makeQuery() {
    final matchFn =
        termUid != null && termUid.isNotEmpty ? 'uid($termUid)' : 'has(Term)';
    final isTermList = kind == TermQueryKind.termList;
    //final isTagList = kind == TermQueryKind.tagsList;

    final audioRange = kind == TermQueryKind.audioList
        ? '(${range.toString()})'
        : '(first: 1)';
    final visualRange = kind == TermQueryKind.visualList
        ? '(${range.toString()})'
        : '(first: 10)';
    final termRange = isTermList ? ', ${range.toString()}' : '';

    final searchExpr = makeSearchFilter();
    final searchFilter = searchExpr.isNotEmpty ? ' and $searchExpr' : '';

    // TODO add filter by tags
    final termFilter = isTermList
        ? '@filter(has(Term) and not eq(lang, "$firstLang")$searchFilter)'
        : '';

    /*final tagFilter = isTagList
        ? '@filter( $searchExpr)'
        : '';*/
    final q = """{
      terms(func: $matchFn$termRange) $termFilter {
        uid
        text
        lang
        transcript@ru
        transcript@en
        tag {
          uid
          text@en
          text@ru
        }
        translated_as {
          uid
          text
          lang
          transcript@ru
          transcript@en
          tag {
            uid
            text@en
            text@ru
          }
        }
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
        }
      }
      count(func: $matchFn) $termFilter {
        total: count(${countBy()})
      }
    }""";
    print(q.toString());
    return q;
  }

  String makeSearchFilter() {
    if (kind != TermQueryKind.termList ) {
      return '';
    }

    final str = (filter?.searchString ?? '').trim();
    if (str.isEmpty) {
      return '';
    }
    /*if(kind == TermQueryKind.tagsList)
    {
      print('Make filter with '+str);
      return 'eq(text@ru, "$str")';
    }*/
    // too small word fails with 'regular expression is too wide-ranging and can't be executed efficiently'
    final regexp = isWord(str) && str.length >= 3 ? 'regexp(text, /$str.*/i)' : '';
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
      case TermQueryKind.tagsList:
        return 'uid';
    }
  }
}
