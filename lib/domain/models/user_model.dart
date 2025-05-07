class UserModel {
  final String uid;
  final String name;
  final int age;
  final String email;

  UserModel({
    required this.uid,
    required this.name,
    required this.age,
    required this.email,
  });

  Map<String, dynamic> toMap() => {'name': name, 'age': age, 'email': email};

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      email: map['email'] ?? '',
    );
  }
}
