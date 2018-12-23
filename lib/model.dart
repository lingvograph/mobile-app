Map<String, T> map<T>(Map<String, dynamic> json, T f(dynamic val)) {
  if (json == null) {
    return new Map();
  }
  return json.map((k, v) => MapEntry(k, f(v)));
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
    text = json['text'];
    transcription = json['transcription'];
    image = Resource.fromAny(json['image']);
    pronunciation = map(json['pronunciation'], (t) => Resource.fromAny(t));
  }
}

class Resource {
  String contentType;
  String url;

  Resource(this.url, [String contentType = null]) {
    // TODO by extension
    this.contentType = contentType == null ? 'image/jpg' : contentType;
  }

  Resource.fromJson(Map<String, dynamic> json) {
    contentType = json['content_type'];
    url = json['url'];
  }

  static Resource fromAny(dynamic val) {
    if (val is String) {
      return Resource(val as String);
    }
    return Resource.fromJson(val);
  }
}
