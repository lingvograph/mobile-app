import 'package:memoapp/model.dart';

abstract class ILingvoService {
  Future<Word> nextWord();
}
