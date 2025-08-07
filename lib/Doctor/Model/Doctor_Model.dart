class DoctorModel {
  String uid;
  String doctorname;
  String email;
  String imageUrl;
  String specialization;

  DoctorModel({
    required this.uid,
    required this.doctorname,
    required this.email,
    required this.imageUrl,
    required this.specialization,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'doctorname': doctorname,
      'email': email,
      'imageUrl': imageUrl,
      'specialization': specialization,
    };
  }

  static DoctorModel fromMap(Map<String, dynamic> map) {
    return DoctorModel(
      uid: map['uid'],
      doctorname: map['doctorname'],
      email: map['email'],
      imageUrl: map['imageUrl'],
      specialization: map['specialization'],
    );
  }
}
