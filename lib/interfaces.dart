import 'dart:async';

import 'package:memoapp/api/termquery.dart';
import 'package:memoapp/api/model.dart';

abstract class ILingvoService {
  Future<ListResult<TermInfo>> fetchTerms(int offset, int limit, {TermFilter filter = null, String lang});
}
