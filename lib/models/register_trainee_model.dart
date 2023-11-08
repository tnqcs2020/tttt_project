import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterTraineeModel {
  String? creditId,
      term,
      creditName,
      yearStart,
      yearEnd,
      userId,
      course,
      studentName;
  int? reachedStep;
  List<UserRegisterModel>? listRegis;
  Timestamp? traineeStart, traineeEnd;

  RegisterTraineeModel({
    this.creditId,
    this.term,
    this.creditName,
    this.yearStart,
    this.userId,
    this.yearEnd,
    this.course,
    this.studentName,
    this.reachedStep = 0,
    this.listRegis,
    this.traineeStart,
    this.traineeEnd,
  });

  Map<String, dynamic> toMap() {
    return {
      'creditId': creditId,
      'term': term,
      'creditName': creditName,
      'yearStart': yearStart,
      'userId': userId,
      'yearEnd': yearEnd,
      'course': course,
      'studentName': studentName,
      'reachedStep': reachedStep,
      'listRegis':
          listRegis != null ? listRegis!.map((i) => i.toMap()).toList() : [],
      'traineeStart': traineeStart,
      'traineeEnd': traineeEnd,
    };
  }

  factory RegisterTraineeModel.fromMap(Map<String, dynamic> map) {
    return RegisterTraineeModel(
      creditId: map['creditId'] ?? '',
      term: map['term'] ?? '',
      creditName: map['creditName'] ?? '',
      yearStart: map['yearStart'] ?? '',
      userId: map['userId'] ?? '',
      yearEnd: map['yearEnd'] ?? '',
      course: map['course'] ?? '',
      studentName: map['studentName'] ?? '',
      reachedStep: map['reachedStep'] ?? 0,
      listRegis: map['listRegis']
          .map<UserRegisterModel>((i) => UserRegisterModel.fromMap(i))
          .toList(),
      traineeStart: map['traineeStart'],
      traineeEnd: map['traineeEnd'],
    );
  }

  String toJson() => json.encode(toMap());

  factory RegisterTraineeModel.fromJson(String source) =>
      RegisterTraineeModel.fromMap(json.decode(source));
}

class UserRegisterModel {
  String? firmId, firmName, jobName, jobId, status;
  Timestamp? createdAt, repliedAt, traineeStart, traineeEnd;
  bool? isConfirmed;

  UserRegisterModel({
    this.firmId,
    this.firmName,
    this.jobId,
    this.jobName,
    this.status,
    this.createdAt,
    this.repliedAt,
    this.isConfirmed = false,
    this.traineeStart,
    this.traineeEnd,
  });

  Map<String, dynamic> toMap() {
    return {
      'firmId': firmId,
      'firmName': firmName,
      'jobId': jobId,
      'jobName': jobName,
      'status': status,
      'createdAt': createdAt,
      'repliedAt': repliedAt,
      'isConfirmed': isConfirmed,
      'traineeStart': traineeStart,
      'traineeEnd': traineeEnd,
    };
  }

  factory UserRegisterModel.fromMap(Map<String, dynamic> map) {
    return UserRegisterModel(
      firmId: map['firmId'] ?? '',
      firmName: map['firmName'] ?? '',
      jobId: map['jobId'] ?? '',
      jobName: map['jobName'] ?? '',
      status: map['status'] ?? '',
      createdAt: map['createdAt'],
      repliedAt: map['repliedAt'],
      isConfirmed: map['isConfirmed'] ?? false,
      traineeStart: map['traineeStart'],
      traineeEnd: map['traineeEnd'],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserRegisterModel.fromJson(String source) =>
      UserRegisterModel.fromMap(json.decode(source));
}
