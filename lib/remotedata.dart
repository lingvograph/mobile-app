import 'package:memoapp/api.dart';
import 'package:memoapp/data.dart';
import 'package:memoapp/fakedata.dart';
import 'package:memoapp/interfaces.dart';
import 'package:memoapp/model.dart';

// TODO GraphQL query to get unknown/learning word, if no words get random word
// TODO find words in order of preferences
makeQuery(String firstLang, int offset) {
  var filter = '@filter(not eq(lang, "$firstLang"))';
  var q = """{
      terms(func: has(<_term>), offset: $offset, first: 100) $filter {
        text
        lang
        transcript: transcript@ru:en
        translated_as {
          text
          lang
          transcript: transcript@ru:en
          audio {
            url
          }
        }
        audio {
          url
        }
        visual {
          url
        }
      }
      count(func: has(<_term>)) $filter {
        total: count(uid)
      }
    }""";
  return q;
}

class RealLingvoService implements ILingvoService {
  int offset = 0;
  int total = 0;
  FakeLingvoService fakeService = new FakeLingvoService();

  @override
  Future<Word> nextWord() async {
    var appState = appData.appState;
    if (!appState.isLoggedIn) {
      return fakeService.nextWord();
    }
    if (offset >= total) {
      offset = 0;
    }

    var firstLang = appState.user.firstLang;
    var q = makeQuery(firstLang, offset);
    try {
      var results = await query(q);
      total = results['count'][0]['total'];

      var result = results['terms'][0];
      var w = Map<String, dynamic>();

      var setProps = (dynamic t) {
        var lang = t['lang'];
        w["text@$lang"] = t['text'];
        if (t.containsKey('transcript')) {
          w["transcription@$lang"] = t['transcript'];
        }
        if (t.containsKey('audio')) {
          w["pronunciation@$lang"] = t['audio'][0];
        }
      };

      setProps(result);
      if (result.containsKey('translated_as')) {
        result['translated_as'].forEach(setProps);
      }
      if (result.containsKey('visual')) {
        w['image'] = result['visual'][0];
      }

      var word = Word.fromJson(w);
      offset += 1;
      return word;
    } catch (err) {
      return fakeService.nextWord();
    }
  }
}
