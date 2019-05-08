import 'package:memoapp/api/api_utils.dart';
import 'package:memoapp/utils.dart';

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
  Map<String, String> transcript;
  List<TermInfo> translations;
  ListResult<MediaInfo> audio;
  ListResult<MediaInfo> visual;
  List<TermInfo> tags;

  TermInfo.fromJson(Map<String, dynamic> json,
      {int audioTotal = 0, int visualTotal = 0}) {
    //print(json.toString());
    uid = json['uid'];
    lang = json['lang'];
    text = json['text'];

    transcript = multilangText(json, 'transcript');
    tags = mapList(json, 'tag', (t) => TermInfo.fromJson(t));
    translations = mapList(json, 'translated_as', (t) => TermInfo.fromJson(t));

    var audioItems = mapList(json, 'audio', (t) => MediaInfo.fromJson(t));
    audio = new ListResult<MediaInfo>(audioItems, audioTotal);

    var visualItems = mapList(json, 'visual', (t) => MediaInfo.fromJson(t));
    visual = new ListResult<MediaInfo>(visualItems, visualTotal);
    // TODO review block below
    if(tags.length>0)
      print(tags[0].text.toString()+" "+text);
    if (visual.total == 0) {
      if (tags.length>0 && isIdiom(tags)) {
        List<MediaInfo> m = new List();
        m.add(new MediaInfo(
            url:
                "https://images.pexels.com/photos/207301/pexels-photo-207301.jpeg?cs=srgb&dl=hd-wallpaper-ivy-wall-207301.jpg&fm=jpg"));
        visual = new ListResult<MediaInfo>(m, 1);
      } else {
        List<MediaInfo> m = new List();
        m.add(new MediaInfo(
            url:
                "https://ak2.picdn.net/shutterstock/videos/3740342/thumb/12.jpg"));
        visual = new ListResult<MediaInfo>(m, 1);
      }
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
