import 'package:memoapp/fakedata.dart';
import 'package:memoapp/interfaces.dart';
import 'package:memoapp/remotedata.dart';
import 'package:memoapp/state.dart';

class AppData {
  AppState _appState;
  ILingvoService lingvo = new FakeLingvoService();

  get appState {
    return _appState;
  }
  set appState(AppState value) {
    _appState = value;
    lingvo = new RealLingvoService(value);
  }
}

var appData = new AppData();
