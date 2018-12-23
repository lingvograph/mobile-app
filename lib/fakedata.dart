import 'dart:math';

import 'package:memoapp/lingvo.dart';
import 'package:memoapp/model.dart';

var words = [
  {
    'text': {
      'en': 'house',
      'ru': 'дом',
    },
    'transcription': {
      'en': 'hause',
      'ru': "'хаус",
    },
    'image': 'http://epicpix.com/wp-content/uploads/2016/04/ff_3280.jpg',
    'pronunciation': {
      'en': 'https://howjsay.com/mp3/house.mp3',
    },
  },
  {
    'text': {
      'en': 'lake',
      'ru': 'озеро',
    },
    'transcription': {
      'en': 'leik',
      'ru': "'лэйк",
    },
    'image': 'https://github.com/flutter/website/blob/master/src/_includes/code/layout/lakes/images/lake.jpg?raw=true',
    'pronunciation': {
      'en': 'https://howjsay.com/mp3/lake.mp3',
    },
  },
].map((t) => Word.fromJson(t))
.toList();

var rnd = new Random();

class FakeLingvoService implements ILingvoService {
  @override
  Future<Word> nextWord() async {
    var i = rnd.nextInt(words.length);
    return words[i];
  }
}
