// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/common/constant.dart';
import 'package:tttt_project/common/date_time_extension.dart';
import 'package:tttt_project/models/cv_model.dart';
import 'package:tttt_project/models/firm_model.dart';
import 'package:tttt_project/models/register_trainee_model.dart';
import 'package:tttt_project/models/setting_trainee_model.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/models/plan_work_model.dart';
import 'package:tttt_project/widgets/custom_button.dart';
import 'package:tttt_project/widgets/custom_radio.dart';
import 'package:tttt_project/widgets/field_detail.dart';
import 'package:tttt_project/widgets/line_detail.dart';
import 'package:tttt_project/widgets/loading.dart';
import 'package:tttt_project/common/user_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyCV extends StatefulWidget {
  const MyCV({
    super.key,
  });

  @override
  State<MyCV> createState() => _MyCVState();
}

class _MyCVState extends State<MyCV> {
  final GlobalKey<FormState> formKey1 = GlobalKey<FormState>();
  final GlobalKey<FormState> formKey2 = GlobalKey<FormState>();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController descriptionCtrl = TextEditingController();
  final currentUser = Get.put(UserController());
  String? userId;
  ValueNotifier<bool> method = ValueNotifier(true);
  List<FirmModel> firms = [];
  RegisterTraineeModel trainee = RegisterTraineeModel();
  bool isTrainee = false;
  ValueNotifier<bool> isLoading = ValueNotifier(true);
  bool isRegistered = false;
  SettingTraineeModel setting = SettingTraineeModel();
  List<ValueNotifier<int>> tieuChi = [];

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  getUserData() async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    userId = sharedPref.getString("userId");
    bool? isLoggedIn = sharedPref.getBool("isLoggedIn");
    if (isLoggedIn == true) {
      currentUser.setCurrentUser(
        setMenuSelected: sharedPref.getInt('menuSelected'),
      );
      var loadData = await firestore.collection('firms').get();
      if (loadData.docs.isNotEmpty) {
        firms = loadData.docs.map((e) => FirmModel.fromMap(e.data())).toList();
      }
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
      DocumentSnapshot<Map<String, dynamic>> isExistUser =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
      if (isExistUser.data() != null) {
        final loadUser = UserModel.fromMap(isExistUser.data()!);
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
        DocumentSnapshot<Map<String, dynamic>> isExitTrainee =
            await firestore.collection('trainees').doc(userId).get();
        if (isExitTrainee.data() != null) {
          setState(() {
            isRegistered = true;
          });
          final loadTrainee =
              RegisterTraineeModel.fromMap(isExitTrainee.data()!);
          if (loadTrainee.listRegis != null) {
            loadTrainee.listRegis!.forEach((e) {
              if (e.isConfirmed == true) {
                isTrainee = true;
              }
            });
          }
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
              final setting = SettingTraineeModel.fromMap(
                  isExistSettingTrainee.docs.first.data());
              firestore.collection('trainees').doc(userId).update({
                'traineeStart': setting.traineeStart,
                'traineeEnd': setting.traineeEnd,
              });
              setState(() {
                loadTrainee.traineeStart = setting.traineeStart;
                loadTrainee.traineeEnd = setting.traineeEnd;
              });
            }
          }
          setState(() {
            trainee = loadTrainee;
          });
        }
      }
    }
    isLoading.value = false;
    await suggestTFIDF();
    // currentUser.loadIn.value = true;
  }

  Future suggestTFIDF() async {
    currentUser.loadIn.value = false;
    final queryParameters = {
      'userId': '$userId',
    };
    final uri = Uri.https(
        'suggest-firms-server.onrender.com', '/suggest-tfidf', queryParameters);
    try {
      final response = await http.post(uri);
      if (response.statusCode == 200) {
        var data = json.decode(response.body) as List;
        List<FirmSuggestModel> temp = [];
        for (var element in data) {
          FirmSuggestModel firmSuggest = FirmSuggestModel.fromMap(element);
          if (firmSuggest.similarityScore! > 0) {
            temp.add(firmSuggest);
          }
        }
        currentUser.suggest.value = temp;
      }
    } catch (e) {
      print(e);
    }
    currentUser.loadIn.value = true;
  }

  Future suggestKNN() async {
    currentUser.loadIn.value = false;
    final queryParameters = {
      'userId': '$userId',
    };
    final uri = Uri.https(
        'suggest-firms-server.onrender.com', '/suggest-knn', queryParameters);
    try {
      final response = await http.post(uri);
      if (response.statusCode == 200) {
        var data = json.decode(response.body) as List;
        List<FirmSuggestModel> temp = [];
        for (var element in data) {
          FirmSuggestModel firmSuggest = FirmSuggestModel.fromMap(element);
          temp.add(firmSuggest);
        }
        currentUser.suggest.value = temp;
      }
    } catch (e) {
      print(e);
    }
    currentUser.loadIn.value = true;
  }

  @override
  void dispose() {
    descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return ValueListenableBuilder(
        valueListenable: method,
        builder: (context, methodVal, child) {
          return Column(
            children: [
              StreamBuilder(
                  stream:
                      firestore.collection('profiles').doc(userId).snapshots(),
                  builder: (context, snapshot) {
                    CVModel profile = CVModel();
                    tieuChi = [];
                    if (snapshot.data != null &&
                        snapshot.data!.data() != null) {
                      profile = CVModel.fromMap(snapshot.data!.data()!);
                      descriptionCtrl.text = profile.description ?? '';
                      if (profile.language != null || profile.language != 0) {
                        tieuChi.add(ValueNotifier(profile.language!));
                        tieuChi.add(ValueNotifier(profile.programming!));
                        tieuChi.add(ValueNotifier(profile.skillGroup!));
                        tieuChi.add(ValueNotifier(profile.machineAI!));
                        tieuChi.add(ValueNotifier(profile.website!));
                        tieuChi.add(ValueNotifier(profile.mobile!));
                      }
                    } else {
                      descriptionCtrl.text = "";
                      for (int i = 0; i < 7; i++) {
                        tieuChi.add(ValueNotifier(0));
                      }
                    }
                    if (snapshot.hasData && isLoading.value == false) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 50),
                        child: Column(
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  CustomRadio(
                                    title: 'Gợi ý theo mô tả',
                                    onTap: () async {
                                      method.value = true;
                                      if (profile.language != null ||
                                          profile.language != 0) {
                                        tieuChi[0] =
                                            ValueNotifier(profile.language!);
                                        tieuChi[1] =
                                            ValueNotifier(profile.programming!);
                                        tieuChi[2] =
                                            ValueNotifier(profile.skillGroup!);
                                        tieuChi[3] =
                                            ValueNotifier(profile.machineAI!);
                                        tieuChi[4] =
                                            ValueNotifier(profile.website!);
                                        tieuChi[5] =
                                            ValueNotifier(profile.mobile!);
                                        descriptionCtrl.text =
                                            profile.description!;
                                      }
                                      await suggestTFIDF();
                                    },
                                    selected: method.value == true,
                                  ),
                                  CustomRadio(
                                    title: 'Gợi ý theo các kỹ năng',
                                    onTap: () async {
                                      method.value = false;
                                      if (profile.language != null ||
                                          profile.language != 0) {
                                        tieuChi[0] =
                                            ValueNotifier(profile.language!);
                                        tieuChi[1] =
                                            ValueNotifier(profile.programming!);
                                        tieuChi[2] =
                                            ValueNotifier(profile.skillGroup!);
                                        tieuChi[3] =
                                            ValueNotifier(profile.machineAI!);
                                        tieuChi[4] =
                                            ValueNotifier(profile.website!);
                                        tieuChi[5] =
                                            ValueNotifier(profile.mobile!);
                                        descriptionCtrl.text =
                                            profile.description!;
                                      }
                                      await suggestKNN();
                                    },
                                    selected: method.value == false,
                                  ),
                                ]),
                            const Divider(),
                            const SizedBox(height: 15),
                            method.value
                                ? Form(
                                    key: formKey1,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        LineDetail(
                                          field: "Mô tả bản thân",
                                          ctrl: descriptionCtrl,
                                          validator: (p0) => p0!.isEmpty
                                              ? 'Không được để trống'
                                              : null,
                                          widthForm: 0.3,
                                        ),
                                      ],
                                    ),
                                  )
                                : Form(
                                    key: formKey2,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: screenWidth * 0.4,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              lineTieuChi(
                                                  title: 'Ngoại ngữ', index: 0),
                                              lineTieuChi(
                                                  title: 'Kỹ năng lập trình',
                                                  index: 1),
                                              lineTieuChi(
                                                  title:
                                                      'Kỹ năng làm việc nhóm',
                                                  index: 2),
                                              lineTieuChi(
                                                  title: 'Máy học, AI',
                                                  index: 3),
                                              lineTieuChi(
                                                  title: 'Website', index: 4),
                                              lineTieuChi(
                                                  title: 'Ứng dụng di động',
                                                  index: 5),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            const SizedBox(height: 45),
                            CustomButton(
                              text: "Lưu và gợi ý công ty",
                              width: screenWidth * 0.1,
                              height: screenHeight * 0.06,
                              onTap: () async {
                                if (method.value) {
                                  if (formKey1.currentState!.validate()) {
                                    DocumentSnapshot<Map<String, dynamic>>
                                        isExistCV = await firestore
                                            .collection('profiles')
                                            .doc(userId)
                                            .get();
                                    if (isExistCV.data() != null &&
                                        descriptionCtrl.text != '') {
                                      final myCV = CVModel(
                                        userId: userId,
                                        description: descriptionCtrl.text,
                                        language: tieuChi[0].value == 0
                                            ? null
                                            : tieuChi[0].value,
                                        programming: tieuChi[1].value == 0
                                            ? null
                                            : tieuChi[1].value,
                                        skillGroup: tieuChi[2].value == 0
                                            ? null
                                            : tieuChi[2].value,
                                        machineAI: tieuChi[3].value == 0
                                            ? null
                                            : tieuChi[3].value,
                                        website: tieuChi[4].value == 0
                                            ? null
                                            : tieuChi[4].value,
                                        mobile: tieuChi[5].value == 0
                                            ? null
                                            : tieuChi[5].value,
                                      );
                                      final json = myCV.toMap();
                                      await firestore
                                          .collection('profiles')
                                          .doc(userId)
                                          .update(json);
                                      await suggestTFIDF();
                                      GV.success(
                                          context: context,
                                          message:
                                              'Thông tin đã được cập nhật.');
                                    } else if (isExistCV.data() == null &&
                                        descriptionCtrl.text != '') {
                                      final myCV = CVModel(
                                        userId: userId,
                                        description: descriptionCtrl.text,
                                        language: tieuChi[0].value == 0
                                            ? null
                                            : tieuChi[0].value,
                                        programming: tieuChi[1].value == 0
                                            ? null
                                            : tieuChi[1].value,
                                        skillGroup: tieuChi[2].value == 0
                                            ? null
                                            : tieuChi[2].value,
                                        machineAI: tieuChi[3].value == 0
                                            ? null
                                            : tieuChi[3].value,
                                        website: tieuChi[4].value == 0
                                            ? null
                                            : tieuChi[4].value,
                                        mobile: tieuChi[5].value == 0
                                            ? null
                                            : tieuChi[5].value,
                                      );
                                      final json = myCV.toMap();
                                      await firestore
                                          .collection('profiles')
                                          .doc(myCV.userId)
                                          .set(json);
                                      await suggestTFIDF();
                                      GV.success(
                                          context: context,
                                          message: 'Đã thêm các thông tin.');
                                    }
                                  }
                                } else {
                                  if (formKey2.currentState!.validate()) {
                                    if (tieuChi[0].value == 0 ||
                                        tieuChi[1].value == 0 ||
                                        tieuChi[2].value == 0 ||
                                        tieuChi[3].value == 0 ||
                                        tieuChi[4].value == 0 ||
                                        tieuChi[5].value == 0) {
                                      GV.error(
                                          context: context,
                                          message:
                                              'Vui lòng chọn đầy đủ các kỹ năng.');
                                    } else {
                                      DocumentSnapshot<Map<String, dynamic>>
                                          isExistCV = await firestore
                                              .collection('profiles')
                                              .doc(userId)
                                              .get();
                                      if (isExistCV.data() != null) {
                                        final myCV = CVModel(
                                          userId: userId,
                                          description: descriptionCtrl.text,
                                          language: tieuChi[0].value,
                                          programming: tieuChi[1].value,
                                          skillGroup: tieuChi[2].value,
                                          machineAI: tieuChi[3].value,
                                          website: tieuChi[4].value,
                                          mobile: tieuChi[5].value,
                                        );
                                        final json = myCV.toMap();
                                        await firestore
                                            .collection('profiles')
                                            .doc(userId)
                                            .update(json);
                                        await suggestKNN();
                                        GV.success(
                                            context: context,
                                            message:
                                                'Thông tin đã được cập nhật.');
                                      } else if (isExistCV.data() == null) {
                                        final myCV = CVModel(
                                          userId: userId,
                                          description: descriptionCtrl.text,
                                          language: tieuChi[0].value,
                                          programming: tieuChi[1].value,
                                          skillGroup: tieuChi[2].value,
                                          machineAI: tieuChi[3].value,
                                          website: tieuChi[4].value,
                                          mobile: tieuChi[5].value,
                                        );
                                        final json = myCV.toMap();
                                        await firestore
                                            .collection('profiles')
                                            .doc(myCV.userId)
                                            .set(json);
                                        await suggestKNN();
                                        GV.success(
                                            context: context,
                                            message: 'Đã thêm các thông tin.');
                                      }
                                    }
                                  }
                                }
                              },
                            ),
                            const SizedBox(height: 25),
                            Obx(
                              () =>
                                  currentUser.suggest.isNotEmpty &&
                                          currentUser.loadIn.isTrue
                                      ? Container(
                                          width: screenWidth * 0.5,
                                          padding:
                                              const EdgeInsets.only(top: 15),
                                          child: ListView.builder(
                                            itemCount:
                                                currentUser.suggest.length,
                                            shrinkWrap: true,
                                            itemBuilder: (context, indexFirm) {
                                              FirmModel firm = FirmModel();
                                              if (firms.isNotEmpty) {
                                                firms.forEach((element) {
                                                  if (currentUser
                                                          .suggest[indexFirm]
                                                          .firmId ==
                                                      element.firmId) {
                                                    firm = element;
                                                  }
                                                });
                                              }
                                              JobRegisterModel check =
                                                  firm.listRegis!.firstWhere(
                                                (element) =>
                                                    element.userId == userId,
                                                orElse: () =>
                                                    JobRegisterModel(),
                                              );
                                              return firm.firmId != null
                                                  ? Card(
                                                      elevation: 5,
                                                      child: ListTile(
                                                        leading: const Icon(
                                                            Icons.house),
                                                        title: Text(
                                                          method.value
                                                              ? '${firm.firmName!} (similarity: ${currentUser.suggest[indexFirm].similarityScore!.toStringAsFixed(2)})'
                                                              : '${firm.firmName!} (distance: ${currentUser.suggest[indexFirm].similarityScore!.toStringAsFixed(2)})',
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        subtitle: Text(
                                                          firm.describe!,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        trailing: check
                                                                    .status ==
                                                                TrangThai.accept
                                                            ? Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  if (check
                                                                          .isConfirmed ==
                                                                      false)
                                                                    Text(check
                                                                        .status!),
                                                                  check.isConfirmed ==
                                                                          false
                                                                      ? const Text(
                                                                          'Chờ xác nhận',
                                                                          style:
                                                                              TextStyle(color: Colors.red),
                                                                        )
                                                                      : const Text(
                                                                          'Công ty thực tập',
                                                                          style:
                                                                              TextStyle(color: Colors.red),
                                                                        ),
                                                                ],
                                                              )
                                                            : check.status ==
                                                                        TrangThai
                                                                            .wait ||
                                                                    check.status ==
                                                                        TrangThai
                                                                            .reject
                                                                ? Text(check
                                                                    .status!)
                                                                : null,
                                                        onTap: () {
                                                          JobRegisterModel
                                                              loadRegis =
                                                              JobRegisterModel();
                                                          currentUser
                                                                  .selectedJob
                                                                  .value =
                                                              JobPositionModel();
                                                          for (var d in firm
                                                              .listRegis!) {
                                                            if (d.userId ==
                                                                userId) {
                                                              currentUser
                                                                      .selectedJob
                                                                      .value =
                                                                  firm.listJob!.firstWhere(
                                                                      (element) =>
                                                                          element
                                                                              .jobId ==
                                                                          d.jobId);
                                                              loadRegis = d;
                                                            }
                                                          }
                                                          showDialog(
                                                            context: context,
                                                            barrierColor:
                                                                Colors.black12,
                                                            barrierDismissible:
                                                                false,
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
                                                                        height: screenHeight *
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
                                                                              width: 30,
                                                                            ),
                                                                            const Expanded(
                                                                              child: Text(
                                                                                'Chi tiết tuyển dụng',
                                                                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                                                                textAlign: TextAlign.center,
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              width: 30,
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
                                                                        constraints: BoxConstraints(
                                                                            minWidth: screenWidth *
                                                                                0.35,
                                                                            maxWidth:
                                                                                screenWidth * 0.5),
                                                                        child:
                                                                            Form(
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: <Widget>[
                                                                              FieldDetail(field: 'Tên công ty', content: '${firm.firmName!}'),
                                                                              FieldDetail(field: 'Người đại diện', content: '${firm.owner != '' ? firm.owner : 'Chưa có thông tin'}'),
                                                                              FieldDetail(field: 'Số điện thoại', content: '${firm.phone != '' ? firm.phone : 'Chưa có thông tin'}'),
                                                                              FieldDetail(field: 'Email', content: '${firm.email != '' ? firm.email : 'Chưa có thông tin'}'),
                                                                              FieldDetail(field: 'Địa chỉ', content: '${firm.address != '' ? firm.address : 'Chưa có thông tin'}'),
                                                                              FieldDetail(field: 'Mô tả', content: '${firm.describe != '' ? firm.describe : 'Chưa có thông tin'}'),
                                                                              const Text(
                                                                                'Yêu cầu kỹ năng (mức độ thông thạo kỹ năng, được đánh giá trên thang điểm từ 1 đến 5)',
                                                                                style: TextStyle(fontWeight: FontWeight.bold),
                                                                              ),
                                                                              if (firm.tieuChi != null)
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(left: 15),
                                                                                  child: Table(
                                                                                    columnWidths: Map.from({
                                                                                      0: const FlexColumnWidth(2),
                                                                                      1: const FlexColumnWidth(2),
                                                                                      2: const FlexColumnWidth(3),
                                                                                    }),
                                                                                    children: [
                                                                                      TableRow(children: [
                                                                                        Row(
                                                                                          children: [
                                                                                            const Text('Ngoại ngữ: '),
                                                                                            Text(
                                                                                              '${firm.tieuChi![0]}',
                                                                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                                                                            )
                                                                                          ],
                                                                                        ),
                                                                                        Row(
                                                                                          children: [
                                                                                            const Text('Kỹ năng lập trình: '),
                                                                                            Text(
                                                                                              '${firm.tieuChi![1]}',
                                                                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                                                                            )
                                                                                          ],
                                                                                        ),
                                                                                        Row(
                                                                                          children: [
                                                                                            const Text('Kỹ năng làm việc nhóm: '),
                                                                                            Text(
                                                                                              '${firm.tieuChi![2]}',
                                                                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                                                                            )
                                                                                          ],
                                                                                        ),
                                                                                      ]),
                                                                                      TableRow(children: [
                                                                                        Row(
                                                                                          children: [
                                                                                            const Text('Máy học, AI: '),
                                                                                            Text(
                                                                                              '${firm.tieuChi![3]}',
                                                                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                                                                            )
                                                                                          ],
                                                                                        ),
                                                                                        Row(
                                                                                          children: [
                                                                                            const Text('Website: '),
                                                                                            Text(
                                                                                              '${firm.tieuChi![4]}',
                                                                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                                                                            )
                                                                                          ],
                                                                                        ),
                                                                                        Row(
                                                                                          children: [
                                                                                            const Text('Ứng dụng di động: '),
                                                                                            Text(
                                                                                              '${firm.tieuChi![5]}',
                                                                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                                                                            )
                                                                                          ],
                                                                                        ),
                                                                                      ]),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              if (setting.settingId != null && DateTime.now().isBeforeTimestamp(setting.traineeStart!)) ...[
                                                                                if (isRegistered == false) ...[
                                                                                  const Text(
                                                                                    'Vị trí tuyển dụng:',
                                                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                                                  ),
                                                                                  for (var job in firm.listJob!)
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(left: 25),
                                                                                      child: ListTile(
                                                                                        dense: true,
                                                                                        contentPadding: EdgeInsets.zero,
                                                                                        title: Text(
                                                                                          '${job.jobName}',
                                                                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                                                                        ),
                                                                                        subtitle: job.describeJob!.isNotEmpty ? Text('${job.describeJob}') : null,
                                                                                      ),
                                                                                    ),
                                                                                  const Padding(
                                                                                    padding: EdgeInsets.only(top: 15),
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Text(
                                                                                          'Bạn cần phải đăng ký thực tập thực tế trước khi ứng tuyển.',
                                                                                          style: TextStyle(
                                                                                            fontSize: 12,
                                                                                            color: Colors.red,
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ] else if (setting.term != trainee.term && setting.traineeStart != trainee.traineeStart) ...[
                                                                                  const Text(
                                                                                    'Vị trí tuyển dụng:',
                                                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                                                  ),
                                                                                  for (var job in firm.listJob!)
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(left: 25),
                                                                                      child: ListTile(
                                                                                        dense: true,
                                                                                        contentPadding: EdgeInsets.zero,
                                                                                        title: Text(
                                                                                          '${job.jobName}',
                                                                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                                                                        ),
                                                                                        subtitle: job.describeJob!.isNotEmpty ? Text('${job.describeJob}') : null,
                                                                                      ),
                                                                                    ),
                                                                                  const Padding(
                                                                                    padding: EdgeInsets.only(top: 15),
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Text(
                                                                                          'Bạn không đăng ký thực tập trong học kỳ này không thể đăng ký.',
                                                                                          style: TextStyle(
                                                                                            fontSize: 12,
                                                                                            color: Colors.red,
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  )
                                                                                ] else if (loadRegis.status == TrangThai.reject) ...[
                                                                                  const Text(
                                                                                    'Vị trí tuyển dụng:',
                                                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                                                  ),
                                                                                  for (var job in firm.listJob!)
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(left: 25),
                                                                                      child: ListTile(
                                                                                        dense: true,
                                                                                        contentPadding: EdgeInsets.zero,
                                                                                        title: Text('${job.jobName}'),
                                                                                        subtitle: job.describeJob!.isNotEmpty ? Text('${job.describeJob}') : null,
                                                                                      ),
                                                                                    ),
                                                                                  const Padding(
                                                                                    padding: EdgeInsets.only(top: 15),
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Text(
                                                                                          'Công ty đã từ chối bạn.',
                                                                                          style: TextStyle(
                                                                                            fontSize: 12,
                                                                                            color: Colors.red,
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  )
                                                                                ] else if (isTrainee && loadRegis.isConfirmed! || (!isTrainee && !loadRegis.isConfirmed! && loadRegis.status == TrangThai.accept)) ...[
                                                                                  const Text(
                                                                                    'Vị trí tuyển dụng:',
                                                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                                                  ),
                                                                                  for (var job in firm.listJob!)
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(left: 25),
                                                                                      child: ListTile(
                                                                                        dense: true,
                                                                                        contentPadding: EdgeInsets.zero,
                                                                                        title: Text(
                                                                                          '${job.jobName}',
                                                                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                                                                        ),
                                                                                        subtitle: job.describeJob!.isNotEmpty ? Text('${job.describeJob}') : null,
                                                                                      ),
                                                                                    ),
                                                                                  if (loadRegis.createdAt != null) FieldDetail(field: 'Vị trí ứng tuyển', content: '${currentUser.selectedJob.value.jobName}'),
                                                                                  if (loadRegis.createdAt != null) FieldDetail(field: 'Ngày ứng tuyển', content: GV.readTimestamp(loadRegis.createdAt!)),
                                                                                  if (loadRegis.repliedAt != null) FieldDetail(field: 'Ngày duyệt', content: GV.readTimestamp(loadRegis.repliedAt!)),
                                                                                  if (trainee.traineeStart != null) FieldDetail(field: 'Thời gian thực tập', content: 'Từ ngày ${GV.readTimestamp(trainee.traineeStart!)} - Đến ngày: ${GV.readTimestamp(trainee.traineeEnd!)}'),
                                                                                  if (loadRegis.isConfirmed!)
                                                                                    const Padding(
                                                                                      padding: EdgeInsets.only(top: 15),
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          Text(
                                                                                            'Công ty bạn đang thực tập.',
                                                                                            style: TextStyle(
                                                                                              fontSize: 12,
                                                                                              color: Colors.red,
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    )
                                                                                ] else if (isTrainee) ...[
                                                                                  const Text(
                                                                                    'Vị trí tuyển dụng:',
                                                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                                                  ),
                                                                                  for (var job in firm.listJob!)
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(left: 25),
                                                                                      child: ListTile(
                                                                                        dense: true,
                                                                                        contentPadding: EdgeInsets.zero,
                                                                                        title: Text(
                                                                                          '${job.jobName}',
                                                                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                                                                        ),
                                                                                        subtitle: job.describeJob!.isNotEmpty ? Text('${job.describeJob}') : null,
                                                                                      ),
                                                                                    ),
                                                                                  if (loadRegis.createdAt != null) FieldDetail(field: 'Vị trí ứng tuyển', content: '${currentUser.selectedJob.value.jobName}'),
                                                                                  if (loadRegis.createdAt != null) FieldDetail(field: 'Ngày ứng tuyển', content: GV.readTimestamp(loadRegis.createdAt!)),
                                                                                  if (loadRegis.repliedAt != null && loadRegis.status == TrangThai.accept) FieldDetail(field: 'Ngày duyệt', content: GV.readTimestamp(loadRegis.repliedAt!)) else if (loadRegis.status != null) FieldDetail(field: 'Trạng thái', content: '${loadRegis.status}'),
                                                                                  const Padding(
                                                                                    padding: EdgeInsets.only(top: 15),
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Text(
                                                                                          'Bạn đã có công ty thực tập không thể ứng tuyển hoặc thay đổi vị trí ứng tuyển.',
                                                                                          style: TextStyle(
                                                                                            fontSize: 12,
                                                                                            color: Colors.red,
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  )
                                                                                ] else if (loadRegis.status == TrangThai.wait || loadRegis.userId == null) ...[
                                                                                  const Text(
                                                                                    'Vị trí tuyển dụng:',
                                                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                                                  ),
                                                                                  for (var data in firm.listJob!)
                                                                                    Obx(
                                                                                      () => CustomRadio(
                                                                                        title: '${data.jobName}',
                                                                                        onTap: () => currentUser.selectedJob.value = data,
                                                                                        subtitle: data.describeJob!.isNotEmpty ? data.describeJob : null,
                                                                                        selected: currentUser.selectedJob.value == data,
                                                                                      ),
                                                                                    ),
                                                                                  if (loadRegis.createdAt != null) FieldDetail(field: 'Ngày ứng tuyển', content: GV.readTimestamp(loadRegis.createdAt!)),
                                                                                ],
                                                                              ] else ...[
                                                                                if (loadRegis.status == TrangThai.reject) ...[
                                                                                  const Text(
                                                                                    'Vị trí tuyển dụng:',
                                                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                                                  ),
                                                                                  for (var job in firm.listJob!)
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(left: 25),
                                                                                      child: ListTile(
                                                                                        dense: true,
                                                                                        contentPadding: EdgeInsets.zero,
                                                                                        title: Text('${job.jobName}'),
                                                                                        subtitle: job.describeJob!.isNotEmpty ? Text('${job.describeJob}') : null,
                                                                                      ),
                                                                                    ),
                                                                                  const Padding(
                                                                                    padding: EdgeInsets.only(top: 15),
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Text(
                                                                                          'Công ty đã từ chối bạn.',
                                                                                          style: TextStyle(
                                                                                            fontSize: 12,
                                                                                            color: Colors.red,
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  )
                                                                                ] else if (isTrainee && loadRegis.isConfirmed! || !isTrainee && !loadRegis.isConfirmed! && loadRegis.status == TrangThai.accept) ...[
                                                                                  const Text(
                                                                                    'Vị trí tuyển dụng:',
                                                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                                                  ),
                                                                                  for (var job in firm.listJob!)
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(left: 25),
                                                                                      child: ListTile(
                                                                                        dense: true,
                                                                                        contentPadding: EdgeInsets.zero,
                                                                                        title: Text(
                                                                                          '${job.jobName}',
                                                                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                                                                        ),
                                                                                        subtitle: job.describeJob!.isNotEmpty ? Text('${job.describeJob}') : null,
                                                                                      ),
                                                                                    ),
                                                                                  if (loadRegis.createdAt != null) FieldDetail(field: 'Vị trí ứng tuyển', content: '${currentUser.selectedJob.value.jobName}'),
                                                                                  if (loadRegis.createdAt != null) FieldDetail(field: 'Ngày ứng tuyển', content: GV.readTimestamp(loadRegis.createdAt!)),
                                                                                  if (loadRegis.repliedAt != null) FieldDetail(field: 'Ngày duyệt', content: GV.readTimestamp(loadRegis.repliedAt!)),
                                                                                  if (trainee.traineeStart != null) FieldDetail(field: 'Thời gian thực tập', content: 'Từ ngày ${GV.readTimestamp(trainee.traineeStart!)} - Đến ngày: ${GV.readTimestamp(trainee.traineeEnd!)}'),
                                                                                ] else if (isTrainee) ...[
                                                                                  const Text(
                                                                                    'Vị trí tuyển dụng:',
                                                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                                                  ),
                                                                                  for (var job in firm.listJob!)
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(left: 25),
                                                                                      child: ListTile(
                                                                                        dense: true,
                                                                                        contentPadding: EdgeInsets.zero,
                                                                                        title: Text(
                                                                                          '${job.jobName}',
                                                                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                                                                        ),
                                                                                        subtitle: job.describeJob!.isNotEmpty ? Text('${job.describeJob}') : null,
                                                                                      ),
                                                                                    ),
                                                                                  if (loadRegis.createdAt != null) FieldDetail(field: 'Vị trí ứng tuyển', content: '${currentUser.selectedJob.value.jobName}'),
                                                                                  if (loadRegis.createdAt != null) FieldDetail(field: 'Ngày ứng tuyển', content: GV.readTimestamp(loadRegis.createdAt!)),
                                                                                  if (loadRegis.repliedAt != null && loadRegis.status == TrangThai.accept) FieldDetail(field: 'Ngày duyệt', content: GV.readTimestamp(loadRegis.repliedAt!)) else if (loadRegis.status != null) FieldDetail(field: 'Trạng thái', content: '${loadRegis.status}'),
                                                                                ] else ...[
                                                                                  const Text(
                                                                                    'Vị trí tuyển dụng:',
                                                                                    style: TextStyle(fontWeight: FontWeight.bold),
                                                                                  ),
                                                                                  for (var job in firm.listJob!)
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(left: 25),
                                                                                      child: ListTile(
                                                                                        dense: true,
                                                                                        contentPadding: EdgeInsets.zero,
                                                                                        title: Text(
                                                                                          '${job.jobName}',
                                                                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                                                                        ),
                                                                                        subtitle: job.describeJob!.isNotEmpty
                                                                                            ? Text(
                                                                                                '${job.describeJob}',
                                                                                              )
                                                                                            : null,
                                                                                      ),
                                                                                    ),
                                                                                ],
                                                                                isTrainee && loadRegis.isConfirmed!
                                                                                    ? const Padding(
                                                                                        padding: EdgeInsets.only(top: 15),
                                                                                        child: Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                                          children: [
                                                                                            Text(
                                                                                              'Công ty bạn đang thực tập.',
                                                                                              style: TextStyle(
                                                                                                fontSize: 12,
                                                                                                color: Colors.red,
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      )
                                                                                    : const Padding(
                                                                                        padding: EdgeInsets.only(top: 15),
                                                                                        child: Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                                          children: [
                                                                                            Text(
                                                                                              'Đã bắt đầu thực tập không thể đăng ký hoặc thay đổi vị trí ứng tuyển.',
                                                                                              style: TextStyle(
                                                                                                fontSize: 12,
                                                                                                color: Colors.red,
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      )
                                                                              ]
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      actions: setting.settingId != null &&
                                                                              setting.term != trainee.term &&
                                                                              setting.traineeStart != trainee.traineeStart
                                                                          ? null
                                                                          : DateTime.now().isBeforeTimestamp(setting.traineeStart!)
                                                                              ? isTrainee
                                                                                  ? null
                                                                                  : (loadRegis.status == null || loadRegis.status == TrangThai.wait) && isTrainee == false
                                                                                      ? [
                                                                                          ElevatedButton(
                                                                                            child: const Text(
                                                                                              "Ứng tuyển",
                                                                                              style: TextStyle(
                                                                                                fontWeight: FontWeight.bold,
                                                                                                fontSize: 16,
                                                                                              ),
                                                                                            ),
                                                                                            onPressed: () async {
                                                                                              if (isRegistered == true) {
                                                                                                if (firm.listRegis!.where((element) => element.userId == userId).isNotEmpty) {
                                                                                                  for (var d in firm.listRegis!) {
                                                                                                    if (d.userId == userId) {
                                                                                                      if (d.jobId == currentUser.selectedJob.value.jobId) {
                                                                                                        GV.warning(context: context, message: 'Không có gì thay đổi.');
                                                                                                      } else {
                                                                                                        var listRegis = firm.listRegis;
                                                                                                        for (int i = 0; i < listRegis!.length; i++) {
                                                                                                          if (listRegis[i].userId == currentUser.userId.value) {
                                                                                                            if (listRegis[i].jobId != currentUser.selectedJob.value.jobId) {
                                                                                                              listRegis[i].jobId = currentUser.selectedJob.value.jobId;
                                                                                                              listRegis[i].jobName = currentUser.selectedJob.value.jobName;
                                                                                                              listRegis[i].createdAt = Timestamp.now();
                                                                                                            }
                                                                                                          }
                                                                                                        }
                                                                                                        await firestore.collection('firms').doc(firm.firmId).update({
                                                                                                          'listRegis': listRegis.map((i) => i.toMap()).toList(),
                                                                                                        });
                                                                                                        var loadListRegis = await firestore.collection('trainees').doc(userId).get();
                                                                                                        final listUserRegis = RegisterTraineeModel.fromMap(loadListRegis.data()!).listRegis;
                                                                                                        for (int i = 0; i < listUserRegis!.length; i++) {
                                                                                                          if (listUserRegis[i].firmId == firm.firmId) {
                                                                                                            if (listUserRegis[i].jobId != currentUser.selectedJob.value.jobId) {
                                                                                                              listUserRegis[i].jobId = currentUser.selectedJob.value.jobId;
                                                                                                              listUserRegis[i].jobName = currentUser.selectedJob.value.jobName;
                                                                                                              listUserRegis[i].createdAt = Timestamp.now();
                                                                                                            }
                                                                                                          }
                                                                                                        }
                                                                                                        await firestore.collection('trainees').doc(userId).update({
                                                                                                          'listRegis': listUserRegis.map((i) => i.toMap()).toList(),
                                                                                                        });
                                                                                                        Navigator.pop(context);
                                                                                                        GV.success(context: context, message: 'Đã cập nhật thành công.');
                                                                                                      }
                                                                                                    }
                                                                                                  }
                                                                                                } else {
                                                                                                  if (currentUser.selectedJob.value.jobId == null) {
                                                                                                    GV.error(context: context, message: 'Vui lòng chọn vị trí ứng tuyển.');
                                                                                                  } else if (trainee.listRegis!.length == 3) {
                                                                                                    GV.error(context: context, message: 'Bạn chỉ có thể đăng ký tối đa 3 công ty.');
                                                                                                  } else {
                                                                                                    showDialog(
                                                                                                        context: context,
                                                                                                        barrierColor: Colors.black12,
                                                                                                        barrierDismissible: false,
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
                                                                                                                  scrollable: true,
                                                                                                                  title: Container(
                                                                                                                    color: Colors.blue.shade600,
                                                                                                                    height: screenHeight * 0.06,
                                                                                                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                                                                                                    child: Row(
                                                                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                                      children: [
                                                                                                                        const SizedBox(
                                                                                                                          width: 30,
                                                                                                                        ),
                                                                                                                        const Expanded(
                                                                                                                          child: Text(
                                                                                                                            'Xác nhận đăng ký',
                                                                                                                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                                                                                                            textAlign: TextAlign.center,
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        SizedBox(
                                                                                                                          width: 30,
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
                                                                                                                  titlePadding: EdgeInsets.zero,
                                                                                                                  shape: Border.all(width: 0.5),
                                                                                                                  content: ConstrainedBox(
                                                                                                                      constraints: BoxConstraints(
                                                                                                                        minWidth: screenWidth * 0.35,
                                                                                                                        maxWidth: screenWidth * 0.35,
                                                                                                                      ),
                                                                                                                      child: const Text('Bạn chỉ có thể đăng ký tối đa 3 công ty và không thể xóa công ty đã đăng ký, bạn có chắc muốn đăng ký công ty này?')),
                                                                                                                  actions: [
                                                                                                                    ElevatedButton(
                                                                                                                      onPressed: () async {
                                                                                                                        final regis = JobRegisterModel(
                                                                                                                          userId: userId,
                                                                                                                          jobId: currentUser.selectedJob.value.jobId,
                                                                                                                          userName: currentUser.userName.value,
                                                                                                                          jobName: currentUser.selectedJob.value.jobName,
                                                                                                                          status: TrangThai.wait,
                                                                                                                          createdAt: Timestamp.now(),
                                                                                                                        );
                                                                                                                        var listRegis = firm.listRegis;
                                                                                                                        listRegis!.add(regis);
                                                                                                                        await firestore.collection('firms').doc(firm.firmId).update({
                                                                                                                          'listRegis': listRegis.map((i) => i.toMap()).toList()
                                                                                                                        });
                                                                                                                        final userRegis = UserRegisterModel(
                                                                                                                          firmId: firm.firmId,
                                                                                                                          jobId: regis.jobId,
                                                                                                                          jobName: regis.jobName,
                                                                                                                          status: TrangThai.wait,
                                                                                                                          firmName: firm.firmName,
                                                                                                                          createdAt: Timestamp.now(),
                                                                                                                        );
                                                                                                                        var loadListRegis = await firestore.collection('trainees').doc(userId).get();
                                                                                                                        final listUserRegis = RegisterTraineeModel.fromMap(loadListRegis.data()!).listRegis;
                                                                                                                        listUserRegis!.add(userRegis);
                                                                                                                        await firestore.collection('trainees').doc(userId).update({
                                                                                                                          'listRegis': listUserRegis.map((i) => i.toMap()).toList(),
                                                                                                                        });
                                                                                                                        if (method.value) {
                                                                                                                          await suggestTFIDF();
                                                                                                                        } else {
                                                                                                                          await suggestKNN();
                                                                                                                        }
                                                                                                                        Navigator.pop(context);
                                                                                                                        Navigator.pop(context);
                                                                                                                        GV.success(context: context, message: 'Đăng ký thành công.');
                                                                                                                      },
                                                                                                                      child: const Text(
                                                                                                                        'Chắc chắn',
                                                                                                                        style: TextStyle(
                                                                                                                          fontWeight: FontWeight.bold,
                                                                                                                          fontSize: 16,
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                    ElevatedButton(
                                                                                                                      onPressed: () {
                                                                                                                        Navigator.pop(context);
                                                                                                                      },
                                                                                                                      child: const Text(
                                                                                                                        'Để sau',
                                                                                                                        style: TextStyle(
                                                                                                                          color: Colors.red,
                                                                                                                          fontSize: 16,
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  ],
                                                                                                                ),
                                                                                                              ],
                                                                                                            ),
                                                                                                          );
                                                                                                        });
                                                                                                  }
                                                                                                }
                                                                                              } else {
                                                                                                GV.error(context: context, message: 'Bạn cần phải đăng ký thực tập trước khi ứng tuyển.');
                                                                                              }
                                                                                            },
                                                                                          ),
                                                                                        ]
                                                                                      : loadRegis.status == TrangThai.accept && loadRegis.isConfirmed == false && isTrainee == false
                                                                                          ? [
                                                                                              ElevatedButton(
                                                                                                onPressed: () async {
                                                                                                  showDialog(
                                                                                                      context: context,
                                                                                                      barrierColor: Colors.black12,
                                                                                                      barrierDismissible: false,
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
                                                                                                                scrollable: true,
                                                                                                                title: Container(
                                                                                                                  color: Colors.blue.shade600,
                                                                                                                  height: screenHeight * 0.06,
                                                                                                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                                                                                                  child: Row(
                                                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                                    children: [
                                                                                                                      const SizedBox(
                                                                                                                        width: 30,
                                                                                                                      ),
                                                                                                                      const Expanded(
                                                                                                                        child: Text(
                                                                                                                          'Xác nhận thực tập',
                                                                                                                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                                                                                                          textAlign: TextAlign.center,
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                      SizedBox(
                                                                                                                        width: 30,
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
                                                                                                                titlePadding: EdgeInsets.zero,
                                                                                                                shape: Border.all(width: 0.5),
                                                                                                                content: ConstrainedBox(
                                                                                                                    constraints: BoxConstraints(
                                                                                                                      minWidth: screenWidth * 0.35,
                                                                                                                      maxWidth: screenWidth * 0.35,
                                                                                                                    ),
                                                                                                                    child: const Text('Bạn chỉ có thể xác nhận thực tập tại một công ty duy nhất và không thể thay đổi, bạn có chắc muốn thực tập tại công ty này?')),
                                                                                                                actions: [
                                                                                                                  ElevatedButton(
                                                                                                                    onPressed: () async {
                                                                                                                      var loadCBHD = await firestore.collection('users').doc(firm.firmId).get();
                                                                                                                      final cbhdName = UserModel.fromMap(loadCBHD.data()!).userName;
                                                                                                                      final plan = PlanWorkModel(
                                                                                                                        cbhdId: firm.firmId,
                                                                                                                        cbhdName: cbhdName,
                                                                                                                        listWork: [],
                                                                                                                        userId: userId,
                                                                                                                      );
                                                                                                                      var listRegis = firm.listRegis;
                                                                                                                      for (int i = 0; i < listRegis!.length; i++) {
                                                                                                                        if (listRegis[i].userId == currentUser.userId.value) {
                                                                                                                          if (listRegis[i].jobId == currentUser.selectedJob.value.jobId) {
                                                                                                                            listRegis[i].isConfirmed = true;
                                                                                                                            plan.traineeStart = trainee.traineeStart;
                                                                                                                            plan.traineeEnd = trainee.traineeEnd;
                                                                                                                          }
                                                                                                                        }
                                                                                                                      }
                                                                                                                      await firestore.collection('plans').doc(userId).set(plan.toMap());
                                                                                                                      firestore.collection('firms').doc(firm.firmId).update({
                                                                                                                        'listRegis': listRegis.map((i) => i.toMap()).toList()
                                                                                                                      });
                                                                                                                      var loadListRegis = await GV.traineesCol.doc(userId).get();
                                                                                                                      final listUserRegis = RegisterTraineeModel.fromMap(loadListRegis.data()!).listRegis;
                                                                                                                      for (int i = 0; i < listUserRegis!.length; i++) {
                                                                                                                        if (listUserRegis[i].firmId == firm.firmId) {
                                                                                                                          if (listUserRegis[i].jobId == currentUser.selectedJob.value.jobId) {
                                                                                                                            listUserRegis[i].isConfirmed = true;
                                                                                                                          }
                                                                                                                        }
                                                                                                                      }
                                                                                                                      await firestore.collection('trainees').doc(userId).update({
                                                                                                                        'listRegis': listUserRegis.map((i) => i.toMap()).toList(),
                                                                                                                        'reachedStep': 2,
                                                                                                                      });
                                                                                                                      if (method.value) {
                                                                                                                        await suggestTFIDF();
                                                                                                                      } else {
                                                                                                                        await suggestKNN();
                                                                                                                      }
                                                                                                                      Navigator.pop(context);
                                                                                                                      Navigator.pop(context);
                                                                                                                      GV.success(context: context, message: 'Đã xác nhận công ty thực tập');
                                                                                                                    },
                                                                                                                    child: const Text(
                                                                                                                      'Chắc chắn',
                                                                                                                      style: TextStyle(
                                                                                                                        fontWeight: FontWeight.bold,
                                                                                                                        fontSize: 16,
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                  ElevatedButton(
                                                                                                                    onPressed: () {
                                                                                                                      Navigator.pop(context);
                                                                                                                    },
                                                                                                                    child: const Text(
                                                                                                                      'Để sau',
                                                                                                                      style: TextStyle(
                                                                                                                        color: Colors.red,
                                                                                                                        fontSize: 16,
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
                                                                                                child: const Text(
                                                                                                  'Xác nhận thực tập',
                                                                                                  style: TextStyle(
                                                                                                    fontWeight: FontWeight.bold,
                                                                                                    fontSize: 16,
                                                                                                  ),
                                                                                                ),
                                                                                              )
                                                                                            ]
                                                                                          : null
                                                                              : null,
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    )
                                                  : const SizedBox.shrink();
                                            },
                                          ),
                                        )
                                      : currentUser.loadIn.isTrue
                                          ? const Padding(
                                              padding: EdgeInsets.only(top: 35),
                                              child: Column(
                                                children: [
                                                  Text(
                                                      'Chưa có công ty phù hợp với bạn, chuyển đến danh sách các công ty để tìm thêm cơ hội.'),
                                                ],
                                              ),
                                            )
                                          : const Padding(
                                              padding: EdgeInsets.only(top: 35),
                                              child: Loading(),
                                            ),
                            )
                          ],
                        ),
                      );
                    }
                    return const Padding(
                      padding: EdgeInsets.only(top: 200),
                      child: Loading(),
                    );
                  }),
            ],
          );
        });
  }

  lineTieuChi({required String title, required int index}) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: screenWidth * 0.1,
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(width: screenWidth * 0.05),
        ValueListenableBuilder(
            valueListenable: tieuChi[index],
            builder: (context, tieuChiVal, child) {
              return Row(
                children: [
                  for (int i = 0; i < 5; i++)
                    CustomRadio(
                      title: '${i + 1}',
                      onTap: () => tieuChi[index].value = i + 1,
                      selected: tieuChi[index].value == i + 1,
                    ),
                ],
              );
            })
      ],
    );
  }
}
