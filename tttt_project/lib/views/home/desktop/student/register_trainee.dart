// ignore_for_file: use_build_context_synchronously, dead_code

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:tttt_project/data/constant.dart';
import 'package:get/get.dart';
import 'package:tttt_project/models/credit_model.dart';
import 'package:tttt_project/models/register_trainee_model.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/widgets/custom_button.dart';
import 'package:tttt_project/widgets/dropdown_style.dart';
import 'package:tttt_project/widgets/footer.dart';
import 'package:tttt_project/widgets/header.dart';
import 'package:tttt_project/widgets/loading.dart';
import 'package:tttt_project/widgets/user_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/widgets/menu/menu_left.dart';

class RegisterTrainee extends StatefulWidget {
  const RegisterTrainee({Key? key}) : super(key: key);

  @override
  State<RegisterTrainee> createState() => _RegisterTraineeState();
}

class _RegisterTraineeState extends State<RegisterTrainee> {
  final currentUser = Get.put(UserController());
  List<String> dshk = [
    HocKy.hk1,
    HocKy.hk2,
    HocKy.hk3,
  ];
  List<NamHoc> dsnh = [NamHoc.n2021, NamHoc.n2122, NamHoc.n2223, NamHoc.n2324];
  List<CreditModel> ds = [
    CreditModel(
        id: 'CT215H', name: 'Thực tập thực tế - CNTT (CLC)', course: '45'),
    CreditModel(id: "CT471", name: "Thực tập thực tế - CNTT", course: '45'),
    CreditModel(id: "CT472", name: "Thực tập thực tế - HTTT", course: '45'),
    CreditModel(id: 'CT473', name: 'Thực tập thực tế - KHMT', course: '45'),
    CreditModel(id: "CT474", name: "Thực tập thực tế - KTPM", course: '45'),
    CreditModel(id: "CT475", name: "Thực tập thực tế - THUD", course: '45'),
    CreditModel(id: "CT476", name: "Thực tập thực tế - TT&MMT", course: '45'),
  ];
  List<CreditModel> dshp = [];
  CreditModel selectedHP = CreditModel(id: '', name: '', course: '');
  // CreditModel? selectedHP;
  String selectedHK = '';
  NamHoc selectedNH = NamHoc(start: '', end: '');
  int upperBound = 4;
  Set<int> reachedSteps = <int>{0, 1, 2, 3, 4};
  String? userId;
  @override
  void initState() {
    getUserData();
    super.initState();
  }

  getUserData() async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    bool? isLoggedIn = sharedPref.getBool("isLoggedIn");
    userId = sharedPref
        .getString(
          'userId',
        )
        .toString();
    if (isLoggedIn == true) {
      currentUser.setCurrentUser(
        setMenuSelected: sharedPref.getInt('menuSelected'),
      );
      DocumentSnapshot<Map<String, dynamic>> isExistUser =
          await GV.usersCol.doc(userId).get();
      if (isExistUser.data() != null) {
        final loadUser = UserModel.fromMap(isExistUser.data()!);
        DocumentSnapshot<Map<String, dynamic>> isExitTrainee =
            await GV.traineesCol.doc(userId).get();
        if (isExitTrainee.data() != null) {
          final loadTrainee =
              RegisterTraineeModel.fromMap(isExitTrainee.data()!);
          currentUser.setCurrentUser(
            setUid: loadUser.uid,
            setUserId: loadUser.userId,
            setName: loadUser.name,
            setClassName: loadUser.className,
            setCourse: loadUser.course,
            setGroup: loadUser.group,
            setMajor: loadUser.major,
            setEmail: loadUser.email,
            setIsRegistered: loadUser.isRegistered,
            setActiveStep: loadTrainee.reachedStep,
            setReachedStep: loadTrainee.reachedStep,
          );
        } else {
          currentUser.setCurrentUser(
            setUid: loadUser.uid,
            setUserId: loadUser.userId,
            setName: loadUser.name,
            setClassName: loadUser.className,
            setCourse: loadUser.course,
            setGroup: loadUser.group,
            setMajor: loadUser.major,
            setEmail: loadUser.email,
            setIsRegistered: loadUser.isRegistered,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.cyan.shade50,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: StreamBuilder(
          stream: GV.usersCol.doc(userId).snapshots(),
          builder: (context, snapshotUser) {
            if (snapshotUser.hasData &&
                snapshotUser.data != null &&
                snapshotUser.connectionState == ConnectionState.active) {
              UserModel? loadUser;
              if (snapshotUser.data!.data() != null) {
                loadUser = UserModel.fromMap(snapshotUser.data!.data()!);
              }
              return Column(
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
                        Expanded(
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
                                  height: 35,
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
                                        "Đăng ký thực tập thực tế",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Obx(
                                      () => EasyStepper(
                                        activeStep:
                                            currentUser.activeStep.value,
                                        maxReachedStep:
                                            currentUser.reachedStep.value,
                                        lineStyle: const LineStyle(
                                          lineLength: 100,
                                          lineThickness: 1,
                                          lineSpace: 5,
                                        ),
                                        stepRadius: 20,
                                        unreachedStepIconColor: Colors.black87,
                                        unreachedStepBorderColor:
                                            Colors.black54,
                                        unreachedStepTextColor: Colors.black,
                                        showLoadingAnimation: false,
                                        steps: [
                                          EasyStep(
                                            icon: const Icon(Icons.edit_square),
                                            customTitle: Text(
                                              'Đăng ký',
                                              style: TextStyle(
                                                  color: currentUser.activeStep
                                                              .value ==
                                                          0
                                                      ? Colors.black
                                                      : Colors.blue.shade900,
                                                  fontWeight: currentUser
                                                              .activeStep
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
                                              'Tìm công ty',
                                              style: TextStyle(
                                                  color: currentUser.activeStep
                                                              .value ==
                                                          1
                                                      ? Colors.black
                                                      : Colors.blue.shade900,
                                                  fontWeight: currentUser
                                                              .activeStep
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
                                            icon: const Icon(
                                                CupertinoIcons.desktopcomputer),
                                            customTitle: Text(
                                              'Thực tập',
                                              style: TextStyle(
                                                  color: currentUser.activeStep
                                                              .value ==
                                                          2
                                                      ? Colors.black
                                                      : Colors.blue.shade900,
                                                  fontWeight: currentUser
                                                              .activeStep
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
                                                  color: currentUser.activeStep
                                                              .value ==
                                                          3
                                                      ? Colors.black
                                                      : Colors.blue.shade900,
                                                  fontWeight: currentUser
                                                              .activeStep
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
                                              CupertinoIcons.checkmark_alt,
                                              grade: 5,
                                            ),
                                            customTitle: Text(
                                              'Kết quả',
                                              style: TextStyle(
                                                  color: currentUser.activeStep
                                                              .value ==
                                                          4
                                                      ? Colors.black
                                                      : Colors.blue.shade900,
                                                  fontWeight: currentUser
                                                              .activeStep
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
                                        onStepReached: (index) {
                                          setState(() => currentUser
                                              .activeStep.value = index);
                                          GV.traineesCol.doc(userId).update({
                                            'reachedStep':
                                                currentUser.reachedStep.value
                                          });
                                        },
                                      ),
                                    ),
                                    const Divider(
                                      thickness: 0.1,
                                      height: 0,
                                      color: Colors.black,
                                    ),
                                    StreamBuilder(
                                      stream: GV.traineesCol
                                          .doc(userId)
                                          .snapshots(),
                                      builder: (context, snapshotTrainee) {
                                        if (snapshotTrainee.hasData &&
                                            snapshotTrainee.connectionState ==
                                                ConnectionState.active) {
                                          final loadTrainee =
                                              RegisterTraineeModel.fromMap(
                                                  snapshotTrainee.data!
                                                      .data()!);
                                          return Obx(
                                            () => switch (
                                                currentUser.activeStep.value) {
                                              1 => _regisFirm(),
                                              2 => _trainee(),
                                              3 => _submit(),
                                              4 => _completed(),
                                              _ => loadUser != null &&
                                                      loadUser.isRegistered ==
                                                          true
                                                  ? _infoCredit(loadTrainee)
                                                  : _regisCredit(),
                                            },
                                          );
                                        } else {
                                          return const Loading();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Footer(),
                ],
              );
            } else {
              return Column(
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
                        Expanded(
                          child: Container(
                            constraints:
                                BoxConstraints(minHeight: screenHeight * 0.7),
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
                                  height: 35,
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
                                        "Đăng ký thực tập thực tế",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox.shrink(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Footer(),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _regisCredit() {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return StreamBuilder(
      stream: GV.creditsCol.snapshots(),
      builder: (context, snapshotCredit) {
        if (snapshotCredit.hasData &&
            snapshotCredit.connectionState == ConnectionState.active) {
          // List<CreditModel> dshp = [];
          // if (snapshotCredit.data != null) {
          //   snapshotCredit.data!.docs.forEach((element) {
          //     dshp.add(CreditModel.fromMap(element.data()));
          //   });
          // }
          return Container(
            padding: const EdgeInsets.only(left: 50, right: 50, top: 15),
            color: Colors.grey.shade400,
            constraints: BoxConstraints(
                minHeight: screenHeight * 0.5, maxWidth: screenWidth * 0.5),
            child: Column(
              children: [
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
                        items: ds
                            .map((CreditModel hp) =>
                                DropdownMenuItem<CreditModel>(
                                  value: hp,
                                  child: Text(
                                    "${hp.id} - ${hp.name}",
                                    style: DropdownStyle.itemStyle,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        value: selectedHP.id.isNotEmpty ? selectedHP : null,
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
                        value: selectedHK.isNotEmpty ? selectedHK : null,
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
                        value: selectedNH.start.isNotEmpty &&
                                selectedNH.end.isNotEmpty
                            ? selectedNH
                            : null,
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
                    if (selectedHP.id.isNotEmpty &&
                        selectedHP.name.isNotEmpty &&
                        selectedHK.isNotEmpty &&
                        selectedNH.start.isNotEmpty &&
                        selectedNH.end.isNotEmpty) {
                      final registerTraineeModel = RegisterTraineeModel(
                          creditId: selectedHP.id,
                          term: selectedHK,
                          creditName: selectedHP.name,
                          yearStart: selectedNH.start,
                          uid: userId!,
                          yearEnd: selectedNH.end,
                          course: currentUser.course.value,
                          studentName: currentUser.name.value,
                          reachedStep: 0);
                      currentUser.reachedStep.value = 0;
                      currentUser.activeStep.value = 1;
                      final docRegister =
                          GV.traineesCol.doc(registerTraineeModel.uid);
                      final json = registerTraineeModel.toMap();
                      await docRegister.set(json);
                      GV.usersCol
                          .doc(registerTraineeModel.uid)
                          .update({'isRegistered': true});
                      currentUser.setCurrentUser(setIsRegistered: true);
                      EasyLoading.showError('Đã đăng ký!');
                    } else {
                      EasyLoading.showError('Chọn đầy đủ thông tin!');
                    }
                  },
                ),
                const SizedBox(height: 35),
                _nextStep(StepEnabling.sequential),
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _infoCredit(RegisterTraineeModel loadTrainee) {
    // double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        children: [
          Container(
            color: Colors.amber,
            child: const Text(
              'Thông tin học phần',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: screenWidth * 0.25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mã HP: ${loadTrainee.creditId}'),
                Text('Tên HP: ${loadTrainee.creditName}'),
                Text('Học kỳ: ${loadTrainee.term}'),
                Text(
                    'Năm học: ${loadTrainee.yearStart} - ${loadTrainee.yearEnd}'),
              ],
            ),
          ),
          const SizedBox(height: 35),
          _nextStep(StepEnabling.sequential),
        ],
      ),
    );
  }

  Widget _regisFirm() {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    bool isRegisFirm = false;
    return isRegisFirm
        ? Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Column(
              children: [
                Container(
                  color: Colors.amber,
                  child: const Text(
                    'Công ty đã đăng ký',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: screenWidth * 0.25,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tên công ty : Abc'),
                      Text('Người đại diện: Nguyễn Văn A'),
                      Text(
                          'Địa chỉ: Ninh Kiều, Cần Thơ Địa chỉ: Ninh Kiều, Cần Thơ Địa chỉ: Ninh Kiều, Cần Thơ'),
                      Text('Điện thoại: 0987654321'),
                    ],
                  ),
                ),
                const SizedBox(height: 35),
                _nextStep(StepEnabling.sequential),
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(top: 35),
            child: Column(
              children: [
                CustomButton(
                  text: "Các công ty ",
                  width: screenWidth * 0.1,
                  height: screenHeight * 0.07,
                  onTap: () async {
                    currentUser.menuSelected.value = 4;
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setInt('menuSelected', 4);
                    Navigator.pushNamed(context, pageSinhVien[4]);
                  },
                ),
              ],
            ),
          );
  }

  Widget _trainee() {
    // double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        children: [
          Container(
            color: Colors.amber,
            child: const Text(
              'Phân công thực tập',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: screenWidth * 0.35,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cán bộ hướng dẫn: Trần Văn B'),
                const Text('Thời gian thực tập: 15/05/2023 - 08/07/2023'),
                const Text('Ngày phân công: 15/05/2023'),
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
                                'Tuan',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                          Container(
                              padding: const EdgeInsets.all(10),
                              child: const Text(
                                'Noi dung',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: const Text(
                              'So buoi',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            child: const Column(
                              children: [
                                Text(
                                  '1',
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  '15/05/2023 - 21/06/2023',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(5),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 5),
                                  child: Text(
                                      'Tìm hiểu tài liệu về FVM, Get Cli.'),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 5),
                                  child: Text(
                                      'Tìm hiểu về quản lý trạng thái - BloC.'),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 5),
                                  child: Text('Tìm hiểu về dio, retrofit.'),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(5),
                            child: const Column(
                              children: [
                                Text(
                                  '10',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 35),
          _nextStep(StepEnabling.sequential),
        ],
      ),
    );
  }

  Widget _submit() {
    // double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        children: [
          Container(
            color: Colors.amber,
            child: const Text(
              'Nộp tài liệu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: screenWidth * 0.25,
            child: const Column(children: []),
          ),
          const SizedBox(height: 35),
          _nextStep(StepEnabling.sequential),
        ],
      ),
    );
  }

  Widget _completed() {
    // double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Column(
        children: [
          Container(
            color: Colors.amber,
            child: const Text(
              'Hoàn thành',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            width: screenWidth * 0.25,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kết quả thực tập'),
              ],
            ),
          ),
          const SizedBox(height: 35),
          _nextStep(StepEnabling.sequential),
        ],
      ),
    );
  }

  bool _allowTabStepping(int index, StepEnabling enabling) {
    return enabling == StepEnabling.sequential
        ? index <= currentUser.reachedStep.value
        : reachedSteps.contains(index);
  }

  Widget _nextStep(StepEnabling enabling) {
    return IconButton(
      onPressed: () {
        if (currentUser.activeStep.value < upperBound) {
          setState(() {
            if (enabling == StepEnabling.sequential) {
              ++currentUser.activeStep.value;
              if (currentUser.reachedStep.value <
                  currentUser.activeStep.value) {
                currentUser.reachedStep.value = currentUser.activeStep.value;
                GV.traineesCol
                    .doc(userId)
                    .update({'reachedStep': currentUser.reachedStep.value});
              }
            } else {
              currentUser.activeStep.value = reachedSteps.firstWhere(
                  (element) => element > currentUser.activeStep.value);
              GV.traineesCol
                  .doc(userId)
                  .update({'reachedStep': currentUser.reachedStep.value});
            }
          });
        }
      },
      icon: const Icon(Icons.arrow_forward_ios),
    );
  }
}

enum StepEnabling { sequential, individual }
