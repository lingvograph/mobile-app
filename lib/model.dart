Map<String, T> mapObjects<T>(Map<String, dynamic> json, T f(Map<String, dynamic> val)) {
  if (json == null) {
    return new Map();
  }
  return json.map((k, v) => MapEntry(k, f(v)));
}

class User {
  String name;

  User(this.name);

  User.fromJson(Map json) : name = json['name'];

  Map<String, dynamic> toJson() => {
        'name': name,
      };
}

class Word {
  Map<String, String> text; // text representation in different languages
  Map<String, String> transcription; // transcription in different languages
  Resource image;
  Map<String, Resource> pronunciation; // top pronunciations in different languages

  Word.fromJson(Map<String, dynamic> json)
      : text = json['text'],
        transcription = json['transcription'],
        image = Resource.fromJson(json['image']),
        pronunciation = mapObjects(json['pronunciation'], (t) => Resource.fromJson(t));
}

class Resource {
  String contentType;
  String url;

  Resource.fromJson(dynamic json) {
    if (json is String) {
      url = json;
      // TODO by extension
      contentType = 'image/jpg';
    } else {
      contentType = json['content_type'];
      url = json['url'];
    }
  }
}
