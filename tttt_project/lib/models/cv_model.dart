import 'dart:convert';

class CVModel {
  String? wish, hobby, uid, skill, achieve;

  CVModel({
    this.wish,
    this.uid,
    this.hobby,
    this.skill,
    this.achieve,
  });

  Map<String, dynamic> toMap() {
    return {
      'wish': wish,
      'uid': uid,
      'hobby': hobby,
      'skill': skill,
      'achieve': achieve,
    };
  }

  factory CVModel.fromMap(Map<String, dynamic> map) {
    return CVModel(
      wish: map['wish'] ?? '',
      uid: map['uid'] ?? '',
      hobby: map['hobby'] ?? '',
      skill: map['skill'] ?? '',
      achieve: map['achieve'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory CVModel.fromJson(String source) =>
      CVModel.fromMap(json.decode(source));

  CVModel copyWith({
    String? wish,
    String? uid,
    String? hobby,
    String? skill,
    String? achieve,
  }) {
    return CVModel(
      wish: wish ?? this.wish,
      uid: uid ?? this.uid,
      hobby: hobby ?? this.hobby,
      skill: skill ?? this.skill,
      achieve: achieve ?? this.achieve,
    );
  }
}
