import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class SettingTraineeModel {
  String? term, yearStart, settingId, yearEnd;

  Timestamp? traineeStart,
      traineeEnd,
      regisStart,
      regisEnd,
      submitEnd,
      pointCVEnd,
      pointCBEnd,
      isClockPoint;

  SettingTraineeModel({
    this.term,
    this.settingId,
    this.yearStart,
    this.yearEnd,
    this.isClockPoint,
    this.traineeStart,
    this.traineeEnd,
    this.regisStart,
    this.regisEnd,
    this.submitEnd,
    this.pointCVEnd,
    this.pointCBEnd,
  });

  Map<String, dynamic> toMap() {
    return {
      'term': term,
      'settingId': settingId,
      'yearStart': yearStart,
      'yearEnd': yearEnd,
      'isClockPoint': isClockPoint,
      'traineeStart': traineeStart,
      'traineeEnd': traineeEnd,
      'regisStart': regisStart,
      'regisEnd': regisEnd,
      'submitEnd': submitEnd,
      'pointCBEnd': pointCBEnd,
      'pointCVEnd': pointCVEnd,
    };
  }

  factory SettingTraineeModel.fromMap(Map<String, dynamic> map) {
    return SettingTraineeModel(
      term: map['term'] ?? '',
      settingId: map['settingId'] ?? '',
      yearStart: map['yearStart'] ?? '',
      yearEnd: map['yearEnd'] ?? '',
      isClockPoint: map['isClockPoint'],
      traineeStart: map['traineeStart'],
      traineeEnd: map['traineeEnd'],
      regisStart: map['regisStart'],
      regisEnd: map['regisEnd'],
      submitEnd: map['submitEnd'],
      pointCVEnd: map['pointCVEnd'],
      pointCBEnd: map['pointCBEnd'],
    );
  }

  String toJson() => json.encode(toMap());

  factory SettingTraineeModel.fromJson(String source) =>
      SettingTraineeModel.fromMap(json.decode(source));
}
