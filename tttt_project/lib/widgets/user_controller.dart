import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tttt_project/models/firm_model.dart';

class UserController extends GetxController {
  RxString uid = "".obs;
  RxString name = "".obs;
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
  RxString gender = "".obs; //true: male, false: female
  RxInt menuSelected = 0.obs;
  RxBool isRegistered = false.obs;
  RxInt selectedStep = 0.obs;
  RxInt reachedStep = 0.obs;
  RxBool loadIn = false.obs;
  Rx<JobPositionModel> selectedJob = JobPositionModel().obs;
  Rx<DateTimeRange> traineeTime =
      DateTimeRange(start: DateTime.now(), end: DateTime.now()).obs;

  setCurrentUser({
    String? setUid,
    String? setName,
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
    int? setMenuSelected,
    bool? setIsRegistered,
    int? setReachedStep,
    int? setSelectedStep,
    bool? setLoadIn,
  }) {
    uid.value = setUid ?? uid.value;
    name.value = setName ?? name.value;
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
    menuSelected.value = setMenuSelected ?? menuSelected.value;
    isRegistered.value = setIsRegistered ?? isRegistered.value;
    reachedStep.value = setReachedStep ?? reachedStep.value;
    selectedStep.value = setSelectedStep ?? selectedStep.value;
    loadIn.value = setLoadIn ?? false;
  }

  resetUser() {
    uid.value = "";
    name.value = "";
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
    menuSelected.value = 0;
    isRegistered.value = false;
    reachedStep.value = 0;
    selectedStep.value = 0;
    loadIn.value = false;
  }
}
