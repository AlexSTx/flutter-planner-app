import 'dart:convert';

class User {
  int? id;
  String name;
  String email;
  String password;

  User({this.id, required this.name, required this.email, required this.password});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{"name": name, "email": email, "password": password};
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(id: map["id"], name: map["name"], email: map["email"], password: map["password"]);
  }

  String toJson() => jsonEncode(toMap());

  factory User.fromJson(String source) => User.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
