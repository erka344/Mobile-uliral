


// @JsonSerializable(createToJson: false)
class UserModel {
  final int? id;
  final String? username;
  final String? password;
  final String? token;

  UserModel({ this.id, this.username, this.password, this.token});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'] as String?,
      password: json['password'] as String?,
      token: json['token'] as String?,
    );
  }

  static List<UserModel> fromList(List<dynamic> userList) {
    return userList.map((e) => UserModel.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'password': password,
    'token': token,
  };
}


