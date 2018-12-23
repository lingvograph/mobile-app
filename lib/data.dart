import 'package:memoapp/fakedata.dart';
import 'package:memoapp/interfaces.dart';

class AppData {
  ILingvoService lingvo = new FakeLingvoService();
}

var appData = new AppData();
