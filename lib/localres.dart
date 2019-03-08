import 'dart:math';

import 'package:memoapp/interfaces.dart';
import 'package:memoapp/model.dart';

final String PasswordLengthNotifications = "passwordLengthNotifications";

var Translations = '''
  {
    "name": 
      [
        {
          "en":"mige",
          "ru":"mikhail"
        }
      ],
      
      "$PasswordLengthNotifications": 
      [
        {
          "en":"The Password must be at least 6 characters.",
          "ru":"Пароль дожен включать как минимум 6 символов"
        }
      ]
  }
''';
