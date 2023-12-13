import 'dart:convert';

class CVModel {
  String? userId, description;
  int? language, programming, skillGroup, machineAI, website, mobile;

  CVModel({
    this.description,
    this.userId,
    this.language,
    this.programming,
    this.skillGroup,
    this.machineAI,
    this.website,
    this.mobile,
  });

  Map<String, dynamic> toMap() {
    return {
      'description': description ?? '',
      'userId': userId ?? '',
      'language': language ?? 0,
      'programming': programming ?? 0,
      'skillGroup': skillGroup ?? 0,
      'machineAI': machineAI ?? 0,
      'website': website ?? 0,
      'mobile': mobile ?? 0,
    };
  }

  factory CVModel.fromMap(Map<String, dynamic> map) {
    return CVModel(
      description: map['description'] ?? '',
      userId: map['userId'] ?? '',
      language: map['language'] ?? 0,
      programming: map['programming'] ?? 0,
      skillGroup: map['skillGroup'] ?? 0,
      machineAI: map['machineAI'] ?? 0,
      website: map['website'] ?? 0,
      mobile: map['mobile'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory CVModel.fromJson(String source) =>
      CVModel.fromMap(json.decode(source));
}
