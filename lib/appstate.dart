import 'dart:async';
import 'dart:convert';

import 'package:memoapp/api.dart';
import 'package:memoapp/model.dart';
import 'package:shared_preferences/shared_preferences.dart';

const PREFS_KEY = 'APP_STATE';

class AppState implements AuthStateListener {
  User _user;
  String _apiToken;

  AppState() {
    _observeAuthState();
  }

  AppState.fromJson(Map json) {
    _user = User.fromJson(json["user"]);
    _apiToken = json["api_token"];
    _observeAuthState();
  }

  Map<String, dynamic> toJson() => {
        'user': _user,
        'api_token': _apiToken,
      };

  _observeAuthState() {
    authState.subscribe(this);
  }

  static Future<AppState> load() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var serializedState = prefs.getString(PREFS_KEY);
      if (serializedState == null || serializedState.length == 0) {
        return new AppState();
      }
      var json = jsonDecode(serializedState);
      var state = AppState.fromJson(json);
      setToken(state.apiToken);
      return state;
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
    } catch (e) {}
  }

  get user {
    return _user;
  }

  set user(User value) {
    _user = value;
    save();
  }

  get apiToken {
    return _apiToken;
  }

  set apiToken(String value) {
    _apiToken = value;
    setToken(value);
    save();
  }

  get isLoggedIn =>
      _user != null &&
      _user.name != null &&
      _user.name.length > 0 &&
      _apiToken != null &&
      _apiToken.length > 0;

  @override
  void onChanged(bool isLoggedIn) {
    if (isLoggedIn) {
    } else {
      _user = null;
      _apiToken = null;
    }
  }
}
