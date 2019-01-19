import 'dart:convert';

import 'package:memoapp/api.dart';
import 'package:memoapp/fakedata.dart';
import 'package:memoapp/interfaces.dart';
import 'package:memoapp/model.dart';
import 'package:memoapp/state.dart';

// TODO GraphQL query to get unknown/learning word, if no words get random word
// TODO find words in order of preferences
makeQuery(String firstLang, int offset) {
  var filter = '@filter(not eq(lang, "${firstLang}"))';
  var q = """{
      words(func: has(<_word>), offset: $offset, first: 1) ${filter} {
        text
        lang
        transcription
        translated_as {
          text
          lang
          transcription
          pronounced_as {
            url
          }
        }
        pronounced_as {
          url
        }
        relevant {
          url
        }
      }
      count(func: has(<_word>)) ${filter} {
        total: count(uid)
      }
    }""";
  return q;
}

class RealLingvoService implements ILingvoService {
  AppState appState;
  int offset = 0;
  int total = 0;
  FakeLingvoService fakeService = new FakeLingvoService();

  RealLingvoService(this.appState);

  @override
  Future<Word> nextWord() async {
    if (!appState.isLoggedIn) {
      return fakeService.nextWord();
    }
    if (offset >= total) {
      offset = 0;
    }

    var firstLang = appState.user.firstLang;
    var q = makeQuery(firstLang, offset);
    try {
      var resp = await query(q);
      if (resp.statusCode == 200) {
        var respText = utf8.decode(resp.bodyBytes);
        var results = jsonDecode(respText);
        total = results['count'][0]['total'];

        var result = results['words'][0];
        var w = Map<String, dynamic>();

        var setProps = (dynamic t) {
          var lang = t['lang'];
          w["text@${lang}"] = t['text'];
          if (t.containsKey('transcription')) {
            w["transcription@${lang}"] = t['transcription'];
          }
          if (t.containsKey('pronounced_as')) {
            w["pronunciation@${lang}"] = t['pronounced_as'][0];
          }
        };

        setProps(result);
        if (result.containsKey('translated_as')) {
          result['translated_as'].forEach(setProps);
        }
        if (result.containsKey('relevant')) {
          w['image'] = result['relevant'][0];
        }

        var word = Word.fromJson(w);
        offset += 1;
        return word;
      }
      return fakeService.nextWord();
    } catch (err) {
      return fakeService.nextWord();
    }
  }
}
