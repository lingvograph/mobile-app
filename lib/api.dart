import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:http_auth/http_auth.dart';
import 'package:memoapp/utils.dart';

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
    var msg = getErrorMessage(resp);
    print('api error: $msg');
    throw new StateError(msg);
  }
  var json = parseJSON(resp);
  return json['token'] as String;
}
dynamic handleResponse(Response resp) {
  if (resp.statusCode == 401) {
    authState.notify(false);
    throw new StateError('bad auth');
  }
  var respText = utf8.decode(resp.bodyBytes);
  var results = jsonDecode(respText);
  return results;
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
    var msg = getErrorMessage(resp);
    print('api error: $msg');
    throw new StateError(msg);
  }
  var results = parseJSON(resp);
  return results;
}
//TODO extract repeated code to function
Future<dynamic> apiPut(String methodPath, String contentType, dynamic body) async {
  var headers = {
    'Authorization': authState.authorizationHeader,
    'Content-Type': contentType,
  };
  var url = makeApiURL(methodPath);
  var resp = await put(url, headers: headers, body: jsonEncode(body));

  if (resp.statusCode == 401) {
    authState.notify(false);
    throw new StateError('bad auth');
  }
  if (!isOK(resp)) {
    var msg = getErrorMessage(resp);
    print('api error: $msg');
    throw new StateError(msg);
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
    var msg = getErrorMessage(resp);
    print('api error: $msg');
    throw new StateError(msg);
  }
  var results = parseJSON(resp);
  return results;
}

Future<UserInfo> fetchCurrentUser() async {
  var results = await getData('/api/me');
  return UserInfo.fromJson(results);
}

/// Make a GraphQL query
Future<dynamic> query(String query) async {
  return postData('/api/query', 'application/graphql', query);
}

/// Upload a file
/// @param path a file path
/// @param contentType mime type of a file
/// @param body file content, bytes or file stream
Future<MediaInfo> upload(String path, String contentType, dynamic body) async {
  var result = await postData('/api/file/$path', contentType, body);
  return MediaInfo.fromJson(result);
}
Future<dynamic> uploadAudio(String path, List<int> body) async {
  var result = await postData('/api/file/$path', "audio", body);
  return MediaInfo.fromJson(result);
}

class MediaInfo {
  String uid;
  String path;
  String url;
  String source;
  String contentType;
  UserInfo author;
  DateTime createdAt;
  int views;
  int likes;
  int dislikes;

  MediaInfo.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    path = getOrElse(json, 'path', '');
    url = json['url'];
    source = getOrElse(json, 'source', '');
    contentType = getOrElse(json, 'content_type', '');
    views = json.containsKey('views') ? json['views'] : 0;
    likes = json.containsKey('likes') ? json['likes'] : 0;
    dislikes = json.containsKey('dislikes') ? json['dislikes'] : 0;
    createdAt = json.containsKey('created_at') ? DateTime.parse(json['created_at']) : null;
    author = json.containsKey('created_by') ? UserInfo.fromJson(json['created_by'][0]) : UserInfo.fromJson({
      'name': 'system',
      'gender': 'robot',
      'country': 'Russia',
    });
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

  static wrapId(String s) {
    if (s.startsWith('0x')) {
      return '<$s>';
    }
    return s;
  }

  /// Make a N-Quad string. If subject or object is not defined returns null.
  static String format(String subject, String predicate, String object) {
    if (subject == null || subject.isEmpty) {
      return null;
    }
    if (object == null || object.isEmpty) {
      return null;
    }
    return '${wrapId(subject)} <$predicate> ${wrapId(object)} .';
  }
}

Future<dynamic> updateGraph(Iterable<dynamic> nquads) {
  var body = nquads.map((t) => t.toString()).join('\n');
  return postData('/api/nquads', 'application/n-quads', body);
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

// TODO consider to make like, dislike bidirectional edges using @reverse
Future<dynamic> rel(String userId, String objectId, String predicate) {
  var nquads = [
    NQuad.format(userId, predicate, objectId),
    NQuad.format(objectId, predicate, userId),
  ].where((t) => t != null && t.isNotEmpty).toList();
  return updateGraph(nquads);
}

// TODO delete previous dislike on like
Future<dynamic> like(String userId, String objectId) {
  return rel(userId, objectId, 'like');
}

// TODO delete previous like on dislike
Future<dynamic> dislike(String userId, String objectId) {
  return rel(userId, objectId, 'dislike');
}

List<T> mapList<T>(Map<String, dynamic> json, String key, T mapper(Map<String, dynamic> val)) {
  if (!json.containsKey(key)) {
    return new List<T>();
  }
  return (json[key] as List<dynamic>).map((t) => mapper(t)).toList();
}

class ListResult<T> {
  List<T> items;
  int total;

  ListResult(this.items, this.total) {
    if (this.total == 0) {
      this.total = items.length;
    }
  }
}

Map<String, String> multilangText(Map<String, dynamic> json, String key) {
  var result = new Map<String, String>();
  // TODO just process @lang
  ['ru', 'en'].forEach((lang) {
    if (json.containsKey('$key@$lang')) {
      result[lang] = json['$key@$lang'] as String;
    }
  });
  return result;
}

class TermInfo {
  String uid;
  String lang;
  String text;
  // transcriptions in different languages
  Map<String, String> transcript;
  List<TermInfo> translations;
  ListResult<MediaInfo> audio;
  ListResult<MediaInfo> visual;
  List<Tag> tags;

  TermInfo.fromJson(Map<String, dynamic> json, {int audioTotal = 0, int visualTotal = 0}) {
    print(json.toString());
    uid = json['uid'];
    lang = json['lang'];
    text = json['text'];

    transcript = multilangText(json, 'transcript');
    tags = mapList(json, 'tag', (t) => Tag.fromJson(t));
    translations = mapList(json, 'translated_as', (t) => TermInfo.fromJson(t));

    var audioItems = mapList(json, 'audio', (t) => MediaInfo.fromJson(t));
    audio = new ListResult<MediaInfo>(audioItems, audioTotal);

    var visualItems = mapList(json, 'visual', (t) => MediaInfo.fromJson(t));
    visual = new ListResult<MediaInfo>(visualItems, visualTotal);
  }
}

class Tag {
  String uid;
  // text in different languages
  Map<String, String> text;

  Tag.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    text = multilangText(json, 'text');
  }
}

class UserInfo {
  String uid;
  String name;
  String firstLang;
  String gender;
  String country;

  UserInfo.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    name = json['name'];
    firstLang = getOrElse(json, 'first_lang', 'ru');
    gender = getOrElse(json, 'gender', '');
    country = getOrElse(json, 'country', '');
  }

  Map<String, dynamic> toJson() => {
    'uid': name,
    'name': name,
    'first_lang': firstLang,
    'gender': gender,
    'country': country,
  };
}

// TODO order by popularity
Future<TermInfo> fetchAudioList(
    String termUid, int offset, limit) async {
  var q = """{
      terms(func: uid($termUid)) {
        uid
        lang
        text
        transcript@ru
        transcript@en
        tag {
          uid
          text@en
          text@ru
        }
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
          content_type
          created_at
          created_by {
            uid
            name
            gender
            country
          }
          views: count(see)
          likes: count(like)
          dislikes: count(dislike)
        }
        visual (first: 10) {
          url
          source
          content_type
          created_at
          created_by {
            uid
            name
          }
          views: count(see)
          likes: count(like)
          dislikes: count(dislike)
        }
      }
      count(func: uid($termUid)) {
        total: count(audio)
      }
    }""";
  var results = await query(q);
  var total = results['count'][0]['total'];
  var term = results['terms'][0] as Map<String, dynamic>;
  return TermInfo.fromJson(term, audioTotal: total);
}
