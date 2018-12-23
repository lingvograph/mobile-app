import 'dart:convert';
import 'package:memoapp/model.dart';
import 'package:shared_preferences/shared_preferences.dart';

const PREFS_KEY = 'APP_STATE';

class AppState {
  User _user;
  String api_token;

  AppState();

  AppState.fromJson(Map json)
      : _user = User.fromJson(json["user"]),
        api_token = json["api_token"];

  Map<String, dynamic> toJson() => {
        'user': _user,
        'api_token': api_token,
      };

  static Future<AppState> load() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var serializedState = prefs.getString(PREFS_KEY);
      if (serializedState == null || serializedState.length == 0) {
        return new AppState();
      }
      var state = jsonDecode(serializedState);
      return AppState.fromJson(state);
    } catch (e) {
      // TODO reset prefs
      return new AppState();
    }
  }

  void save() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var json = jsonEncode(this);
      prefs.setString(PREFS_KEY, json);
    } catch (e) {
    }
  }

  get user {
    return _user;
  }
  set user(User value) {
    _user = value;
    save();
  }

  get isLoggedIn => _user != null && api_token != null && api_token.length > 0;
}
