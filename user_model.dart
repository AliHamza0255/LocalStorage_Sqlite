import 'dart:typed_data';

class User {
  int? id;
  String username;
  String email;
  String password;
  String city;
  String gender;
  String address;
  Uint8List? image;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.city,
    required this.gender,
    required this.address,
    this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'city': city,
      'gender': gender,
      'address': address,
      'image': image,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      city: map['city'],
      gender: map['gender'],
      address: map['address'],
      image: map['image'] as Uint8List?,
    );
  }
}