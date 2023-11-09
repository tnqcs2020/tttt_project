import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/data/constant.dart';
import 'package:tttt_project/models/appreciate_model.dart';
import 'package:tttt_project/models/firm_model.dart';
import 'package:tttt_project/models/plan_work_model.dart';
import 'package:tttt_project/models/register_trainee_model.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/widgets/custom_button.dart';
import 'package:tttt_project/widgets/custom_radio.dart';
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
  List<FirmModel> firms = [];
  String myClass = '';
  List<TextEditingController> points = [];
  final _formKey = GlobalKey<FormState>();

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
    var loadFirm = await firestore.collection('firms').get();
    if (loadFirm.docs.isNotEmpty) {
      setState(() {
        firms = loadFirm.docs.map((e) => FirmModel.fromMap(e.data())).toList();
      });
    }
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
                padding: const EdgeInsets.only(top: 15),
                child: Container(
                  decoration: const BoxDecoration(color: Colors.white),
                  height: screenHeight * 0.45,
                  width: screenWidth * 0.55,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        color: Colors.green,
                        height: screenHeight * 0.035,
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
                              flex: 5,
                              child: Text(
                                'Công ty thực tập',
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
                                            //                 trainees.forEach((e2) {
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
                                            //                 });
                                          });
                                          return traineeClass.isNotEmpty
                                              ? ListView.builder(
                                                  itemCount:
                                                      traineeClass.length,
                                                  shrinkWrap: true,
                                                  itemBuilder:
                                                      (context, indexTrain) {
                                                    FirmModel firm =
                                                        FirmModel();
                                                    traineeClass[indexTrain]
                                                        .listRegis!
                                                        .forEach((e1) {
                                                      if (e1.isConfirmed ==
                                                          true) {
                                                        firms.forEach((e2) {
                                                          if (e1.firmId ==
                                                              e2.firmId) {
                                                            firm = e2;
                                                          }
                                                        });
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
                                                                        .center),
                                                          ),
                                                          Expanded(
                                                            flex: 3,
                                                            child: Text(
                                                                '${traineeClass[indexTrain].studentName}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center),
                                                          ),
                                                          Expanded(
                                                            flex: 5,
                                                            child: Text(
                                                                '${firm.firmName}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center),
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
                                                                          'Thông tin sinh viên',
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              1),
                                                                      onPressed:
                                                                          () {},
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .info,
                                                                        size:
                                                                            22,
                                                                        color: Colors
                                                                            .blue
                                                                            .shade800,
                                                                      )),
                                                                  IconButton(
                                                                      tooltip:
                                                                          'Đánh giá',
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              1),
                                                                      onPressed:
                                                                          () {},
                                                                      icon:
                                                                          const Icon(
                                                                        CupertinoIcons
                                                                            .pencil_ellipsis_rectangle,
                                                                        size:
                                                                            22,
                                                                        color: Colors
                                                                            .red,
                                                                      ))
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
                                                        FirmModel firm =
                                                            FirmModel();
                                                        UserRegisterModel
                                                            userRegister =
                                                            UserRegisterModel();
                                                        traineeClass[indexTrain]
                                                            .listRegis!
                                                            .forEach((e1) {
                                                          if (e1.isConfirmed ==
                                                              true) {
                                                            firms.forEach((e2) {
                                                              if (e1.firmId ==
                                                                  e2.firmId) {
                                                                firm = e2;
                                                              }
                                                            });
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
                                                                            .center),
                                                              ),
                                                              Expanded(
                                                                flex: 3,
                                                                child: Text(
                                                                    '${traineeClass[indexTrain].studentName}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center),
                                                              ),
                                                              Expanded(
                                                                flex: 5,
                                                                child: Text(
                                                                  '${firm.firmName}',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .justify,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
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
                                                                              'Thông tin sinh viên',
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
                                                                              Icon(
                                                                            Icons.info,
                                                                            size:
                                                                                22,
                                                                            color:
                                                                                Colors.blue.shade800,
                                                                          )),
                                                                      IconButton(
                                                                          tooltip:
                                                                              'Đánh giá',
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              bottom:
                                                                                  1),
                                                                          onPressed:
                                                                              () {
                                                                            showAppreciate(
                                                                                context: context,
                                                                                user: user,
                                                                                trainee: traineeClass[indexTrain],
                                                                                userRegister: userRegister,
                                                                                firms: firms);
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
                        Text('Tại: ${userRegister.firmName}'),
                        Text('Vị trí thực tập: ${userRegister.jobName}'),
                        Text(
                            'Ngày ứng tuyển: ${GV.readTimestamp(userRegister.createdAt!)}'),
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

  showAppreciate({
    required BuildContext context,
    required UserModel user,
    required RegisterTraineeModel trainee,
    required UserRegisterModel userRegister,
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
                            Text('Họ tên: ${user.userName}'),
                            Text('Mã số: ${user.userId}'),
                            Text('Vị trí thực tập: ${userRegister.jobName}'),
                            Text('Vị trí thực tập: ${userRegister.firmName}'),
                            Text(
                                'Thời gian thực tập: Từ ngày: ${GV.readTimestamp(trainee.traineeStart!)} - Đến ngày: ${GV.readTimestamp(trainee.traineeEnd!)}'),
                            // Padding(
                            //   padding: const EdgeInsets.only(top: 10),
                            //   child: Table(
                            //     border: TableBorder.all(),
                            //     columnWidths: Map.from({
                            //       0: const FlexColumnWidth(11),
                            //       1: const FlexColumnWidth(3),
                            //     }),
                            //     children: [
                            //       TableRow(
                            //         children: [
                            //           Container(
                            //               padding: const EdgeInsets.all(10),
                            //               child: const Text(
                            //                 'Nội dung đánh giá',
                            //                 textAlign: TextAlign.center,
                            //                 style: TextStyle(
                            //                   fontWeight: FontWeight.bold,
                            //                 ),
                            //               )),
                            //           Container(
                            //             padding: const EdgeInsets.all(10),
                            //             child: const Text(
                            //               'Điểm chấm (từ 1-10)',
                            //               textAlign: TextAlign.center,
                            //               style: TextStyle(
                            //                 fontWeight: FontWeight.bold,
                            //               ),
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //       rowAppreciate(
                            //         content: 'I. Tinh thần kỷ luật',
                            //       ),
                            //       rowAppreciate(
                            //         content:
                            //             'I.1. Thực hiện nội quy của cơ quan (nếu thực tập online thì không chẩm điểm)',
                            //         point: points[0],
                            //       ),
                            //       rowAppreciate(
                            //         content:
                            //             'I.2. Chấp hành giờ giấc làm việc (nếu thực tập online thì không chẩm điểm)',
                            //         point: points[1],
                            //       ),
                            //       rowAppreciate(
                            //         content:
                            //             'I.3. Thái độ giao tiếp với cán bộ trong đơn vị (nếu thực lập online thì không chấm điểm)',
                            //         point: points[2],
                            //       ),
                            //       rowAppreciate(
                            //         content: 'I.4. Tích cực trong công việc',
                            //         point: points[3],
                            //       ),
                            //       rowAppreciate(
                            //         content:
                            //             'II. Khả năng chuyên môn, nghiệp vụ',
                            //       ),
                            //       rowAppreciate(
                            //         content: 'II.1. Đáp ứng yêu cầu công việc',
                            //         point: points[4],
                            //       ),
                            //       rowAppreciate(
                            //         content:
                            //             'II.2. Tinh thần học hỏi, nâng cao trình độ chuyên môn, nghiệp vụ',
                            //         point: points[5],
                            //       ),
                            //       rowAppreciate(
                            //         content:
                            //             'II.3. Có đề xuất, sáng kiến, năng động trong công việc',
                            //         point: points[6],
                            //       ),
                            //       rowAppreciate(
                            //         content: 'III. Kết quả công tác',
                            //       ),
                            //       rowAppreciate(
                            //         content:
                            //             'III.1. Báo cáo tiến độ công việc cho cán bộ hướng dẫn mỗi tuần 1 lần',
                            //         point: points[7],
                            //       ),
                            //       rowAppreciate(
                            //         content:
                            //             'III.2. Hoàn thành công việc được giao',
                            //         point: points[8],
                            //       ),
                            //       rowAppreciate(
                            //         content:
                            //             'III.3. Kết quả công việc có đóng góp cho cơ quan nơi thực tập',
                            //         point: points[9],
                            //       ),
                            //     ],
                            //   ),
                            // ),
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
                                // if (_formKey.currentState!.validate()) {
                                //   List<ContentAppreciateModel>
                                //       contentAppreciates = [];
                                //   for (var index = 0; index < 10; index++) {
                                //     contentAppreciates.add(
                                //       ContentAppreciateModel(
                                //         content: contentAppreciate[index],
                                //         title: index < 4
                                //             ? 'I. Tinh thần kỷ luật'
                                //             : index < 7
                                //                 ? 'II. Khả năng chuyên môn, nghiệp vụ'
                                //                 : 'III. Kết quả công tác',
                                //         point: double.parse(points[index].text),
                                //       ),
                                //     );
                                //   }
                                //   final appreciate = AppreciateModel(
                                //     cbhdId: plan.cbhdId,
                                //     cbhdName: plan.cbhdName,
                                //     jobName: jobRegister.jobName,
                                //     commentCTDT: commentCTDT.text,
                                //     commentSV: commentSV.text,
                                //     createdAt: Timestamp.now(),
                                //     traineeEnd: plan.traineeEnd,
                                //     traineeStart: plan.traineeStart,
                                //     userId: jobRegister.userId,
                                //     appreciateCTDT: appreciateCTDT,
                                //     listContent: contentAppreciates,
                                //     firmName: firms
                                //         .firstWhere((element) =>
                                //             element.firmId == userId)
                                //         .firmName,
                                //     jobId: jobRegister.jobId,
                                //   );
                                //   firestore
                                //       .collection('appreciates')
                                //       .doc(appreciate.userId)
                                //       .set(appreciate.toMap());
                                //   GV.success(
                                //       context: context,
                                //       message: 'Cập nhật thành công.');
                                // }
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
                  validator: (value) =>
                      double.parse(value!) > 10 ? "Bé hơn hoặc bằng 10" : null,
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
