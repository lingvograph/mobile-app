import 'package:memoapp/fakedata.dart';
import 'package:memoapp/lingvo.dart';

class AppData {
  ILingvoService lingvo = new FakeLingvoService();
}

var appData = new AppData();
