import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class FirmModel {
  String? firmId, firmName, email, phone, owner, describe, address;
  List<JobPositionModel>? listJob;
  List<JobRegisterModel>? listRegis;

  FirmModel({
    this.firmId,
    this.firmName,
    this.email,
    this.owner,
    this.phone,
    this.describe,
    this.address,
    this.listJob,
    this.listRegis,
  });

  Map<String, dynamic> toMap() {
    return {
      'firmId': firmId,
      'firmName': firmName,
      'email': email,
      'owner': owner,
      'phone': phone,
      'describe': describe ?? '',
      'address': address,
      'listJob': listJob!.map((i) => i.toMap()).toList(),
      'listRegis': listRegis!.map((i) => i.toMap()).toList(),
    };
  }

  factory FirmModel.fromMap(Map<String, dynamic> data) {
    return FirmModel(
      firmId: data['firmId'] ?? '',
      firmName: data['firmName'] ?? '',
      email: data['email'] ?? '',
      owner: data['owner'] ?? '',
      phone: data['phone'] ?? '',
      describe: data['describe'] ?? '',
      address: data['address'] ?? '',
      listJob: data['listJob']
          .map<JobPositionModel>((i) => JobPositionModel.fromMap(i))
          .toList(),
      listRegis: data['listRegis']
          .map<JobRegisterModel>((i) => JobRegisterModel.fromMap(i))
          .toList(),
    );
  }

  String toJson() => json.encode(toMap());

  factory FirmModel.fromJson(String source) =>
      FirmModel.fromMap(json.decode(source));
}

class JobPositionModel {
  String? jobId, describeJob, jobName, quantity;

  JobPositionModel({
    this.jobId,
    this.describeJob,
    this.jobName,
    this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'describeJob': describeJob,
      'jobName': jobName,
      'quantity': quantity,
    };
  }

  factory JobPositionModel.fromMap(Map<String, dynamic> map) {
    return JobPositionModel(
      jobId: map['jobId'] ?? '',
      describeJob: map['describeJob'] ?? '',
      jobName: map['jobName'] ?? '',
      quantity: map['quantity'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory JobPositionModel.fromJson(String source) =>
      JobPositionModel.fromMap(json.decode(source));
}

class JobRegisterModel {
  String? userId, userName, jobId, status, jobName;
  Timestamp? createdAt, repliedAt, traineeStart, traineeEnd;
  bool? isConfirmed;
  JobRegisterModel({
    this.userId,
    this.jobId,
    this.userName,
    this.status,
    this.jobName,
    this.createdAt,
    this.repliedAt,
    this.isConfirmed = false,
    this.traineeStart,
    this.traineeEnd,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'jobId': jobId,
      'userName': userName,
      'status': status,
      'jobName': jobName,
      'createdAt': createdAt,
      'repliedAt': repliedAt,
      'isConfirmed': isConfirmed,
      'traineeStart': traineeStart,
      'traineeEnd': traineeEnd,
    };
  }

  factory JobRegisterModel.fromMap(Map<String, dynamic> map) {
    return JobRegisterModel(
      userId: map['userId'] ?? '',
      jobId: map['jobId'] ?? '',
      userName: map['userName'] ?? '',
      status: map['status'] ?? '',
      jobName: map['jobName'] ?? '',
      createdAt: map['createdAt'],
      repliedAt: map['repliedAt'],
      isConfirmed: map['isConfirmed'] ?? false,
      traineeStart: map['traineeStart'],
      traineeEnd: map['traineeEnd'],
    );
  }

  String toJson() => json.encode(toMap());

  factory JobRegisterModel.fromJson(String source) =>
      JobRegisterModel.fromMap(json.decode(source));
}

class FirmSuggestModel {
  String? firmId, firmName;
  double? similarityScore;

  FirmSuggestModel({
    this.firmId,
    this.firmName,
    this.similarityScore,
  });

  Map<String, dynamic> toMap() {
    return {
      'firmId': firmId,
      'firmName': firmName,
      'email': similarityScore,
    };
  }

  factory FirmSuggestModel.fromMap(Map<String, dynamic> data) {
    return FirmSuggestModel(
      firmId: data['firmId'] ?? '',
      firmName: data['firmName'] ?? '',
      similarityScore: data['similarityScore'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory FirmSuggestModel.fromJson(String source) =>
      FirmSuggestModel.fromMap(json.decode(source));
}
