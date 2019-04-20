import 'dart:async';

import 'package:memoapp/api/termquery.dart';
import 'package:memoapp/api/api.dart' as api;
import 'package:memoapp/AppData.dart';
import 'package:memoapp/api/model.dart';
import 'package:memoapp/interfaces.dart';

class RealLingvoService implements ILingvoService {
  @override
  Future<ListResult<TermInfo>> fetchTerms(int offset, int limit,
      {TermFilter filter = null}) async {
    var appState = appData.appState;
    var firstLang = appState.user.firstLang;
    return api.fetchTerms(firstLang, offset, limit, filter: filter);
  }
}
