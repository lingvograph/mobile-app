import 'dart:async';

import 'package:memoapp/api.dart';

abstract class ILingvoService {
  Future<ListResult<TermInfo>> fetchTerms(int offset, int limit, {TermFilter filter = null});
}
