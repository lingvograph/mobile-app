import 'dart:convert';
import 'package:http/http.dart';

dynamic parseJSON(Response resp) {
  var respText = utf8.decode(resp.bodyBytes);
  return jsonDecode(respText);
}

bool isOK(Response resp) {
  return resp.statusCode >= 200 && resp.statusCode < 300;
}

bool isJSON(Response resp) {
  if (resp.headers.containsKey('content-type')) {
    var s = resp.headers['content-type'];
    return s != null && s.startsWith('application/json');
  }
  return false;
}

String getErrorMessage(Response resp) {
  if (isJSON(resp)) {
    var json = parseJSON(resp) as Map<String, dynamic>;
    if (json.containsKey('error')) {
      var error = json['error'] as String;
      return error;
    }
    if (json.containsKey('error_message')) {
      var error = json['error_message'] as String;
      return error;
    }
    return utf8.decode(resp.bodyBytes);
  } else {
    return utf8.decode(resp.bodyBytes);
  }
}

Map<String, String> multilangText(Map<String, dynamic> json, String key) {
  final prefix = '$key@';
  final result = new Map<String, String>();
  json.keys.where((k) => k.startsWith(prefix)).forEach((k) {
    final lang = k.substring(k.indexOf('@') + 1);
    result[lang] = json[k] as String;
  });
  return result;
}
