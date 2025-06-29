// Define the AuthModel class here
class AuthModel {
  final String? id;
  final String? email;
  final String? password;

  AuthModel({this.id, this.email, this.password});

  // Add serialization and deserialization methods if needed
  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      id: json['id'],
      email: json['email'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
    };
  }
}
