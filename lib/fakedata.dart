import 'dart:math';

import 'package:memoapp/interfaces.dart';
import 'package:memoapp/model.dart';

var words = [
  {
    'text@en': 'house',
    'text@ru': 'дом',
    'transcription@en': 'hause',
    'transcription@ru': "'хаус",
    'pronunciation@en': 'https://howjsay.com/mp3/house.mp3',
    'image': 'http://epicpix.com/wp-content/uploads/2016/04/ff_3280.jpg',
  },
  {
    'text@en': 'lake',
    'text@ru': 'озеро',
    'transcription@en': 'leik',
    'transcription@ru': "'лэйк",
    'pronunciation@en': 'https://howjsay.com/mp3/lake.mp3',
    'image': 'https://github.com/flutter/website/blob/master/src/_includes/code/layout/lakes/images/lake.jpg?raw=true',
  },
  {
    'text@en': 'girl',
    'text@ru': 'девушка',
    'transcription@en': 'gerl',
    'transcription@ru': "'гёл",
    'pronunciation@en': 'https://howjsay.com/mp3/girl.mp3',
    'image': 'https://i.ytimg.com/vi/ktlQrO2Sifg/maxresdefault.jpg',
  },
].map((t) => Word.fromJson(t))
.toList();

var i = 0;

class FakeLingvoService implements ILingvoService {
  @override
  Future<Word> nextWord() async {
    if (i >= words.length) {
      i = 0;
    }
    return words[i++];
  }
}
