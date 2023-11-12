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
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController skillCtrl = TextEditingController();
  final TextEditingController achieveCtrl = TextEditingController();
  final TextEditingController hobbyCtrl = TextEditingController();
  final TextEditingController wishCtrl = TextEditingController();
  final currentUser = Get.put(UserController());
  String? userId;
  CVModel loadCV = CVModel();
  ValueNotifier<List<FirmSuggestModel>> firmSuggest = ValueNotifier([]);
  List<FirmModel> firms = [];
  RegisterTraineeModel trainee = RegisterTraineeModel();
  bool isTrainee = false;
  ValueNotifier<bool> isLoading = ValueNotifier(true);
  bool isRegistered = false;
  SettingTraineeModel setting = SettingTraineeModel();

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
        DocumentSnapshot<Map<String, dynamic>> isExistCV =
            await firestore.collection('cvs').doc(userId).get();
        if (isExistCV.data() != null) {
          loadCV = CVModel.fromMap(isExistCV.data()!);
          skillCtrl.text = loadCV.skill ?? '';
          achieveCtrl.text = loadCV.achieve ?? '';
          hobbyCtrl.text = loadCV.hobby ?? '';
          wishCtrl.text = loadCV.wish ?? '';
        }
      }
    }
    isLoading.value = false;
    await getFirmsSuggest();
  }

  Future getFirmsSuggest() async {
    currentUser.loadIn.value = false;
    final queryParameters = {
      'userId': '$userId',
    };
    final uri = Uri.https(
        'suggest-firms-server.onrender.com', '/suggest', queryParameters);
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
        setState(() {
          if (temp.length > 5) {
            firmSuggest.value = temp.getRange(0, 4).toList();
          } else {
            firmSuggest.value = temp;
          }
        });
      }
      currentUser.loadIn.value = true;
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    skillCtrl.dispose();
    hobbyCtrl.dispose();
    achieveCtrl.dispose();
    wishCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return ValueListenableBuilder(
        valueListenable: isLoading,
        builder: (context, isLoadingVal, child) {
          return isLoading.value == false
              ? Obx(
                  () => Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 50),
                        child: Form(
                          key: formKey,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  LineDetail(
                                      field: "Họ tên",
                                      display: currentUser.userName.value),
                                  LineDetail(
                                      field: "Mã số",
                                      display: currentUser.userId.value
                                          .toUpperCase()),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  LineDetail(
                                      field: "Lớp",
                                      display: currentUser.className.value),
                                  LineDetail(
                                      field: "Khóa",
                                      display: currentUser.course.value),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  LineDetail(
                                    field: "Kỹ năng",
                                    ctrl: skillCtrl,
                                    validator: (p0) => p0!.isEmpty
                                        ? 'Không được để trống'
                                        : null,
                                  ),
                                  LineDetail(
                                      field: "Thành tích", ctrl: achieveCtrl),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  LineDetail(
                                      field: "Sở thích", ctrl: hobbyCtrl),
                                  LineDetail(
                                      field: "Nguyện vọng", ctrl: wishCtrl),
                                ],
                              ),
                              const SizedBox(height: 55),
                              CustomButton(
                                text: "Lưu",
                                width: screenWidth * 0.1,
                                height: screenHeight * 0.07,
                                onTap: () async {
                                  if (formKey.currentState!.validate()) {
                                    DocumentSnapshot<Map<String, dynamic>>
                                        isExistCV = await firestore
                                            .collection('cvs')
                                            .doc(userId)
                                            .get();
                                    if (isExistCV.data() != null &&
                                        (skillCtrl.text != '' ||
                                            achieveCtrl.text != '' ||
                                            hobbyCtrl.text != '' ||
                                            wishCtrl.text != '')) {
                                      final myCV = CVModel(
                                          userId: currentUser.userId.value,
                                          skill: skillCtrl.text,
                                          achieve: achieveCtrl.text,
                                          hobby: hobbyCtrl.text,
                                          wish: wishCtrl.text);
                                      final json = myCV.toMap();
                                      firestore
                                          .collection('cvs')
                                          .doc(myCV.userId)
                                          .update(json);
                                      GV.success(
                                          context: context,
                                          message:
                                              'Thông tin đã được cập nhật.');
                                    } else if (skillCtrl.text != '' ||
                                        achieveCtrl.text != '' ||
                                        hobbyCtrl.text != '' ||
                                        wishCtrl.text != '') {
                                      final myCV = CVModel(
                                          userId: currentUser.userId.value,
                                          skill: skillCtrl.text,
                                          achieve: achieveCtrl.text,
                                          hobby: hobbyCtrl.text,
                                          wish: wishCtrl.text);
                                      final json = myCV.toMap();
                                      await firestore
                                          .collection('cvs')
                                          .doc(myCV.userId)
                                          .set(json);
                                      GV.success(
                                          context: context,
                                          message: 'Đã thêm các thông tin.');
                                    }
                                    await getFirmsSuggest();
                                  }
                                },
                              ),
                              ValueListenableBuilder(
                                  valueListenable: firmSuggest,
                                  builder: (context, firmSuggestVal, child) {
                                    return firmSuggest.value.isNotEmpty &&
                                            currentUser.loadIn.isTrue
                                        ? Container(
                                            width: screenWidth * 0.5,
                                            padding:
                                                const EdgeInsets.only(top: 15),
                                            child: ListView.builder(
                                              itemCount:
                                                  firmSuggest.value.length,
                                              shrinkWrap: true,
                                              itemBuilder:
                                                  (context, indexFirm) {
                                                FirmModel firm = FirmModel();
                                                if (firms.isNotEmpty) {
                                                  firms.forEach((element) {
                                                    if (firmSuggest
                                                            .value[indexFirm]
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
                                                            firm.firmName!,
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          subtitle: Text(
                                                            firm.describe!,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          trailing: check
                                                                      .status ==
                                                                  TrangThai
                                                                      .accept
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
                                                            for (var d in firm
                                                                .listRegis!) {
                                                              if (d.userId ==
                                                                  userId) {
                                                                currentUser
                                                                        .selectedJob
                                                                        .value =
                                                                    firm.listJob!.firstWhere((element) =>
                                                                        element
                                                                            .jobId ==
                                                                        d.jobId);
                                                                loadRegis = d;
                                                              }
                                                            }
                                                            showDialog(
                                                              context: context,
                                                              barrierColor:
                                                                  Colors
                                                                      .black12,
                                                              barrierDismissible:
                                                                  false,
                                                              builder:
                                                                  (context) {
                                                                return Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .only(
                                                                    top: screenHeight *
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
                                                                              screenHeight * 0.06,
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              horizontal: 10),
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
                                                                                  style: TextStyle(fontWeight: FontWeight.bold),
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
                                                                            EdgeInsets.zero,
                                                                        shape: Border.all(
                                                                            width:
                                                                                0.5),
                                                                        content:
                                                                            ConstrainedBox(
                                                                          constraints: BoxConstraints(
                                                                              minWidth: screenWidth * 0.35,
                                                                              maxWidth: screenWidth * 0.5),
                                                                          child:
                                                                              Form(
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: <Widget>[
                                                                                Text('Tên công ty: ${firm.firmName!}'),
                                                                                Text('Người đại diện: ${firm.owner!}'),
                                                                                Text('Số điện thoại: ${firm.phone!}'),
                                                                                Text('Email: ${firm.email!}'),
                                                                                Text('Địa chỉ: ${firm.address!}'),
                                                                                Text(
                                                                                  'Mô tả: ${firm.describe!}',
                                                                                  overflow: TextOverflow.clip,
                                                                                  textAlign: TextAlign.justify,
                                                                                ),
                                                                                if (setting.settingId != null && DateTime.now().isBeforeTimestamp(setting.traineeStart!)) ...[
                                                                                  if (isRegistered == false) ...[
                                                                                    const Text('Vị trí tuyển dụng:'),
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
                                                                                          subtitle: Text(
                                                                                            '${job.describeJob}',
                                                                                            textAlign: TextAlign.justify,
                                                                                            overflow: TextOverflow.clip,
                                                                                          ),
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
                                                                                  ] else if (setting.settingId != null && setting.term != trainee.term && setting.traineeStart != trainee.traineeStart) ...[
                                                                                    const Text('Vị trí tuyển dụng:'),
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
                                                                                          subtitle: Text(
                                                                                            '${job.describeJob}',
                                                                                            textAlign: TextAlign.justify,
                                                                                            overflow: TextOverflow.clip,
                                                                                          ),
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
                                                                                  ] else if (isTrainee && loadRegis.isConfirmed!) ...[
                                                                                    Text('Vị trí ứng tuyển: ${currentUser.selectedJob.value.jobName} '),
                                                                                    Text('Ngày ứng tuyển: ${GV.readTimestamp(loadRegis.createdAt!)}'),
                                                                                    Text('Ngày duyệt: ${GV.readTimestamp(loadRegis.repliedAt!)}'),
                                                                                    Text('Thời gian thực tập: Từ ngày ${GV.readTimestamp(trainee.traineeStart!)} - Đến ngày: ${GV.readTimestamp(trainee.traineeEnd!)}'),
                                                                                  ] else if (isTrainee) ...[
                                                                                    const Text('Vị trí tuyển dụng:'),
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
                                                                                          subtitle: Text(
                                                                                            '${job.describeJob}',
                                                                                            textAlign: TextAlign.justify,
                                                                                            overflow: TextOverflow.clip,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    const Padding(
                                                                                      padding: EdgeInsets.only(top: 15),
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          Text(
                                                                                            'Bạn đã có công ty thực tập không thể ứng tuyển được nữa.',
                                                                                            style: TextStyle(
                                                                                              fontSize: 12,
                                                                                              color: Colors.red,
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    )
                                                                                  ] else if (loadRegis.status == TrangThai.wait || loadRegis.userId == null) ...[
                                                                                    const Text('Vị trí tuyển dụng:'),
                                                                                    for (var data in firm.listJob!)
                                                                                      Obx(
                                                                                        () => CustomRadio(
                                                                                          title: '${data.jobName}',
                                                                                          onTap: () => currentUser.selectedJob.value = data,
                                                                                          subtitle: '${data.describeJob}',
                                                                                          selected: currentUser.selectedJob.value == data,
                                                                                        ),
                                                                                      ),
                                                                                  ],
                                                                                ] else ...[
                                                                                  if (isTrainee && loadRegis.isConfirmed!) ...[
                                                                                    Text('Vị trí ứng tuyển: ${currentUser.selectedJob.value.jobName} '),
                                                                                    Text('Ngày ứng tuyển: ${GV.readTimestamp(loadRegis.createdAt!)}'),
                                                                                    Text('Ngày duyệt: ${GV.readTimestamp(loadRegis.repliedAt!)}'),
                                                                                    Text('Thời gian thực tập: Từ ngày ${GV.readTimestamp(trainee.traineeStart!)} - Đến ngày: ${GV.readTimestamp(trainee.traineeEnd!)}'),
                                                                                  ] else if (isTrainee) ...[
                                                                                    const Text('Vị trí tuyển dụng:'),
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
                                                                                          subtitle: Text(
                                                                                            '${job.describeJob}',
                                                                                            textAlign: TextAlign.justify,
                                                                                            overflow: TextOverflow.clip,
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                  ],
                                                                                  const Padding(
                                                                                    padding: EdgeInsets.only(top: 15),
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Text(
                                                                                          'Đã bắt đầu thực tập không thể đăng ký hoặc thay đổi vị trí ứng tuyển',
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
                                                                        actions: DateTime.now().isBeforeTimestamp(setting.traineeStart!)
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
                                                                                                    } else if (currentUser.selectedJob.value.jobId == null) {
                                                                                                      GV.error(context: context, message: 'Vui lòng chọn vị trí ứng tuyển.');
                                                                                                    } else {
                                                                                                      var listRegis = firm.listRegis;
                                                                                                      for (int i = 0; i < listRegis!.length; i++) {
                                                                                                        if (listRegis[i].userId == currentUser.userId.value) {
                                                                                                          if (listRegis[i].jobId != currentUser.selectedJob.value.jobId) {
                                                                                                            listRegis[i].jobId = currentUser.selectedJob.value.jobId;
                                                                                                            listRegis[i].jobName = currentUser.selectedJob.value.jobName;
                                                                                                          }
                                                                                                        }
                                                                                                      }
                                                                                                      firestore.collection('firms').doc(firm.firmId).update({
                                                                                                        'listRegis': listRegis.map((i) => i.toMap()).toList()
                                                                                                      });
                                                                                                      var loadListRegis = await firestore.collection('trainees').doc(userId).get();

                                                                                                      final listUserRegis = RegisterTraineeModel.fromMap(loadListRegis.data()!).listRegis;
                                                                                                      for (int i = 0; i < listUserRegis!.length; i++) {
                                                                                                        if (listUserRegis[i].firmId == firm.firmId) {
                                                                                                          if (listUserRegis[i].jobId != currentUser.selectedJob.value.jobId) {
                                                                                                            listUserRegis[i].jobId = currentUser.selectedJob.value.jobId;
                                                                                                            listUserRegis[i].jobName = currentUser.selectedJob.value.jobName;
                                                                                                          }
                                                                                                        }
                                                                                                      }
                                                                                                      firestore.collection('trainees').doc(userId).update({
                                                                                                        'listRegis': listUserRegis.map((i) => i.toMap()).toList(),
                                                                                                      });
                                                                                                      await getFirmsSuggest();
                                                                                                      Navigator.pop(context);
                                                                                                      GV.success(context: context, message: 'Đã cập nhật thành công.');
                                                                                                    }
                                                                                                  }
                                                                                                }
                                                                                              } else {
                                                                                                if (currentUser.selectedJob.value.jobId == null) {
                                                                                                  GV.error(context: context, message: 'Vui lòng chọn vị trí ứng tuyển.');
                                                                                                } else {
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
                                                                                                  firestore.collection('firms').doc(firm.firmId).update({
                                                                                                    'listRegis': listRegis.map((i) => i.toMap()).toList()
                                                                                                  });
                                                                                                  final userRegis = UserRegisterModel(
                                                                                                    firmId: firm.firmId,
                                                                                                    jobId: regis.jobId,
                                                                                                    jobName: regis.jobName,
                                                                                                    status: TrangThai.wait,
                                                                                                    createdAt: Timestamp.now(),
                                                                                                  );
                                                                                                  var loadListRegis = await firestore.collection('trainees').doc(userId).get();
                                                                                                  final listUserRegis = RegisterTraineeModel.fromMap(loadListRegis.data()!).listRegis;
                                                                                                  listUserRegis!.add(userRegis);
                                                                                                  firestore.collection('trainees').doc(userId).update({
                                                                                                    'listRegis': listUserRegis.map((i) => i.toMap()).toList(),
                                                                                                  });

                                                                                                  Navigator.pop(context);
                                                                                                  GV.success(context: context, message: 'Đăng ký thành công.');
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
                                                                                                firestore.collection('plans').doc(userId).set(plan.toMap());
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
                                                                                                firestore.collection('trainees').doc(userId).update({
                                                                                                  'listRegis': listUserRegis.map((i) => i.toMap()).toList(),
                                                                                                });
                                                                                                Navigator.pop(context);
                                                                                                GV.success(context: context, message: 'Đã xác nhận công ty thực tập');
                                                                                              },
                                                                                              child: const Text(
                                                                                                'Xác nhận',
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
                                                padding:
                                                    EdgeInsets.only(top: 35),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                        'Chưa có công ty phù hợp với bạn, chuyển đến danh sách các công ty để tìm thêm cơ hội.'),
                                                  ],
                                                ),
                                              )
                                            : const Padding(
                                                padding:
                                                    EdgeInsets.only(top: 35),
                                                child: Loading(),
                                              );
                                  })
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const Padding(
                  padding: EdgeInsets.only(top: 200),
                  child: Loading(),
                );
        });
  }
}
