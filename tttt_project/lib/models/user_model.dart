import 'dart:convert';

class UserModel {
  String? uid,
      userId,
      name,
      email,
      phone,
      password,
      gender,
      birthday,
      avatar,
      classId,
      className,
      course,
      major,
      address,
      group;
  bool? isRegistered;

  UserModel({
    required this.uid,
    required this.userId,
    required this.name,
    required this.classId,
    required this.className,
    required this.course,
    required this.major,
    required this.email,
    required this.password,
    required this.group,
    this.phone,
    this.birthday,
    this.gender,
    this.avatar,
    this.address,
    this.isRegistered = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'userId': userId,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'gender': gender,
      'birthday': birthday,
      'avatar': avatar,
      'classId': classId,
      'className': className,
      'course': course,
      'major': major,
      'address': address,
      'isRegistered': isRegistered,
      'group': group,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
        uid: map['uid'] ?? '',
        userId: map['userId'] ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        password: map['password'] ?? '',
        phone: map['phone'] ?? '',
        birthday: map['birthday'] ?? '',
        gender: map['gender'] ?? '',
        avatar: map['avatar'] ?? '',
        classId: map['classId'] ?? '',
        className: map['className'] ?? '',
        course: map['course'] ?? '',
        major: map['major'] ?? '',
        address: map['address'] ?? '',
        group: map['group'] ?? '',
        isRegistered: map['isRegistered'] ?? false);
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  UserModel copyWith({
    String? uid,
    String? userId,
    String? name,
    String? email,
    String? password,
    String? phone,
    String? birthday,
    String? gender,
    String? avatar,
    String? classId,
    String? className,
    String? course,
    String? major,
    String? address,
    String? group,
    bool? isRegistered,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      birthday: birthday ?? this.birthday,
      gender: gender ?? this.gender,
      avatar: avatar ?? this.avatar,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      course: course ?? this.course,
      major: major ?? this.major,
      address: address ?? this.address,
      group: group ?? this.group,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }
}
