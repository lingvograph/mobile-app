import 'package:memoapp/AppState.dart';
import 'package:memoapp/interfaces.dart';
import 'package:memoapp/remotedata.dart';

class AppData {
  AppState appState;
  ILingvoService lingvo = new RealLingvoService();
}

var appData = new AppData();
