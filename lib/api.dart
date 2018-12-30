import 'dart:convert';
import 'package:http/http.dart';
import 'package:http_auth/http_auth.dart';

// TODO move to config
const apiBaseURL = 'http://192.168.0.107:4200/api';

abstract class AuthStateListener {
  void onChanged(bool isLoggedIn);
}

// TODO revise auth state management
class AuthState {
  String apiToken = '';
  List<AuthStateListener> _subscribers = new List<AuthStateListener>();

  void subscribe(AuthStateListener listener) {
    _subscribers.add(listener);
  }

  void notify(bool isLoggedIn) {
    if (!isLoggedIn) {
      apiToken = '';
    }
    _subscribers.forEach((AuthStateListener s) => s.onChanged(isLoggedIn));
  }
}

var authState = new AuthState();

void setToken(String token) {
  authState.apiToken = token;
}

String makeApiURL(String path) {
  return apiBaseURL + path;
}

Future<String> login(String username, String password) async {
  var http = BasicAuthClient(username, password);
  var res = await http.post(makeApiURL('/login'));
  var json = jsonDecode(res.body);
  return json['token'] as String;
}

Future<Response> query(String query) async {
  var headers = {
    'Authorization': 'Bearer ' + authState.apiToken,
    'Content-Type': 'application/graphql',
  };
  var resp = await post(makeApiURL('/query'), headers: headers, body: query);
  if (resp.statusCode == 401) {
    authState.notify(false);
  }
  return resp;
}
