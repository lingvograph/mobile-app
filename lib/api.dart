import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:http_auth/http_auth.dart';
import 'package:memoapp/model.dart';

// TODO move to config
const BASE_URL = 'https://lingvograph.com';
const API_KEY =
    'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImFwcF9zZWNyZXQiOiJRRUk3NTNOODJPQ1VJWEk2In0.eyJhcHBfaWQiOiJRVERIOUtZNSJ9.SC9pgbkOB4aMdMZ8xM39eqCAJAmXRZ9T6EyiEIXvfkE';

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

  String get authorizationHeader {
    return 'Bearer $apiToken';
  }
}

var authState = new AuthState();

void setToken(String token) {
  authState.apiToken = token;
}

String makeApiURL(String path, {bool withKey = true}) {
  return BASE_URL + path + (withKey ? '?key=$API_KEY' : '');
}

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

// TODO handle login error
Future<String> login(String username, String password) async {
  var http = BasicAuthClient(username, password);
  var resp = await http.post(makeApiURL('/api/login', withKey: false));
  if (!isOK(resp)) {
    throw new StateError(getErrorMessage(resp));
  }
  var json = parseJSON(resp);
  return json['token'] as String;
}

/// a generic POST API call
/// @param path relative path to API method
/// @param contentType mime type of a body
/// @param body content to be posted
Future<dynamic> postData(
    String methodPath, String contentType, dynamic body) async {
  var headers = {
    'Authorization': authState.authorizationHeader,
    'Content-Type': contentType,
  };
  var url = makeApiURL(methodPath);
  var resp = await post(url, headers: headers, body: body);
  if (resp.statusCode == 401) {
    authState.notify(false);
    throw new StateError('bad auth');
  }
  if (!isOK(resp)) {
    throw new StateError(getErrorMessage(resp));
  }
  var results = parseJSON(resp);
  return results;
}

/// a generic GET API call
/// @param path relative path to API method
Future<dynamic> getData(String methodPath) async {
  var headers = {
    'Authorization': authState.authorizationHeader,
  };
  var url = makeApiURL(methodPath);
  var resp = await get(url, headers: headers);
  if (resp.statusCode == 401) {
    authState.notify(false);
    throw new StateError('bad auth');
  }
  if (!isOK(resp)) {
    throw new StateError(getErrorMessage(resp));
  }
  var results = parseJSON(resp);
  return results;
}

Future<User> fetchCurrentUser() async {
  var results = await getData('/api/me');
  return User.fromJson(results);
}

/// Make a GraphQL query
Future<dynamic> query(String query) async {
  return postData('/api/query', 'application/graphql', query);
}

/// Upload a file
/// @param path a file path
/// @param contentType mime type of a file
/// @param body file content, bytes or file stream
Future<FileInfo> upload(String path, String contentType, dynamic body) async {
  var result = await postData('/api/file/$path', contentType, body);
  return FileInfo.fromJson(result);
}

class FileInfo {
  String uid;
  String path;
  String url;
  String contentType;

  FileInfo.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    path = json['path'];
    url = json['url'];
    contentType = json['content_type'];
  }
}

class NQuad {
  String subject;
  String predicate;
  String object;

  @override
  String toString() {
    return '$subject <$predicate> $object .';
  }

  /// Make a N-Quad string. If subject or object is not defined returns null.
  static String format(String subject, String predicate, String object) {
    if (subject == null || subject.isEmpty) {
      return null;
    }
    if (object == null || object.isEmpty) {
      return null;
    }
    return '$subject <$predicate> $object .';
  }
}

Future<dynamic> updateGraph(Iterable<dynamic> nquads) {
  var body = nquads.map((t) => t.toString()).join('\n');
  return postData('/api/data/nquads', 'application/n-quads', body);
}

class TermUpdate {
  String audioUid;
  String imageUid;
}

// TODO actually these connections should be approved, this can be done using temporary edge like audio_unverified, image_unverified
/// Allows to connect given term to audio or image
Future<dynamic> upadteTerm(String termUid, TermUpdate input) {
  var nquads = [
    NQuad.format(termUid, 'audio', input.audioUid),
    NQuad.format(termUid, 'visual', input.imageUid),
  ].where((t) => t != null && t.isNotEmpty).toList();
  return updateGraph(nquads);
}

List<T> mapList<T>(Map<String, dynamic> json, String key, T mapper(Map<String, dynamic> val)) {
  if (!json.containsKey(key)) {
    return new List<T>();
  }
  return (json[key] as List<Map<String, dynamic>>).map(mapper).toList();
}

class TermInfo {
  String uid;
  String lang;
  String text;
  // transcriptions in different languages
  Map<String, String> transcript;
  List<TermInfo> translations;
  ListResult<AudioInfo> audio;

  TermInfo.fromJson(Map<String, dynamic> results) {
    var total = results['count'][0]['total'];
    var json = results['term'][0] as Map<String, dynamic>;

    uid = json['uid'];
    lang = json['lang'];
    text = json['text'];

    transcript = new Map<String, String>();
    ['ru', 'en'].forEach((lang) {
      if (json.containsKey('transcript@$lang')) {
        transcript[lang] = json['transcript@$lang'] as String;
      }
    });

    translations = mapList(json, 'translated_as', (t) => TermInfo.fromJson(t));
    var audioItems = mapList(json, 'audio', (t) => AudioInfo.fromJson(t));
    audio = new ListResult<AudioInfo>(audioItems, total);
  }
}

class UserInfo {
  String uid;
  String name;

  UserInfo.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    name = json['name'];
  }
}

class AudioInfo {
  String uid;
  String url;
  String source;
  UserInfo author;
  DateTime createdAt;

  AudioInfo.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    url = json['url'];
    source = json['url'];
    createdAt = DateTime.parse(json['created_at']);
    author = UserInfo.fromJson(json['created_by']);
  }
}

// TODO order by popularity
Future<TermInfo> fetchAudioList(
    String termUid, int offset, limit) async {
  var q = """{
      term(func: uid($termUid)) {
        uid
        lang
        text
        transcript@ru
        transcript@en
        translated_as {
          uid
          lang
          text
          transcript@ru
          transcript@en
        }
        audio (offset: $offset, first: $limit) {
          uid
          url
          source
          created_at
          created_by {
            uid
            name
          }
        }
      }
      count(func: uid($termUid)) {
        total: count(audio)
      }
    }""";
  var results = await query(q);
  return TermInfo.fromJson(results);
}
