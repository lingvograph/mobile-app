import 'dart:async';

import 'package:memoapp/api.dart';
import 'package:memoapp/AppData.dart';
import 'package:memoapp/interfaces.dart';

// TODO inline RealLingvoService
class RealLingvoService implements ILingvoService {
  @override
  Future<ListResult<TermInfo>> fetch(int offset, int limit) async {
    var appState = appData.appState;
    var firstLang = appState.user.firstLang;
    return fetchTerms(firstLang, offset, limit);
  }
}
