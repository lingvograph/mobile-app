import 'dart:async';

import 'package:memoapp/model.dart';

abstract class ILingvoService {
  Future<ListResult<Term>> fetch(int offset, int limit);
}
