import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class PlanWorkModel {
  String? cbhdId, cbhdName, userId;
  Timestamp? createdAt, traineeStart, traineeEnd;
  List<WorkModel>? listWork;
  bool? completeTraining;

  PlanWorkModel(
      {this.cbhdId,
      this.cbhdName,
      this.createdAt,
      this.traineeStart,
      this.userId,
      this.traineeEnd,
      this.listWork,
      this.completeTraining});

  Map<String, dynamic> toMap() {
    return {
      'cbhdId': cbhdId,
      'cbhdName': cbhdName,
      'createdAt': createdAt,
      'traineeStart': traineeStart,
      'userId': userId,
      'traineeEnd': traineeEnd,
      'listWork': listWork!.map((i) => i.toMap()).toList(),
      'completeTraining': completeTraining
    };
  }

  factory PlanWorkModel.fromMap(Map<String, dynamic> map) {
    return PlanWorkModel(
      cbhdId: map['cbhdId'] ?? '',
      cbhdName: map['cbhdName'] ?? '',
      createdAt: map['createdAt'],
      traineeStart: map['traineeStart'],
      userId: map['userId'] ?? '',
      traineeEnd: map['traineeEnd'],
      listWork:
          map['listWork'].map<WorkModel>((i) => WorkModel.fromMap(i)).toList(),
      completeTraining: map['completeTraining'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory PlanWorkModel.fromJson(String source) =>
      PlanWorkModel.fromMap(json.decode(source));
}

class WorkModel {
  String? content, totalDay, comment;
  Timestamp? dayStart, dayEnd;
  bool? isCompleted;

  WorkModel({
    this.content,
    this.comment,
    this.totalDay,
    this.isCompleted = false,
    this.dayStart,
    this.dayEnd,
  });

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'comment': comment,
      'totalDay': totalDay,
      'isCompleted': isCompleted,
      'dayStart': dayStart,
      'dayEnd': dayEnd,
    };
  }

  factory WorkModel.fromMap(Map<String, dynamic> map) {
    return WorkModel(
      content: map['content'] ?? '',
      comment: map['comment'] ?? '',
      totalDay: map['totalDay'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      dayStart: map['dayStart'],
      dayEnd: map['dayEnd'],
    );
  }

  String toJson() => json.encode(toMap());

  factory WorkModel.fromJson(String source) =>
      WorkModel.fromMap(json.decode(source));
}
