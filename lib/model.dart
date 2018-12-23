Map<String, T> map<T>(Map<String, dynamic> json, T f(dynamic val)) {
  if (json == null) {
    return new Map();
  }
  return json.map((k, v) => MapEntry(k, f(v)));
}

Map<String, dynamic> nest(Map<String, dynamic> json) {
  var result = new Map<String, dynamic>();
  json.forEach((k, v) {
    var i = k.indexOf('@');
    if (i >= 0) {
      var p = k.substring(0, i);
      if (!result.containsKey(p)) {
        result[p] = new Map<String, dynamic>();
      }
      var lang = k.substring(i + 1);
      result[p][lang] = v;
    } else {
      result[k] = v;
    }
  });
  return result;
}

class User {
  String name;
  String firstLang = 'ru';

  User(this.name, this.firstLang);

  User.fromJson(Map json) : name = json['name'];

  Map<String, dynamic> toJson() => {
        'name': name,
      };
}

class Word {
  // text representation in different languages
  Map<String, String> text;

  // transcriptions in different languages
  Map<String, String> transcription;

  // transcription in different languages
  Resource image;

  // top pronunciations in different languages
  Map<String, Resource> pronunciation;

  Word.fromJson(Map<String, dynamic> json) {
    var d = nest(json);
    text = map(d['text'], (t) => t as String);
    transcription = map(d['transcription'], (t) => t as String);
    image = Resource.fromAny(d['image']);
    pronunciation = map(d['pronunciation'], (t) => Resource.fromAny(t));
  }
}

class Resource {
  String contentType;
  String url;

  Resource(this.url, [String contentType]) {
    // TODO by extension
    this.contentType = contentType == null ? 'image/jpg' : contentType;
  }

  Resource.fromJson(Map<String, dynamic> json) {
    contentType = json['content_type'];
    url = json['url'];
  }

  static Resource fromAny(dynamic val) {
    if (val is String) {
      return Resource(val);
    }
    return Resource.fromJson(val);
  }
}
