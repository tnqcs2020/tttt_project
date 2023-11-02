import 'dart:convert';

class SubmitModel {
  String? userId;
  List<FileModel>? files;
  SubmitModel({
    this.userId,
    this.files,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'files': files!.map((i) => i.toMap()).toList(),
    };
  }

  factory SubmitModel.fromMap(Map<String, dynamic> map) {
    return SubmitModel(
      userId: map['userId'] ?? '',
      files: map['files'].map<FileModel>((i) => FileModel.fromMap(i)).toList(),
    );
  }

  String toJson() => json.encode(toMap());

  factory SubmitModel.fromJson(String source) =>
      SubmitModel.fromMap(json.decode(source));
}

class FileModel {
  String? fileName, fileUrl;

  FileModel({
    this.fileName,
    this.fileUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'fileName': fileName,
      'fileUrl': fileUrl,
    };
  }

  factory FileModel.fromMap(Map<String, dynamic> map) {
    return FileModel(
      fileName: map['fileName'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory FileModel.fromJson(String source) =>
      FileModel.fromMap(json.decode(source));
}
