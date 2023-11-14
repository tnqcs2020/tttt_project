// ignore_for_file: use_build_context_synchronously, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/common/constant.dart';
import 'package:tttt_project/common/date_time_extension.dart';
import 'package:tttt_project/models/appreciate_cv_model.dart';
import 'package:tttt_project/models/credit_model.dart';
import 'package:tttt_project/models/firm_model.dart';
import 'package:tttt_project/models/register_trainee_model.dart';
import 'package:tttt_project/models/setting_trainee_model.dart';
import 'package:tttt_project/models/submit_bodel.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/models/plan_work_model.dart';
import 'package:tttt_project/widgets/custom_button.dart';
import 'package:tttt_project/widgets/dropdown_style.dart';
import 'package:tttt_project/widgets/footer.dart';
import 'package:tttt_project/widgets/header.dart';
import 'package:tttt_project/widgets/line_detail.dart';
import 'package:tttt_project/widgets/loading.dart';
import 'package:tttt_project/widgets/menu/menu_left.dart';
import 'package:tttt_project/common/user_controller.dart';

class RegisterTrainee extends StatefulWidget {
  const RegisterTrainee({Key? key}) : super(key: key);

  @override
  State<RegisterTrainee> createState() => _RegisterTraineeState();
}

class _RegisterTraineeState extends State<RegisterTrainee> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final currentUser = Get.put(UserController());
  CreditModel selectedHP = CreditModel.empty;
  String selectedHK = HocKy.empty;
  NamHoc selectedNH = NamHoc.empty;
  int upperBound = 4;
  Set<int> reachedSteps = <int>{0, 1, 2, 3, 4};
  String userId = '';
  UserModel user = UserModel();
  RegisterTraineeModel trainee = RegisterTraineeModel();
  List<PlatformFile> fileSelect = [];
  List<FileModel> submits = [];
  List<FileModel> files = [];
  SettingTraineeModel setting = SettingTraineeModel();
  List<CreditModel> credits = [];
  AppreciateCVModel appreciate = AppreciateCVModel();

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  getData() async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    bool? isLoggedIn = sharedPref.getBool("isLoggedIn");
    setState(() {
      userId = sharedPref
          .getString(
            'userId',
          )
          .toString();
    });
    if (isLoggedIn == true) {
      currentUser.setCurrentUser(
        setMenuSelected: sharedPref.getInt('menuSelected'),
      );
      DocumentSnapshot<Map<String, dynamic>> isExistUser =
          await firestore.collection('users').doc(userId).get();
      if (isExistUser.data() != null) {
        final loadUser = UserModel.fromMap(isExistUser.data()!);
        setState(() {
          user = loadUser;
        });
        DocumentSnapshot<Map<String, dynamic>> atMoment =
            await firestore.collection('atMoment').doc('now').get();
        if (atMoment.data() != null) {
          QuerySnapshot<Map<String, dynamic>> isExistSettingTrainee =
              await firestore
                  .collection('settingTrainees')
                  .where('term', isEqualTo: atMoment.data()!['term'])
                  .where('yearStart', isEqualTo: atMoment.data()!['yearStart'])
                  .get();
          if (isExistSettingTrainee.docs.isNotEmpty) {
            final settingTrainee = SettingTraineeModel.fromMap(
                isExistSettingTrainee.docs.first.data());
            setState(() {
              setting = settingTrainee;
            });
          }
        }
        DocumentSnapshot<Map<String, dynamic>> isExistSubmit =
            await firestore.collection('submits').doc(userId).get();
        if (isExistSubmit.data() != null) {
          final loadSubmit = SubmitModel.fromMap(isExistSubmit.data()!);
          setState(() {
            files = loadSubmit.files ?? [];
          });
        }
        QuerySnapshot<Map<String, dynamic>> isExistCredit = await firestore
            .collection('credits')
            .where('course', isEqualTo: user.course)
            .get();
        if (isExistCredit.docs.isNotEmpty) {
          isExistCredit.docs.forEach((element) {
            var temp = CreditModel.fromMap(element.data());
            setState(() {
              credits.add(temp);
            });
          });
        }
        DocumentSnapshot<Map<String, dynamic>> isExitTrainee =
            await firestore.collection('trainees').doc(userId).get();
        if (isExitTrainee.data() != null) {
          RegisterTraineeModel loadTrainee =
              RegisterTraineeModel.fromMap(isExitTrainee.data()!);

          if (loadTrainee.traineeStart == null &&
              loadTrainee.traineeEnd == null) {
            QuerySnapshot<Map<String, dynamic>> isExistSettingTrainee =
                await firestore
                    .collection('settingTrainees')
                    .where('term', isEqualTo: loadTrainee.term)
                    .where('yearStart', isEqualTo: loadTrainee.yearStart)
                    .where('yearEnd', isEqualTo: loadTrainee.yearEnd)
                    .get();
            if (isExistSettingTrainee.docs.isNotEmpty) {
              final settingTrainee = SettingTraineeModel.fromMap(
                  isExistSettingTrainee.docs.first.data());
              firestore.collection('trainees').doc(userId).update({
                'traineeStart': settingTrainee.traineeStart,
                'traineeEnd': settingTrainee.traineeEnd,
              });
              loadTrainee.traineeStart = settingTrainee.traineeStart;
              loadTrainee.traineeEnd = settingTrainee.traineeEnd;
            }
          }
          var isHasFirm = false;
          loadTrainee.listRegis!.forEach((element) {
            if (element.isConfirmed!) {
              isHasFirm = true;
            }
          });
          if (DateTime.now().isAfterTimestamp(setting.traineeEnd) &&
              DateTime.now().isAfterTimestamp(loadTrainee.traineeEnd) &&
              isHasFirm) {
            if (DateTime.now().isAfterTimestamp(setting.traineeEnd) &&
                DateTime.now().isBeforeOrEqual(setting.submitEnd)) {
              loadTrainee.reachedStep = 3;
              final isExist =
                  await firestore.collection('trainees').doc(userId).get();
              if (isExist.data() != null) {
                firestore
                    .collection('trainees')
                    .doc(userId)
                    .update({'reachedStep': 3});
              }
            } else if (DateTime.now().isAfterTimestamp(setting.submitEnd)) {
              loadTrainee.reachedStep = 4;
              final isExist =
                  await firestore.collection('trainees').doc(userId).get();
              if (isExist.data() != null) {
                firestore
                    .collection('trainees')
                    .doc(userId)
                    .update({'reachedStep': 4});
              }
            }
          }
          setState(() {
            trainee = loadTrainee;
          });
          currentUser.setCurrentUser(
            setUid: loadUser.uid,
            setUserId: loadUser.userId,
            setUserName: loadUser.userName,
            setClassName: loadUser.className,
            setCourse: loadUser.course,
            setGroup: loadUser.group,
            setMajor: loadUser.major,
            setEmail: loadUser.email,
            setAddress: loadUser.address,
            setBirthday: loadUser.birthday,
            setCvChucVu: loadUser.cvChucVu,
            setCvId: loadUser.cvId,
            setCvName: loadUser.cvName,
            setGender: loadUser.gender,
            setPhone: loadUser.phone,
            setClassId: loadUser.classId,
            setCVClass: loadUser.cvClass,
            setReachedStep: loadTrainee.reachedStep,
          );
          currentUser.selectedStep.value = loadTrainee.reachedStep!;
        } else {
          currentUser.setCurrentUser(
            setUid: loadUser.uid,
            setUserId: loadUser.userId,
            setUserName: loadUser.userName,
            setClassName: loadUser.className,
            setCourse: loadUser.course,
            setGroup: loadUser.group,
            setMajor: loadUser.major,
            setEmail: loadUser.email,
            setAddress: loadUser.address,
            setBirthday: loadUser.birthday,
            setCvChucVu: loadUser.cvChucVu,
            setCvId: loadUser.cvId,
            setCvName: loadUser.cvName,
            setGender: loadUser.gender,
            setPhone: loadUser.phone,
            setClassId: loadUser.classId,
            setCVClass: loadUser.cvClass,
          );
        }
      }
    }
    final isExistApp =
        await firestore.collection('appreciatesCV').doc(userId).get();
    if (isExistApp.data() != null) {
      setState(() {
        appreciate = AppreciateCVModel.fromMap(isExistApp.data()!);
      });
    }
    currentUser.loadIn.value = true;
  }

  @override
  void dispose() {
    // selectedStep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.cyan.shade50,
      body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              const Header(),
              Padding(
                padding: EdgeInsets.only(
                  top: screenHeight * 0.02,
                  bottom: screenHeight * 0.02,
                  left: screenWidth * 0.08,
                  right: screenWidth * 0.08,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MenuLeft(),
                    SizedBox(width: screenWidth * 0.03),
                    Obx(
                      () => Expanded(
                        child: Container(
                          constraints:
                              BoxConstraints(minHeight: screenHeight * 0.70),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              border: Border.all(
                                style: BorderStyle.solid,
                                width: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(5)),
                          child: Column(
                            children: [
                              Container(
                                height: screenHeight * 0.06,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade600,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(5.0),
                                    topRight: Radius.circular(5.0),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Quản lý thực tập thực tế",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              currentUser.loadIn.isTrue
                                  ? Column(
                                      children: [
                                        EasyStepper(
                                          activeStep:
                                              currentUser.selectedStep.value,
                                          maxReachedStep:
                                              currentUser.reachedStep.value,
                                          lineStyle: const LineStyle(
                                            lineLength: 100,
                                            lineThickness: 1,
                                            lineSpace: 5,
                                          ),
                                          stepRadius: 20,
                                          unreachedStepIconColor:
                                              Colors.black87,
                                          unreachedStepBorderColor:
                                              Colors.black54,
                                          unreachedStepTextColor: Colors.black,
                                          showLoadingAnimation: false,
                                          steps: [
                                            EasyStep(
                                              icon:
                                                  const Icon(Icons.edit_square),
                                              customTitle: Text(
                                                'Đăng ký',
                                                style: TextStyle(
                                                    color: currentUser
                                                                .selectedStep
                                                                .value ==
                                                            0
                                                        ? Colors.black
                                                        : Colors.blue.shade900,
                                                    fontWeight: currentUser
                                                                .selectedStep
                                                                .value ==
                                                            0
                                                        ? FontWeight.bold
                                                        : null),
                                                textAlign: TextAlign.center,
                                              ),
                                              enabled: _allowTabStepping(
                                                  0, StepEnabling.sequential),
                                            ),
                                            EasyStep(
                                              icon: const Icon(
                                                  CupertinoIcons.house_fill),
                                              customTitle: Text(
                                                'Công ty',
                                                style: TextStyle(
                                                    color: currentUser
                                                                .selectedStep
                                                                .value ==
                                                            1
                                                        ? Colors.black
                                                        : Colors.blue.shade900,
                                                    fontWeight: currentUser
                                                                .selectedStep
                                                                .value ==
                                                            1
                                                        ? FontWeight.bold
                                                        : null),
                                                textAlign: TextAlign.center,
                                              ),
                                              enabled: _allowTabStepping(
                                                  1, StepEnabling.sequential),
                                            ),
                                            EasyStep(
                                              icon: const Icon(CupertinoIcons
                                                  .desktopcomputer),
                                              customTitle: Text(
                                                'Thực tập',
                                                style: TextStyle(
                                                    color: currentUser
                                                                .selectedStep
                                                                .value ==
                                                            2
                                                        ? Colors.black
                                                        : Colors.blue.shade900,
                                                    fontWeight: currentUser
                                                                .selectedStep
                                                                .value ==
                                                            2
                                                        ? FontWeight.bold
                                                        : null),
                                                textAlign: TextAlign.center,
                                              ),
                                              enabled: _allowTabStepping(
                                                  2, StepEnabling.sequential),
                                            ),
                                            EasyStep(
                                              icon: const Icon(
                                                  CupertinoIcons.doc_fill),
                                              customTitle: Text(
                                                'Nộp tài liệu',
                                                style: TextStyle(
                                                    color: currentUser
                                                                .selectedStep
                                                                .value ==
                                                            3
                                                        ? Colors.black
                                                        : Colors.blue.shade900,
                                                    fontWeight: currentUser
                                                                .selectedStep
                                                                .value ==
                                                            3
                                                        ? FontWeight.bold
                                                        : null),
                                                textAlign: TextAlign.center,
                                              ),
                                              enabled: _allowTabStepping(
                                                  3, StepEnabling.sequential),
                                            ),
                                            EasyStep(
                                              icon: const Icon(
                                                CupertinoIcons
                                                    .checkmark_seal_fill,
                                                grade: 5,
                                              ),
                                              customTitle: Text(
                                                'Kết quả',
                                                style: TextStyle(
                                                    color: currentUser
                                                                .selectedStep
                                                                .value ==
                                                            4
                                                        ? Colors.black
                                                        : Colors.blue.shade900,
                                                    fontWeight: currentUser
                                                                .selectedStep
                                                                .value ==
                                                            4
                                                        ? FontWeight.bold
                                                        : null),
                                                textAlign: TextAlign.center,
                                              ),
                                              enabled: _allowTabStepping(
                                                  4, StepEnabling.sequential),
                                            ),
                                          ],
                                          onStepReached: (index) async {
                                            currentUser.selectedStep.value =
                                                index;
                                            final isExist = await firestore
                                                .collection('trainees')
                                                .doc(userId)
                                                .get();
                                            if (isExist.data() != null) {
                                              firestore
                                                  .collection('trainees')
                                                  .doc(userId)
                                                  .update({
                                                'reachedStep': currentUser
                                                    .reachedStep.value
                                              });
                                            }
                                          },
                                        ),
                                        const Divider(
                                          thickness: 0.1,
                                          height: 0,
                                          color: Colors.black,
                                        ),
                                        switch (
                                            currentUser.selectedStep.value) {
                                          1 => _regisFirm(),
                                          2 => _trainee(),
                                          3 => _submit(),
                                          4 => _completed(),
                                          _ => trainee.userId != null
                                              ? _infoCredit(trainee)
                                              : _regisCredit(),
                                        },
                                      ],
                                    )
                                  : const Padding(
                                      padding: EdgeInsets.only(top: 200),
                                      child: Loading(),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Footer(),
            ],
          )),
    );
  }

  Widget _regisCredit() {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return DateTime.now()
            .isBetweenEqual(from: setting.regisStart, to: setting.regisEnd)
        ? Container(
            padding: const EdgeInsets.only(left: 50, right: 50, top: 25),
            constraints: BoxConstraints(
                minHeight: screenHeight * 0.5, maxWidth: screenWidth * 0.5),
            child: Column(
              children: [
                if (setting.regisStart != null && setting.regisEnd != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          'Thời gian đăng ký từ ngày ${GV.readTimestamp(setting.regisStart!)} đến ngày ${GV.readTimestamp(setting.regisEnd!)}'),
                    ],
                  ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    SizedBox(
                      width: screenWidth * 0.07,
                      child: const Text(
                        "Học Phần",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton2<CreditModel>(
                        isExpanded: true,
                        hint: Center(
                          child: Text(
                            'Chọn',
                            style: DropdownStyle.hintStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        items: credits
                            .map((CreditModel hp) =>
                                DropdownMenuItem<CreditModel>(
                                  value: hp,
                                  child: Text(
                                    "${hp.creditId} - ${hp.creditName}",
                                    style: DropdownStyle.itemStyle,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        value:
                            selectedHP != CreditModel.empty ? selectedHP : null,
                        onChanged: (value) {
                          setState(() {
                            selectedHP = value!;
                          });
                        },
                        buttonStyleData: DropdownStyle.buttonStyleLong,
                        iconStyleData: DropdownStyle.iconStyleData,
                        dropdownStyleData: DropdownStyle.dropdownStyleLong,
                        menuItemStyleData: DropdownStyle.menuItemStyleData,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    SizedBox(
                      width: screenWidth * 0.07,
                      child: const Text(
                        "Học Kỳ",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        hint: Center(
                          child: Text(
                            'Chọn',
                            style: DropdownStyle.hintStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        items: dshk
                            .map((String hk) => DropdownMenuItem<String>(
                                  value: hk,
                                  child: Text(
                                    hk,
                                    style: DropdownStyle.itemStyle,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        value: selectedHK != HocKy.empty ? selectedHK : null,
                        onChanged: (value) {
                          setState(() {
                            selectedHK = value!;
                          });
                        },
                        buttonStyleData: DropdownStyle.buttonStyleShort,
                        iconStyleData: DropdownStyle.iconStyleData,
                        dropdownStyleData: DropdownStyle.dropdownStyleShort,
                        menuItemStyleData: DropdownStyle.menuItemStyleData,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    SizedBox(
                      width: screenWidth * 0.07,
                      child: const Text(
                        "Năm Học",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton2<NamHoc>(
                        isExpanded: true,
                        hint: Center(
                          child: Text(
                            "Chọn",
                            style: DropdownStyle.hintStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        items: dsnh
                            .map((NamHoc nh) => DropdownMenuItem<NamHoc>(
                                  value: nh,
                                  child: Text(
                                    "${nh.start} - ${nh.end}",
                                    style: DropdownStyle.itemStyle,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        value: selectedNH != NamHoc.empty ? selectedNH : null,
                        onChanged: (value) {
                          setState(() {
                            selectedNH = value!;
                          });
                        },
                        buttonStyleData: DropdownStyle.buttonStyleMedium,
                        iconStyleData: DropdownStyle.iconStyleData,
                        dropdownStyleData: DropdownStyle.dropdownStyleMedium,
                        menuItemStyleData: DropdownStyle.menuItemStyleData,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 55),
                CustomButton(
                  text: "Đăng Ký",
                  width: screenWidth * 0.1,
                  height: screenHeight * 0.07,
                  onTap: () async {
                    if (selectedHP.creditId.isNotEmpty &&
                        selectedHP.creditName.isNotEmpty &&
                        selectedHK != HocKy.empty &&
                        selectedNH != NamHoc.empty) {
                      if (setting.term != selectedHK &&
                          selectedNH.start != setting.yearStart) {
                        GV.error(
                            context: context,
                            message:
                                'Vui lòng chọn đúng học kỳ và năm học hiện tại');
                      } else {
                        RegisterTraineeModel registerTraineeModel =
                            RegisterTraineeModel(
                          creditId: selectedHP.creditId,
                          term: selectedHK,
                          creditName: selectedHP.creditName,
                          yearStart: selectedNH.start,
                          userId: userId,
                          yearEnd: selectedNH.end,
                          course: currentUser.course.value,
                          studentName: currentUser.userName.value,
                          classId: currentUser.classId.value,
                          reachedStep: 0,
                          traineeStart: setting.traineeStart,
                          traineeEnd: setting.traineeEnd,
                        );
                        if (setting.settingId != null) {
                          final updateTimeTrainee = await firestore
                              .collection('trainees')
                              .where('term', isEqualTo: setting.term)
                              .where('yearStart', isEqualTo: setting.yearStart)
                              .where('yearEnd', isEqualTo: setting.yearEnd)
                              .get();
                          if (updateTimeTrainee.docs.isNotEmpty) {
                            List<RegisterTraineeModel> traineeUpdates = [];
                            updateTimeTrainee.docs.forEach((element) =>
                                traineeUpdates.add(RegisterTraineeModel.fromMap(
                                    element.data())));
                            traineeUpdates.forEach((element) {
                              element.traineeStart = setting.traineeStart;
                              element.traineeEnd = setting.traineeEnd;
                            });
                            if (traineeUpdates.isNotEmpty) {
                              traineeUpdates.forEach((element) {
                                firestore
                                    .collection('trainees')
                                    .doc(element.userId)
                                    .update({
                                  'traineeStart': element.traineeStart,
                                  'traineeEnd': element.traineeEnd,
                                });
                              });
                            }
                          }
                        }
                        currentUser.reachedStep.value = 0;
                        final docRegister = firestore
                            .collection('trainees')
                            .doc(registerTraineeModel.userId);
                        final json = registerTraineeModel.toMap();
                        await docRegister.set(json);
                        GV.success(context: context, message: 'Đã đăng ký!');
                        _nextStep(StepEnabling.sequential);
                        setState(() {
                          trainee = registerTraineeModel;
                        });
                      }
                    } else {
                      GV.error(
                          context: context, message: 'Chọn đầy đủ thông tin!');
                    }
                  },
                ),
              ],
            ),
          )
        : DateTime.now().isBeforeTimestamp(setting.regisStart)
            ? Container(
                padding: const EdgeInsets.only(left: 50, right: 50),
                constraints: BoxConstraints(
                    minHeight: screenHeight * 0.5, maxWidth: screenWidth * 0.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Chưa tới thời gian đăng ký.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (setting.regisStart != null && setting.regisEnd != null)
                      Text(
                          'Thời gian đăng ký từ ngày ${GV.readTimestamp(setting.regisStart!)} đến ngày ${GV.readTimestamp(setting.regisEnd!)}')
                  ],
                ),
              )
            : DateTime.now().isAfterTimestamp(setting.regisEnd)
                ? Container(
                    padding: const EdgeInsets.only(left: 50, right: 50),
                    constraints: BoxConstraints(
                        minHeight: screenHeight * 0.5,
                        maxWidth: screenWidth * 0.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Đã quá thời gian đăng ký.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (setting.regisStart != null &&
                            setting.regisEnd != null)
                          Text(
                              'Thời gian đăng ký từ ngày ${GV.readTimestamp(setting.regisStart!)} đến ngày ${GV.readTimestamp(setting.regisEnd!)}')
                      ],
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.only(left: 50, right: 50),
                    constraints: BoxConstraints(
                        minHeight: screenHeight * 0.5,
                        maxWidth: screenWidth * 0.5),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Chưa có thời gian đăng ký cụ thể.',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
  }

  Widget _infoCredit(RegisterTraineeModel loadTrainee) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        children: [
          const Text(
            'Thông tin học phần',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: screenWidth * 0.3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LineDetail(
                    field: 'Mã HP',
                    widthField: 0.1,
                    display: loadTrainee.creditId),
                LineDetail(
                    field: 'Tên HP',
                    widthField: 0.1,
                    display: loadTrainee.creditName),
                LineDetail(
                    field: 'Học kỳ',
                    widthField: 0.1,
                    display: loadTrainee.term),
                LineDetail(
                    field: 'Năm học',
                    widthField: 0.1,
                    display:
                        '${loadTrainee.yearStart} - ${loadTrainee.yearEnd}'),
                if (loadTrainee.traineeStart != null &&
                    loadTrainee.traineeEnd != null)
                  LineDetail(
                      field: 'Thời gian thực tập',
                      widthField: 0.1,
                      display:
                          '${GV.readTimestamp(loadTrainee.traineeStart!)} - ${GV.readTimestamp(loadTrainee.traineeEnd!)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _regisFirm() {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return StreamBuilder(
        stream: firestore
            .collection('trainees')
            .doc(currentUser.userId.value)
            .snapshots(),
        builder: (context, snapshotTrainee) {
          if (snapshotTrainee.hasData &&
              snapshotTrainee.data != null &&
              snapshotTrainee.connectionState == ConnectionState.active) {
            RegisterTraineeModel loadTrainee =
                RegisterTraineeModel.fromMap(snapshotTrainee.data!.data()!);
            List<UserRegisterModel> listAccepted = [];
            bool isTrainee = false;
            UserRegisterModel firmConfirm = UserRegisterModel();
            if (loadTrainee.listRegis != null &&
                loadTrainee.listRegis!.isNotEmpty) {
              listAccepted = loadTrainee.listRegis!
                  .where((element) => element.status == TrangThai.accept)
                  .toList();
              loadTrainee.listRegis!.forEach((e) {
                if (e.isConfirmed == true) {
                  isTrainee = true;
                  firmConfirm = e;
                }
              });
            }
            return isTrainee && firmConfirm.firmId != null
                ? StreamBuilder(
                    stream: firestore
                        .collection('firms')
                        .doc(firmConfirm.firmId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.data != null &&
                          snapshot.data!.data() != null) {
                        FirmModel firm =
                            FirmModel.fromMap(snapshot.data!.data()!);
                        return Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Column(
                            children: [
                              const Text(
                                'Thông tin công ty',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 15),
                              SizedBox(
                                width: screenWidth * 0.35,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    LineDetail(
                                        field: 'Tên công ty',
                                        display: firm.firmName,
                                        widthForm: 0.28),
                                    if (firm.owner != '')
                                      LineDetail(
                                          field: 'Người đại diện',
                                          display: firm.owner,
                                          widthForm: 0.28),
                                    if (firm.phone != '')
                                      LineDetail(
                                          field: 'Số điện thoại',
                                          display: firm.phone,
                                          widthForm: 0.28),
                                    if (firm.email != "")
                                      LineDetail(
                                          field: 'Email',
                                          display: firm.email,
                                          widthForm: 0.28),
                                    if (firm.address != '')
                                      LineDetail(
                                          field: 'Địa chỉ',
                                          display: firm.address,
                                          widthForm: 0.28),
                                    LineDetail(
                                        field: 'Mô tả',
                                        display: firm.describe,
                                        widthForm: 0.28),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const Padding(
                        padding: EdgeInsets.only(top: 150),
                        child: Loading(),
                      );
                    })
                : setting.traineeStart != null &&
                        DateTime.now().isBeforeTimestamp(setting.traineeStart)
                    ? loadTrainee.listRegis != null &&
                            loadTrainee.listRegis!.isNotEmpty
                        ? listAccepted.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(top: 15),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Các công ty chấp nhận thực tập',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (setting.traineeStart != null)
                                      Text(
                                          'Bạn cần xác nhận trước ngày thực tập (${GV.readTimestamp(setting.traineeStart!)})'),
                                    const SizedBox(height: 15),
                                    SizedBox(
                                      width: screenWidth * 0.5,
                                      child: ListView.separated(
                                        itemCount: listAccepted.length,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          return StreamBuilder(
                                              stream: firestore
                                                  .collection('firms')
                                                  .doc(listAccepted[index]
                                                      .firmId)
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                if (snapshot.data != null &&
                                                    snapshot.data!.data() !=
                                                        null) {
                                                  FirmModel firm =
                                                      FirmModel.fromMap(snapshot
                                                          .data!
                                                          .data()!);
                                                  return Card(
                                                    elevation: 5,
                                                    child: ListTile(
                                                      title: Text(
                                                          '${firm.firmName}'),
                                                      subtitle: Text(
                                                        'Vị trí ứng tuyển: ${listAccepted[index].jobName}',
                                                      ),
                                                      trailing:
                                                          listAccepted[index]
                                                                      .status ==
                                                                  TrangThai
                                                                      .accept
                                                              ? const Text(
                                                                  'Chờ xác nhận',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                )
                                                              : Text(
                                                                  listAccepted[
                                                                          index]
                                                                      .status!),
                                                      onTap: () {
                                                        showDialog(
                                                          context: context,
                                                          barrierColor:
                                                              Colors.black12,
                                                          builder: (context) {
                                                            return Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(
                                                                top:
                                                                    screenHeight *
                                                                        0.06,
                                                                bottom:
                                                                    screenHeight *
                                                                        0.02,
                                                                left:
                                                                    screenWidth *
                                                                        0.27,
                                                                right:
                                                                    screenWidth *
                                                                        0.08,
                                                              ),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  AlertDialog(
                                                                    scrollable:
                                                                        true,
                                                                    title:
                                                                        Container(
                                                                      color: Colors
                                                                          .blue
                                                                          .shade600,
                                                                      height:
                                                                          screenHeight *
                                                                              0.06,
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              10),
                                                                      child:
                                                                          Row(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          const SizedBox(
                                                                            width:
                                                                                30,
                                                                          ),
                                                                          const Expanded(
                                                                            child: Text('Chi tiết tuyển dụng',
                                                                                style: TextStyle(fontWeight: FontWeight.bold),
                                                                                textAlign: TextAlign.center),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                30,
                                                                            child: IconButton(
                                                                                padding: const EdgeInsets.only(bottom: 1),
                                                                                onPressed: () {
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                icon: const Icon(Icons.close)),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    titlePadding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                    shape: Border.all(
                                                                        width:
                                                                            0.5),
                                                                    content:
                                                                        ConstrainedBox(
                                                                      constraints:
                                                                          BoxConstraints(
                                                                              minWidth: screenWidth * 0.35),
                                                                      child:
                                                                          Form(
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: <Widget>[
                                                                            Text('Tên công ty: ${firm.firmName}'),
                                                                            Text('Người đại diện: ${firm.owner}'),
                                                                            Text('Số điện thoại: ${firm.phone}'),
                                                                            Text('Email: ${firm.email}'),
                                                                            Text('Địa chỉ: ${firm.address}'),
                                                                            Text('Mô tả: ${firm.describe}'),
                                                                            Text('Vị trí ứng tuyển: ${listAccepted[index].jobName} '),
                                                                            if (listAccepted[index].createdAt !=
                                                                                null)
                                                                              Text('Ngày ứng tuyển: ${GV.readTimestamp(listAccepted[index].createdAt!)}'),
                                                                            if (listAccepted[index].repliedAt !=
                                                                                null)
                                                                              Text('Ngày duyệt: ${GV.readTimestamp(listAccepted[index].repliedAt!)}'),
                                                                            if (trainee.traineeStart != null &&
                                                                                trainee.traineeEnd != null)
                                                                              Text('Thời gian thực tập: Từ ngày ${GV.readTimestamp(trainee.traineeStart!)} - Đến ngày  ${GV.readTimestamp(trainee.traineeEnd!)}'),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    actions: [
                                                                      ElevatedButton(
                                                                        onPressed:
                                                                            () async {
                                                                          var loadCBHD = await firestore
                                                                              .collection('users')
                                                                              .doc(firm.firmId)
                                                                              .get();
                                                                          final cbhdName =
                                                                              UserModel.fromMap(loadCBHD.data()!).userName;
                                                                          final plan =
                                                                              PlanWorkModel(
                                                                            cbhdId:
                                                                                firm.firmId,
                                                                            cbhdName:
                                                                                cbhdName,
                                                                            listWork: [],
                                                                            userId:
                                                                                userId,
                                                                          );
                                                                          var listRegis =
                                                                              firm.listRegis;
                                                                          for (int i = 0;
                                                                              i < listRegis!.length;
                                                                              i++) {
                                                                            if (listRegis[i].userId ==
                                                                                currentUser.userId.value) {
                                                                              listRegis[i].isConfirmed = true;
                                                                              plan.traineeStart = trainee.traineeStart;
                                                                              plan.traineeEnd = trainee.traineeEnd;
                                                                            }
                                                                          }
                                                                          firestore
                                                                              .collection('plans')
                                                                              .doc(userId)
                                                                              .set(plan.toMap());
                                                                          firestore
                                                                              .collection(
                                                                                  'firms')
                                                                              .doc(firm
                                                                                  .firmId)
                                                                              .update({
                                                                            'listRegis':
                                                                                listRegis.map((i) => i.toMap()).toList()
                                                                          });
                                                                          final listUserRegis =
                                                                              loadTrainee.listRegis;
                                                                          for (int i = 0;
                                                                              i < listUserRegis!.length;
                                                                              i++) {
                                                                            if (listUserRegis[i].firmId ==
                                                                                firm.firmId) {
                                                                              listUserRegis[i].isConfirmed = true;
                                                                            }
                                                                          }
                                                                          firestore
                                                                              .collection('trainees')
                                                                              .doc(userId)
                                                                              .update({
                                                                            'listRegis':
                                                                                listUserRegis.map((i) => i.toMap()).toList(),
                                                                          });
                                                                          Navigator.pop(
                                                                              context);
                                                                          _nextStep(
                                                                              StepEnabling.sequential);
                                                                          GV.success(
                                                                              context: context,
                                                                              message: 'Đã xác nhận công ty thực tập');
                                                                        },
                                                                        child:
                                                                            const Text(
                                                                          'Xác nhận',
                                                                          style:
                                                                              TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                      ElevatedButton(
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child:
                                                                            const Text(
                                                                          'Để sau',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.red,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  );
                                                } else {
                                                  return const SizedBox
                                                      .shrink();
                                                }
                                              });
                                        },
                                        separatorBuilder: (context, index) =>
                                            const Divider(),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(top: 100),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Chưa có công ty phê duyệt đăng ký của bạn.',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (setting.traineeStart != null)
                                      Text(
                                          'Bạn cần có công ty thực tập trước ngày thực tập (${GV.readTimestamp(setting.traineeStart!)})'),
                                    const SizedBox(height: 35),
                                    CustomButton(
                                      text: "Ứng tuyển thêm",
                                      width: screenWidth * 0.1,
                                      height: screenHeight * 0.07,
                                      onTap: () async {
                                        currentUser.menuSelected.value = 3;
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        prefs.setInt('menuSelected', 3);
                                        Navigator.pushNamed(
                                            context, pageSinhVien[3]);
                                      },
                                    ),
                                  ],
                                ),
                              )
                        : Padding(
                            padding: const EdgeInsets.only(top: 100),
                            child: Column(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Bạn chưa đăng ký công ty',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (setting.traineeStart != null)
                                      Text(
                                          'Bạn cần có công ty thực tập trước ngày thực tập (${GV.readTimestamp(setting.traineeStart!)})')
                                  ],
                                ),
                                const SizedBox(height: 35),
                                CustomButton(
                                  text: "Tìm công ty ngay",
                                  width: screenWidth * 0.1,
                                  height: screenHeight * 0.07,
                                  onTap: () async {
                                    currentUser.menuSelected.value = 3;
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    prefs.setInt('menuSelected', 3);
                                    Navigator.pushNamed(
                                        context, pageSinhVien[3]);
                                  },
                                ),
                              ],
                            ),
                          )
                    : Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: Column(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Bạn chưa có công ty thực tập',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                if (setting.traineeStart != null)
                                  Text(
                                      'Đã bắt đầu thời gian thực tập (${GV.readTimestamp(setting.traineeStart!)}) vui lòng liên hệ giảng viên cố vấn để được giải quyết.')
                              ],
                            ),
                          ],
                        ));
          }
          return const Padding(
            padding: EdgeInsets.only(top: 150),
            child: Loading(),
          );
        });
  }

  Widget _trainee() {
    // double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return StreamBuilder(
        stream: firestore
            .collection('plans')
            .doc(currentUser.userId.value)
            .snapshots(),
        builder: (context, snapshotPlan) {
          if (snapshotPlan.hasData &&
              snapshotPlan.data != null &&
              snapshotPlan.connectionState == ConnectionState.active) {
            final plan = PlanWorkModel.fromMap(snapshotPlan.data!.data()!);
            return Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Column(
                children: [
                  const Text(
                    'Phân công công việc',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: screenWidth * 0.5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cán bộ hướng dẫn: ${plan.cbhdName}'),
                        Text(
                            'Thời gian thực tập: ${GV.readTimestamp(plan.traineeStart!)} - ${GV.readTimestamp(plan.traineeEnd!)}'),
                        if (plan.listWork!.isEmpty)
                          const Text(
                              'Hãy chờ cán bộ phân công trong ít ngày tới'),
                        if (plan.listWork!.isNotEmpty) ...[
                          Text(
                              'Ngày phân công:  ${GV.readTimestamp(plan.createdAt!)}'),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Table(
                              border: TableBorder.all(),
                              columnWidths: Map.from({
                                0: const FlexColumnWidth(1),
                                1: const FlexColumnWidth(3),
                                2: const FlexColumnWidth(1),
                              }),
                              children: [
                                TableRow(
                                  children: [
                                    Container(
                                        padding: const EdgeInsets.all(10),
                                        child: const Text(
                                          'Tuần',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )),
                                    Container(
                                        padding: const EdgeInsets.all(10),
                                        child: const Text(
                                          'Nội dung công việc',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      child: const Text(
                                        'Số buổi',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                for (int i = 0; i < plan.listWork!.length; i++)
                                  TableRow(
                                    children: [
                                      TableCell(
                                        verticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            children: [
                                              Text(
                                                GV.readTimestamp(plan
                                                    .listWork![i].dayStart!),
                                                textAlign: TextAlign.center,
                                              ),
                                              Text(
                                                '${i + 1}',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                                textAlign: TextAlign.center,
                                              ),
                                              Text(
                                                GV.readTimestamp(
                                                    plan.listWork![i].dayEnd!),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        verticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                plan.listWork![i].content!,
                                                textAlign: TextAlign.start,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        verticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          child: Text(
                                            '${plan.listWork![i].totalDay}',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),
                ],
              ),
            );
          }
          return const Padding(
            padding: EdgeInsets.only(top: 150),
            child: Loading(),
          );
        });
  }

  Widget _submit() {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Nộp tài liệu',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: screenWidth * 0.35,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: screenWidth * 0.08,
                      child: const Text(
                        "Tài liệu cần nộp: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                          "Báo cáo thực tập thực tế (.pdf, .docx), các hình ảnh, source, website, ứng dụng liên quan đến quá trình thực tập (nếu có)."),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    SizedBox(
                      width: screenWidth * 0.08,
                      child: const Text(
                        "Hạn nộp: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (setting.submitEnd != null)
                      Text(
                          "Đến hết ngày ${GV.readTimestamp(setting.submitEnd!)}"),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: screenWidth * 0.08,
                      child: const Text(
                        "Đã nộp: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: files.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              itemCount: files.length,
                              itemBuilder: (context, index) {
                                return Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        openInANewTab(files[index].fileUrl);
                                      },
                                      child: Text(
                                        files[index].fileName!,
                                        style: TextStyle(
                                          color: Colors.blue.shade900,
                                          decoration: TextDecoration.underline,
                                          decorationColor: Colors.blue.shade900,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    InkWell(
                                      onTap: () async {
                                        showDialog(
                                            context: context,
                                            barrierColor: Colors.black12,
                                            builder: (context) {
                                              return Padding(
                                                padding: EdgeInsets.only(
                                                  top: screenHeight * 0.06,
                                                  bottom: screenHeight * 0.02,
                                                  left: screenWidth * 0.27,
                                                  right: screenWidth * 0.08,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    AlertDialog(
                                                      title: Container(
                                                        color: Colors
                                                            .blue.shade600,
                                                        height:
                                                            screenHeight * 0.06,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 10),
                                                        child: const Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              'Xóa tài liệu',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 20),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      titlePadding:
                                                          EdgeInsets.zero,
                                                      shape: Border.all(
                                                          width: 0.5),
                                                      content: const Text(
                                                          "Bạn có chắc chắn muốn xóa tài liệu này?"),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                            "Hủy",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () async {
                                                            await deleteFile(
                                                                deleteAt:
                                                                    index);
                                                          },
                                                          child: const Text(
                                                            "Đồng ý",
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              );
                                            });
                                      },
                                      child: const Icon(
                                        Icons.delete_outlined,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            )
                          : const Text("Bạn chưa nộp!"),
                    ),
                  ],
                ),
                const SizedBox(height: 75),
                DateTime.now().isBeforeOrEqual(setting.submitEnd)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 35,
                            child: ElevatedButton(
                              onPressed: () async {
                                await selectMultipleFiles();
                                await uploadMultipleFiles();
                              },
                              style: const ButtonStyle(
                                  elevation: MaterialStatePropertyAll(5)),
                              child: const Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Tải lên",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(width: 10),
                                    Icon(
                                      Icons.upload_file,
                                      size: 25,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 35),
                          SizedBox(
                            width: 150,
                            height: 35,
                            child: ElevatedButton(
                              onPressed: () async {
                                showDialog(
                                    context: context,
                                    barrierColor: Colors.black12,
                                    builder: (context) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          top: screenHeight * 0.06,
                                          bottom: screenHeight * 0.02,
                                          left: screenWidth * 0.27,
                                          right: screenWidth * 0.08,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            AlertDialog(
                                              title: Container(
                                                color: Colors.blue.shade600,
                                                height: screenHeight * 0.06,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                child: const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Xóa tài liệu',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 20),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              titlePadding: EdgeInsets.zero,
                                              shape: Border.all(width: 0.5),
                                              content: const Text(
                                                  "Bạn có chắc chắn muốn xóa tất cả tài liệu này?"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text(
                                                    "Hủy",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    await deleteFile();
                                                  },
                                                  child: const Text(
                                                    "Đồng ý",
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                              },
                              style: const ButtonStyle(
                                  elevation: MaterialStatePropertyAll(5)),
                              child: const Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Xóa tất cả",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Đã quá thời gian nộp bài.',
                            style: TextStyle(color: Colors.red),
                          )
                        ],
                      )
              ],
            ),
          ),
        ],
      ),
    );
  }

  openInANewTab(url) {
    html.window.open(url, 'PlaceholderName');
  }

  void downloadFile(String url) {
    html.AnchorElement anchorElement = html.AnchorElement(href: url);
    anchorElement.download = url;
    anchorElement.click();
  }

  selectMultipleFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );
    if (result != null) {
      setState(() {
        fileSelect = result.files;
      });
    }
  }

  uploadMultipleFiles() async {
    // var temp = submits;
    try {
      for (var i = 0; i < fileSelect.length; i++) {
        storage.UploadTask uploadTask;
        storage.Reference ref = storage.FirebaseStorage.instance
            .ref()
            .child('docSubmit')
            .child('/$userId')
            .child(fileSelect[i].name);
        uploadTask = ref.putData(fileSelect[i].bytes!);
        await uploadTask.whenComplete(() => null);
        var url = await ref.getDownloadURL();
        final fileModel = FileModel(
          fileName: fileSelect[i].name,
          fileUrl: url,
        );
        bool hasFile = false;
        if (files.isNotEmpty) {
          for (int i = 0; i < files.length; i++) {
            if (files[i].fileName == fileModel.fileName) {
              hasFile = true;
              setState(() {
                files[i].fileUrl = url;
              });
            }
          }
        }
        if (hasFile != true) {
          setState(() {
            files.add(fileModel);
          });
        }
      }
      GV.success(context: context, message: 'Tài liệu đã được tải lên.');
      firestore
          .collection('submits')
          .doc(userId)
          .set(SubmitModel(userId: userId, files: files).toMap());
    } catch (e) {
      print(e);
      GV.error(context: context, message: 'Đã có lỗi xảy ra.');
    }
  }

  deleteFile({int? deleteAt}) async {
    List<FileModel> temp = [];
    if (deleteAt != null) {
      setState(() {
        files[deleteAt].fileName = '';
        files[deleteAt].fileUrl = '';
      });

      files.forEach((e) {
        if (e.fileName != '' && e.fileUrl != '') {
          temp.add(e);
        }
      });
    }
    setState(() {
      files = temp;
    });
    firestore.collection('submits').doc(userId).update({
      'files': temp.map((i) => i.toMap()).toList(),
    });
    Navigator.of(context).pop();
    GV.success(context: context, message: 'Tài liệu đã được xóa.');
  }

  Widget _completed() {
    // double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Kết quả thực tập',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: screenWidth * 0.25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DateTime.now().isAfterTimestamp(setting.pointCVEnd)
                        ? appreciate.pointChar != 'F'
                            ? const Column(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: Colors.green,
                                    size: 55,
                                  ),
                                  Text('Chúc mừng bạn đã hoàn thành môn học.'),
                                ],
                              )
                            : const Column(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    color: Colors.red,
                                    size: 55,
                                  ),
                                  Text('Bạn đã trượt môn học.'),
                                ],
                              )
                        : const SizedBox.shrink(),
                  ],
                ),
                LineDetail(field: 'Học kỳ', display: trainee.term),
                LineDetail(
                    field: 'Năm học',
                    display: '${trainee.yearStart} - ${trainee.yearEnd}'),
                LineDetail(
                  field: 'Học phần',
                  display: trainee.creditName,
                ),
                DateTime.now().isAfterTimestamp(setting.pointCVEnd)
                    ? LineDetail(
                        field: 'Điểm/Điểm chữ',
                        display:
                            '${appreciate.finalTotal}/${appreciate.pointChar}')
                    : const LineDetail(
                        field: 'Điểm/Điểm chữ', display: 'Đang chờ chấm điểm'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _allowTabStepping(int index, StepEnabling enabling) {
    return enabling == StepEnabling.sequential
        ? index <= currentUser.reachedStep.value
        : reachedSteps.contains(index);
  }

  _nextStep(StepEnabling enabling) async {
    if (currentUser.selectedStep.value < upperBound) {
      if (enabling == StepEnabling.sequential) {
        ++currentUser.selectedStep.value;
        if (currentUser.reachedStep.value < currentUser.selectedStep.value) {
          currentUser.reachedStep.value = currentUser.selectedStep.value;
          final isExist =
              await firestore.collection('trainees').doc(userId).get();
          if (isExist.data() != null) {
            firestore
                .collection('trainees')
                .doc(userId)
                .update({'reachedStep': currentUser.reachedStep.value});
          }
        }
      } else {
        currentUser.selectedStep.value = reachedSteps
            .firstWhere((element) => element > currentUser.selectedStep.value);
        final isExist =
            await firestore.collection('trainees').doc(userId).get();
        if (isExist.data() != null) {
          firestore
              .collection('trainees')
              .doc(userId)
              .update({'reachedStep': currentUser.reachedStep.value});
        }
      }
    }
  }
}

enum StepEnabling { sequential, individual }
