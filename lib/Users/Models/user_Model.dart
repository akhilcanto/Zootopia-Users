class UserModel {
  String uid;
  String name;
  String email;
  String phone;
  String imageUrl;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.imageUrl,
  });

  // Convert UserModel to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNo':phone,
      'imageUrl':imageUrl,
      // 'phone':phone,
    };
  }

  // Convert Firestore document to UserModelz
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ,
      name: map['name'],
      email: map['email'],
      phone: map['phoneNo'],
      imageUrl: map['imageUrl'],
    );
  }

/* String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get password => _password;

  set password(String value) {
    _password = value;
  }*/
}
