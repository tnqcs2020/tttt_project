import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/data/constant.dart';
import 'package:tttt_project/data/pdf.dart';
import 'package:tttt_project/models/appreciate_cv_model.dart';
import 'package:tttt_project/models/appreciate_model.dart';
import 'package:tttt_project/models/plan_work_model.dart';
import 'package:tttt_project/models/register_trainee_model.dart';
import 'package:tttt_project/models/submit_bodel.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/widgets/custom_button.dart';
import 'package:tttt_project/widgets/dropdown_style.dart';
import 'package:tttt_project/widgets/loading.dart';
import 'package:tttt_project/widgets/user_controller.dart';

class ListStudentClassTrainee extends StatefulWidget {
  const ListStudentClassTrainee({Key? key}) : super(key: key);

  @override
  State<ListStudentClassTrainee> createState() => _ListStudentClassState();
}

class _ListStudentClassState extends State<ListStudentClassTrainee> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final currentUser = Get.put(UserController());
  String? userId;
  List<UserModel> users = [];
  String selectedHK = HocKy.empty;
  NamHoc selectedNH = NamHoc.empty;
  ValueNotifier<bool> isViewed = ValueNotifier(false);
  // List<FirmModel> firms = [];
  List<AppreciateModel> appreciateCB = [];
  String myClass = '';
  List<TextEditingController> points = [];
  final _formKey = GlobalKey<FormState>();
  ValueNotifier<double> total = ValueNotifier(0);
  ValueNotifier<double> finalTotal = ValueNotifier(0);
  List<SubmitModel> submits = [];
  List<AppreciateCVModel> appCV = [];
  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    setState(() {
      userId = sharedPref
          .getString(
            'userId',
          )
          .toString();
    });
    // var loadFirm = await firestore.collection('firms').get();
    // if (loadFirm.docs.isNotEmpty) {
    //   setState(() {
    //     firms = loadFirm.docs.map((e) => FirmModel.fromMap(e.data())).toList();
    //   });
    // }
    var loadAppreciateCB = await firestore.collection('appreciates').get();
    if (loadAppreciateCB.docs.isNotEmpty) {
      setState(() {
        appreciateCB = loadAppreciateCB.docs
            .map((e) => AppreciateModel.fromMap(e.data()))
            .toList();
      });
    }
    var loadSubmit = await firestore.collection('submits').get();
    if (loadSubmit.docs.isNotEmpty) {
      setState(() {
        submits =
            loadSubmit.docs.map((e) => SubmitModel.fromMap(e.data())).toList();
      });
    }
    // var loadAppCV = await firestore.collection('appreciatesCV').get();
    // if (loadAppCV.docs.isNotEmpty) {
    //   setState(() {
    //     appCV = loadAppCV.docs
    //         .map((e) => AppreciateCVModel.fromMap(e.data()))
    //         .toList();
    //   });
    // }
    var loadUser = await firestore.collection('users').get();
    if (loadUser.docs.isNotEmpty) {
      setState(() {
        users = loadUser.docs.map((e) => UserModel.fromMap(e.data())).toList();
      });
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
        setState(() {
          myClass = loadUser.cvClass!.last.classId!;
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
        );
      }
    }

    currentUser.loadIn.value = true;
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
                    const SizedBox(width: 55),
                    CustomButton(
                        text: 'Xem',
                        width: 100,
                        height: 40,
                        onTap: () {
                          if (selectedHK != HocKy.empty &&
                              selectedNH != NamHoc.empty) {
                            setState(() {
                              isViewed.value = true;
                            });
                            currentUser.isCompleted.value = true;
                          }
                        }),
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
                              flex: 2,
                              child: Text(
                                'Đã nộp báo cáo',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Cán bộ chấm điểm',
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
                              child: myClass.isNotEmpty
                                  ? StreamBuilder(
                                      stream: firestore
                                          .collection('trainees')
                                          .where('classId', isEqualTo: myClass)
                                          .snapshots(),
                                      builder: (context, snapshotTrainee) {
                                        if (snapshotTrainee.hasData &&
                                            snapshotTrainee.data != null &&
                                            snapshotTrainee.connectionState ==
                                                ConnectionState.active) {
                                          List<RegisterTraineeModel> load = [];
                                          List<RegisterTraineeModel>
                                              traineeClass = [];
                                          if (snapshotTrainee
                                              .data!.docs.isNotEmpty) {
                                            snapshotTrainee.data!.docs.forEach(
                                                (element) => load.add(
                                                    RegisterTraineeModel
                                                        .fromMap(
                                                            element.data())));
                                          }
                                          load.forEach((e) {
                                            if (selectedHK == HocKy.tatca &&
                                                selectedNH == NamHoc.tatca) {
                                              traineeClass.add(e);
                                            } else if (selectedHK ==
                                                HocKy.tatca) {
                                              if (e.yearStart ==
                                                  selectedNH.start) {
                                                traineeClass.add(e);
                                              }
                                            } else if (selectedNH ==
                                                NamHoc.tatca) {
                                              if (e.term == selectedHK) {
                                                traineeClass.add(e);
                                              }
                                            } else if (e.term == selectedHK &&
                                                e.yearStart ==
                                                    selectedNH.start) {
                                              traineeClass.add(e);
                                            }
                                          });
                                          return traineeClass.isNotEmpty
                                              ? ListView.builder(
                                                  itemCount:
                                                      traineeClass.length,
                                                  shrinkWrap: true,
                                                  itemBuilder:
                                                      (context, indexTrain) {
                                                    UserRegisterModel
                                                        userRegister =
                                                        UserRegisterModel();
                                                    traineeClass[indexTrain]
                                                        .listRegis!
                                                        .forEach((e1) {
                                                      if (e1.isConfirmed ==
                                                          true) {
                                                        userRegister = e1;
                                                      }
                                                    });
                                                    UserModel user =
                                                        UserModel();
                                                    users.forEach((e) {
                                                      if (e.userId ==
                                                          traineeClass[
                                                                  indexTrain]
                                                              .userId) {
                                                        user = e;
                                                      }
                                                    });
                                                    bool isApCB = false;
                                                    AppreciateModel appreciate =
                                                        AppreciateModel();
                                                    appreciateCB
                                                        .forEach((element) {
                                                      if (element.userId ==
                                                          traineeClass[
                                                                  indexTrain]
                                                              .userId) {
                                                        isApCB = true;
                                                        appreciate = element;
                                                      }
                                                    });
                                                    bool isSubmit = false;
                                                    submits.forEach((element) {
                                                      if (element.userId ==
                                                          traineeClass[
                                                                  indexTrain]
                                                              .userId) {
                                                        isSubmit = true;
                                                      }
                                                    });
                                                    return Container(
                                                      height:
                                                          screenHeight * 0.05,
                                                      color: indexTrain % 2 == 0
                                                          ? Colors.blue.shade50
                                                          : null,
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                                '${indexTrain + 1}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center),
                                                          ),
                                                          Expanded(
                                                            flex: 2,
                                                            child: Text(
                                                                '${traineeClass[indexTrain].userId}'
                                                                    .toUpperCase(),
                                                                textAlign:
                                                                    TextAlign
                                                                        .justify),
                                                          ),
                                                          Expanded(
                                                            flex: 3,
                                                            child: Text(
                                                                '${traineeClass[indexTrain].studentName}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .justify),
                                                          ),
                                                          Expanded(
                                                            flex: 2,
                                                            child: isSubmit
                                                                ? const Icon(
                                                                    Icons
                                                                        .check_circle,
                                                                    color: Colors
                                                                        .green,
                                                                  )
                                                                : const Icon(Icons
                                                                    .not_interested),
                                                          ),
                                                          Expanded(
                                                            flex: 2,
                                                            child: isApCB
                                                                ? const Icon(
                                                                    Icons
                                                                        .check_circle,
                                                                    color: Colors
                                                                        .green,
                                                                  )
                                                                : const Icon(Icons
                                                                    .not_interested),
                                                          ),
                                                          Expanded(
                                                              flex: 2,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  IconButton(
                                                                      tooltip:
                                                                          'Thông tin sinh viên và bảng phân công công việc',
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              1),
                                                                      onPressed:
                                                                          () {
                                                                        showInfo(
                                                                            context:
                                                                                context,
                                                                            user:
                                                                                user,
                                                                            trainee:
                                                                                traineeClass[indexTrain],
                                                                            userRegister: userRegister);
                                                                      },
                                                                      icon:
                                                                          const Icon(
                                                                        Icons
                                                                            .info,
                                                                        size:
                                                                            22,
                                                                        color: Colors
                                                                            .grey,
                                                                      )),
                                                                  IconButton(
                                                                      tooltip:
                                                                          'Kết quả của cán bộ hướng dẫn',
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              1),
                                                                      onPressed:
                                                                          () {
                                                                        showAppreciateCB(
                                                                            context:
                                                                                context,
                                                                            user:
                                                                                user,
                                                                            appreciate:
                                                                                appreciate);
                                                                      },
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .my_library_books,
                                                                        size:
                                                                            22,
                                                                        color: Colors
                                                                            .blue
                                                                            .shade800,
                                                                      )),
                                                                  StreamBuilder(
                                                                      stream: firestore
                                                                          .collection(
                                                                              'appreciatesCV')
                                                                          .snapshots(),
                                                                      builder:
                                                                          (context,
                                                                              snapshot) {
                                                                        if (snapshot
                                                                            .hasData) {
                                                                          appCV = snapshot
                                                                              .data!
                                                                              .docs
                                                                              .map((e) => AppreciateCVModel.fromMap(e.data()))
                                                                              .toList();
                                                                        }
                                                                        return IconButton(
                                                                            tooltip:
                                                                                'Đánh giá',
                                                                            padding:
                                                                                const EdgeInsets.only(bottom: 1),
                                                                            onPressed: () {
                                                                              points = [];
                                                                              double pointCB = 0;
                                                                              appreciateCB.forEach((element) {
                                                                                if (element.userId == traineeClass[indexTrain].userId) {
                                                                                  double totalPoint = 0;
                                                                                  bool isOnl = false;
                                                                                  for (var i = 0; i < element.listContent!.length; i++) {
                                                                                    if (i < 3 && element.listContent![i].point == 0) {
                                                                                      isOnl = true;
                                                                                    }
                                                                                  }
                                                                                  if (isOnl) {
                                                                                    for (var i = 3; i < element.listContent!.length; i++) {
                                                                                      totalPoint += element.listContent![i].point!;
                                                                                    }
                                                                                  } else {
                                                                                    for (var i = 0; i < element.listContent!.length; i++) {
                                                                                      totalPoint += element.listContent![i].point!;
                                                                                    }
                                                                                  }
                                                                                  if (isOnl) {
                                                                                    pointCB = (totalPoint / 70) * 5;
                                                                                  } else {
                                                                                    pointCB = (totalPoint / 100) * 5;
                                                                                  }
                                                                                }
                                                                              });
                                                                              for (int i = 0; i < 11; i++) {
                                                                                if (i == 3) {
                                                                                  points.add(TextEditingController(text: pointCB.toStringAsFixed(2)));
                                                                                } else {
                                                                                  points.add(TextEditingController(text: initPoint[i].toString()));
                                                                                }
                                                                              }
                                                                              double temp = 0;
                                                                              for (var i = 0; i < 10; i++) {
                                                                                temp += double.parse(points[i].text);
                                                                              }
                                                                              setState(() {
                                                                                total.value = double.parse(temp.toStringAsFixed(2));
                                                                                finalTotal.value = double.parse((temp - double.parse(points[10].text)).toStringAsFixed(2));
                                                                              });
                                                                              showAppreciate(context: context, user: user, trainee: traineeClass[indexTrain], userRegister: userRegister);
                                                                            },
                                                                            icon: const Icon(
                                                                              CupertinoIcons.pencil_ellipsis_rectangle,
                                                                              size: 22,
                                                                              color: Colors.red,
                                                                            ));
                                                                      })
                                                                ],
                                                              )),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                )
                                              : const Center(
                                                  child: Text(
                                                      'Chưa có sinh viên thực tập.'),
                                                );
                                        } else {
                                          return const Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Center(child: Loading()),
                                            ],
                                          );
                                        }
                                      },
                                    )
                                  : const SizedBox.shrink())
                          : selectedHK == HocKy.empty &&
                                  selectedNH == NamHoc.empty
                              ? Expanded(
                                  child: myClass.isNotEmpty
                                      ? StreamBuilder(
                                          stream: firestore
                                              .collection('trainees')
                                              .where('classId',
                                                  isEqualTo: myClass)
                                              .snapshots(),
                                          builder: (context, snapshotTrainee) {
                                            if (snapshotTrainee.hasData &&
                                                snapshotTrainee.data != null &&
                                                snapshotTrainee
                                                        .connectionState ==
                                                    ConnectionState.active) {
                                              List<RegisterTraineeModel>
                                                  traineeClass = [];
                                              if (snapshotTrainee
                                                  .data!.docs.isNotEmpty) {
                                                snapshotTrainee
                                                    .data!.docs
                                                    .forEach((element) =>
                                                        traineeClass.add(
                                                            RegisterTraineeModel
                                                                .fromMap(element
                                                                    .data())));
                                              }
                                              return traineeClass.isNotEmpty
                                                  ? ListView.builder(
                                                      itemCount:
                                                          traineeClass.length,
                                                      shrinkWrap: true,
                                                      itemBuilder: (context,
                                                          indexTrain) {
                                                        UserRegisterModel
                                                            userRegister =
                                                            UserRegisterModel();
                                                        traineeClass[indexTrain]
                                                            .listRegis!
                                                            .forEach((e1) {
                                                          if (e1.isConfirmed ==
                                                              true) {
                                                            userRegister = e1;
                                                          }
                                                        });
                                                        UserModel user =
                                                            UserModel();
                                                        users.forEach((e) {
                                                          if (e.userId ==
                                                              traineeClass[
                                                                      indexTrain]
                                                                  .userId) {
                                                            user = e;
                                                          }
                                                        });
                                                        bool isApCB = false;
                                                        AppreciateModel
                                                            appreciate =
                                                            AppreciateModel();
                                                        appreciateCB
                                                            .forEach((element) {
                                                          if (element.userId ==
                                                              traineeClass[
                                                                      indexTrain]
                                                                  .userId) {
                                                            isApCB = true;
                                                            appreciate =
                                                                element;
                                                          }
                                                        });
                                                        bool isSubmit = false;
                                                        submits
                                                            .forEach((element) {
                                                          if (element.userId ==
                                                              traineeClass[
                                                                      indexTrain]
                                                                  .userId) {
                                                            isSubmit = true;
                                                          }
                                                        });
                                                        return Container(
                                                          height: screenHeight *
                                                              0.05,
                                                          color:
                                                              indexTrain % 2 ==
                                                                      0
                                                                  ? Colors.blue
                                                                      .shade50
                                                                  : null,
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                    '${indexTrain + 1}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center),
                                                              ),
                                                              Expanded(
                                                                flex: 2,
                                                                child: Text(
                                                                    '${traineeClass[indexTrain].userId}'
                                                                        .toUpperCase(),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .justify),
                                                              ),
                                                              Expanded(
                                                                flex: 3,
                                                                child: Text(
                                                                    '${traineeClass[indexTrain].studentName}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .justify),
                                                              ),
                                                              Expanded(
                                                                flex: 2,
                                                                child: isSubmit
                                                                    ? const Icon(
                                                                        Icons
                                                                            .check_circle,
                                                                        color: Colors
                                                                            .green,
                                                                      )
                                                                    : const Icon(
                                                                        Icons
                                                                            .not_interested),
                                                              ),
                                                              Expanded(
                                                                flex: 2,
                                                                child: isApCB
                                                                    ? const Icon(
                                                                        Icons
                                                                            .check_circle,
                                                                        color: Colors
                                                                            .green,
                                                                      )
                                                                    : const Icon(
                                                                        Icons
                                                                            .not_interested),
                                                              ),
                                                              Expanded(
                                                                  flex: 2,
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      IconButton(
                                                                          tooltip:
                                                                              'Thông tin sinh viên và bảng phân công công việc',
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              bottom:
                                                                                  1),
                                                                          onPressed:
                                                                              () {
                                                                            showInfo(
                                                                                context: context,
                                                                                user: user,
                                                                                trainee: traineeClass[indexTrain],
                                                                                userRegister: userRegister);
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
                                                                          tooltip:
                                                                              'Kết quả của cán bộ hướng dẫn',
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              bottom:
                                                                                  1),
                                                                          onPressed:
                                                                              () {
                                                                            showAppreciateCB(
                                                                                context: context,
                                                                                user: user,
                                                                                appreciate: appreciate);
                                                                          },
                                                                          icon:
                                                                              Icon(
                                                                            Icons.my_library_books,
                                                                            size:
                                                                                22,
                                                                            color:
                                                                                Colors.blue.shade800,
                                                                          )),
                                                                      StreamBuilder(
                                                                          stream: firestore
                                                                              .collection(
                                                                                  'appreciatesCV')
                                                                              .snapshots(),
                                                                          builder:
                                                                              (context, snapshot) {
                                                                            if (snapshot.hasData) {
                                                                              appCV = snapshot.data!.docs.map((e) => AppreciateCVModel.fromMap(e.data())).toList();
                                                                            }
                                                                            return IconButton(
                                                                                tooltip: 'Đánh giá',
                                                                                padding: const EdgeInsets.only(bottom: 1),
                                                                                onPressed: () {
                                                                                  points = [];
                                                                                  double pointCB = 0;
                                                                                  appreciateCB.forEach((element) {
                                                                                    if (element.userId == traineeClass[indexTrain].userId) {
                                                                                      double totalPoint = 0;
                                                                                      bool isOnl = false;
                                                                                      for (var i = 0; i < element.listContent!.length; i++) {
                                                                                        if (i < 3 && element.listContent![i].point == 0) {
                                                                                          isOnl = true;
                                                                                        }
                                                                                      }
                                                                                      if (isOnl) {
                                                                                        for (var i = 3; i < element.listContent!.length; i++) {
                                                                                          totalPoint += element.listContent![i].point!;
                                                                                        }
                                                                                      } else {
                                                                                        for (var i = 0; i < element.listContent!.length; i++) {
                                                                                          totalPoint += element.listContent![i].point!;
                                                                                        }
                                                                                      }
                                                                                      if (isOnl) {
                                                                                        pointCB = (totalPoint / 70) * 5;
                                                                                      } else {
                                                                                        pointCB = (totalPoint / 100) * 5;
                                                                                      }
                                                                                    }
                                                                                  });
                                                                                  bool isAppCV = false;
                                                                                  appCV.forEach((element) {
                                                                                    if (element.userId == user.userId) {
                                                                                      isAppCV = true;
                                                                                    }
                                                                                  });
                                                                                  if (isAppCV) {
                                                                                    appCV.forEach((element) {
                                                                                      if (element.userId == user.userId) {
                                                                                        for (int i = 0; i < 10; i++) {
                                                                                          points.add(TextEditingController(text: element.listPoint![i].toString()));
                                                                                        }
                                                                                        points.add(TextEditingController(text: element.subPoint.toString()));
                                                                                        setState(() {
                                                                                          total.value = element.total!;
                                                                                          finalTotal.value = element.finalTotal!;
                                                                                        });
                                                                                      }
                                                                                    });
                                                                                  } else {
                                                                                    for (int i = 0; i < 11; i++) {
                                                                                      if (i == 3) {
                                                                                        points.add(TextEditingController(text: pointCB.toStringAsFixed(2)));
                                                                                      } else {
                                                                                        points.add(TextEditingController(text: initPoint[i].toString()));
                                                                                      }
                                                                                    }
                                                                                    double temp = 0;
                                                                                    for (var i = 0; i < 10; i++) {
                                                                                      temp += double.parse(points[i].text);
                                                                                    }
                                                                                    setState(() {
                                                                                      total.value = double.parse(temp.toStringAsFixed(2));
                                                                                      finalTotal.value = double.parse((temp - double.parse(points[10].text)).toStringAsFixed(2));
                                                                                    });
                                                                                  }

                                                                                  showAppreciate(
                                                                                    context: context,
                                                                                    user: user,
                                                                                    trainee: traineeClass[indexTrain],
                                                                                    userRegister: userRegister,
                                                                                  );
                                                                                },
                                                                                icon: const Icon(
                                                                                  CupertinoIcons.pencil_ellipsis_rectangle,
                                                                                  size: 22,
                                                                                  color: Colors.red,
                                                                                ));
                                                                          })
                                                                    ],
                                                                  )),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    )
                                                  : const Center(
                                                      child: Text(
                                                          'Chưa có sinh viên thực tập.'),
                                                    );
                                            } else {
                                              return const Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Center(child: Loading()),
                                                ],
                                              );
                                            }
                                          },
                                        )
                                      : const SizedBox.shrink())
                              : const Expanded(
                                  child: Center(
                                    child: Text(
                                        'Vui lòng nhấn vào nút xem để tiếp tục.'),
                                  ),
                                ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 35),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                        text: 'Khóa điểm',
                        width: 100,
                        height: 40,
                        onTap: () {}),
                    const SizedBox(width: 15),
                    CustomButton(
                      text: 'Xuất điểm',
                      width: 100,
                      height: 40,
                      onTap: () async {
                        if (selectedHK != HocKy.empty &&
                            selectedNH != NamHoc.empty) {
                          List<AppreciateCVModel> list = [];
                          appCV.forEach((element) {
                            if (selectedHK == HocKy.tatca &&
                                selectedNH == NamHoc.tatca) {
                              list.add(element);
                            } else if (selectedHK == HocKy.tatca) {
                              if (element.yearStart == selectedNH.start) {
                                list.add(element);
                              }
                            } else if (selectedNH == NamHoc.tatca) {
                              if (element.term == selectedHK) {
                                list.add(element);
                              }
                            } else if (element.term == selectedHK &&
                                element.yearStart == selectedNH.start) {
                              list.add(element);
                            }
                          });
                          await exportPDF(
                              myClass, selectedHK, selectedNH, list);
                        } else {
                          GV.error(
                              context: context,
                              message:
                                  'Vui lòng chọn học kỳ, năm học và kiểm tra lại danh sách trước khi xuất file.');
                        }
                      },
                    ),
                  ],
                ),
              )
            ],
          );
        });
  }

  showInfo({
    required BuildContext context,
    required UserModel user,
    required RegisterTraineeModel trainee,
    required UserRegisterModel userRegister,
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
                contentPadding: EdgeInsets.zero,
                shape: Border.all(width: 0.5),
                content: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    constraints: BoxConstraints(minWidth: screenWidth * 0.35),
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Table(
                          columnWidths: Map.from({
                            0: const FlexColumnWidth(3),
                            1: const FlexColumnWidth(2),
                          }),
                          children: [
                            TableRow(children: [
                              Text(
                                  'Mã sinh viên: ${user.userId!.toUpperCase()}'),
                              Text('Học kỳ thực tập: ${trainee.term}'),
                            ]),
                            TableRow(children: [
                              Text('Họ tên: ${user.userName}'),
                              Text(
                                  'Năm học: ${trainee.yearStart} -  ${trainee.yearEnd}'),
                            ]),
                            TableRow(children: [
                              Text(
                                  'Thời gian thực tập: Từ ngày: ${GV.readTimestamp(trainee.traineeStart!)} - Đến ngày: ${GV.readTimestamp(trainee.traineeEnd!)}'),
                              Text(
                                  'Ngày ứng tuyển: ${GV.readTimestamp(userRegister.createdAt!)}'),
                            ]),
                            TableRow(children: [
                              Text('Tại: ${userRegister.firmName}'),
                              Text('Vị trí thực tập: ${userRegister.jobName}'),
                            ]),
                          ],
                        ),
                        StreamBuilder(
                            stream: firestore
                                .collection('plans')
                                .doc(user.userId)
                                .snapshots(),
                            builder: (context, snapshotPlan) {
                              if (snapshotPlan.hasData &&
                                  snapshotPlan.data != null &&
                                  snapshotPlan.connectionState ==
                                      ConnectionState.active) {
                                final plan = PlanWorkModel.fromMap(
                                    snapshotPlan.data!.data()!);
                                return SizedBox(
                                  width: screenWidth * 0.55,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Table(
                                        columnWidths: Map.from({
                                          0: const FlexColumnWidth(3),
                                          1: const FlexColumnWidth(2),
                                        }),
                                        children: [
                                          TableRow(children: [
                                            Text(
                                                'Cán bộ hướng dẫn: ${plan.cbhdName}'),
                                            Text(
                                                'Ngày phân công:  ${GV.readTimestamp(plan.createdAt!)}'),
                                          ]),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Table(
                                          border: TableBorder.all(),
                                          columnWidths: Map.from({
                                            0: const FlexColumnWidth(1),
                                            1: const FlexColumnWidth(3),
                                            2: const FlexColumnWidth(1),
                                            3: const FlexColumnWidth(1)
                                          }),
                                          children: [
                                            TableRow(
                                              children: [
                                                Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: const Text(
                                                      'Tuần',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    )),
                                                Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: const Text(
                                                      'Nội dung công việc',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    )),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: const Text(
                                                    'Số buổi',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: const Text(
                                                    'Nhận xét',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            for (int i = 0;
                                                i < plan.listWork!.length;
                                                i++)
                                              TableRow(
                                                children: [
                                                  TableCell(
                                                    verticalAlignment:
                                                        TableCellVerticalAlignment
                                                            .middle,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            GV.readTimestamp(
                                                                plan
                                                                    .listWork![
                                                                        i]
                                                                    .dayStart!),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                          Text(
                                                            '${i + 1}',
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                          Text(
                                                            GV.readTimestamp(
                                                                plan
                                                                    .listWork![
                                                                        i]
                                                                    .dayEnd!),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  TableCell(
                                                    verticalAlignment:
                                                        TableCellVerticalAlignment
                                                            .middle,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            plan.listWork![i]
                                                                .content!,
                                                            textAlign:
                                                                TextAlign.start,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  TableCell(
                                                    verticalAlignment:
                                                        TableCellVerticalAlignment
                                                            .middle,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      child: Text(
                                                        '${plan.listWork![i].totalDay}',
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                  TableCell(
                                                    verticalAlignment:
                                                        TableCellVerticalAlignment
                                                            .middle,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      child: Text(
                                                        '${plan.listWork![i].comment}',
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }),
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

  showAppreciate({
    required BuildContext context,
    required UserModel user,
    required RegisterTraineeModel trainee,
    required UserRegisterModel userRegister,
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
                            Text('Họ tên: ${user.userName}'),
                            Text('Mã số: ${user.userId!.toUpperCase()}'),
                            Text('Vị trí thực tập: ${userRegister.jobName}'),
                            Text('Vị trí thực tập: ${userRegister.firmName}'),
                            Text(
                                'Thời gian thực tập: Từ ngày: ${GV.readTimestamp(trainee.traineeStart!)} - Đến ngày: ${GV.readTimestamp(trainee.traineeEnd!)}'),
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Table(
                                border: TableBorder.all(),
                                columnWidths: Map.from({
                                  0: const FlexColumnWidth(11),
                                  1: const FlexColumnWidth(2),
                                  2: const FlexColumnWidth(2),
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
                                          'Điểm tối đa',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        child: const Text(
                                          'Điểm chấm',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  rowAppreciate(
                                    content: appreciateCV[0],
                                    pointMax: pointAppreciateCV[0].toString(),
                                  ),
                                  rowAppreciate(
                                    content: appreciateCV[1],
                                    pointMax: pointAppreciateCV[1].toString(),
                                    point: points[0],
                                  ),
                                  rowAppreciate(
                                    content: appreciateCV[2],
                                    pointMax: pointAppreciateCV[2].toString(),
                                    point: points[1],
                                  ),
                                  rowAppreciate(
                                    content: appreciateCV[3],
                                    pointMax: pointAppreciateCV[3].toString(),
                                  ),
                                  rowAppreciate(
                                    content: appreciateCV[4],
                                    pointMax: pointAppreciateCV[4].toString(),
                                    point: points[2],
                                  ),
                                  rowAppreciate(
                                    content: appreciateCV[5],
                                    pointMax: pointAppreciateCV[5].toString(),
                                    point: points[3],
                                  ),
                                  rowAppreciate(
                                    content: appreciateCV[6],
                                    pointMax: pointAppreciateCV[6].toString(),
                                  ),
                                  rowAppreciate(
                                    content: appreciateCV[7],
                                    pointMax: pointAppreciateCV[7].toString(),
                                    point: points[4],
                                  ),
                                  rowAppreciate(
                                    content: appreciateCV[8],
                                    pointMax: pointAppreciateCV[8].toString(),
                                    point: points[5],
                                  ),
                                  rowAppreciate(
                                    content: appreciateCV[9],
                                    pointMax: pointAppreciateCV[9].toString(),
                                    point: points[6],
                                  ),
                                  rowAppreciate(
                                    content: appreciateCV[10],
                                    pointMax: pointAppreciateCV[10].toString(),
                                    point: points[7],
                                  ),
                                  rowAppreciate(
                                    content: appreciateCV[11],
                                    pointMax: pointAppreciateCV[11].toString(),
                                    point: points[8],
                                  ),
                                  rowAppreciate(
                                    content: appreciateCV[12],
                                    pointMax: pointAppreciateCV[12].toString(),
                                    point: points[9],
                                  ),
                                  TableRow(
                                    children: [
                                      TableCell(
                                          verticalAlignment:
                                              TableCellVerticalAlignment.middle,
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    appreciateCV[13],
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign:
                                                        TextAlign.justify,
                                                    overflow: TextOverflow.clip,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )),
                                      const TableCell(
                                          verticalAlignment:
                                              TableCellVerticalAlignment.middle,
                                          child: Padding(
                                            padding: EdgeInsets.all(10),
                                            child: Row(
                                              children: [
                                                Text(
                                                  "10",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  textAlign: TextAlign.center,
                                                  overflow: TextOverflow.clip,
                                                ),
                                              ],
                                            ),
                                          )),
                                      TableCell(
                                          verticalAlignment:
                                              TableCellVerticalAlignment.middle,
                                          child: ValueListenableBuilder(
                                              valueListenable: total,
                                              builder: (context, val, child) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          total.value
                                                              .toString(),
                                                          textAlign:
                                                              TextAlign.justify,
                                                          overflow:
                                                              TextOverflow.clip,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              })),
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      TableCell(
                                          verticalAlignment:
                                              TableCellVerticalAlignment.middle,
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    appreciateCV[14],
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign:
                                                        TextAlign.justify,
                                                    overflow: TextOverflow.clip,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )),
                                      const SizedBox.shrink(),
                                      TableCell(
                                        verticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        child: TextFormField(
                                          controller: points[10],
                                          minLines: 1,
                                          style: const TextStyle(fontSize: 13),
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                          onChanged: (value) {
                                            double temp = 0;
                                            for (var i = 0; i < 10; i++) {
                                              temp +=
                                                  double.parse(points[i].text);
                                            }
                                            setState(() {
                                              total.value = double.parse(
                                                  temp.toStringAsFixed(2));
                                              finalTotal.value = double.parse(
                                                  (temp -
                                                          double.parse(
                                                              points[10].text))
                                                      .toStringAsFixed(2));
                                            });
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                  TableRow(
                                    children: [
                                      TableCell(
                                          verticalAlignment:
                                              TableCellVerticalAlignment.middle,
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    appreciateCV[15],
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    textAlign:
                                                        TextAlign.justify,
                                                    overflow: TextOverflow.clip,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )),
                                      const SizedBox.shrink(),
                                      TableCell(
                                          verticalAlignment:
                                              TableCellVerticalAlignment.middle,
                                          child: ValueListenableBuilder(
                                              valueListenable: finalTotal,
                                              builder: (context, val, child) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        finalTotal.value
                                                            .toString(),
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        textAlign:
                                                            TextAlign.center,
                                                        overflow:
                                                            TextOverflow.clip,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              })),
                                    ],
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
                                if (_formKey.currentState!.validate()) {
                                  List<double> list = [];
                                  for (int i = 0; i < 10; i++) {
                                    list.add(double.parse(points[i].text));
                                  }
                                  String pointChar = '';
                                  if (finalTotal.value >= 9.0) {
                                    pointChar = 'A';
                                  } else if (finalTotal.value >= 8.0) {
                                    pointChar = 'B+';
                                  } else if (finalTotal.value >= 7.0) {
                                    pointChar = 'B';
                                  } else if (finalTotal.value >= 6.5) {
                                    pointChar = 'C+';
                                  } else if (finalTotal.value >= 5.5) {
                                    pointChar = 'C';
                                  } else if (finalTotal.value >= 5.0) {
                                    pointChar = 'D+';
                                  } else if (finalTotal.value >= 4.0) {
                                    pointChar = 'D';
                                  } else {
                                    pointChar = 'F';
                                  }
                                  AppreciateCVModel appreciateModel =
                                      AppreciateCVModel(
                                    cbhdId: userRegister.firmId,
                                    firmName: userRegister.firmName,
                                    jobName: userRegister.jobName,
                                    userId: user.userId,
                                    userName: user.userName,
                                    traineeStart: trainee.traineeStart,
                                    traineeEnd: trainee.traineeEnd,
                                    createdAt: Timestamp.now(),
                                    total: total.value,
                                    finalTotal: finalTotal.value,
                                    subPoint: double.parse(points[10].text),
                                    listPoint: list,
                                    term: trainee.term,
                                    yearStart: trainee.yearStart,
                                    yearEnd: trainee.yearEnd,
                                    pointChar: pointChar,
                                  );
                                  appCV.forEach((element) {
                                    if (element.userId ==
                                        appreciateModel.userId) {
                                      setState(() {
                                        element = appreciateModel;
                                      });
                                    }
                                  });
                                  firestore
                                      .collection('appreciatesCV')
                                      .doc(appreciateModel.userId)
                                      .set(appreciateModel.toMap());
                                  Navigator.of(context).pop();
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

  TableRow rowAppreciate({
    required String content,
    required String pointMax,
    TextEditingController? point,
  }) {
    return TableRow(
      children: [
        TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      content,
                      textAlign: TextAlign.justify,
                      style: point == null
                          ? const TextStyle(fontWeight: FontWeight.bold)
                          : null,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ],
              ),
            )),
        TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Text(
                    pointMax == '0' ? '' : pointMax,
                    textAlign: TextAlign.center,
                    style: point == null
                        ? const TextStyle(fontWeight: FontWeight.bold)
                        : null,
                    overflow: TextOverflow.clip,
                  ),
                ],
              ),
            )),
        point != null
            ? TableCell(
                verticalAlignment: TableCellVerticalAlignment.middle,
                child: TextFormField(
                  controller: point,
                  minLines: 1,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    double temp = 0;
                    for (var i = 0; i < 10; i++) {
                      temp += double.parse(points[i].text);
                    }
                    setState(() {
                      total.value = double.parse(temp.toStringAsFixed(2));
                      finalTotal.value = double.parse(
                          (temp - double.parse(points[10].text))
                              .toStringAsFixed(2));
                    });
                  },
                  validator: (value) =>
                      double.parse(value!) > double.parse(pointMax)
                          ? "Bé hơn hoặc bằng ${double.parse(pointMax)}"
                          : null,
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  showAppreciateCB({
    required BuildContext context,
    required UserModel user,
    required AppreciateModel appreciate,
  }) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double totalPoint = 0;
    bool isOnl = false;
    for (var i = 0; i < appreciate.listContent!.length; i++) {
      if (i < 3 && appreciate.listContent![i].point == 0) {
        isOnl = true;
      }
    }
    if (isOnl) {
      for (var i = 3; i < appreciate.listContent!.length; i++) {
        totalPoint += appreciate.listContent![i].point!;
      }
    } else {
      for (var i = 0; i < appreciate.listContent!.length; i++) {
        totalPoint += appreciate.listContent![i].point!;
      }
    }
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
                      constraints: BoxConstraints(minWidth: screenWidth * 0.55),
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Họ tên cán bộ hướng dẫn: ${appreciate.cbhdName}'),
                          Text('Họ tên sinh viên: ${user.userName}'),
                          Text('Mã số: ${user.userId!.toUpperCase()}'),
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
                                rowAppreciateCB(
                                  content: 'I. Tinh thần kỷ luật',
                                ),
                                rowAppreciateCB(
                                  content:
                                      'I.1. Thực hiện nội quy của cơ quan (nếu thực tập online thì không chẩm điểm)',
                                  point: appreciate.listContent?[0].point!,
                                ),
                                rowAppreciateCB(
                                  content:
                                      'I.2. Chấp hành giờ giấc làm việc (nếu thực tập online thì không chẩm điểm)',
                                  point: appreciate.listContent?[1].point!,
                                ),
                                rowAppreciateCB(
                                  content:
                                      'I.3. Thái độ giao tiếp với cán bộ trong đơn vị (nếu thực lập online thì không chấm điểm)',
                                  point: appreciate.listContent?[2].point!,
                                ),
                                rowAppreciateCB(
                                  content: 'I.4. Tích cực trong công việc',
                                  point: appreciate.listContent?[3].point!,
                                ),
                                rowAppreciateCB(
                                  content: 'II. Khả năng chuyên môn, nghiệp vụ',
                                ),
                                rowAppreciateCB(
                                  content: 'II.1. Đáp ứng yêu cầu công việc',
                                  point: appreciate.listContent?[4].point!,
                                ),
                                rowAppreciateCB(
                                  content:
                                      'II.2. Tinh thần học hỏi, nâng cao trình độ chuyên môn, nghiệp vụ',
                                  point: appreciate.listContent?[5].point!,
                                ),
                                rowAppreciateCB(
                                  content:
                                      'II.3. Có đề xuất, sáng kiến, năng động trong công việc',
                                  point: appreciate.listContent?[6].point!,
                                ),
                                rowAppreciateCB(
                                  content: 'III. Kết quả công tác',
                                ),
                                rowAppreciateCB(
                                  content:
                                      'III.1. Báo cáo tiến độ công việc cho cán bộ hướng dẫn mỗi tuần 1 lần',
                                  point: appreciate.listContent?[7].point!,
                                ),
                                rowAppreciateCB(
                                  content:
                                      'III.2. Hoàn thành công việc được giao',
                                  point: appreciate.listContent?[8].point!,
                                ),
                                rowAppreciateCB(
                                  content:
                                      'III.3. Kết quả công việc có đóng góp cho cơ quan nơi thực tập',
                                  point: appreciate.listContent?[9].point!,
                                ),
                                rowAppreciateCB(
                                  content: 'CỘNG',
                                  point: totalPoint,
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
                                  child: Text(appreciate.commentSV!),
                                )),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                              'Đánh giá của cơ quan về chương trình đào tạo (CTDT): ${appreciate.appreciateCTDT}'),
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
                                  child: Text(appreciate.commentCTDT!),
                                )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  TableRow rowAppreciateCB({
    required String content,
    double? point,
  }) {
    return TableRow(
      children: [
        TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: content == 'CỘNG'
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  Text(
                    content,
                    textAlign: TextAlign.center,
                    style: point == null || content == 'CỘNG'
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
                child: Center(
                    child: Text(
                  point.toString(),
                  style: content == 'CỘNG'
                      ? TextStyle(fontWeight: FontWeight.bold)
                      : null,
                )),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
