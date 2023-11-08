// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/data/constant.dart';
import 'package:tttt_project/models/firm_model.dart';
import 'package:tttt_project/models/register_trainee_model.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/widgets/custom_button.dart';
import 'package:tttt_project/widgets/dropdown_style.dart';
import 'package:tttt_project/widgets/loading.dart';
import 'package:tttt_project/widgets/user_controller.dart';

class ListStudentRegis extends StatefulWidget {
  const ListStudentRegis({
    super.key,
  });

  @override
  State<ListStudentRegis> createState() => _ListStudentRegisState();
}

class _ListStudentRegisState extends State<ListStudentRegis> {
  final firestore = FirebaseFirestore.instance;
  final currentUser = Get.put(UserController());
  String? userId;
  List<UserModel> loadUsers = [];
  List<JobRegisterModel> listRegis = [];
  UserModel user = UserModel();
  String selectedTT = TrangThai.empty;
  ValueNotifier<bool> isViewed = ValueNotifier(false);

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
                          width: screenWidth * 0.06,
                          child: const Text(
                            "Trạng thái",
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
                                "Chọn",
                                style: DropdownStyle.hintStyle,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            items: dsttAll
                                .map((String tt) => DropdownMenuItem<String>(
                                      value: tt,
                                      child: Center(
                                        child: Text(
                                          tt,
                                          style: DropdownStyle.itemStyle,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            value: selectedTT != TrangThai.empty
                                ? selectedTT
                                : null,
                            onChanged: (value) {
                              setState(() {
                                selectedTT = value!;
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
                    const SizedBox(width: 75),
                    CustomButton(
                        text: 'Xem',
                        width: 100,
                        height: 45,
                        onTap: () {
                          if (selectedTT != TrangThai.empty) {
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
                              flex: 3,
                              child: Text(
                                'MSSV',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                'Họ tên',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Text(
                                'Vị trí ứng tuyển',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Trạng thái',
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
                              child: StreamBuilder(
                                stream: firestore
                                    .collection('firms')
                                    .where('firmId', isEqualTo: userId)
                                    .snapshots(),
                                builder: (context, snapshotFirm) {
                                  List<FirmModel> loadFirms = [];
                                  if (snapshotFirm.hasData &&
                                      snapshotFirm.data != null &&
                                      snapshotFirm.connectionState ==
                                          ConnectionState.active) {
                                    snapshotFirm.data?.docs.forEach((element) {
                                      loadFirms.add(
                                          FirmModel.fromMap(element.data()));
                                    });
                                    listRegis = [];
                                    for (var element in loadFirms) {
                                      if (element.firmId == userId) {
                                        for (var e in element.listRegis!) {
                                          if (selectedTT == TrangThai.tatca &&
                                              e.isConfirmed == false) {
                                            listRegis.add(e);
                                          } else {
                                            if (e.status == selectedTT &&
                                                e.isConfirmed == false) {
                                              listRegis.add(e);
                                            }
                                          }
                                        }
                                      }
                                    }
                                    return listRegis.isNotEmpty
                                        ? ListView.builder(
                                            itemCount: listRegis.length,
                                            shrinkWrap: true,
                                            itemBuilder: (context, indexRegis) {
                                              return Container(
                                                height: screenHeight * 0.05,
                                                color: indexRegis % 2 == 0
                                                    ? Colors.blue.shade50
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
                                                      flex: 3,
                                                      child: Text(
                                                          '${listRegis[indexRegis].userId}'
                                                              .toUpperCase(),
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                                    Expanded(
                                                      flex: 4,
                                                      child: Text(
                                                          '${listRegis[indexRegis].userName}',
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Text(
                                                          '${listRegis[indexRegis].jobName}',
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Text(
                                                          listRegis[indexRegis]
                                                                      .status! ==
                                                                  TrangThai
                                                                      .accept
                                                              ? 'Chờ xác nhận'
                                                              : listRegis[
                                                                      indexRegis]
                                                                  .status!,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                          textAlign:
                                                              TextAlign.center),
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
                                                                  'Thông tin và xét duyệt',
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          1),
                                                              onPressed:
                                                                  () async {
                                                                loadUsers.forEach(
                                                                    (element) {
                                                                  if (element
                                                                          .userId ==
                                                                      listRegis[
                                                                              indexRegis]
                                                                          .userId) {
                                                                    user =
                                                                        element;
                                                                  }
                                                                });
                                                                showInfoAndReply(
                                                                  context:
                                                                      context,
                                                                  jobRegister:
                                                                      listRegis[
                                                                          indexRegis],
                                                                );
                                                              },
                                                              icon: Icon(
                                                                  CupertinoIcons
                                                                      .pencil_outline,
                                                                  size: 22,
                                                                  color: Colors
                                                                      .blue
                                                                      .shade900))
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          )
                                        : const Center(
                                            child: Text(
                                                'Chưa có sinh viên đăng ký.'));
                                  } else {
                                    return const Loading();
                                  }
                                },
                              ),
                            )
                          : selectedTT == TrangThai.empty
                              ? Expanded(
                                  child: StreamBuilder(
                                    stream: firestore
                                        .collection('firms')
                                        .where('firmId', isEqualTo: userId)
                                        .snapshots(),
                                    builder: (context, snapshotFirm) {
                                      List<FirmModel> loadFirms = [];
                                      if (snapshotFirm.hasData &&
                                          snapshotFirm.data != null &&
                                          snapshotFirm.connectionState ==
                                              ConnectionState.active) {
                                        snapshotFirm.data?.docs
                                            .forEach((element) {
                                          loadFirms.add(FirmModel.fromMap(
                                              element.data()));
                                        });
                                        listRegis = [];
                                        for (var element in loadFirms) {
                                          if (element.firmId == userId) {
                                            for (var e in element.listRegis!) {
                                              if (e.status == TrangThai.wait ||
                                                  e.status ==
                                                          TrangThai.accept &&
                                                      e.isConfirmed == false) {
                                                listRegis.add(e);
                                              }
                                            }
                                          }
                                        }
                                        return listRegis.isNotEmpty
                                            ? ListView.builder(
                                                itemCount: listRegis.length,
                                                shrinkWrap: true,
                                                itemBuilder:
                                                    (context, indexRegis) {
                                                  return Container(
                                                    height: screenHeight * 0.05,
                                                    color: indexRegis % 2 == 0
                                                        ? Colors.blue.shade50
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
                                                          flex: 3,
                                                          child: Text(
                                                              '${listRegis[indexRegis].userId}'
                                                                  .toUpperCase(),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center),
                                                        ),
                                                        Expanded(
                                                          flex: 4,
                                                          child: Text(
                                                              '${listRegis[indexRegis].userName}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center),
                                                        ),
                                                        Expanded(
                                                          flex: 5,
                                                          child: Text(
                                                              '${listRegis[indexRegis].jobName}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center),
                                                        ),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Text(
                                                              listRegis[indexRegis]
                                                                          .status! ==
                                                                      TrangThai
                                                                          .accept
                                                                  ? 'Chờ xác nhận'
                                                                  : listRegis[
                                                                          indexRegis]
                                                                      .status!,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .red),
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
                                                                    'Thông tin và xét duyệt',
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            1),
                                                                onPressed:
                                                                    () async {
                                                                  loadUsers.forEach(
                                                                      (element) {
                                                                    if (element
                                                                            .userId ==
                                                                        listRegis[indexRegis]
                                                                            .userId) {
                                                                      user =
                                                                          element;
                                                                    }
                                                                  });
                                                                  showInfoAndReply(
                                                                    context:
                                                                        context,
                                                                    jobRegister:
                                                                        listRegis[
                                                                            indexRegis],
                                                                  );
                                                                },
                                                                icon: Icon(
                                                                    CupertinoIcons
                                                                        .pencil_outline,
                                                                    size: 22,
                                                                    color: Colors
                                                                        .blue
                                                                        .shade900),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              )
                                            : const Center(
                                                child: Text(
                                                    'Chưa có sinh viên đăng ký.'));
                                      } else {
                                        return const Loading();
                                      }
                                    },
                                  ),
                                )
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

  showInfoAndReply({
    required BuildContext context,
    required JobRegisterModel jobRegister,
  }) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      barrierColor: Colors.black12,
      barrierDismissible: false,
      builder: (context) {
        return StreamBuilder(
            stream: firestore
                .collection('trainees')
                .where('userId', isEqualTo: jobRegister.userId!)
                .snapshots(),
            builder: (context, snapshotTrainee) {
              RegisterTraineeModel loadTrainee = RegisterTraineeModel();
              if (snapshotTrainee.data != null) {
                loadTrainee = RegisterTraineeModel.fromMap(
                    snapshotTrainee.data!.docs.first.data());
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
                                child: Text('Thông tin ứng tuyển',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
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
                        content: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          constraints:
                              BoxConstraints(minWidth: screenWidth * 0.3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                  'Mã sinh viên: ${user.userId!.toUpperCase()}'),
                              Text(
                                'Họ tên: ${user.userName!}',
                              ),
                              Text(
                                'Ngành: ${user.major!}',
                              ),
                              Text(
                                'Email: ${user.email!}',
                              ),
                              Text(
                                'Số điện thoại: ${user.phone!}',
                              ),
                              Text(
                                'Ngày ứng tuyển: ${GV.readTimestamp(jobRegister.createdAt!)}',
                              ),
                              Text(
                                  'Thực tập: Từ ngày: ${GV.readTimestamp(loadTrainee.traineeStart!)} - Đến ngày: ${GV.readTimestamp(loadTrainee.traineeEnd!)}'),
                              if (jobRegister.status == TrangThai.accept)
                                Text(
                                  'Ngày duyệt: ${GV.readTimestamp(jobRegister.repliedAt!)}',
                                ),
                            ],
                          ),
                        ),
                        actions: jobRegister.status == TrangThai.wait
                            ? [
                                ElevatedButton(
                                  child: const Text(
                                    "Chấp nhận",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () {
                                    for (var d in loadTrainee.listRegis!) {
                                      if (d.firmId == userId) {
                                        d.status = TrangThai.accept;
                                        d.repliedAt = Timestamp.now();
                                      }
                                    }
                                    GV.traineesCol
                                        .doc(jobRegister.userId)
                                        .update({
                                      'listRegis': loadTrainee.listRegis!
                                          .map((i) => i.toMap())
                                          .toList(),
                                    });
                                    jobRegister.status = TrangThai.accept;
                                    jobRegister.repliedAt = Timestamp.now();
                                    GV.firmsCol.doc(userId).update({
                                      'listRegis': listRegis
                                          .map((i) => i.toMap())
                                          .toList(),
                                    });
                                    Navigator.pop(context);
                                    GV.success(
                                        context: context,
                                        message:
                                            'Đã duyệt sinh viên, chờ xác nhận.');
                                  },
                                ),
                                ElevatedButton(
                                  child: const Text(
                                    "Từ chối",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red),
                                  ),
                                  onPressed: () async {
                                    for (var d in loadTrainee.listRegis!) {
                                      if (d.firmId == userId) {
                                        d.status = TrangThai.reject;
                                        d.repliedAt = Timestamp.now();
                                      }
                                    }
                                    GV.traineesCol
                                        .doc(jobRegister.userId)
                                        .update({
                                      'listRegis': loadTrainee.listRegis!
                                          .map((i) => i.toMap())
                                          .toList(),
                                    });
                                    jobRegister.status = TrangThai.reject;
                                    jobRegister.repliedAt = Timestamp.now();
                                    GV.firmsCol.doc(userId).update({
                                      'listRegis': listRegis
                                          .map((i) => i.toMap())
                                          .toList(),
                                    });
                                    Navigator.pop(context);
                                    GV.error(
                                        context: context,
                                        message: 'Đã từ chối nhận sinh viên.');
                                  },
                                ),
                              ]
                            : null,
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            });
      },
    );
  }
}
