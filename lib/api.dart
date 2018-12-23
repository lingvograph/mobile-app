import 'dart:convert';
import 'package:http_auth/http_auth.dart';

const apiBaseURL = 'http://192.168.0.107:4200/api';

Future<String> login(String username, String password) async {
  var http = BasicAuthClient(username, password);
  var res = await http.post(apiBaseURL + '/login');
  var json = jsonDecode(res.body);
  return json['token'] as String;
}
