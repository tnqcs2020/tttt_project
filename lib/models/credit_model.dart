import 'dart:convert';

class CreditModel {
  String creditId, creditName, course, major, docId;

  CreditModel({
    required this.creditId,
    required this.creditName,
    required this.course,
    required this.major,
    required this.docId,
  });

  Map<String, dynamic> toMap() {
    return {
      'creditId': creditId,
      'creditName': creditName,
      'course': course,
      'major': major,
      'docId':docId
    };
  }

  static CreditModel empty =
      CreditModel(creditId: '', creditName: '', course: '', major: '', docId: '');
  static CreditModel tatca =
      CreditModel(creditId: 'Tất cả', creditName: '', course: '', major: '', docId: '');
      
  factory CreditModel.fromMap(Map<String, dynamic> map) {
    return CreditModel(
      creditId: map['creditId'] ?? '',
      creditName: map['creditName'] ?? '',
      course: map['course'] ?? '',
      major: map['major'] ?? '',
      docId: map['docId']?? ''
    );
  }

  String toJson() => json.encode(toMap());

  factory CreditModel.fromJson(String source) =>
      CreditModel.fromMap(json.decode(source));
}
