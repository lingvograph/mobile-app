import 'package:memoapp/api/model.dart';

enum TermQueryKind { termList, audioList, visualList }

class TermFilter {
  String searchString;
  List<Tag> tags;

  TermFilter(String searchString, {this.tags}) {
    this.searchString = (searchString ?? '').trim();
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

    final audioRange = kind == TermQueryKind.audioList
        ? '(${range.toString()})'
        : '(first: 1)';
    final visualRange = kind == TermQueryKind.visualList
        ? '(${range.toString()})'
        : '(first: 10)';
    final termRange = isTermList ? ', ${range.toString()}' : '';

    // TODO use regexp to find by substring
    final searchFilter =
    isTermList && filter != null && filter.searchString.isNotEmpty
        ? ' and anyoftext(text, "${filter.searchString}")'
        : '';

    // TODO add filter by tags
    final termFilter = isTermList
        ? '@filter(has(Term) and not eq(lang, "$firstLang")$searchFilter)'
        : '';

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
      count(func: has(Term)) $termFilter {
        total: count(${countBy()})
      }
    }""";
    return q;
  }

  countBy() {
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
