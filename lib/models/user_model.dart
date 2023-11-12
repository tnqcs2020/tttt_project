import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? uid,
      userId,
      userName,
      email,
      phone,
      password,
      gender,
      birthday,
      classId,
      className,
      course,
      major,
      address,
      group,
      cvId,
      cvName,
      cvChucVu,
      majorId,
      khoa;
  List<ClassModel>? cvClass;

  UserModel({
    this.uid,
    this.userId,
    this.userName,
    this.classId,
    this.className,
    this.course,
    this.major,
    this.email,
    this.password,
    this.group,
    this.phone,
    this.birthday,
    this.gender,
    this.address,
    this.cvId,
    this.cvName,
    this.cvChucVu,
    this.cvClass,
    this.majorId,
    this.khoa,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'userId': userId,
      'userName': userName,
      'email': email,
      'password': password,
      'phone': phone,
      'gender': gender,
      'birthday': birthday,
      'classId': classId,
      'className': className,
      'course': course,
      'major': major,
      'address': address,
      'group': group,
      'cvId': cvId,
      'cvName': cvName,
      'cvChucVu': cvChucVu,
      'cvClass': cvClass!.map((e) => e.toMap()).toList(),
      'majorId': majorId,
      'khoa': khoa,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      phone: map['phone'] ?? '',
      birthday: map['birthday'] ?? '',
      gender: map['gender'] ?? '',
      classId: map['classId'] ?? '',
      className: map['className'] ?? '',
      course: map['course'] ?? '',
      major: map['major'] ?? '',
      address: map['address'] ?? '',
      group: map['group'] ?? '',
      cvId: map['cvId'] ?? '',
      cvName: map['cvName'] ?? '',
      cvChucVu: map['cvChucVu'] ?? '',
      cvClass:
          map['cvClass'].map<ClassModel>((i) => ClassModel.fromMap(i)).toList(),
      majorId: map['majorId'] ?? '',
      khoa: map['khoa'],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));
}

class ClassModel {
  String? className, quantity, classId, course, cvId, major;
  Timestamp? yearStart, yearEnd;

  ClassModel({
    this.className,
    this.classId,
    this.quantity,
    this.course,
    this.cvId,
    this.major,
    this.yearStart,
    this.yearEnd,
  });

  static ClassModel empty = ClassModel(classId: '');
  static ClassModel tatca = ClassModel(classId: 'Tất cả');

  Map<String, dynamic> toMap() {
    return {
      'className': className,
      'classId': classId,
      'quantity': quantity,
      'course': course,
      'cvId': cvId,
      'yearStart': yearStart,
      'yearEnd': yearEnd,
      'major': major,
    };
  }

  factory ClassModel.fromMap(Map<String, dynamic> map) {
    return ClassModel(
      className: map['className'] ?? '',
      classId: map['classId'] ?? '',
      quantity: map['quantity'] ?? '',
      course: map['course'] ?? '',
      cvId: map['cvId'] ?? '',
      major: map['major'] ?? '',
      yearStart: map['yearStart'],
      yearEnd: map['yearEnd'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ClassModel.fromJson(String source) =>
      ClassModel.fromMap(json.decode(source));
}
