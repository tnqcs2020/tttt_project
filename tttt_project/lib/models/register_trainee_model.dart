import 'dart:convert';

class RegisterTraineeModel {
  String? creditId,
      term,
      creditName,
      yearStart,
      yearEnd,
      userId,
      course,
      studentName;
  int? reachedStep;
  List<UserRegisterModel>? listRegis;

  RegisterTraineeModel({
    this.creditId,
    this.term,
    this.creditName,
    this.yearStart,
    this.userId,
    this.yearEnd,
    this.course,
    this.studentName,
    this.reachedStep = 0,
    this.listRegis,
  });

  Map<String, dynamic> toMap() {
    return {
      'creditId': creditId,
      'term': term,
      'creditName': creditName,
      'yearStart': yearStart,
      'userId': userId,
      'yearEnd': yearEnd,
      'course': course,
      'studentName': studentName,
      'reachedStep': reachedStep,
      'listRegis': listRegis!.map((i) => i.toMap()).toList(),
    };
  }

  factory RegisterTraineeModel.fromMap(Map<String, dynamic> map) {
    return RegisterTraineeModel(
      creditId: map['creditId'] ?? '',
      term: map['term'] ?? '',
      creditName: map['creditName'] ?? '',
      yearStart: map['yearStart'] ?? '',
      userId: map['userId'] ?? '',
      yearEnd: map['yearEnd'] ?? '',
      course: map['course'] ?? '',
      studentName: map['studentName'] ?? '',
      reachedStep: map['reachedStep'] ?? 0,
      listRegis: map['listRegis']
          .map<UserRegisterModel>((i) => UserRegisterModel.fromMap(i))
          .toList(),
    );
  }

  String toJson() => json.encode(toMap());

  factory RegisterTraineeModel.fromJson(String source) =>
      RegisterTraineeModel.fromMap(json.decode(source));
}

class UserRegisterModel {
  String? firmId, name, jobId;
  bool? isAccepted;

  UserRegisterModel({
    this.firmId,
    this.jobId,
    this.name,
    this.isAccepted,
  });

  Map<String, dynamic> toMap() {
    return {
      'firmId': firmId,
      'jobId': jobId,
      'name': name,
      'isAccepted': isAccepted,
    };
  }

  factory UserRegisterModel.fromMap(Map<String, dynamic> map) {
    return UserRegisterModel(
      firmId: map['firmId'] ?? '',
      jobId: map['jobId'] ?? '',
      name: map['name'] ?? '',
      isAccepted: map['isAccepted'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserRegisterModel.fromJson(String source) =>
      UserRegisterModel.fromMap(json.decode(source));
}
