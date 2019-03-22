import 'dart:convert';

import 'package:memoapp/data.dart';
import 'package:memoapp/localres.dart';
import 'package:meta/meta.dart';

String lanuidge = appData.appState.user.firstLang;
String getString({@required String key}) {
  var json = jsonDecode(Translations);
  return (json[key] as List<dynamic>)[0][lanuidge];
}
