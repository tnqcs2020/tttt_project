import 'dart:convert';

class FirmModel {
  String? firmId, name, email, phone, owner, describe, address;
  List<JobPositionModel>? listJob;
  List<JobRegisterModel>? listRegis;

  FirmModel(
      {this.firmId,
      this.name,
      this.email,
      this.owner,
      this.phone,
      this.describe,
      this.address,
      this.listJob,
      this.listRegis});

  Map<String, dynamic> toMap() {
    return {
      'firmId': firmId,
      'name': name,
      'email': email,
      'owner': owner,
      'phone': phone,
      'describe': describe,
      'address': address,
      'listJob': listJob!.map((i) => i.toMap()).toList(),
      'listRegis': listRegis!.map((i) => i.toMap()).toList(),
    };
  }

  factory FirmModel.fromMap(Map<String, dynamic> data) {
    return FirmModel(
      firmId: data['firmId'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      owner: data['owner'] ?? '',
      phone: data['phone'] ?? '',
      describe: data['describe'] ?? '',
      address: data['address'] ?? '',
      listJob: data['listJob']
          .map<JobPositionModel>((i) => JobPositionModel.fromMap(i))
          .toList(),
      listRegis: data['listRegis']
          .map<JobRegisterModel>((i) => JobRegisterModel.fromMap(i))
          .toList(),
    );
  }

  String toJson() => json.encode(toMap());

  factory FirmModel.fromJson(String source) =>
      FirmModel.fromMap(json.decode(source));
}

class JobPositionModel {
  String? jobId, describeJob, name, quantity;

  JobPositionModel({
    this.jobId,
    this.describeJob,
    this.name,
    this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'describeJob': describeJob,
      'name': name,
      'quantity': quantity,
    };
  }

  factory JobPositionModel.fromMap(Map<String, dynamic> map) {
    return JobPositionModel(
      jobId: map['jobId'] ?? '',
      describeJob: map['describeJob'] ?? '',
      name: map['name'] ?? '',
      quantity: map['quantity'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory JobPositionModel.fromJson(String source) =>
      JobPositionModel.fromMap(json.decode(source));
}

class JobRegisterModel {
  String? userId, name, jobId;
  bool? isAccepted;

  JobRegisterModel({
    this.userId,
    this.jobId,
    this.name,
    this.isAccepted,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'jobId': jobId,
      'name': name,
      'isAccepted': isAccepted,
    };
  }

  factory JobRegisterModel.fromMap(Map<String, dynamic> map) {
    return JobRegisterModel(
      userId: map['userId'] ?? '',
      jobId: map['jobId'] ?? '',
      name: map['name'] ?? '',
      isAccepted: map['isAccepted'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory JobRegisterModel.fromJson(String source) =>
      JobRegisterModel.fromMap(json.decode(source));
}
