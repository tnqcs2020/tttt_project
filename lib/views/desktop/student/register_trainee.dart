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
import 'package:tttt_project/data/constant.dart';
import 'package:tttt_project/models/credit_model.dart';
import 'package:tttt_project/models/firm_model.dart';
import 'package:tttt_project/models/register_trainee_model.dart';
import 'package:tttt_project/models/submit_bodel.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/models/work_model.dart';
import 'package:tttt_project/widgets/custom_button.dart';
import 'package:tttt_project/widgets/dropdown_style.dart';
import 'package:tttt_project/widgets/footer.dart';
import 'package:tttt_project/widgets/header.dart';
import 'package:tttt_project/widgets/loading.dart';
import 'package:tttt_project/widgets/menu/menu_left.dart';
import 'package:tttt_project/widgets/user_controller.dart';

class RegisterTrainee extends StatefulWidget {
  const RegisterTrainee({Key? key}) : super(key: key);

  @override
  State<RegisterTrainee> createState() => _RegisterTraineeState();
}

class _RegisterTraineeState extends State<RegisterTrainee> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final currentUser = Get.put(UserController());
  List<String> dshk = [
    HocKy.hk1,
    HocKy.hk2,
    HocKy.hk3,
  ];
  List<NamHoc> dsnh = [NamHoc.n2122, NamHoc.n2223, NamHoc.n2324];
  List<CreditModel> dshp = [];
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
  CreditModel selectedHP = CreditModel(id: '', name: '', course: '');
  String selectedHK = '';
  NamHoc selectedNH = NamHoc(start: '', end: '');
  int upperBound = 4;
  Set<int> reachedSteps = <int>{0, 1, 2, 3, 4};
  String? userId;
  UserModel user = UserModel();
  RegisterTraineeModel trainee = RegisterTraineeModel();
  List<PlatformFile> fileSelect = [];
  List<FileModel> submits = [];
  List<FileModel> files = [];

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
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
          await firestore.collection('users').doc(userId).get();
      if (isExistUser.data() != null) {
        final loadUser = UserModel.fromMap(isExistUser.data()!);
        setState(() {
          user = loadUser;
        });
        DocumentSnapshot<Map<String, dynamic>> isExitSubmit =
            await firestore.collection('submits').doc(userId).get();
        if (isExitSubmit.data() != null) {
          final loadSubmit = SubmitModel.fromMap(isExitSubmit.data()!);
          setState(() {
            files = loadSubmit.files ?? [];
          });
        }
        DocumentSnapshot<Map<String, dynamic>> isExitTrainee =
            await firestore.collection('trainees').doc(userId).get();
        if (isExitTrainee.data() != null) {
          final loadTrainee =
              RegisterTraineeModel.fromMap(isExitTrainee.data()!);
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
                                  "Quản lý thực tập thực tế",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          currentUser.loadIn.isTrue
                              ? Column(
                                  children: [
                                    Obx(
                                      () => EasyStepper(
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
                                            icon: const Icon(
                                                CupertinoIcons.desktopcomputer),
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
                                        onStepReached: (index) {
                                          setState(() => currentUser
                                              .selectedStep.value = index);
                                          firestore
                                              .collection('trainees')
                                              .doc(userId)
                                              .update({
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
                                    Obx(
                                      () => switch (
                                          currentUser.selectedStep.value) {
                                        1 => _regisFirm(),
                                        2 => _trainee(),
                                        3 => _submit(),
                                        4 => _completed(),
                                        _ => user.userId != null
                                            ? _infoCredit(trainee)
                                            : _regisCredit(),
                                      },
                                    ),
                                  ],
                                )
                              : const Padding(
                                  padding: EdgeInsets.only(top: 200),
                                  child: Loading(),
                                ),
                        ],
                      ),
                    )),
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
                      .map((CreditModel hp) => DropdownMenuItem<CreditModel>(
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
                  value:
                      selectedNH.start.isNotEmpty && selectedNH.end.isNotEmpty
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
                  userId: userId ?? '',
                  yearEnd: selectedNH.end,
                  course: currentUser.course.value,
                  studentName: currentUser.userName.value,
                  reachedStep: 0,
                  listRegis: [],
                );
                currentUser.reachedStep.value = 0;
                final docRegister = firestore
                    .collection('trainees')
                    .doc(registerTraineeModel.userId);
                final json = registerTraineeModel.toMap();
                await docRegister.set(json);
                GV.success(context: context, message: 'Đã đăng ký!');
                _nextStep(StepEnabling.sequential);
              } else {
                GV.error(context: context, message: 'Chọn đầy đủ thông tin!');
              }
            },
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
        ],
      ),
    );
  }

  Widget _regisFirm() {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return StreamBuilder(
        stream: firestore.collection('trainees').doc(userId).snapshots(),
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
                                width: screenWidth * 0.25,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Tên công ty: ${firm.firmName!}'),
                                    Text('Người đại diện: ${firm.owner!}'),
                                    Text('Số điện thoại: ${firm.phone!}'),
                                    Text('Email: ${firm.email!}'),
                                    Text('Địa chỉ: ${firm.address!}'),
                                    Text('Mô tả: ${firm.describe!}'),
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
                : loadTrainee.listRegis != null &&
                        loadTrainee.listRegis!.isNotEmpty
                    ? listAccepted.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Column(
                              children: [
                                Container(
                                  color: Colors.amber,
                                  child: const Text(
                                    'Các công ty chấp nhận thực tập',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(
                                  width: screenWidth * 0.5,
                                  child: ListView.separated(
                                    itemCount: listAccepted.length,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return StreamBuilder(
                                          stream: firestore
                                              .collection('firms')
                                              .doc(listAccepted[index].firmId)
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            if (snapshot.data != null &&
                                                snapshot.data!.data() != null) {
                                              FirmModel firm =
                                                  FirmModel.fromMap(
                                                      snapshot.data!.data()!);
                                              return Card(
                                                elevation: 5,
                                                child: ListTile(
                                                  title:
                                                      Text('${firm.firmName}'),
                                                  subtitle: Text(
                                                    'Vị trí ứng tuyển: ${listAccepted[index].jobName}',
                                                  ),
                                                  trailing: listAccepted[index]
                                                              .status ==
                                                          TrangThai.accept
                                                      ? const Text(
                                                          'Chờ xác nhận',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        )
                                                      : Text(listAccepted[index]
                                                          .status!),
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      barrierColor:
                                                          Colors.black12,
                                                      builder: (context) {
                                                        return Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                            top: screenHeight *
                                                                0.06,
                                                            bottom:
                                                                screenHeight *
                                                                    0.02,
                                                            left: screenWidth *
                                                                0.27,
                                                            right: screenWidth *
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
                                                                  height: 50,
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          10,
                                                                      horizontal:
                                                                          10),
                                                                  child: Row(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      const Expanded(
                                                                        child: Text(
                                                                            'Chi tiết tuyển dụng',
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold),
                                                                            textAlign: TextAlign.center),
                                                                      ),
                                                                      IconButton(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              bottom:
                                                                                  1),
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                          icon:
                                                                              const Icon(Icons.close))
                                                                    ],
                                                                  ),
                                                                ),
                                                                titlePadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                shape:
                                                                    Border.all(
                                                                        width:
                                                                            0.5),
                                                                content:
                                                                    ConstrainedBox(
                                                                  constraints: BoxConstraints(
                                                                      minWidth:
                                                                          screenWidth *
                                                                              0.35),
                                                                  child: Form(
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: <Widget>[
                                                                        Text(
                                                                            'Tên công ty: ${firm.firmName}'),
                                                                        Text(
                                                                            'Người đại diện: ${firm.owner}'),
                                                                        Text(
                                                                            'Số điện thoại: ${firm.phone}'),
                                                                        Text(
                                                                            'Email: ${firm.email}'),
                                                                        Text(
                                                                            'Địa chỉ: ${firm.address}'),
                                                                        Text(
                                                                            'Mô tả: ${firm.describe}'),
                                                                        Text(
                                                                            'Vị trí ứng tuyển: ${listAccepted[index].jobName} '),
                                                                        Text(
                                                                            'Ngày bắt đầu: ${GV.readTimestamp(listAccepted[index].traineeStart!)} - Ngày kết thúc:  ${GV.readTimestamp(listAccepted[index].traineeEnd!)}'),
                                                                        Text(
                                                                            'Ngày ứng tuyển: ${GV.readTimestamp(listAccepted[index].createdAt!)}'),
                                                                        Text(
                                                                            'Ngày duyệt: ${GV.readTimestamp(listAccepted[index].repliedAt!)}'),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                actions: [
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () async {
                                                                      var loadCBHD = await firestore
                                                                          .collection(
                                                                              'users')
                                                                          .doc(firm
                                                                              .firmId)
                                                                          .get();
                                                                      final cbhdName =
                                                                          UserModel.fromMap(loadCBHD.data()!)
                                                                              .userName;
                                                                      final plan =
                                                                          PlanModel(
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
                                                                      for (int i =
                                                                              0;
                                                                          i < listRegis!.length;
                                                                          i++) {
                                                                        if (listRegis[i].userId ==
                                                                            currentUser.userId.value) {
                                                                          listRegis[i].isConfirmed =
                                                                              true;
                                                                          plan.traineeStart =
                                                                              listRegis[i].traineeStart;
                                                                          plan.traineeEnd =
                                                                              listRegis[i].traineeEnd;
                                                                        }
                                                                      }
                                                                      firestore
                                                                          .collection(
                                                                              'plans')
                                                                          .doc(
                                                                              userId)
                                                                          .set(plan
                                                                              .toMap());
                                                                      firestore
                                                                          .collection(
                                                                              'firms')
                                                                          .doc(firm
                                                                              .firmId)
                                                                          .update({
                                                                        'listRegis': listRegis
                                                                            .map((i) =>
                                                                                i.toMap())
                                                                            .toList()
                                                                      });
                                                                      final listUserRegis =
                                                                          loadTrainee
                                                                              .listRegis;
                                                                      for (int i =
                                                                              0;
                                                                          i < listUserRegis!.length;
                                                                          i++) {
                                                                        if (listUserRegis[i].firmId ==
                                                                            firm.firmId) {
                                                                          listUserRegis[i].isConfirmed =
                                                                              true;
                                                                        }
                                                                      }
                                                                      firestore
                                                                          .collection(
                                                                              'trainees')
                                                                          .doc(
                                                                              userId)
                                                                          .update({
                                                                        'listRegis': listUserRegis
                                                                            .map((i) =>
                                                                                i.toMap())
                                                                            .toList(),
                                                                      });
                                                                      Navigator.pop(
                                                                          context);
                                                                      _nextStep(
                                                                          StepEnabling
                                                                              .sequential);
                                                                      GV.success(
                                                                          context:
                                                                              context,
                                                                          message:
                                                                              'Đã xác nhận công ty thực tập');
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                      'Xác nhận',
                                                                      style: TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold),
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
                                                                        color: Colors
                                                                            .red,
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
                                              return const SizedBox.shrink();
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
                              children: [
                                const Text(
                                    'Chưa có công ty phê duyệt đăng ký của bạn.'),
                                const SizedBox(height: 20),
                                CustomButton(
                                  text: "Ứng tuyển thêm",
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
                            const Text('Bạn chưa đăng ký công ty'),
                            const SizedBox(height: 20),
                            CustomButton(
                              text: "Tìm công ty ngay",
                              width: screenWidth * 0.1,
                              height: screenHeight * 0.07,
                              onTap: () async {
                                currentUser.menuSelected.value = 3;
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setInt('menuSelected', 3);
                                Navigator.pushNamed(context, pageSinhVien[3]);
                              },
                            ),
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

  Widget _trainee() {
    // double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return StreamBuilder(
        stream: firestore.collection('plans').doc(userId).snapshots(),
        builder: (context, snapshotPlan) {
          if (snapshotPlan.hasData &&
              snapshotPlan.data != null &&
              snapshotPlan.connectionState == ConnectionState.active) {
            final plan = PlanModel.fromMap(snapshotPlan.data!.data()!);
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
                  const SizedBox(height: 15),
                  IconButton(
                    onPressed: () {
                      _nextStep(StepEnabling.sequential);
                    },
                    icon: const Icon(Icons.arrow_forward_outlined),
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
          Container(
            color: Colors.amber,
            child: const Text(
              'Nộp tài liệu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
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
                    const Text("Đến hết ngày 15/11/2023"),
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
                                                        height: 50,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 35,
                      child: ElevatedButton(
                        onPressed: () async {
                          await selectMultipleFiles();
                          await uploadMultipleFiles();
                          _nextStep(StepEnabling.sequential);
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
                                style: TextStyle(fontWeight: FontWeight.bold),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      AlertDialog(
                                        title: Container(
                                          color: Colors.blue.shade600,
                                          height: 50,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 10),
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Xóa tài liệu',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
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
                                                fontWeight: FontWeight.bold,
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
                'Hoàn thành',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 15),
          SizedBox(
            width: screenWidth * 0.25,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Học phần: '),
                Text('Công ty:'),
                Text('Cán bộ:'),
                Text('Cố vấn:'),
                Text('Trạng thái: Đang chờ chấm điểm'),
                Text('Điểm:'),
                Text('Kết quả: Hoàn thành môn học')
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

  _nextStep(StepEnabling enabling) {
    if (currentUser.selectedStep.value < upperBound) {
      if (enabling == StepEnabling.sequential) {
        ++currentUser.selectedStep.value;
        if (currentUser.reachedStep.value < currentUser.selectedStep.value) {
          currentUser.reachedStep.value = currentUser.selectedStep.value;
          firestore
              .collection('trainees')
              .doc(userId)
              .update({'reachedStep': currentUser.reachedStep.value});
        }
      } else {
        currentUser.selectedStep.value = reachedSteps
            .firstWhere((element) => element > currentUser.selectedStep.value);
        firestore
            .collection('trainees')
            .doc(userId)
            .update({'reachedStep': currentUser.reachedStep.value});
      }
    }
  }
}

enum StepEnabling { sequential, individual }
