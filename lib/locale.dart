import 'package:memoapp/AppData.dart';

final localeData = const {
  'en': {
    'passwordValidation': 'The Password must be at least 6 characters.',
  },
  'ru': {
    'passwordValidation': 'Пароль дожен включать как минимум 6 символов',
  },
};

String lang() {
  return appData?.appState?.user?.firstLang ?? 'ru';
}

// TODO make a tool to generate code below
class SR {
  static get passwordValidation {
    return localeData[lang()]['passwordValidation'];
  }
}
