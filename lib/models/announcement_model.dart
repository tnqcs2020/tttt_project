import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tttt_project/models/submit_bodel.dart';

class AnnouncementModel {
  String? announcementId, title, content, type;
  List<FileModel>? files;
  Timestamp? createdAt;

  AnnouncementModel({
    this.announcementId,
    this.title,
    this.type,
    this.content,
    this.files,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'announcementId': announcementId,
      'title': title,
      'type': type,
      'content': content,
      'files': files!.map((i) => i.toMap()).toList(),
      'createdAt': createdAt,
    };
  }

  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    return AnnouncementModel(
      announcementId: map['announcementId'] ?? '',
      title: map['title'] ?? '',
      type: map['type'] ?? '',
      content: map['content'] ?? '',
      files: map['files'].map<FileModel>((i) => FileModel.fromMap(i)).toList(),
      createdAt: map['createdAt'],
    );
  }

  String toJson() => json.encode(toMap());

  factory AnnouncementModel.fromJson(String source) =>
      AnnouncementModel.fromMap(json.decode(source));
}

class TBModel {
  String? title;
  Timestamp? createdAt;

  TBModel({
    this.title,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'createdAt': createdAt,
    };
  }

  factory TBModel.fromMap(Map<String, dynamic> map) {
    return TBModel(
      title: map['title'] ?? '',
      createdAt: map['createdAt'],
    );
  }
}