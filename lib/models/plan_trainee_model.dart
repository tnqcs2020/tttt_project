import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class PlanTraineeModel {
  String? title, term, yearStart, planTraineeId, yearEnd, notice;
  Timestamp? createdAt;
  List<ContentModel>? listContent;

  PlanTraineeModel({
    this.title,
    this.term,
    this.yearStart,
    this.createdAt,
    this.yearEnd,
    this.planTraineeId,
    this.notice,
    this.listContent,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'term': term,
      'yearStart': yearStart,
      'createdAt': createdAt,
      'yearEnd': yearEnd,
      'planTraineeId': planTraineeId,
      'notice': notice,
      'listContent': listContent != null
          ? listContent!.map((i) => i.toMap()).toList()
          : [],
    };
  }

  factory PlanTraineeModel.fromMap(Map<String, dynamic> map) {
    return PlanTraineeModel(
      title: map['title'] ?? '',
      term: map['term'] ?? '',
      yearStart: map['yearStart'] ?? '',
      createdAt: map['createdAt'],
      yearEnd: map['yearEnd'] ?? '',
      planTraineeId: map['planTraineeId'] ?? '',
      notice: map['notice'],
      listContent: map['listContent']
          .map<ContentModel>((i) => ContentModel.fromMap(i))
          .toList(),
    );
  }

  String toJson() => json.encode(toMap());

  factory PlanTraineeModel.fromJson(String source) =>
      PlanTraineeModel.fromMap(json.decode(source));
}

class ContentModel {
  String? content, note;
  Timestamp? dayStart, dayEnd;

  ContentModel({
    this.content,
    this.note,
    this.dayStart,
    this.dayEnd,
  });

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'note': note,
      'dayStart': dayStart,
      'dayEnd': dayEnd,
    };
  }

  factory ContentModel.fromMap(Map<String, dynamic> map) {
    return ContentModel(
      content: map['content'] ?? '',
      note: map['note'] ?? '',
      dayStart: map['dayStart'],
      dayEnd: map['dayEnd'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ContentModel.fromJson(String source) =>
      ContentModel.fromMap(json.decode(source));
}
