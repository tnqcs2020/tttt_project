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
import 'package:tttt_project/models/firm_model.dart';
import 'package:tttt_project/models/register_trainee_model.dart';
import 'package:tttt_project/models/setting_trainee_model.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/models/plan_work_model.dart';
import 'package:tttt_project/widgets/custom_button.dart';
import 'package:tttt_project/widgets/custom_radio.dart';
import 'package:tttt_project/widgets/dropdown_style.dart';
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
    var loadTrainee = await firestore.collection('trainees').get();
    if (loadTrainee.docs.isNotEmpty) {
      trainees = loadTrainee.docs
          .map((e) => RegisterTraineeModel.fromMap(e.data()))
          .toList();
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
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return ValueListenableBuilder(
        valueListenable: isViewed,
        builder: (context, value, child) {
          return Column(
            children: [
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Chọn',
                                    style: DropdownStyle.hintStyle,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            items: dshkAll
                                .map((String hk) => DropdownMenuItem<String>(
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
                            value:
                                selectedHK != HocKy.empty ? selectedHK : null,
                            onChanged: (value) {
                              setState(() {
                                selectedHK = value!;
                              });
                              currentUser.isCompleted.value = false;
                            },
                            buttonStyleData: DropdownStyle.buttonStyleShort,
                            iconStyleData: DropdownStyle.iconStyleData,
                            dropdownStyleData: DropdownStyle.dropdownStyleShort,
                            menuItemStyleData: DropdownStyle.menuItemStyleData,
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
                            items: dsnhAll
                                .map((NamHoc nh) => DropdownMenuItem<NamHoc>(
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
                            value:
                                selectedNH != NamHoc.empty ? selectedNH : null,
                            onChanged: (value) {
                              setState(() {
                                selectedNH = value!;
                              });
                              currentUser.isCompleted.value = false;
                            },
                            buttonStyleData: DropdownStyle.buttonStyleMedium,
                            iconStyleData: DropdownStyle.iconStyleData,
                            dropdownStyleData:
                                DropdownStyle.dropdownStyleMedium,
                            menuItemStyleData: DropdownStyle.menuItemStyleData,
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
                padding: const EdgeInsets.only(top: 15, bottom: 35),
                child: Container(
                  decoration: const BoxDecoration(color: Colors.white),
                  height: screenHeight * 0.45,
                  width: screenWidth * 0.6,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        color: Colors.green,
                        height: screenHeight * 0.04,
                        child: const Row(
                          children: [
                            Expanded(
                              child: Text(
                                'STT',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'MSSV',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Họ tên',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                'Vị trí thực tập',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Phân việc',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Điểm',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Thao tác',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
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
                                          isEqualTo: currentUser.userId.value)
                                      .snapshots(),
                                  builder: (context, snapshotFirm) {
                                    if (snapshotFirm.hasData &&
                                        snapshotFirm.data != null) {
                                      List<FirmModel> loadFirms = [];
                                      List<JobRegisterModel> listRegis = [];
                                      if (snapshotFirm.data!.docs.isNotEmpty) {
                                        snapshotFirm.data!.docs.forEach(
                                            (element) => loadFirms.add(
                                                FirmModel.fromMap(
                                                    element.data())));
                                        for (var e
                                            in loadFirms.first.listRegis!) {
                                          if (e.isConfirmed == true) {
                                            listRegis.add(e);
                                          }
                                        }
                                      }
                                      List<JobRegisterModel> listSelect = [];
                                      listRegis.forEach((e1) {
                                        trainees.forEach((e2) {
                                          if (selectedHK == HocKy.tatca &&
                                              selectedNH == NamHoc.tatca) {
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
                                          } else if (e1.userId == e2.userId &&
                                              e2.term == selectedHK &&
                                              e2.yearStart ==
                                                  selectedNH.start) {
                                            listSelect.add(e1);
                                          }
                                        });
                                      });
                                      listRegis.sort(
                                        (a, b) =>
                                            a.userId!.compareTo(b.userId!),
                                      );
                                      return listSelect.isNotEmpty
                                          ? ListView.builder(
                                              itemCount: listSelect.length,
                                              shrinkWrap: true,
                                              itemBuilder:
                                                  (context, indexRegis) {
                                                return StreamBuilder(
                                                    stream: firestore
                                                        .collection('plans')
                                                        .where('userId',
                                                            isEqualTo: listRegis[
                                                                    indexRegis]
                                                                .userId)
                                                        .snapshots(),
                                                    builder: (context,
                                                        snapshotPlan) {
                                                      if (snapshotPlan
                                                              .hasData &&
                                                          snapshotPlan.data !=
                                                              null &&
                                                          snapshotPlan
                                                                  .connectionState ==
                                                              ConnectionState
                                                                  .active) {
                                                        PlanWorkModel plan =
                                                            PlanWorkModel();
                                                        List<PlanWorkModel>
                                                            listPlan = [];
                                                        RegisterTraineeModel
                                                            trainee =
                                                            RegisterTraineeModel();
                                                        if (snapshotPlan.data!
                                                            .docs.isNotEmpty) {
                                                          snapshotPlan
                                                              .data!.docs
                                                              .forEach((element) =>
                                                                  listPlan.add(
                                                                      PlanWorkModel.fromMap(
                                                                          element
                                                                              .data())));
                                                          listPlan.forEach(
                                                              (element) {
                                                            if (element
                                                                    .userId ==
                                                                listRegis[
                                                                        indexRegis]
                                                                    .userId) {
                                                              plan = element;
                                                            }
                                                          });
                                                        }
                                                        return Container(
                                                          height: screenHeight *
                                                              0.05,
                                                          color:
                                                              indexRegis % 2 ==
                                                                      0
                                                                  ? Colors.blue
                                                                      .shade50
                                                                  : null,
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                    '${indexRegis + 1}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center),
                                                              ),
                                                              Expanded(
                                                                flex: 2,
                                                                child: Text(
                                                                    '${listRegis[indexRegis].userId}'
                                                                        .toUpperCase(),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .justify),
                                                              ),
                                                              Expanded(
                                                                flex: 3,
                                                                child: Text(
                                                                    '${listRegis[indexRegis].userName}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .justify),
                                                              ),
                                                              Expanded(
                                                                flex: 4,
                                                                child: Text(
                                                                  '${listRegis[indexRegis].jobName}',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .justify,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                              Expanded(
                                                                  child: plan
                                                                          .listWork!
                                                                          .isEmpty
                                                                      ? const Icon(
                                                                          Icons
                                                                              .not_interested_rounded,
                                                                          color:
                                                                              Colors.grey,
                                                                        )
                                                                      : const Icon(
                                                                          Icons
                                                                              .check_circle_rounded,
                                                                          color:
                                                                              Colors.green,
                                                                        )),
                                                              Expanded(
                                                                child:
                                                                    StreamBuilder(
                                                                        stream: firestore
                                                                            .collection(
                                                                                'appreciates')
                                                                            .doc(listRegis[indexRegis]
                                                                                .userId)
                                                                            .snapshots(),
                                                                        builder:
                                                                            (context,
                                                                                snapshotA) {
                                                                          if (snapshotA.hasData &&
                                                                              snapshotA.data != null &&
                                                                              snapshotA.data!.data() != null) {
                                                                            final app =
                                                                                AppreciateModel.fromMap(snapshotA.data!.data()!);
                                                                            double
                                                                                total =
                                                                                0;
                                                                            app.listContent!.forEach((element) {
                                                                              total += element.point!;
                                                                            });
                                                                            return Text(
                                                                              total > 70 ? '$total/100' : '$total/70',
                                                                              style: const TextStyle(color: Colors.red),
                                                                              textAlign: TextAlign.center,
                                                                            );
                                                                          }
                                                                          return const Text(
                                                                              '-',
                                                                              textAlign: TextAlign.center);
                                                                        }),
                                                              ),
                                                              Expanded(
                                                                  flex: 2,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      IconButton(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              bottom:
                                                                                  1),
                                                                          onPressed:
                                                                              () {
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
                                                                            );
                                                                          },
                                                                          icon:
                                                                              const Icon(
                                                                            Icons.info,
                                                                            size:
                                                                                22,
                                                                            color:
                                                                                Colors.grey,
                                                                          )),
                                                                      IconButton(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              bottom:
                                                                                  1),
                                                                          onPressed:
                                                                              () {
                                                                            contents =
                                                                                [];
                                                                            comments =
                                                                                [];
                                                                            totalDay =
                                                                                [];
                                                                            isCompleted =
                                                                                [];
                                                                            weekStart =
                                                                                [];
                                                                            weekEnd =
                                                                                [];
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
                                                                            showAssignAndFollow(
                                                                              context: context,
                                                                              plan: plan,
                                                                              jobRegister: listRegis[indexRegis],
                                                                            );
                                                                          },
                                                                          icon:
                                                                              Icon(
                                                                            Icons.work_history_rounded,
                                                                            size:
                                                                                22,
                                                                            color:
                                                                                Colors.blue.shade900,
                                                                          )),
                                                                      IconButton(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              bottom:
                                                                                  1),
                                                                          onPressed:
                                                                              () async {
                                                                            if (DateTime.now().isBeforeTimestamp(setting.traineeEnd!)) {
                                                                              GV.error(context: context, message: 'Chưa đến thời gian đánh giá thực tập.');
                                                                            } else if (DateTime.now().isAfterTimestamp(setting.pointCBEnd!)) {
                                                                              GV.error(context: context, message: 'Đã quá thơi gian đánh giá.');
                                                                            }
                                                                            if (DateTime.now().isBetweenEqual(
                                                                                from: setting.traineeEnd!,
                                                                                to: setting.pointCBEnd!)) {
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
                                                                                for (var i = 0; i < appreciate.listContent!.length; i++) {
                                                                                  points.add(TextEditingController(text: appreciate.listContent![i].point.toString()));
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
                                                                                for (var i = 0; i < 10; i++) {
                                                                                  points.add(TextEditingController(text: '10'));
                                                                                }
                                                                                currentUser.selected.value = 5;
                                                                              }
                                                                              showAppreciate(
                                                                                context: context,
                                                                                plan: plan,
                                                                                jobRegister: listRegis[indexRegis],
                                                                                firms: loadFirms,
                                                                              );
                                                                            }
                                                                          },
                                                                          icon:
                                                                              const Icon(
                                                                            CupertinoIcons.pencil_ellipsis_rectangle,
                                                                            size:
                                                                                22,
                                                                            color:
                                                                                Colors.red,
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
                                              isEqualTo:
                                                  currentUser.userId.value)
                                          .snapshots(),
                                      builder: (context, snapshotFirm) {
                                        if (snapshotFirm.hasData &&
                                            snapshotFirm.data != null) {
                                          List<FirmModel> loadFirms = [];
                                          List<JobRegisterModel> listRegis = [];
                                          if (snapshotFirm
                                              .data!.docs.isNotEmpty) {
                                            snapshotFirm.data!.docs.forEach(
                                                (element) => loadFirms.add(
                                                    FirmModel.fromMap(
                                                        element.data())));
                                            FirmModel firm = FirmModel();
                                            loadFirms.forEach((element) {
                                              if (element.firmId == userId) {
                                                firm = element;
                                              }
                                            });
                                            if (firm.listRegis != null) {
                                              for (var e in firm.listRegis!) {
                                                if (e.isConfirmed == true) {
                                                  listRegis.add(e);
                                                }
                                              }
                                            }
                                          }
                                          listRegis.sort(
                                            (a, b) =>
                                                a.userId!.compareTo(b.userId!),
                                          );
                                          return listRegis.isNotEmpty
                                              ? ListView.builder(
                                                  itemCount: listRegis.length,
                                                  shrinkWrap: true,
                                                  itemBuilder:
                                                      (context, indexRegis) {
                                                    return StreamBuilder(
                                                        stream: firestore
                                                            .collection('plans')
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
                                                                  null &&
                                                              snapshotPlan
                                                                      .connectionState ==
                                                                  ConnectionState
                                                                      .active) {
                                                            PlanWorkModel plan =
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
                                                                      listPlan.add(
                                                                          PlanWorkModel.fromMap(
                                                                              element.data())));
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
                                                                  ? Colors.blue
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
                                                                    child: Text(
                                                                      '${listRegis[indexRegis].jobName}',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .justify,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                      child: plan
                                                                              .listWork!
                                                                              .isEmpty
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
                                                                            final app =
                                                                                AppreciateModel.fromMap(snapshotA.data!.data()!);
                                                                            double
                                                                                total =
                                                                                0;
                                                                            app.listContent!.forEach((element) {
                                                                              total += element.point!;
                                                                            });
                                                                            return Text(
                                                                              total > 70 ? '$total/100' : '$total/70',
                                                                              style: const TextStyle(color: Colors.red),
                                                                              textAlign: TextAlign.center,
                                                                            );
                                                                          }
                                                                          return const Text(
                                                                              '-',
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
                                                                              tooltip: 'Thông tin sinh viên',
                                                                              padding: const EdgeInsets.only(bottom: 1),
                                                                              onPressed: () {
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
                                                                                showAssignAndFollow(
                                                                                  context: context,
                                                                                  plan: plan,
                                                                                  jobRegister: listRegis[indexRegis],
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
                                                                                if (DateTime.now().isBeforeTimestamp(setting.traineeEnd!)) {
                                                                                  GV.error(context: context, message: 'Chưa đến thời gian đánh giá thực tập.');
                                                                                } else if (DateTime.now().isAfterTimestamp(setting.pointCBEnd!)) {
                                                                                  GV.error(context: context, message: 'Đã quá thơi gian đánh giá.');
                                                                                }
                                                                                if (DateTime.now().isBetweenEqual(from: setting.traineeEnd!, to: setting.pointCBEnd!)) {
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
                                                                                    for (var i = 0; i < appreciate.listContent!.length; i++) {
                                                                                      points.add(TextEditingController(text: appreciate.listContent![i].point.toString()));
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
                                                                                    for (var i = 0; i < 10; i++) {
                                                                                      points.add(TextEditingController(text: '10'));
                                                                                    }
                                                                                    currentUser.selected.value = 5;
                                                                                  }
                                                                                  showAppreciate(
                                                                                    context: context,
                                                                                    plan: plan,
                                                                                    jobRegister: listRegis[indexRegis],
                                                                                    firms: loadFirms,
                                                                                  );
                                                                                }
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
                                                        'Chưa có sinh viên thực tập.'),
                                                  ),
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
        });
  }

  showInfo({
    required BuildContext context,
    required JobRegisterModel jobRegister,
    required RegisterTraineeModel trainee,
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
                            style: TextStyle(fontWeight: FontWeight.bold),
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
                        Text('Mã sinh viên: ${user.userId!.toUpperCase()}'),
                        Text('Họ tên: ${user.userName}'),
                        Text('Ngành: ${user.major}'),
                        Text('Email: ${user.email}'),
                        Text('Số điện thoại: ${user.phone}'),
                        Text('Học kỳ thực tập: ${trainee.term}'),
                        Text(
                            'Năm học: ${trainee.yearStart} -  ${trainee.yearEnd}'),
                        Text('Vị trí thực tập: ${jobRegister.jobName}'),
                        Text(
                            'Ngày ứng tuyển: ${GV.readTimestamp(jobRegister.createdAt!)}'),
                        Text(
                            'Thời gian thực tập: Từ ngày: ${GV.readTimestamp(trainee.traineeStart!)} - Đến ngày: ${GV.readTimestamp(trainee.traineeEnd!)}'),
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
                            'Phân công & theo dõi tiến độ công việc',
                            style: TextStyle(fontWeight: FontWeight.bold),
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
                                  dayStart:
                                      Timestamp.fromDate(weekStart[indexWork]),
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
                                  ),
                                  rowAppreciate(
                                    content:
                                        'I.2. Chấp hành giờ giấc làm việc (nếu thực tập online thì không chẩm điểm)',
                                    point: points[1],
                                    isOnl: true,
                                  ),
                                  rowAppreciate(
                                    content:
                                        'I.3. Thái độ giao tiếp với cán bộ trong đơn vị (nếu thực lập online thì không chấm điểm)',
                                    point: points[2],
                                    isOnl: true,
                                  ),
                                  rowAppreciate(
                                    content: 'I.4. Tích cực trong công việc',
                                    point: points[3],
                                  ),
                                  rowAppreciate(
                                    content:
                                        'II. Khả năng chuyên môn, nghiệp vụ',
                                  ),
                                  rowAppreciate(
                                    content: 'II.1. Đáp ứng yêu cầu công việc',
                                    point: points[4],
                                  ),
                                  rowAppreciate(
                                    content:
                                        'II.2. Tinh thần học hỏi, nâng cao trình độ chuyên môn, nghiệp vụ',
                                    point: points[5],
                                  ),
                                  rowAppreciate(
                                    content:
                                        'II.3. Có đề xuất, sáng kiến, năng động trong công việc',
                                    point: points[6],
                                  ),
                                  rowAppreciate(
                                    content: 'III. Kết quả công tác',
                                  ),
                                  rowAppreciate(
                                    content:
                                        'III.1. Báo cáo tiến độ công việc cho cán bộ hướng dẫn mỗi tuần 1 lần',
                                    point: points[7],
                                  ),
                                  rowAppreciate(
                                    content:
                                        'III.2. Hoàn thành công việc được giao',
                                    point: points[8],
                                  ),
                                  rowAppreciate(
                                    content:
                                        'III.3. Kết quả công việc có đóng góp cho cơ quan nơi thực tập',
                                    point: points[9],
                                  ),
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
                                            currentUser.selected.value = i;
                                            setState(() {
                                              appreciateCTDT =
                                                  appreciatesCTDT[i];
                                            });
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
                                } else if (_formKey.currentState!.validate()) {
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
                                        point: double.parse(points[index].text),
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
            decoration: InputDecoration(
              hintText: DateTime.now().isAfter(dayEnd)
                  ? null
                  : 'Chưa đến thời gian đánh giá tiến độ',
              border: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
            ),
            enabled: DateTime.now().isAfter(dayEnd) ? true : false,
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: ValueListenableBuilder(
              valueListenable: completed,
              builder: (context, value, child) {
                return MaterialButton(
                  onPressed: () {
                    if (DateTime.now().isAfter(dayEnd)) {
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
                              'Bạn chỉ có thể đánh giá sau ngày ${DateFormat('dd/MM/yyyy').format(dayEnd)}');
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
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
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
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
