import 'dart:convert';

class CVModel {
  String? wish, hobby, userId, skill, achieve;

  CVModel({
    this.wish,
    this.userId,
    this.hobby,
    this.skill,
    this.achieve,
  });

  Map<String, dynamic> toMap() {
    return {
      'wish': wish,
      'userId': userId ?? '',
      'hobby': hobby,
      'skill': skill ?? '',
      'achieve': achieve,
    };
  }

  factory CVModel.fromMap(Map<String, dynamic> map) {
    return CVModel(
      wish: map['wish'] ?? '',
      userId: map['userId'] ?? '',
      hobby: map['hobby'] ?? '',
      skill: map['skill'] ?? '',
      achieve: map['achieve'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory CVModel.fromJson(String source) =>
      CVModel.fromMap(json.decode(source));
}
