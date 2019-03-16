import 'dart:async';

import 'package:memoapp/model.dart';

abstract class ILingvoService {
  Future<ListResult<Word>> fetch(int offset, int limit);
}
