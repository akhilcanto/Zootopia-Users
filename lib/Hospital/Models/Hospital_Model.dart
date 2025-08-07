class HospitalModel {
  String uid;
  String hospitalname;
  String email;
  String imageUrl;
  String state;
  String district;
  String city;
  String description;
  String phone;

  HospitalModel({
    required this.uid,
    required this.hospitalname,
    required this.email,
    required this.imageUrl,
    required this.state,
    required this.district,
    required this.city,
    required this.description,
    required this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'hospitalname': hospitalname,
      'email': email,
      'imageUrl': imageUrl,
      'state': state,
      'district': district,
      'city': city,
      'description': description,
      'phone': phone,
    };
  }

  static HospitalModel fromMap(Map<String, dynamic> map) {
    return HospitalModel(
      uid: map['uid'],
      hospitalname: map['hospitalname'],
      email: map['email'],
      imageUrl: map['imageUrl'],
      state: map['state'],
      district: map['district'],
      city: map['city'],
      description: map['description'],
      phone: map['phone'],
    );
  }
}
