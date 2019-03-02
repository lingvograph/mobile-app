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
    'image': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f1/%D0%9E%D0%B7%D0%B5%D1%80%D0%BE_%D0%A1%D0%BC%D0%B5%D1%80%D0%B4%D1%8F%D1%87%D1%8C%D0%B5.jpg/1200px-%D0%9E%D0%B7%D0%B5%D1%80%D0%BE_%D0%A1%D0%BC%D0%B5%D1%80%D0%B4%D1%8F%D1%87%D1%8C%D0%B5.jpg',
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
    'image': 'https://ormatek.com/upload/products/2b4/f32/2b4f3266f8c711e6951c2c768a5115e1/main/2b4f3266-f8c7-11e6-951c-2c768a5115e1_4ea178f7-4536-11e7-bc9d-2c768a5115e1.jpeg',
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
    'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRKLUYuJGon1owJX__Y7Ov3uzLVPwMzK7dXDS375I5DRRP3ISprGA',
  },
   {
    'text@en': 'car',
    'text@ru': 'автомобиль',
    'transcription@en': 'kɑːr',
    'transcription@ru': "'кар",
    'pronunciation@en': 'https://howjsay.com/mp3/car.mp3',
    'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRmIGgC7NLbTyrby1pTLhexemP0apw-H_zJ0at2BdJhPuHdhqiu',
  },
  {
    'text@en': 'door',
    'text@ru': 'дверь',
    'transcription@en': 'dɔːr',
    'transcription@ru': "'дор",
    'pronunciation@en': 'https://howjsay.com/mp3/door.mp3',
    'image': 'https://images.obi.ru/product/RU/800x600/400211_1.jpg',
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
