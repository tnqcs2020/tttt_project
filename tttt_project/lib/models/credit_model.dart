import 'dart:convert';

class CreditModel {
  String id, name, course;

  CreditModel({
    required this.id,
    required this.name,
    required this.course,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'course': course};
  }

  factory CreditModel.fromMap(Map<String, dynamic> map) {
    return CreditModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      course: map['course'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory CreditModel.fromJson(String source) =>
      CreditModel.fromMap(json.decode(source));

  CreditModel copyWith({
    String? id,
    String? name,
    String? course,
  }) {
    return CreditModel(
      id: id ?? this.id,
      name: name ?? this.name,
      course: course ?? this.course,
    );
  }
}
