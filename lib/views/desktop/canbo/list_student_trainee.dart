// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/common/constant.dart';
import 'package:tttt_project/common/date_time_extension.dart';
import 'package:tttt_project/models/appreciate_model.dart';
import 'package:tttt_project/models/cv_model.dart';
import 'package:tttt_project/models/firm_model.dart';
import 'package:tttt_project/models/register_trainee_model.dart';
import 'package:tttt_project/models/setting_trainee_model.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/models/plan_work_model.dart';
import 'package:tttt_project/widgets/custom_button.dart';
import 'package:tttt_project/widgets/custom_radio.dart';
import 'package:tttt_project/widgets/dropdown_style.dart';
import 'package:tttt_project/widgets/field_detail.dart';
import 'package:tttt_project/widgets/loading.dart';
import 'package:tttt_project/common/user_controller.dart';

class ListStudentTrainee extends StatefulWidget {
  const ListStudentTrainee({
    super.key,
  });

  @override
  State<ListStudentTrainee> createState() => _ListStudentTraineeState();
}

class _ListStudentTraineeState extends State<ListStudentTrainee> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final currentUser = Get.put(UserController());
  String? userId;
  List<UserModel> loadUsers = [];
  UserModel user = UserModel();
  String selectedHK = HocKy.empty;
  NamHoc selectedNH = NamHoc.empty;
  ValueNotifier<bool> isViewed = ValueNotifier(false);
  List<RegisterTraineeModel> trainees = [];
  List<TextEditingController> contents = [];
  List<TextEditingController> totalDay = [];
  List<TextEditingController> comments = [];
  List<ValueNotifier<bool>> isCompleted = [];
  List<DateTime> weekStart = [];
  List<DateTime> weekEnd = [];
  List<TextEditingController> points = [];
  TextEditingController commentSV = TextEditingController();
  TextEditingController commentCTDT = TextEditingController();
  String? appreciateCTDT;
  final _formKey = GlobalKey<FormState>();
  SettingTraineeModel setting = SettingTraineeModel();
  ValueNotifier finalTotal = ValueNotifier(0);
  String hknow = HocKy.empty;
  NamHoc nhnow = NamHoc.empty;
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    userId = sharedPref
        .getString(
          'userId',
        )
        .toString();
    currentUser.loadIn.value = false;
    var loadTrainee = await firestore.collection('trainees').get();
    if (loadTrainee.docs.isNotEmpty) {
      trainees = loadTrainee.docs
          .map((e) => RegisterTraineeModel.fromMap(e.data()))
          .toList();
    }
    DocumentSnapshot<Map<String, dynamic>> atMoment =
        await firestore.collection('atMoment').doc('now').get();
    if (atMoment.data() != null) {
      setState(() {
        hknow = atMoment.data()!['term'];
        final temp = NamHoc(
            start: atMoment.data()!['yearStart'],
            end: atMoment.data()!['yearEnd']);
        nhnow = temp;
      });
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
    var loadData = await GV.usersCol.get();
    if (loadData.docs.isNotEmpty) {
      loadUsers =
          loadData.docs.map((e) => UserModel.fromMap(e.data())).toList();
    }
    bool? isLoggedIn = sharedPref.getBool("isLoggedIn");
    if (isLoggedIn == true) {
      currentUser.setCurrentUser(
        setMenuSelected: sharedPref.getInt('menuSelected'),
      );
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
      }
    }
    currentUser.loadIn.value = true;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Obx(
      () => currentUser.loadIn.value == true
          ? ValueListenableBuilder(
              valueListenable: isViewed,
              builder: (context, value, child) {
                return Column(
                  children: [
                    if (setting.traineeStart != null &&
                        DateTime.now().isBeforeOrEqual(Timestamp.fromDate(
                            setting.traineeStart!.toDate().add(const Duration(
                                days: 6,
                                hours: 23,
                                minutes: 59,
                                seconds: 59)))))
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          'Thời gian thực tập từ ${GV.readTimestamp(setting.traineeStart!)} đến ${GV.readTimestamp(setting.traineeEnd!)}, bạn cần phân công công việc cho sinh viên đến hết ngày ${DateFormat('dd/MM/yyyy').format(setting.traineeStart!.toDate().add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59)))}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    else if (setting.traineeStart != null &&
                        DateTime.now().isBeforeOrEqual(setting.traineeEnd))
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          'Thời gian thực tập từ ${GV.readTimestamp(setting.traineeStart!)} đến ${GV.readTimestamp(setting.traineeEnd!)}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    else if (setting.pointCBEnd != null &&
                        DateTime.now().isBetweenEqual(
                            from: setting.traineeEnd, to: setting.pointCBEnd))
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          'Bạn cần đánh giá thực tập cho sinh viên từ ${GV.readTimestampAfter(setting.traineeEnd!)} đến ${GV.readTimestamp(setting.pointCBEnd!)}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: screenWidth * 0.04,
                                child: const Text(
                                  "Học kỳ",
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
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          hknow,
                                          style: DropdownStyle.hintStyle,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  items: dshkAll
                                      .map((String hk) =>
                                          DropdownMenuItem<String>(
                                            value: hk,
                                            child: Center(
                                              child: Text(
                                                hk,
                                                style: DropdownStyle.itemStyle,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  value: selectedHK != HocKy.empty
                                      ? selectedHK
                                      : null,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedHK = value!;
                                    });
                                    currentUser.isCompleted.value = false;
                                  },
                                  buttonStyleData:
                                      DropdownStyle.buttonStyleShort,
                                  iconStyleData: DropdownStyle.iconStyleData,
                                  dropdownStyleData:
                                      DropdownStyle.dropdownStyleShort,
                                  menuItemStyleData:
                                      DropdownStyle.menuItemStyleData,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 25),
                          Row(
                            children: [
                              SizedBox(
                                width: screenWidth * 0.05,
                                child: const Text(
                                  "Năm học",
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
                                      nhnow.start == nhnow.end
                                          ? "${nhnow.start}"
                                          : "${nhnow.start} - ${nhnow.end}",
                                      style: DropdownStyle.hintStyle,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  items: dsnhAll
                                      .map((NamHoc nh) =>
                                          DropdownMenuItem<NamHoc>(
                                            value: nh,
                                            child: Center(
                                              child: Text(
                                                nh.start == nh.end
                                                    ? nh.start
                                                    : "${nh.start} - ${nh.end}",
                                                style: DropdownStyle.itemStyle,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  value: selectedNH != NamHoc.empty
                                      ? selectedNH
                                      : null,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedNH = value!;
                                    });
                                    currentUser.isCompleted.value = false;
                                  },
                                  buttonStyleData:
                                      DropdownStyle.buttonStyleMedium,
                                  iconStyleData: DropdownStyle.iconStyleData,
                                  dropdownStyleData:
                                      DropdownStyle.dropdownStyleMedium,
                                  menuItemStyleData:
                                      DropdownStyle.menuItemStyleData,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 35),
                          CustomButton(
                              text: 'Xem',
                              width: 100,
                              height: 45,
                              onTap: () {
                                if (selectedHK != HocKy.empty &&
                                    selectedNH != NamHoc.empty) {
                                  setState(() {
                                    isViewed.value = true;
                                  });
                                  currentUser.isCompleted.value = true;
                                }
                              })
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 35),
                      child: Container(
                        decoration: const BoxDecoration(color: Colors.white),
                        height: screenHeight * 0.45,
                        width: screenWidth * 0.6,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              color: GV.fieldColor,
                              height: screenHeight * 0.04,
                              child: const Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'STT',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'MSSV',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      'Họ tên',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Text(
                                      'Vị trí thực tập',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Phân việc',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Điểm',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Thao tác',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            isViewed.value && currentUser.isCompleted.isTrue
                                ? Expanded(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: StreamBuilder(
                                        stream: firestore
                                            .collection('firms')
                                            .where('firmId',
                                                isEqualTo:
                                                    currentUser.userId.value)
                                            .snapshots(),
                                        builder: (context, snapshotFirm) {
                                          if (snapshotFirm.hasData &&
                                              snapshotFirm.data != null &&
                                              snapshotFirm.connectionState ==
                                                  ConnectionState.active) {
                                            List<FirmModel> loadFirms = [];
                                            List<JobRegisterModel> listRegis =
                                                [];
                                            if (snapshotFirm
                                                .data!.docs.isNotEmpty) {
                                              snapshotFirm.data!.docs.forEach(
                                                  (element) => loadFirms.add(
                                                      FirmModel.fromMap(
                                                          element.data())));
                                              for (var e in loadFirms
                                                  .first.listRegis!) {
                                                if (e.isConfirmed == true) {
                                                  listRegis.add(e);
                                                }
                                              }
                                            }
                                            List<JobRegisterModel> listSelect =
                                                [];
                                            listRegis.forEach((e1) {
                                              trainees.forEach((e2) {
                                                if (selectedHK == HocKy.tatca &&
                                                    selectedNH ==
                                                        NamHoc.tatca) {
                                                  if (e1.userId == e2.userId) {
                                                    listSelect.add(e1);
                                                  }
                                                } else if (selectedHK ==
                                                    HocKy.tatca) {
                                                  if (e1.userId == e2.userId &&
                                                      e2.yearStart ==
                                                          selectedNH.start) {
                                                    listSelect.add(e1);
                                                  }
                                                } else if (selectedNH ==
                                                    NamHoc.tatca) {
                                                  if (e1.userId == e2.userId &&
                                                      e2.term == selectedHK) {
                                                    listSelect.add(e1);
                                                  }
                                                } else if (e1.userId ==
                                                        e2.userId &&
                                                    e2.term == selectedHK &&
                                                    e2.yearStart ==
                                                        selectedNH.start) {
                                                  listSelect.add(e1);
                                                }
                                              });
                                            });
                                            listRegis.sort(
                                              (a, b) => a.userId!
                                                  .compareTo(b.userId!),
                                            );
                                            return listSelect.isNotEmpty
                                                ? ListView.builder(
                                                    itemCount:
                                                        listSelect.length,
                                                    shrinkWrap: true,
                                                    itemBuilder:
                                                        (context, indexRegis) {
                                                      return StreamBuilder(
                                                          stream: firestore
                                                              .collection(
                                                                  'plans')
                                                              .where('userId',
                                                                  isEqualTo:
                                                                      listRegis[
                                                                              indexRegis]
                                                                          .userId)
                                                              .snapshots(),
                                                          builder: (context,
                                                              snapshotPlan) {
                                                            if (snapshotPlan
                                                                    .hasData &&
                                                                snapshotPlan
                                                                        .data !=
                                                                    null) {
                                                              PlanWorkModel
                                                                  plan =
                                                                  PlanWorkModel();
                                                              List<PlanWorkModel>
                                                                  listPlan = [];
                                                              RegisterTraineeModel
                                                                  trainee =
                                                                  RegisterTraineeModel();
                                                              if (snapshotPlan
                                                                  .data!
                                                                  .docs
                                                                  .isNotEmpty) {
                                                                snapshotPlan
                                                                    .data!.docs
                                                                    .forEach((element) =>
                                                                        listPlan
                                                                            .add(PlanWorkModel.fromMap(element.data())));
                                                                listPlan.forEach(
                                                                    (element) {
                                                                  if (element
                                                                          .userId ==
                                                                      listRegis[
                                                                              indexRegis]
                                                                          .userId) {
                                                                    plan =
                                                                        element;
                                                                  }
                                                                });
                                                              }
                                                              return Container(
                                                                height:
                                                                    screenHeight *
                                                                        0.05,
                                                                color: indexRegis %
                                                                            2 ==
                                                                        0
                                                                    ? Colors
                                                                        .blue
                                                                        .shade50
                                                                    : null,
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child: Text(
                                                                          '${indexRegis + 1}',
                                                                          textAlign:
                                                                              TextAlign.center),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 2,
                                                                      child: Text(
                                                                          '${listRegis[indexRegis].userId}'
                                                                              .toUpperCase(),
                                                                          textAlign:
                                                                              TextAlign.justify),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 3,
                                                                      child: Text(
                                                                          '${listRegis[indexRegis].userName}',
                                                                          textAlign:
                                                                              TextAlign.justify),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 4,
                                                                      child:
                                                                          Text(
                                                                        '${listRegis[indexRegis].jobName}',
                                                                        textAlign:
                                                                            TextAlign.justify,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                        child: plan.listWork!.isEmpty
                                                                            ? const Icon(
                                                                                Icons.not_interested_rounded,
                                                                                color: Colors.grey,
                                                                              )
                                                                            : const Icon(
                                                                                Icons.check_circle_rounded,
                                                                                color: Colors.green,
                                                                              )),
                                                                    Expanded(
                                                                      child: StreamBuilder(
                                                                          stream: firestore.collection('appreciates').doc(listRegis[indexRegis].userId).snapshots(),
                                                                          builder: (context, snapshotA) {
                                                                            if (snapshotA.hasData &&
                                                                                snapshotA.data != null &&
                                                                                snapshotA.data!.data() != null) {
                                                                              final app = AppreciateModel.fromMap(snapshotA.data!.data()!);
                                                                              double total = 0;
                                                                              app.listContent!.forEach((element) {
                                                                                total += element.point!;
                                                                              });
                                                                              return Text(
                                                                                total > 70 ? '$total/100' : '$total/70',
                                                                                style: const TextStyle(color: Colors.red),
                                                                                textAlign: TextAlign.center,
                                                                              );
                                                                            }
                                                                            return const Text('-',
                                                                                textAlign: TextAlign.center);
                                                                          }),
                                                                    ),
                                                                    Expanded(
                                                                        flex: 2,
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            IconButton(
                                                                                padding: const EdgeInsets.only(bottom: 1),
                                                                                onPressed: () async {
                                                                                  final loadCV = await firestore.collection('profiles').doc(listRegis[indexRegis].userId).get();
                                                                                  CVModel? cv;
                                                                                  if (loadCV.data() != null) {
                                                                                    cv = CVModel.fromMap(loadCV.data()!);
                                                                                  }
                                                                                  loadUsers.forEach((element) {
                                                                                    if (element.userId == listRegis[indexRegis].userId) {
                                                                                      user = element;
                                                                                    }
                                                                                  });
                                                                                  trainees.forEach((element) {
                                                                                    if (element.userId == listRegis[indexRegis].userId) {
                                                                                      trainee = element;
                                                                                    }
                                                                                  });
                                                                                  showInfo(
                                                                                    context: context,
                                                                                    jobRegister: listRegis[indexRegis],
                                                                                    trainee: trainee,
                                                                                    cv: cv,
                                                                                  );
                                                                                },
                                                                                icon: const Icon(
                                                                                  Icons.info,
                                                                                  size: 22,
                                                                                  color: Colors.grey,
                                                                                )),
                                                                            IconButton(
                                                                                padding: const EdgeInsets.only(bottom: 1),
                                                                                onPressed: () {
                                                                                  contents = [];
                                                                                  comments = [];
                                                                                  totalDay = [];
                                                                                  isCompleted = [];
                                                                                  weekStart = [];
                                                                                  weekEnd = [];
                                                                                  if (plan.listWork!.isEmpty) {
                                                                                    for (var i = 0; i < 8; i++) {
                                                                                      contents.add(TextEditingController());
                                                                                      totalDay.add(TextEditingController());

                                                                                      comments.add(TextEditingController());
                                                                                      isCompleted.add(ValueNotifier(false));
                                                                                      weekStart.add(getStartWeek((i + 1), plan.traineeStart!));
                                                                                      weekEnd.add(getEndWeek((i + 1), plan.traineeStart!));
                                                                                    }
                                                                                  } else {
                                                                                    for (var i = 0; i < 8; i++) {
                                                                                      contents.add(TextEditingController(text: plan.listWork![i].content));
                                                                                      totalDay.add(TextEditingController(text: plan.listWork![i].totalDay));
                                                                                      comments.add(TextEditingController(text: plan.listWork![i].comment));
                                                                                      isCompleted.add(ValueNotifier(plan.listWork![i].isCompleted!));
                                                                                      weekStart.add(getStartWeek((i + 1), plan.traineeStart!));
                                                                                      weekEnd.add(getEndWeek((i + 1), plan.traineeStart!));
                                                                                    }
                                                                                  }
                                                                                  trainees.forEach((element) {
                                                                                    if (element.userId == listRegis[indexRegis].userId) {
                                                                                      trainee = element;
                                                                                    }
                                                                                  });
                                                                                  showAssignAndFollow(
                                                                                    context: context,
                                                                                    plan: plan,
                                                                                    jobRegister: listRegis[indexRegis],
                                                                                    islocked: DateTime.now().isAfterTimestamp(trainee.traineeEnd!),
                                                                                  );
                                                                                },
                                                                                icon: Icon(
                                                                                  Icons.work_history_rounded,
                                                                                  size: 22,
                                                                                  color: Colors.blue.shade900,
                                                                                )),
                                                                            IconButton(
                                                                                padding: const EdgeInsets.only(bottom: 1),
                                                                                onPressed: () async {
                                                                                  points = [];
                                                                                  loadUsers.forEach((element) {
                                                                                    if (element.userId == listRegis[indexRegis].userId) {
                                                                                      user = element;
                                                                                    }
                                                                                  });
                                                                                  var loadAppeciate = await firestore.collection('appreciates').where('userId', isEqualTo: user.userId).get();
                                                                                  if (loadAppeciate.docs.isNotEmpty) {
                                                                                    var appreciates = loadAppeciate.docs.map((e) => AppreciateModel.fromMap(e.data())).toList();
                                                                                    var appreciate = appreciates.firstWhere((element) => element.userId == listRegis[indexRegis].userId);
                                                                                    finalTotal.value = 0;
                                                                                    for (var i = 0; i < appreciate.listContent!.length; i++) {
                                                                                      points.add(TextEditingController(text: appreciate.listContent![i].point.toString()));
                                                                                      setState(() {
                                                                                        finalTotal.value += int.parse(appreciate.listContent![i].point!.toStringAsFixed(0));
                                                                                      });
                                                                                    }
                                                                                    for (var i = 0; i < appreciatesCTDT.length; i++) {
                                                                                      if (appreciatesCTDT[i] == appreciate.appreciateCTDT) {
                                                                                        appreciateCTDT = appreciate.appreciateCTDT!;
                                                                                        currentUser.selected.value = i;
                                                                                      }
                                                                                    }
                                                                                    commentCTDT.text = appreciate.commentCTDT!;
                                                                                    commentSV.text = appreciate.commentSV!;
                                                                                  } else {
                                                                                    finalTotal.value = 0;
                                                                                    for (var i = 0; i < 10; i++) {
                                                                                      points.add(TextEditingController(text: '10'));
                                                                                      setState(() {
                                                                                        finalTotal.value += 10;
                                                                                      });
                                                                                    }
                                                                                    currentUser.selected.value = 5;
                                                                                  }
                                                                                  trainees.forEach((element) {
                                                                                    if (element.userId == listRegis[indexRegis].userId) {
                                                                                      trainee = element;
                                                                                    }
                                                                                  });
                                                                                  showAppreciate(
                                                                                    context: context,
                                                                                    plan: plan,
                                                                                    jobRegister: listRegis[indexRegis],
                                                                                    firms: loadFirms,
                                                                                    islocked: DateTime.now().isAfterTimestamp(setting.traineeEnd) && DateTime.now().isBeforeOrEqual(setting.pointCBEnd) ? false : true,
                                                                                  );
                                                                                },
                                                                                icon: const Icon(
                                                                                  CupertinoIcons.pencil_ellipsis_rectangle,
                                                                                  size: 22,
                                                                                  color: Colors.red,
                                                                                ))
                                                                          ],
                                                                        )),
                                                                  ],
                                                                ),
                                                              );
                                                            }
                                                            return const SizedBox
                                                                .shrink();
                                                          });
                                                    },
                                                  )
                                                : SizedBox(
                                                    height: screenHeight * 0.45,
                                                    width: screenWidth * 0.6,
                                                    child: const Center(
                                                        child: Text(
                                                            'Chưa có sinh viên thực tập.')),
                                                  );
                                          } else {
                                            return SizedBox(
                                              height: screenHeight * 0.45,
                                              width: screenWidth * 0.6,
                                              child: const Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Loading(),
                                                ],
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  )
                                : selectedHK == HocKy.empty &&
                                        selectedNH == NamHoc.empty
                                    ? Expanded(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: StreamBuilder(
                                            stream: firestore
                                                .collection('firms')
                                                .where('firmId',
                                                    isEqualTo: currentUser
                                                        .userId.value)
                                                .snapshots(),
                                            builder: (context, snapshotFirm) {
                                              if (snapshotFirm.hasData &&
                                                  snapshotFirm.data != null) {
                                                List<FirmModel> loadFirms = [];
                                                List<JobRegisterModel>
                                                    listRegis = [];
                                                List<JobRegisterModel> listR =
                                                    [];
                                                if (snapshotFirm
                                                    .data!.docs.isNotEmpty) {
                                                  snapshotFirm.data!.docs
                                                      .forEach((element) =>
                                                          loadFirms.add(
                                                              FirmModel.fromMap(
                                                                  element
                                                                      .data())));
                                                  FirmModel firm = FirmModel();
                                                  loadFirms.forEach((element) {
                                                    if (element.firmId ==
                                                        userId) {
                                                      firm = element;
                                                    }
                                                  });
                                                  if (firm.listRegis != null) {
                                                    for (var e
                                                        in firm.listRegis!) {
                                                      if (e.isConfirmed ==
                                                          true) {
                                                        listR.add(e);
                                                      }
                                                    }
                                                  }
                                                  listR.forEach((e1) {
                                                    trainees.forEach((e2) {
                                                      if (e1.userId ==
                                                              e2.userId &&
                                                          e2.term == hknow &&
                                                          e2.yearStart ==
                                                              nhnow.start) {
                                                        listRegis.add(e1);
                                                      }
                                                    });
                                                  });
                                                }
                                                listRegis.sort(
                                                  (a, b) => a.userId!
                                                      .compareTo(b.userId!),
                                                );
                                                return listRegis.isNotEmpty
                                                    ? ListView.builder(
                                                        itemCount:
                                                            listRegis.length,
                                                        shrinkWrap: true,
                                                        itemBuilder: (context,
                                                            indexRegis) {
                                                          return StreamBuilder(
                                                              stream: firestore
                                                                  .collection(
                                                                      'plans')
                                                                  .where(
                                                                      'userId',
                                                                      isEqualTo:
                                                                          listRegis[indexRegis]
                                                                              .userId)
                                                                  .snapshots(),
                                                              builder: (context,
                                                                  snapshotPlan) {
                                                                if (snapshotPlan
                                                                        .hasData &&
                                                                    snapshotPlan
                                                                            .data !=
                                                                        null) {
                                                                  PlanWorkModel
                                                                      plan =
                                                                      PlanWorkModel();
                                                                  List<PlanWorkModel>
                                                                      listPlan =
                                                                      [];
                                                                  RegisterTraineeModel
                                                                      trainee =
                                                                      RegisterTraineeModel();
                                                                  if (snapshotPlan
                                                                      .data!
                                                                      .docs
                                                                      .isNotEmpty) {
                                                                    snapshotPlan
                                                                        .data!
                                                                        .docs
                                                                        .forEach((element) =>
                                                                            listPlan.add(PlanWorkModel.fromMap(element.data())));
                                                                    listPlan.forEach(
                                                                        (element) {
                                                                      if (element
                                                                              .userId ==
                                                                          listRegis[indexRegis]
                                                                              .userId) {
                                                                        plan =
                                                                            element;
                                                                      }
                                                                    });
                                                                  }
                                                                  return Container(
                                                                    height:
                                                                        screenHeight *
                                                                            0.05,
                                                                    color: indexRegis %
                                                                                2 ==
                                                                            0
                                                                        ? Colors
                                                                            .blue
                                                                            .shade50
                                                                        : null,
                                                                    child: Row(
                                                                      children: [
                                                                        Expanded(
                                                                          child: Text(
                                                                              '${indexRegis + 1}',
                                                                              textAlign: TextAlign.center),
                                                                        ),
                                                                        Expanded(
                                                                          flex:
                                                                              2,
                                                                          child: Text(
                                                                              '${listRegis[indexRegis].userId}'.toUpperCase(),
                                                                              textAlign: TextAlign.justify),
                                                                        ),
                                                                        Expanded(
                                                                          flex:
                                                                              3,
                                                                          child: Text(
                                                                              '${listRegis[indexRegis].userName}',
                                                                              textAlign: TextAlign.justify),
                                                                        ),
                                                                        Expanded(
                                                                          flex:
                                                                              4,
                                                                          child:
                                                                              Text(
                                                                            '${listRegis[indexRegis].jobName}',
                                                                            textAlign:
                                                                                TextAlign.justify,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                            child: plan.listWork!.isEmpty
                                                                                ? const Icon(
                                                                                    Icons.not_interested_rounded,
                                                                                    color: Colors.grey,
                                                                                  )
                                                                                : const Icon(
                                                                                    Icons.check_circle_rounded,
                                                                                    color: Colors.green,
                                                                                  )),
                                                                        Expanded(
                                                                          child: StreamBuilder(
                                                                              stream: firestore.collection('appreciates').doc(listRegis[indexRegis].userId).snapshots(),
                                                                              builder: (context, snapshotA) {
                                                                                if (snapshotA.hasData && snapshotA.data != null && snapshotA.data!.data() != null) {
                                                                                  final app = AppreciateModel.fromMap(snapshotA.data!.data()!);
                                                                                  double total = 0;
                                                                                  app.listContent!.forEach((element) {
                                                                                    total += element.point!;
                                                                                  });
                                                                                  return Text(
                                                                                    total > 70 ? '$total/100' : '$total/70',
                                                                                    style: const TextStyle(color: Colors.red),
                                                                                    textAlign: TextAlign.center,
                                                                                  );
                                                                                }
                                                                                return const Text('-', textAlign: TextAlign.center);
                                                                              }),
                                                                        ),
                                                                        Expanded(
                                                                            flex:
                                                                                2,
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                IconButton(
                                                                                    tooltip: 'Thông tin sinh viên',
                                                                                    padding: const EdgeInsets.only(bottom: 1),
                                                                                    onPressed: () async {
                                                                                      final loadCV = await firestore.collection('profiles').doc(listRegis[indexRegis].userId).get();
                                                                                      CVModel? cv;
                                                                                      if (loadCV.data() != null) {
                                                                                        cv = CVModel.fromMap(loadCV.data()!);
                                                                                      }
                                                                                      loadUsers.forEach((element) {
                                                                                        if (element.userId == listRegis[indexRegis].userId) {
                                                                                          user = element;
                                                                                        }
                                                                                      });
                                                                                      trainees.forEach((element) {
                                                                                        if (element.userId == listRegis[indexRegis].userId) {
                                                                                          trainee = element;
                                                                                        }
                                                                                      });
                                                                                      showInfo(
                                                                                        context: context,
                                                                                        jobRegister: listRegis[indexRegis],
                                                                                        trainee: trainee,
                                                                                        cv: cv,
                                                                                      );
                                                                                    },
                                                                                    icon: const Icon(
                                                                                      Icons.info,
                                                                                      size: 22,
                                                                                      color: Colors.grey,
                                                                                    )),
                                                                                IconButton(
                                                                                    tooltip: 'Phân công và theo dõi',
                                                                                    padding: const EdgeInsets.only(bottom: 1),
                                                                                    onPressed: () {
                                                                                      contents = [];
                                                                                      comments = [];
                                                                                      totalDay = [];
                                                                                      isCompleted = [];
                                                                                      weekStart = [];
                                                                                      weekEnd = [];
                                                                                      if (plan.listWork!.isEmpty) {
                                                                                        for (var i = 0; i < 8; i++) {
                                                                                          contents.add(TextEditingController());
                                                                                          totalDay.add(TextEditingController());
                                                                                          comments.add(TextEditingController());
                                                                                          isCompleted.add(ValueNotifier(false));
                                                                                          weekStart.add(getStartWeek((i + 1), plan.traineeStart!));
                                                                                          weekEnd.add(getEndWeek((i + 1), plan.traineeStart!));
                                                                                        }
                                                                                      } else {
                                                                                        for (var i = 0; i < 8; i++) {
                                                                                          contents.add(TextEditingController(text: plan.listWork![i].content));
                                                                                          totalDay.add(TextEditingController(text: plan.listWork![i].totalDay));
                                                                                          comments.add(TextEditingController(text: plan.listWork![i].comment));
                                                                                          isCompleted.add(ValueNotifier(plan.listWork![i].isCompleted!));
                                                                                          weekStart.add(getStartWeek((i + 1), plan.traineeStart!));
                                                                                          weekEnd.add(getEndWeek((i + 1), plan.traineeStart!));
                                                                                        }
                                                                                      }
                                                                                      trainees.forEach((element) {
                                                                                        if (element.userId == listRegis[indexRegis].userId) {
                                                                                          trainee = element;
                                                                                        }
                                                                                      });
                                                                                      showAssignAndFollow(
                                                                                        context: context,
                                                                                        plan: plan,
                                                                                        jobRegister: listRegis[indexRegis],
                                                                                        islocked: DateTime.now().isAfterTimestamp(trainee.traineeEnd!),
                                                                                      );
                                                                                    },
                                                                                    icon: Icon(
                                                                                      Icons.work_history_rounded,
                                                                                      size: 22,
                                                                                      color: Colors.blue.shade900,
                                                                                    )),
                                                                                IconButton(
                                                                                    tooltip: 'Đánh giá',
                                                                                    padding: const EdgeInsets.only(bottom: 1),
                                                                                    onPressed: () async {
                                                                                      points = [];
                                                                                      loadUsers.forEach((element) {
                                                                                        if (element.userId == listRegis[indexRegis].userId) {
                                                                                          user = element;
                                                                                        }
                                                                                      });
                                                                                      var loadAppeciate = await firestore.collection('appreciates').where('userId', isEqualTo: user.userId).get();
                                                                                      if (loadAppeciate.docs.isNotEmpty) {
                                                                                        var appreciates = loadAppeciate.docs.map((e) => AppreciateModel.fromMap(e.data())).toList();
                                                                                        var appreciate = appreciates.firstWhere((element) => element.userId == listRegis[indexRegis].userId);
                                                                                        finalTotal.value = 0;
                                                                                        for (var i = 0; i < appreciate.listContent!.length; i++) {
                                                                                          points.add(TextEditingController(text: appreciate.listContent![i].point.toString()));
                                                                                          setState(() {
                                                                                            finalTotal.value += int.parse(appreciate.listContent![i].point!.toStringAsFixed(0));
                                                                                          });
                                                                                        }
                                                                                        for (var i = 0; i < appreciatesCTDT.length; i++) {
                                                                                          if (appreciatesCTDT[i] == appreciate.appreciateCTDT) {
                                                                                            appreciateCTDT = appreciate.appreciateCTDT!;
                                                                                            currentUser.selected.value = i;
                                                                                          }
                                                                                        }
                                                                                        commentCTDT.text = appreciate.commentCTDT!;
                                                                                        commentSV.text = appreciate.commentSV!;
                                                                                      } else {
                                                                                        finalTotal.value = 0;
                                                                                        for (var i = 0; i < 10; i++) {
                                                                                          points.add(TextEditingController(text: '10'));
                                                                                          setState(() {
                                                                                            finalTotal.value += 10;
                                                                                          });
                                                                                        }
                                                                                        currentUser.selected.value = 5;
                                                                                      }
                                                                                      trainees.forEach((element) {
                                                                                        if (element.userId == listRegis[indexRegis].userId) {
                                                                                          trainee = element;
                                                                                        }
                                                                                      });
                                                                                      showAppreciate(
                                                                                        context: context,
                                                                                        plan: plan,
                                                                                        jobRegister: listRegis[indexRegis],
                                                                                        firms: loadFirms,
                                                                                        islocked: DateTime.now().isAfterTimestamp(setting.traineeEnd) && DateTime.now().isBeforeOrEqual(setting.pointCBEnd) ? false : true,
                                                                                      );
                                                                                      // }
                                                                                    },
                                                                                    icon: const Icon(
                                                                                      CupertinoIcons.pencil_ellipsis_rectangle,
                                                                                      size: 22,
                                                                                      color: Colors.red,
                                                                                    ))
                                                                              ],
                                                                            )),
                                                                      ],
                                                                    ),
                                                                  );
                                                                }
                                                                return const SizedBox
                                                                    .shrink();
                                                              });
                                                        },
                                                      )
                                                    : SizedBox(
                                                        height:
                                                            screenHeight * 0.45,
                                                        width:
                                                            screenWidth * 0.6,
                                                        child: const Center(
                                                          child: Text(
                                                              'Chưa có sinh viên thực tập.'),
                                                        ),
                                                      );
                                              } else if (snapshotFirm
                                                      .connectionState ==
                                                  ConnectionState.waiting) {
                                                return SizedBox(
                                                  height: screenHeight * 0.45,
                                                  width: screenWidth * 0.6,
                                                  child: const Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Loading(),
                                                    ],
                                                  ),
                                                );
                                              } else {
                                                return const SizedBox.shrink();
                                              }
                                            },
                                          ),
                                        ),
                                      )
                                    : const Expanded(
                                        child: Center(
                                          child: Text(
                                              'Vui lòng chọn học kỳ và năm học sau đó nhấn vào nút xem để tiếp tục.'),
                                        ),
                                      ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              })
          : SizedBox(
              height: screenHeight * 0.45,
              width: screenWidth * 0.67,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Loading(),
                ],
              ),
            ),
    );
  }

  showInfo({
    required BuildContext context,
    required JobRegisterModel jobRegister,
    required RegisterTraineeModel trainee,
    CVModel? cv,
  }) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
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
                        child: Text('Thông tin thực tập',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                            textAlign: TextAlign.center),
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
                  constraints: BoxConstraints(minWidth: screenWidth * 0.35),
                  child: Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        FieldDetail(
                            field: 'Mã sinh viên',
                            content: user.userId!.toUpperCase()),
                        FieldDetail(field: 'Họ tên', content: user.userName!),
                        FieldDetail(field: 'Ngành', content: user.major!),
                        FieldDetail(field: 'Email', content: user.email!),
                        FieldDetail(
                            field: 'Số điện thoại', content: user.phone!),
                        if (cv != null)
                          FieldDetail(
                              field: 'Mô tả bản thân',
                              content: '${cv.description}'),
                        if (cv != null)
                          const Text(
                            'Kỹ năng (mức độ thông thạo kỹ năng, được đánh giá trên thang điểm từ 1 đến 5)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        if (cv != null)
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
                                        '${cv.language}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text('Kỹ năng lập trình: '),
                                      Text(
                                        '${cv.programming}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text('Kỹ năng làm việc nhóm: '),
                                      Text(
                                        '${cv.skillGroup}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                ]),
                                TableRow(children: [
                                  Row(
                                    children: [
                                      const Text('Máy học, AI: '),
                                      Text(
                                        '${cv.machineAI}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text('Website: '),
                                      Text(
                                        '${cv.website}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text('Ứng dụng di động: '),
                                      Text(
                                        '${cv.mobile}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                ]),
                              ],
                            ),
                          ),
                        FieldDetail(
                            field: 'Vị tri ứng tuyển',
                            content: '${jobRegister.jobName}'),
                        FieldDetail(
                            field: 'Ngày ứng tuyển',
                            content: GV.readTimestamp(jobRegister.createdAt!)),
                        FieldDetail(
                            field: 'Thực tập',
                            content:
                                'Từ ngày ${GV.readTimestamp(trainee.traineeStart!)} - Đến ngày ${GV.readTimestamp(trainee.traineeEnd!)}'),
                        if (jobRegister.status == TrangThai.accept)
                          FieldDetail(
                              field: 'Ngày duyệt',
                              content:
                                  GV.readTimestamp(jobRegister.repliedAt!)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  showAssignAndFollow({
    required BuildContext context,
    required PlanWorkModel plan,
    required JobRegisterModel jobRegister,
    required bool islocked,
  }) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    showDialog(
        context: context,
        barrierColor: Colors.black12,
        barrierDismissible: false,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.06,
              bottom: screenHeight * 0.02,
              left: screenWidth * 0.2,
              right: screenWidth * 0.01,
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 45,
                        ),
                        const Expanded(
                          child: Text(
                            'Phân công và theo dõi tiến độ công việc',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                          width: 45,
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
                  contentPadding: EdgeInsets.zero,
                  actionsPadding: EdgeInsets.zero,
                  content: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                      constraints: BoxConstraints(minWidth: screenWidth * 0.65),
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Họ tên: ${jobRegister.userName}'),
                          Text('Vị trí thực tập: ${jobRegister.jobName}'),
                          Text(
                              'Thời gian thực tập: Từ ngày: ${GV.readTimestamp(plan.traineeStart!)} - Đến ngày: ${GV.readTimestamp(plan.traineeEnd!)}'),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Table(
                              border: TableBorder.all(),
                              columnWidths: Map.from({
                                0: const FlexColumnWidth(3),
                                1: const FlexColumnWidth(7),
                                2: const FlexColumnWidth(2),
                                3: const FlexColumnWidth(5),
                                4: const FlexColumnWidth(2),
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
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      child: const Text(
                                        'Nhận xét',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      child: const Text(
                                        'Hoàn thành',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                for (var indexWork = 0;
                                    indexWork < 8;
                                    indexWork++)
                                  planRowWork(
                                    weekId: indexWork,
                                    dayStart: weekStart[indexWork],
                                    dayEnd: weekEnd[indexWork],
                                    content: contents[indexWork],
                                    totalDay: totalDay[indexWork],
                                    comment: comments[indexWork],
                                    completed: isCompleted[indexWork],
                                    islocked: islocked,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (islocked == false)
                            ElevatedButton(
                              onPressed: () async {
                                List<WorkModel> work = [];
                                for (var indexWork = 0;
                                    indexWork < 8;
                                    indexWork++) {
                                  work.add(WorkModel(
                                    content: contents[indexWork].text,
                                    totalDay: totalDay[indexWork].text,
                                    comment: comments[indexWork].text,
                                    isCompleted: isCompleted[indexWork].value,
                                    dayStart: Timestamp.fromDate(
                                        weekStart[indexWork]),
                                    dayEnd:
                                        Timestamp.fromDate(weekEnd[indexWork]),
                                  ));
                                }
                                firestore
                                    .collection('plans')
                                    .doc(plan.userId)
                                    .update(
                                  {
                                    'listWork':
                                        work.map((e) => e.toMap()).toList(),
                                    if (plan.createdAt == null)
                                      'createdAt': Timestamp.now()
                                  },
                                );
                                GV.success(
                                    context: context,
                                    message: 'Cập nhật thành công.');
                              },
                              style: const ButtonStyle(
                                  elevation: MaterialStatePropertyAll(5)),
                              child: const Text(
                                'Cập nhật',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  showAppreciate({
    required BuildContext context,
    required PlanWorkModel plan,
    required JobRegisterModel jobRegister,
    required List<FirmModel> firms,
    required bool islocked,
  }) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    showDialog(
        context: context,
        barrierColor: Colors.black12,
        barrierDismissible: false,
        builder: (context) {
          return Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.only(
                top: screenHeight * 0.06,
                bottom: screenHeight * 0.02,
                left: screenWidth * 0.2,
                right: screenWidth * 0.01,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AlertDialog(
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
                              'Đánh giá thực tập',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
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
                    contentPadding: EdgeInsets.zero,
                    actionsPadding: EdgeInsets.zero,
                    content: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Container(
                        constraints:
                            BoxConstraints(minWidth: screenWidth * 0.55),
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Họ tên: ${jobRegister.userName}'),
                            Text('Vị trí thực tập: ${jobRegister.jobName}'),
                            Text(
                                'Thời gian thực tập: Từ ngày: ${GV.readTimestamp(plan.traineeStart!)} - Đến ngày: ${GV.readTimestamp(plan.traineeEnd!)}'),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Table(
                                border: TableBorder.all(),
                                columnWidths: Map.from({
                                  0: const FlexColumnWidth(11),
                                  1: const FlexColumnWidth(3),
                                }),
                                children: [
                                  TableRow(
                                    children: [
                                      Container(
                                          padding: const EdgeInsets.all(10),
                                          child: const Text(
                                            'Nội dung đánh giá',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        child: const Text(
                                          'Điểm chấm (từ 1-10)',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  rowAppreciate(
                                    content: 'I. Tinh thần kỷ luật',
                                  ),
                                  rowAppreciate(
                                    content:
                                        'I.1. Thực hiện nội quy của cơ quan (nếu thực tập online thì không chẩm điểm)',
                                    point: points[0],
                                    isOnl: true,
                                    islocked: islocked,
                                  ),
                                  rowAppreciate(
                                    content:
                                        'I.2. Chấp hành giờ giấc làm việc (nếu thực tập online thì không chẩm điểm)',
                                    point: points[1],
                                    isOnl: true,
                                    islocked: islocked,
                                  ),
                                  rowAppreciate(
                                    content:
                                        'I.3. Thái độ giao tiếp với cán bộ trong đơn vị (nếu thực lập online thì không chấm điểm)',
                                    point: points[2],
                                    isOnl: true,
                                    islocked: islocked,
                                  ),
                                  rowAppreciate(
                                    content: 'I.4. Tích cực trong công việc',
                                    point: points[3],
                                    islocked: islocked,
                                  ),
                                  rowAppreciate(
                                    content:
                                        'II. Khả năng chuyên môn, nghiệp vụ',
                                  ),
                                  rowAppreciate(
                                    content: 'II.1. Đáp ứng yêu cầu công việc',
                                    point: points[4],
                                    islocked: islocked,
                                  ),
                                  rowAppreciate(
                                    content:
                                        'II.2. Tinh thần học hỏi, nâng cao trình độ chuyên môn, nghiệp vụ',
                                    point: points[5],
                                    islocked: islocked,
                                  ),
                                  rowAppreciate(
                                    content:
                                        'II.3. Có đề xuất, sáng kiến, năng động trong công việc',
                                    point: points[6],
                                    islocked: islocked,
                                  ),
                                  rowAppreciate(
                                    content: 'III. Kết quả công tác',
                                  ),
                                  rowAppreciate(
                                    content:
                                        'III.1. Báo cáo tiến độ công việc cho cán bộ hướng dẫn mỗi tuần 1 lần',
                                    point: points[7],
                                    islocked: islocked,
                                  ),
                                  rowAppreciate(
                                    content:
                                        'III.2. Hoàn thành công việc được giao',
                                    point: points[8],
                                    islocked: islocked,
                                  ),
                                  rowAppreciate(
                                    content:
                                        'III.3. Kết quả công việc có đóng góp cho cơ quan nơi thực tập',
                                    point: points[9],
                                    islocked: islocked,
                                  ),
                                  TableRow(
                                    children: [
                                      const TableCell(
                                          verticalAlignment:
                                              TableCellVerticalAlignment.middle,
                                          child: Padding(
                                            padding: EdgeInsets.all(10),
                                            child: Text(
                                              'TỔNG',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          )),
                                      TableCell(
                                          verticalAlignment:
                                              TableCellVerticalAlignment.middle,
                                          child: ValueListenableBuilder(
                                            valueListenable: finalTotal,
                                            builder: (context, value, child) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(15),
                                                child: Text(
                                                  finalTotal.value.toString(),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  textAlign: TextAlign.right,
                                                ),
                                              );
                                            },
                                          )),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            SizedBox(
                              width: screenWidth * 0.45,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text('Nhận xét khác về sinh viên:'),
                                  Expanded(
                                      child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    child: TextFormField(
                                      controller: commentSV,
                                      minLines: 1,
                                      maxLines: 5,
                                      readOnly: islocked,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(width: 0.1),
                                        ),
                                      ),
                                    ),
                                  )),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            const Text(
                                'Đánh giá của cơ quan về chương trình đào tạo (CTDT):'),
                            Obx(
                              () => Container(
                                width: screenWidth * 0.25,
                                padding: const EdgeInsets.only(left: 25),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (var i = 0;
                                        i < appreciatesCTDT.length;
                                        i++)
                                      CustomRadio(
                                          title: appreciatesCTDT[i],
                                          selected:
                                              currentUser.selected.value == i,
                                          onTap: () {
                                            if (islocked == false) {
                                              currentUser.selected.value = i;
                                              setState(() {
                                                appreciateCTDT =
                                                    appreciatesCTDT[i];
                                              });
                                            }
                                          }),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            SizedBox(
                              width: screenWidth * 0.45,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                      'Đề xuất góp ý của cơ quan về CTDT:'),
                                  Expanded(
                                      child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15),
                                    child: TextFormField(
                                      controller: commentCTDT,
                                      minLines: 1,
                                      maxLines: 5,
                                      readOnly: islocked,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(width: 0.1),
                                        ),
                                      ),
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (islocked == false)
                              ElevatedButton(
                                onPressed: () async {
                                  bool isOnl = false;
                                  if ((points[0].text == '0' &&
                                          points[1].text != '0' &&
                                          points[2].text != '0') ||
                                      (points[0].text != '0' &&
                                          points[1].text == '0' &&
                                          points[2].text != '0') ||
                                      (points[0].text != '0' &&
                                          points[1].text != '0' &&
                                          points[2].text == '0') ||
                                      (points[0].text == '0' &&
                                          points[1].text == '0' &&
                                          points[2].text != '0') ||
                                      (points[0].text != '0' &&
                                          points[1].text == '0' &&
                                          points[2].text == '0') ||
                                      (points[0].text == '0' &&
                                          points[1].text != '0' &&
                                          points[2].text == '0')) {
                                    isOnl = true;
                                  }
                                  if (isOnl) {
                                    GV.error(
                                        context: context,
                                        message:
                                            "Nếu online 3 mục đầu tiên đều phải bằng 0.");
                                  } else if (_formKey.currentState!
                                      .validate()) {
                                    List<ContentAppreciateModel>
                                        contentAppreciates = [];
                                    for (var index = 0; index < 10; index++) {
                                      contentAppreciates.add(
                                        ContentAppreciateModel(
                                          content: contentAppreciate[index],
                                          title: index < 4
                                              ? 'I. Tinh thần kỷ luật'
                                              : index < 7
                                                  ? 'II. Khả năng chuyên môn, nghiệp vụ'
                                                  : 'III. Kết quả công tác',
                                          point:
                                              double.parse(points[index].text),
                                        ),
                                      );
                                    }
                                    final appreciate = AppreciateModel(
                                      cbhdId: plan.cbhdId,
                                      cbhdName: plan.cbhdName,
                                      jobName: jobRegister.jobName,
                                      commentCTDT: commentCTDT.text,
                                      commentSV: commentSV.text,
                                      createdAt: Timestamp.now(),
                                      traineeEnd: plan.traineeEnd,
                                      traineeStart: plan.traineeStart,
                                      userId: jobRegister.userId,
                                      appreciateCTDT: appreciateCTDT,
                                      listContent: contentAppreciates,
                                      firmName: firms
                                          .firstWhere((element) =>
                                              element.firmId == userId)
                                          .firmName,
                                      jobId: jobRegister.jobId,
                                    );
                                    firestore
                                        .collection('appreciates')
                                        .doc(appreciate.userId)
                                        .set(appreciate.toMap());
                                    GV.success(
                                        context: context,
                                        message: 'Cập nhật thành công.');
                                  }
                                },
                                style: const ButtonStyle(
                                    elevation: MaterialStatePropertyAll(5)),
                                child: const Text(
                                  'Đánh giá',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  getStartWeek(int weekId, Timestamp dayStart) {
    var start =
        DateTime.fromMicrosecondsSinceEpoch(dayStart.microsecondsSinceEpoch);

    return start = weekId == 1
        ? start.add(Duration(days: ((weekId - 1) * 6)))
        : start.add(Duration(days: ((weekId - 1) * 6) + (weekId - 1)));
  }

  getEndWeek(int weekId, Timestamp dayStart) {
    var start =
        DateTime.fromMicrosecondsSinceEpoch(dayStart.microsecondsSinceEpoch);
    return start = weekId == 1
        ? start.add(Duration(days: weekId * 6))
        : start.add(Duration(days: (6 * weekId) + (weekId - 1)));
  }

  TableRow planRowWork({
    required int weekId,
    required DateTime dayStart,
    required DateTime dayEnd,
    required TextEditingController content,
    required TextEditingController totalDay,
    required TextEditingController comment,
    required ValueNotifier<bool> completed,
    bool islocked = false,
  }) {
    return TableRow(
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Text(DateFormat('dd/MM/yyyy').format(dayStart).toString()),
                Text(
                  '${weekId + 1}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(DateFormat('dd/MM/yyyy').format(dayEnd).toString()),
              ],
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: TextFormField(
            controller: content,
            minLines: 1,
            maxLines: 10,
            readOnly: islocked,
            style: const TextStyle(fontSize: 13),
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: TextFormField(
            controller: totalDay,
            minLines: 1,
            maxLines: 10,
            readOnly: islocked,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13),
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: TextFormField(
            controller: comment,
            minLines: 1,
            maxLines: 10,
            style: const TextStyle(fontSize: 13),
            readOnly: islocked,
            decoration: InputDecoration(
              hintText: DateTime.now().isAfterOrEqual(Timestamp.fromDate(
                      dayEnd.subtract(const Duration(days: 1))))
                  ? null
                  : 'Thời gian đánh giá tiến độ từ ${DateFormat('dd/MM/yyyy').format(dayEnd.subtract(const Duration(days: 1)))}',
              border: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
            ),
            enabled: DateTime.now().isAfterOrEqual(Timestamp.fromDate(
                    dayEnd.subtract(const Duration(days: 1))))
                ? true
                : false,
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: ValueListenableBuilder(
              valueListenable: completed,
              builder: (context, value, child) {
                return MaterialButton(
                  onPressed: () {
                    if (islocked == false) {
                      if (DateTime.now().isAfterOrEqual(Timestamp.fromDate(
                          dayEnd.subtract(const Duration(days: 1))))) {
                        setState(() {
                          if (completed.value) {
                            completed.value = false;
                          } else {
                            completed.value = true;
                          }
                        });
                      } else {
                        GV.error(
                            context: context,
                            message:
                                'Bạn chỉ có thể đánh giá từ ngày ${DateFormat('dd/MM/yyyy').format(dayEnd.subtract(const Duration(days: 1)))}');
                      }
                    }
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: completed.value
                        ? Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.lightBlue.shade900,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(50)),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.circle,
                                color: Colors.lightBlue.shade900,
                                size: 16,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.circle_outlined,
                            size: 20,
                          ),
                  ),
                );
              }),
        ),
      ],
    );
  }

  TableRow rowAppreciate({
    required String content,
    TextEditingController? point,
    bool isOnl = false,
    bool islocked = false,
  }) {
    return TableRow(
      children: [
        TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Text(
                    content,
                    textAlign: TextAlign.center,
                    style: point == null
                        ? const TextStyle(fontWeight: FontWeight.bold)
                        : null,
                    overflow: TextOverflow.visible,
                  ),
                ],
              ),
            )),
        point != null
            ? TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: TextFormField(
                  controller: point,
                  maxLines: 1,
                  readOnly: islocked,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                  textAlign: TextAlign.right,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) => isOnl
                      ? double.parse(value!) > 10
                          ? "Từ 0đ đến 10đ"
                          : null
                      : double.parse(value!) < 1 || double.parse(value) > 10
                          ? 'Từ 1đ đến 10đ'
                          : null,
                  onChanged: (value) {
                    finalTotal.value = 0;
                    for (var i = 0; i < points.length; i++) {
                      setState(() {
                        finalTotal.value += int.parse(points[i].text);
                      });
                    }
                  },
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
