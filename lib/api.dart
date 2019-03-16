import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:http_auth/http_auth.dart';
import 'package:memoapp/model.dart';

// TODO move to config
const baseURL = 'http://lingvograph.com:4200';

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

String makeApiURL(String path) {
  return baseURL + path;
}

Future<String> login(String username, String password) async {
  var http = BasicAuthClient(username, password);
  var res = await http.post(makeApiURL('/api/login'));
  var json = jsonDecode(res.body);
  return json['token'] as String;
}

/// a generic POST API call
/// @param path relative path to API method
/// @param contentType mime type of a body
/// @param body content to be posted
Future<dynamic> postData(String methodPath, String contentType, dynamic body) async {
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
  var respText = utf8.decode(resp.bodyBytes);
  var results = jsonDecode(respText);
  return results;
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
Future<ListResult<AudioInfo>> fetchAudioList(String termUid, int offset, limit) async {
  var q = """{
      term(func: uid($termUid)) {
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
  var total = results['count'][0]['total'];
  var objects = results['term'][0]['audio'] as List<dynamic>;
  var items = objects.map((t) => AudioInfo.fromJson(t)).toList();
  return new ListResult<AudioInfo>(items, total);
}
