import 'dart:async';

import 'package:memoapp/api.dart';
import 'package:memoapp/AppData.dart';
import 'package:memoapp/interfaces.dart';

// TODO filter known words
makeQuery(String firstLang, int offset, int limit) {
  var filter = '@filter(not eq(lang, "$firstLang"))';
  var q = """{
      terms(func: has(Term), offset: $offset, first: $limit) $filter 
      {
        uid
        text
        lang
        transcript@ru
        transcript@en
        tag 
        {
          uid
          text@en
          text@ru
        }
        translated_as 
        {
          uid
          text
          lang
          transcript@ru
          transcript@en
          tag 
          {
            uid
            text@en
            text@ru
          }
        }
        audio 
        {
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
        visual 
        {
          url
          source
          content_type
          created_at
          created_by 
          {
            uid
            name
          }
        }
      }
      count(func: has(Term)) $filter 
      {
        total: count(uid)
      }
    }""";
  return q;
}

class RealLingvoService implements ILingvoService {
  @override
  Future<ListResult<TermInfo>> fetch(int offset, int limit) async {
    var appState = appData.appState;
    var firstLang = appState.user.firstLang;
    var q = makeQuery(firstLang, offset, limit);
    var results = await query(q);
    var total = results['count'][0]['total'];
    var terms = results['terms'] as List<dynamic>;
    var items = terms.map((t) => TermInfo.fromJson(t)).toList();
    return new ListResult<TermInfo>(items, total);
  }
}
