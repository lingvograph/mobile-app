import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:memoapp/api/api_utils.dart';
import 'package:memoapp/components/TermView.dart';
import 'package:memoapp/utils.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:http_auth/http_auth.dart';
import 'package:memoapp/api/termquery.dart';
import 'package:memoapp/api/api_utils.dart';
import 'package:memoapp/api/model.dart';
import 'package:uuid/uuid.dart';

import 'api.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class ListResult<T> {
  List<T> items;
  int total;

  ListResult(this.items, this.total) {
    if (this.total == 0) {
      this.total = items.length;
    }
  }
}

class Pagination {
  int offset;
  int limit;

  Pagination(this.offset, this.limit);

  @override
  String toString() {
    return 'offset: $offset, first: $limit';
  }
}

class UserInfo {
  String uid;
  String name;
  String firstLang;
  String targetLang;
  String gender;
  String country;
  String avatar;
  String firstName, lastName;
  String email;
  UserInfo.fromJson(Map<String, dynamic> json) {
    print(json.toString());
    uid = json['uid'];
    name = json['name'];
    firstLang = getOrElse(json, 'first_lang', 'ru');
    targetLang = getOrElse(json, 'target_lang', 'en');
    gender = getOrElse(json, 'gender', '');
    country = getOrElse(json, 'country', '');
    avatar = getOrElse(json, 'avatar', '');
    firstName = getOrElse(json, 'first_name', '');
    lastName = getOrElse(json, 'last_name', '');
    email = getOrElse(json, 'email', '');
    //getLang();
  }

  Map<String, dynamic> toJson() => {
        'first_Lang':firstLang,
        'uid': name,
        'name': name,
        'first_lang': firstLang,
        'gender': gender,
        'country': country,
        'avatar' : avatar
      };

  void getLang() async
  {
    var result = await getData("/api/data/user/"+this.uid);
    print(result);
  }
}

class MediaInfo {
  String uid;
  String path;
  String url;
  String source;
  String contentType;
  UserInfo author;
  DateTime createdAt;
  int views = 0;
  int likes = 0;
  int dislikes = 0;

  MediaInfo(
      {this.uid,
      this.path,
      this.url,
      this.source,
      this.contentType,
      this.author,
      this.createdAt,
      this.views = 0,
      this.likes = 0,
      this.dislikes = 0});

  static MediaInfo empty = new MediaInfo();

  MediaInfo.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    path = getOrElse(json, 'path', '');
    url = json['url'];
    source = getOrElse(json, 'source', '');
    contentType = getOrElse(json, 'content_type', '');
    views = json.containsKey('views') ? json['views'] : 0;
    likes = json.containsKey('likes') ? json['likes'] : 0;
    dislikes = json.containsKey('dislikes') ? json['dislikes'] : 0;
    createdAt = json.containsKey('created_at')
        ? parseTime(json['created_at'])
        : null;
    author = json.containsKey('created_by')
        ? UserInfo.fromJson(json['created_by'][0])
        : UserInfo.fromJson({
            'name': 'system',
            'gender': 'robot',
            'country': 'Russia',
          });
  }
}

class TermInfo {
  String uid;
  String lang;
  String text;

  // transcriptions in different languages
  List<TermInfo> transcript;
  List<TermInfo> translations;
  ListResult<MediaInfo> audio;
  ListResult<MediaInfo> visual;
  List<TermInfo> tags;
  List<TermInfo> isInOtherTerms;
  List<TermInfo> relatedTo;
  List<TermInfo> definition;
  List<TermInfo> definitionOf;
  List<TermInfo> synonyms;
  List<TermInfo> antonyms;



  TermInfo.fromJson(Map<String, dynamic> json,
      {int audioTotal = 0, int visualTotal = 0}) {
    //print(json.toString());
    //print(json.keys.toList().toString());
    uid = json['uid'];
    lang = json['lang'];
    text = json['text'];

    transcript =mapList(json, 'transcription', (t) => TermInfo.fromJson(t));
    tags = mapList(json, 'tag', (t) => TermInfo.fromJson(t));
    translations = mapList(json, 'translated_as', (t) => TermInfo.fromJson(t));

    isInOtherTerms = mapList(json, 'in', (t) => TermInfo.fromJson(t));
    relatedTo = mapList(json, 'related', (t) => TermInfo.fromJson(t));
    definition = mapList(json, 'definition', (t) => TermInfo.fromJson(t));
    definitionOf = mapList(json, 'definition_of', (t) => TermInfo.fromJson(t));
    synonyms = mapList(json, 'synonyms', (t) => TermInfo.fromJson(t));
    antonyms = mapList(json, 'antonym', (t) => TermInfo.fromJson(t));



    var audioItems = mapList(json, 'audio', (t) => MediaInfo.fromJson(t));
    audio = new ListResult<MediaInfo>(audioItems, audioTotal);

    var visualItems = mapList(json, 'visual', (t) => MediaInfo.fromJson(t));
    visual = new ListResult<MediaInfo>(visualItems, visualTotal);
    // TODO review block below
    //if(tags.length>0)
    //  print(tags[0].text.toString()+" "+text);

    //Если нет картинки то засунуть рандомную картинку с ресурса в сети, по этому адресу вернётся случайная картинка
    if (visual.total == 0) {

        List<MediaInfo> m = new List();
        m.add(new MediaInfo(uid: new Uuid().v4(),
            url:
                TermView.randomImageUrl));
        visual = new ListResult<MediaInfo>(m, 1);

    }

  }

  /* not connected Failed host lookup: (путь до картинки). Что-то я делаю не так, google.com лукапается нормально
  * Вообще у CachedNetworkImageProvider есть функция на ошибку, и я её даже написал, но она не работает. С сетью вообще всё сложно и половина всего не работает..*/
  checkIfImageAvailible(String url) async
  {
    try {

      final result = await InternetAddress.lookup(url);
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print(url.toString()+' connected');
      }
    } on SocketException catch (e) {
      print(url.toString()+' - not connected '+e.message.toString());
    }
  }

  bool equals(TermInfo l) {
    return l.uid == this.uid;
  }
  static bool contains(List<TermInfo> l, TermInfo t)
  {
    for(int i=0;i<l.length;i++)
    {
      if(t.equals(l[i]))
        return true;
    }
    return false;
  }
  static remove(List<TermInfo> l, TermInfo t)
  {
    for(int i=0;i<l.length;i++)
    {
      if(t.equals(l[i]))
        l.removeAt(i);
    }
  }
}
bool isIdiom(List<TermInfo> tags)
{
  for(int i=0;i<tags.length;i++)
    {
      if(tags[i].text == "idiom" || tags[i].text == "phrase")
        {
          return true;
        }

    }
  return false;
}
List<T> mapList<T>(
    Map<String, dynamic> json, String key, T mapper(Map<String, dynamic> val)) {
  if (!json.containsKey(key)) {
    return new List<T>();
  }
  return (json[key] as List<dynamic>).map((t) => mapper(t)).toList();
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
