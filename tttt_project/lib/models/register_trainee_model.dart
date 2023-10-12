import 'dart:convert';

class RegisterTraineeModel {
  String creditId,
      term,
      creditName,
      yearStart,
      yearEnd,
      uid,
      course,
      studentName;
  int reachedStep;

  RegisterTraineeModel({
    required this.creditId,
    required this.term,
    required this.creditName,
    required this.yearStart,
    required this.uid,
    required this.yearEnd,
    required this.course,
    required this.studentName,
    this.reachedStep = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'creditId': creditId,
      'term': term,
      'creditName': creditName,
      'yearStart': yearStart,
      'uid': uid,
      'yearEnd': yearEnd,
      'course': course,
      'studentName': studentName,
      'reachedStep': reachedStep,
    };
  }

  factory RegisterTraineeModel.fromMap(Map<String, dynamic> map) {
    return RegisterTraineeModel(
      creditId: map['creditId'] ?? '',
      term: map['term'] ?? '',
      creditName: map['creditName'] ?? '',
      yearStart: map['yearStart'] ?? '',
      uid: map['uid'] ?? '',
      yearEnd: map['yearEnd'] ?? '',
      course: map['course'] ?? '',
      studentName: map['studentName'] ?? '',
      reachedStep: map['reachedStep'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory RegisterTraineeModel.fromJson(String source) =>
      RegisterTraineeModel.fromMap(json.decode(source));

  RegisterTraineeModel copyWith({
    String? creditId,
    String? term,
    String? creditName,
    String? yearStart,
    String? uid,
    String? yearEnd,
    String? course,
    String? studentName,
    int? reachedStep,
  }) {
    return RegisterTraineeModel(
      creditId: creditId ?? this.creditId,
      term: term ?? this.term,
      creditName: creditName ?? this.creditName,
      yearStart: yearStart ?? this.yearStart,
      uid: uid ?? this.uid,
      yearEnd: yearEnd ?? this.yearEnd,
      course: course ?? this.course,
      studentName: studentName ?? this.studentName,
      reachedStep: reachedStep ?? this.reachedStep,
    );
  }
}
