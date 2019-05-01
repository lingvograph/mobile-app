import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:http_auth/http_auth.dart';
import 'package:memoapp/api/termquery.dart';
import 'package:memoapp/api/api_utils.dart';
import 'package:memoapp/api/model.dart';

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

enum HttpVerb { post, put }

/// a generic POST API call
/// @param path relative path to API method
/// @param body content to be posted
/// @param contentType mime type of a body
/// @param verb HTTP verb
Future<dynamic> postData(String methodPath, dynamic body,
    {String contentType = 'application/json',
    HttpVerb verb = HttpVerb.post}) async {
  var headers = {
    'Authorization': authState.authorizationHeader,
    'Content-Type': contentType,
  };

  if (body is Map) {
    body = jsonEncode(body);
  }

  var url = makeApiURL(methodPath);
  Response resp;
  switch (verb) {
    case HttpVerb.post:
      resp = await post(url, headers: headers, body: body);
      break;
    case HttpVerb.put:
      resp = await put(url, headers: headers, body: body);
      break;
  }
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
  return postData('/api/query', query, contentType: 'application/graphql');
}

/// Upload a file
/// @param path a file path
/// @param contentType mime type of a file
/// @param body file content, bytes or file stream
Future<MediaInfo> upload(String path, String contentType, dynamic body) async {
  var result =
      await postData('/api/file/$path', body, contentType: contentType);
  return MediaInfo.fromJson(result);
}

Future<dynamic> updateGraph(Iterable<dynamic> nquads) {
  var body = nquads.map((t) => t.toString()).join('\n');
  return postData('/api/nquads', body, contentType: 'application/n-quads');
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

Future<dynamic> rel(String userId, String objectId, String predicate) {
  var nquads = [
    NQuad.format(userId, predicate, objectId),
    NQuad.format(objectId, predicate, userId),
  ].where((t) => t != null && t.isNotEmpty).toList();
  return updateGraph(nquads);
}

Future<dynamic> view(String userId, String objectId) {
  return rel(userId, objectId, 'see');
}

Future<dynamic> likebase(
    String userId, String objectId, String predicate, String reverse) {
  final Map<String, String> body = {
    'set': [
      NQuad.format(userId, predicate, objectId),
      NQuad.format(objectId, predicate, userId),
    ].join('\n'),
    'delete': [
      NQuad.format(userId, reverse, objectId),
      NQuad.format(objectId, reverse, userId),
    ].join('\n'),
  };
  return postData('/api/nquads', body);
}

Future<dynamic> like(String userId, String objectId) {
  return likebase(userId, objectId, 'like', 'dislike');
}

Future<dynamic> dislike(String userId, String objectId) {
  return likebase(userId, objectId, 'dislike', 'like');
}

Future<ListResult<TermInfo>> fetchTerms(String firstLang, int offset, int limit,
    {TermFilter filter = null}) async {
  final range = new Pagination(offset, limit);
  final q = new TermQuery(
      kind: TermQueryKind.termList,
      firstLang: firstLang,
      range: range,
      filter: filter);
  var qs = q.makeQuery();
  var results = await query(qs);
  var total = results['count'][0]['total'];
  var terms = results['terms'] as List<dynamic>;
  var items = terms.map((t) => TermInfo.fromJson(t)).toList();
  return new ListResult<TermInfo>(items, total);
}

Future<TermInfo> fetchAudioList(String termUid, int offset, int limit) async {
  final range = new Pagination(offset, limit);
  final q = new TermQuery(
      kind: TermQueryKind.audioList, termUid: termUid, range: range);
  final qs = q.makeQuery();
  final results = await query(qs);
  final total = results['count'][0]['total'];
  final term = results['terms'][0] as Map<String, dynamic>;
  return TermInfo.fromJson(term, audioTotal: total);
}
