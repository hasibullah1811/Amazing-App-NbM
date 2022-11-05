// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  User({
    required this.user,
  });

  UserClass user;

  factory User.fromJson(Map<String, dynamic> json) => User(
        user: UserClass.fromJson(json["user"]),
      );

  Map<String, dynamic> toJson() => {
        "user": user.toJson(),
      };
}

class UserClass {
  UserClass({
    required this.uid,
    required this.email,
    required this.emailVerified,
    required this.displayName,
    required this.isAnonymous,
  });

  String uid;
  String email;
  bool emailVerified;
  String displayName;
  bool isAnonymous;

  factory UserClass.fromJson(Map<String, dynamic> json) => UserClass(
        uid: json["uid"],
        email: json["email"],
        emailVerified: json["emailVerified"],
        displayName: json["displayName"],
        isAnonymous: json["isAnonymous"],
      );

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "email": email,
        "emailVerified": emailVerified,
        "displayName": displayName,
        "isAnonymous": isAnonymous,
      };
}
