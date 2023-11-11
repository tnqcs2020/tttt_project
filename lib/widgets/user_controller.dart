import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tttt_project/models/firm_model.dart';
import 'package:tttt_project/models/submit_bodel.dart';
import 'package:tttt_project/models/user_model.dart';

class UserController extends GetxController {
  RxString uid = "".obs;
  RxString userName = "".obs;
  RxString userId = "".obs;
  RxString birthday = "".obs;
  RxString email = "".obs;
  RxString classId = "".obs;
  RxString className = "".obs;
  RxString course = "".obs;
  RxString major = "".obs;
  RxString phone = "".obs;
  RxString address = "".obs;
  RxString group =
      "".obs; //0:firm, 1:student, 2: teacher, 3: supervisor, 4: admin
  RxString gender = "".obs;
  RxString cvId = "".obs;
  RxString cvName = "".obs;
  RxString cvChucVu = "".obs;
  RxList<ClassModel> cvClass = RxList();
  RxInt menuSelected = 0.obs;
  RxInt selectedStep = 0.obs;
  RxInt reachedStep = 0.obs;
  RxBool loadIn = false.obs;
  Rx<JobPositionModel> selectedJob = JobPositionModel().obs;
  Rx<DateTimeRange> traineeTime =
      DateTimeRange(start: DateTime.now(), end: DateTime.now()).obs;
  RxBool isCompleted = false.obs;
  RxInt selected = 999.obs;
  RxString selectedString = ''.obs;
  RxList<FileModel> selectedFiles = RxList();
  RxDouble finalTotal = 0.0.obs;
  RxString selectedCourse = ''.obs;
  RxString selectedMajor = ''.obs;
  
  setCurrentUser({
    String? setUid,
    String? setUserName,
    String? setUserId,
    String? setBirthday,
    String? setEmail,
    String? setClassId,
    String? setClassName,
    String? setCourse,
    String? setMajor,
    String? setPhone,
    String? setAddress,
    String? setGroup,
    String? setGender,
    String? setCvId,
    String? setCvName,
    List<ClassModel>? setCVClass,
    String? setCvChucVu,
    int? setMenuSelected,
    int? setReachedStep,
    bool? setLoadIn,
  }) {
    uid.value = setUid ?? uid.value;
    userName.value = setUserName ?? userName.value;
    userId.value = setUserId ?? userId.value;
    email.value = setEmail ?? email.value;
    birthday.value = setBirthday ?? birthday.value;
    classId.value = setClassId ?? classId.value;
    className.value = setClassName ?? className.value;
    course.value = setCourse ?? course.value;
    major.value = setMajor ?? major.value;
    phone.value = setPhone ?? phone.value;
    group.value = setGroup ?? group.value;
    gender.value = setGender ?? gender.value;
    address.value = setAddress ?? address.value;
    cvId.value = setCvId ?? cvId.value;
    cvName.value = setCvName ?? cvName.value;
    cvChucVu.value = setCvChucVu ?? cvChucVu.value;
    cvClass = setCVClass != null ? RxList(setCVClass) : cvClass;
    menuSelected.value = setMenuSelected ?? menuSelected.value;
    reachedStep.value = setReachedStep ?? reachedStep.value;
    loadIn.value = setLoadIn ?? false;
  }

  resetUser() {
    uid.value = "";
    userName.value = "";
    userId.value = "";
    email.value = "";
    birthday.value = "";
    classId.value = "";
    className.value = "";
    course.value = "";
    major.value = "";
    phone.value = "";
    group.value = "";
    gender.value = "";
    address.value = "";
    cvId.value = "";
    cvName.value = "";
    cvChucVu.value = "";
    cvClass.value = [];
    menuSelected.value = 0;
    reachedStep.value = 0;
    selectedStep.value = 0;
    loadIn.value = false;
  }
}
