import 'dart:async';

import 'package:memoapp/api.dart';
import 'package:memoapp/AppData.dart';
import 'package:memoapp/interfaces.dart';
import 'package:memoapp/model.dart';

// TODO filter known words
makeQuery(String firstLang, int offset, int limit) {
  var filter = '@filter(not eq(lang, "$firstLang"))';
  var q = """{
      terms(func: has(Term), offset: $offset, first: $limit) $filter {
        uid
        text
        lang
        transcript@ru
        transcript@en
        translated_as {
          text
          lang
        }
        audio {
          url
        }
        visual {
          url
        }
      }
      count(func: has(Term)) $filter {
        total: count(uid)
      }
    }""";
  return q;
}

class RealLingvoService implements ILingvoService {
  @override
  Future<ListResult<Term>> fetch(int offset, int limit) async {
    var appState = appData.appState;
    var firstLang = appState.user.firstLang;
    var q = makeQuery(firstLang, offset, limit);
    var results = await query(q);
    var total = results['count'][0]['total'];
    var terms = results['terms'] as List<dynamic>;
    var items = terms.map((t) => decode(t)).toList();
    return new ListResult<Term>(items, total);
  }

  Term decode(dynamic result) {
    var w = Map<String, dynamic>();

    var setProps = (dynamic t) {
      if (t.containsKey('uid')) {
        w['id'] = t['uid'];
      }

      var lang = t['lang'];
      w['text@$lang'] = t['text'];

      ['ru', 'en'].forEach((lang) {
        if (t.containsKey('transcript@$lang')) {
          var k = 'transcription@$lang';
          if (!w.containsKey(k)) {
            w[k] = t['transcript@$lang'];
          }
        }
      });

      if (t.containsKey('audio')) {
        var k = 'pronunciation@$lang';
        if (!w.containsKey(k)) {
          w[k] = t['audio'][0];
        }
      }
    };

    setProps(result);
    if (result.containsKey('translated_as')) {
      result['translated_as'].forEach(setProps);
    }
    if (result.containsKey('visual')) {
      w['image'] = result['visual'];
    }

    return Term.fromJson(w);
  }
}
