import 'dart:math';

import 'package:memoapp/interfaces.dart';
import 'package:memoapp/model.dart';

final String PasswordLengthNotifications = "passwordLengthNotifications";

String _ru = "ru";
String _en = "en";
var Translations = '''
  {
    "name": 
      [
        {
          "$_en":"mige",
          "$_ru":"mikhail"
        }
      ],
      
      "$PasswordLengthNotifications": 
      [
        {
          "$_en":"The Password must be at least 6 characters.",
          "$_ru":"Пароль дожен включать как минимум 6 символов"
        }
      ]
  }
''';
