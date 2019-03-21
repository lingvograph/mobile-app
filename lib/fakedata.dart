import 'dart:async';
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
    'image':
        'https://github.com/flutter/website/blob/master/src/_includes/code/layout/lakes/images/lake.jpg?raw=true',
  },
  {
    'text@en': 'girl',
    'text@ru': 'девушка',
    'transcription@en': 'gerl',
    'transcription@ru': "'гёл",
    'pronunciation@en': 'https://howjsay.com/mp3/girl.mp3',
    'image': 'https://i.ytimg.com/vi/ktlQrO2Sifg/maxresdefault.jpg',
  },
  {
    'text@en': 'bed',
    'text@ru': 'кровать',
    'transcription@en': 'bed',
    'transcription@ru': "'бэд",
    'pronunciation@en': 'https://howjsay.com/mp3/bed.mp3',
    'image':
        'https://hoff.ru//upload/iblock/9be/9be0921f96cf2f30b4e5136c4eccd7d8.jpg',
  },
  {
    'text@en': 'boy',
    'text@ru': 'мальчик',
    'transcription@en': 'bOI',
    'transcription@ru': "'бой",
    'pronunciation@en': 'https://howjsay.com/mp3/boy.mp3',
    'image': 'https://www.paparazzi.ru/upload/wysiwyg_files/img/1472483485.jpg',
  },
  {
    'text@en': 'body',
    'text@ru': 'тело',
    'transcription@en': 'bOdI',
    'transcription@ru': "'боди",
    'pronunciation@en': 'https://howjsay.com/mp3/body.mp3',
    'image':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRKLUYuJGon1owJX__Y7Ov3uzLVPwMzK7dXDS375I5DRRP3ISprGA',
  },
  {
    'text@en': 'car',
    'text@ru': 'автомобиль',
    'transcription@en': 'kɑːr',
    'transcription@ru': "'кар",
    'pronunciation@en': 'https://howjsay.com/mp3/car.mp3',
    'image':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRmIGgC7NLbTyrby1pTLhexemP0apw-H_zJ0at2BdJhPuHdhqiu',
  },
  {
    'text@en': 'door',
    'text@ru': 'дверь',
    'transcription@en': 'dɔːr',
    'transcription@ru': "'дор",
    'pronunciation@en': 'https://howjsay.com/mp3/door.mp3',
    'image': 'https://images.obi.ru/product/RU/800x600/400211_1.jpg',
  },
].map((t) => Word.fromJson(t)).toList();

class FakeLingvoService implements ILingvoService {
  @override
  Future<ListResult<Word>> fetch(int offset, int limit) async {
    if (offset >= words.length) {
      throw new Exception("offset out of range");
    }
    var end = min(words.length, offset + limit);
    var list = words.sublist(offset, end);
    return new ListResult<Word>(list, words.length);
  }
}
