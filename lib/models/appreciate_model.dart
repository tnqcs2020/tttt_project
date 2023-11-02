import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class AppreciateModel {
  String? cbhdId,
      cbhdName,
      userId,
      firmName,
      jobId,
      jobName,
      commentSV,
      commentCTDT,
      appreciateCTDT;
  Timestamp? createdAt, traineeStart, traineeEnd;
  List<ContentAppreciateModel>? listContent;

  AppreciateModel({
    this.cbhdId,
    this.cbhdName,
    this.createdAt,
    this.traineeStart,
    this.userId,
    this.traineeEnd,
    this.listContent,
    this.firmName,
    this.jobName,
    this.commentSV,
    this.commentCTDT,
    this.appreciateCTDT,
    this.jobId,
  });

  Map<String, dynamic> toMap() {
    return {
      'cbhdId': cbhdId,
      'cbhdName': cbhdName,
      'createdAt': createdAt,
      'traineeStart': traineeStart,
      'userId': userId,
      'traineeEnd': traineeEnd,
      'listContent': listContent!.map((i) => i.toMap()).toList(),
      'firmName': firmName,
      'jobName': jobName,
      'commentSV': commentSV,
      'commentCTDT': commentCTDT,
      'appreciateCTDT': appreciateCTDT,
      'jobId': jobId,
    };
  }

  factory AppreciateModel.fromMap(Map<String, dynamic> map) {
    return AppreciateModel(
      cbhdId: map['cbhdId'] ?? '',
      cbhdName: map['cbhdName'] ?? '',
      createdAt: map['createdAt'],
      traineeStart: map['traineeStart'],
      userId: map['userId'] ?? '',
      traineeEnd: map['traineeEnd'],
      listContent: map['listContent']
          .map<ContentAppreciateModel>((i) => ContentAppreciateModel.fromMap(i))
          .toList(),
      firmName: map['firmName'] ?? '',
      jobName: map['jobName'] ?? '',
      commentSV: map['commentSV'] ?? '',
      commentCTDT: map['commentCTDT'] ?? '',
      appreciateCTDT: map['appreciateCTDT'] ?? '',
      jobId: map['jobId'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory AppreciateModel.fromJson(String source) =>
      AppreciateModel.fromMap(json.decode(source));
}

class ContentAppreciateModel {
  String? title;
  String? content;
  double? point;

  ContentAppreciateModel({
    this.title,
    this.content,
    this.point,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'point': point,
    };
  }

  factory ContentAppreciateModel.fromMap(Map<String, dynamic> map) {
    return ContentAppreciateModel(
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      point: map['point'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ContentAppreciateModel.fromJson(String source) =>
      ContentAppreciateModel.fromMap(json.decode(source));
}
