import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class AppreciateCVModel {
  String? cbhdId,
      userName,
      userId,
      firmName,
      jobName,
      term,
      yearStart,
      yearEnd,
      pointChar;
  Timestamp? createdAt, traineeStart, traineeEnd;
  List<double>? listPoint;
  double? subPoint, total, finalTotal;

  AppreciateCVModel({
    this.cbhdId,
    this.userName,
    this.createdAt,
    this.traineeStart,
    this.userId,
    this.traineeEnd,
    this.listPoint,
    this.firmName,
    this.jobName,
    this.total,
    this.subPoint,
    this.finalTotal,
    this.term,
    this.yearStart,
    this.yearEnd,
    this.pointChar,
  });

  Map<String, dynamic> toMap() {
    return {
      'cbhdId': cbhdId,
      'userName': userName,
      'createdAt': createdAt,
      'traineeStart': traineeStart,
      'userId': userId,
      'traineeEnd': traineeEnd,
      'listPoint': listPoint,
      'firmName': firmName,
      'jobName': jobName,
      'total': total,
      'subPoint': subPoint,
      'finalTotal': finalTotal,
      'term': term,
      'yearStart': yearStart,
      'yearEnd': yearEnd,
      'pointChar': pointChar,
    };
  }

  factory AppreciateCVModel.fromMap(Map<String, dynamic> map) {
    return AppreciateCVModel(
      cbhdId: map['cbhdId'] ?? '',
      userName: map['userName'] ?? '',
      createdAt: map['createdAt'],
      traineeStart: map['traineeStart'],
      userId: map['userId'] ?? '',
      traineeEnd: map['traineeEnd'],
      listPoint:
          (map['listPoint'] as List).map((item) => item as double).toList(),
      firmName: map['firmName'] ?? '',
      jobName: map['jobName'] ?? '',
      total: map['total'],
      subPoint: map['subPoint'],
      finalTotal: map['finalTotal'],
      term: map['term'] ?? '',
      yearStart: map['yearStart'] ?? '',
      yearEnd: map['yearEnd'] ?? '',
      pointChar: map['pointChar'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory AppreciateCVModel.fromJson(String source) =>
      AppreciateCVModel.fromMap(json.decode(source));
}
