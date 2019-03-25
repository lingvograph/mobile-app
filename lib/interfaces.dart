import 'dart:async';

import 'package:memoapp/api.dart';

abstract class ILingvoService {
  Future<ListResult<TermInfo>> fetch(int offset, int limit);
}
