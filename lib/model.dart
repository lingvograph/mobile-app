class User {
  String name;

  User(this.name);

  User.fromJson(Map json) : name = json["name"];

  Map<String, dynamic> toJson() => {
        'name': name,
      };
}
