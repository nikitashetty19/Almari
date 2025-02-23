class UserModel {
  String username;
  String gender;

  UserModel({required this.username, required this.gender});

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'gender': gender,
    };
  }
}
