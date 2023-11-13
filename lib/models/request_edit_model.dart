import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class RequestEditModel {
  String? requireId, cvId, cvName, term, yearStart, yearEnd;
  Timestamp? createdAt, delayAt, repliedAt;

  RequestEditModel({
    this.requireId,
    this.term,
    this.cvId,
    this.cvName,
    this.yearStart,
    this.yearEnd,
    this.createdAt,
    this.delayAt,
    this.repliedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'requireId': requireId,
      'term': term,
      'cvId': cvId,
      'yearStart': yearStart,
      'yearEnd': yearEnd,
      'createdAt': createdAt,
      'delayAt': delayAt,
      'cvName': cvName,
      'repliedAt': repliedAt,
    };
  }

  factory RequestEditModel.fromMap(Map<String, dynamic> map) {
    return RequestEditModel(
      requireId: map['requireId'] ?? '',
      term: map['term'] ?? '',
      cvId: map['cvId'] ?? '',
      yearStart: map['yearStart'] ?? '',
      yearEnd: map['yearEnd'] ?? '',
      createdAt: map['createdAt'],
      delayAt: map['delayAt'],
      cvName: map['cvName'] ?? '',
      repliedAt: map['repliedAt'],
    );
  }

  String toJson() => json.encode(toMap());

  factory RequestEditModel.fromJson(String source) =>
      RequestEditModel.fromMap(json.decode(source));
}
