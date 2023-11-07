// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/data/constant.dart';
import 'package:tttt_project/models/firm_model.dart';
import 'package:tttt_project/models/register_trainee_model.dart';
import 'package:tttt_project/models/user_model.dart';
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
  final currentUser = Get.put(UserController());
  String? userId;
  List<UserModel> loadUsers = [];
  List<JobRegisterModel> listRegis = [];
  UserModel user = UserModel();

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
    return StreamBuilder(
      stream: GV.firmsCol.where('firmId', isEqualTo: userId).snapshots(),
      builder: (context, snapshotFirm) {
        List<FirmModel> loadFirms = [];
        if (snapshotFirm.hasData &&
            snapshotFirm.data != null &&
            snapshotFirm.connectionState == ConnectionState.active) {
          snapshotFirm.data?.docs.forEach((element) {
            loadFirms.add(FirmModel.fromMap(element.data()));
          });
          listRegis = [];
          for (var element in loadFirms) {
            if (element.firmId == userId) {
              for (var e in element.listRegis!) {
                if (e.status == TrangThai.wait ||
                    e.status == TrangThai.accept && e.isConfirmed == false) {
                  listRegis.add(e);
                }
              }
            }
          }
          return listRegis.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.5,
                        child: ListView.builder(
                          itemCount: listRegis.length,
                          shrinkWrap: true,
                          itemBuilder: (context, indexRegis) {
                            return SizedBox(
                              width: screenWidth * 0.5,
                              child: Card(
                                elevation: 5,
                                child: ListTile(
                                  title: Text(listRegis[indexRegis].userName!),
                                  subtitle: Text(
                                      'Vị trí ứng tuyển: ${listRegis[indexRegis].jobName}'),
                                  onTap: () async {
                                    loadUsers.forEach((element) {
                                      if (element.userId ==
                                          listRegis[indexRegis].userId) {
                                        user = element;
                                      }
                                    });
                                    showDialog(
                                      context: context,
                                      barrierColor: Colors.black12,
                                      barrierDismissible: false,
                                      builder: (context) {
                                        return StreamBuilder(
                                            stream: GV.traineesCol
                                                .where('userId',
                                                    isEqualTo:
                                                        listRegis[indexRegis]
                                                            .userId!)
                                                .snapshots(),
                                            builder:
                                                (context, snapshotTrainee) {
                                              RegisterTraineeModel loadTrainee =
                                                  RegisterTraineeModel();
                                              if (snapshotTrainee.data !=
                                                  null) {
                                                loadTrainee =
                                                    RegisterTraineeModel
                                                        .fromMap(snapshotTrainee
                                                            .data!.docs.first
                                                            .data());
                                              }
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
                                                      scrollable: true,
                                                      title: Container(
                                                        color: Colors
                                                            .blue.shade600,
                                                        height:
                                                            screenHeight * 0.06,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 10),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            const SizedBox(
                                                              width: 30,
                                                            ),
                                                            const Expanded(
                                                              child: Text(
                                                                  'Thông tin ứng tuyển',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center),
                                                            ),
                                                            SizedBox(
                                                              width: 30,
                                                              child: IconButton(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              1),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .close)),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      titlePadding:
                                                          EdgeInsets.zero,
                                                      shape: Border.all(
                                                          width: 0.5),
                                                      content: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 10),
                                                        constraints:
                                                            BoxConstraints(
                                                                minWidth:
                                                                    screenWidth *
                                                                        0.3),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
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
                                                              'Ngày ứng tuyển: ${GV.readTimestamp(listRegis[indexRegis].createdAt!)}',
                                                            ),
                                                            Text(
                                                                'Từ ngày: ${GV.readTimestamp(listRegis[indexRegis].traineeStart!)} - Đến ngày: ${GV.readTimestamp(listRegis[indexRegis].traineeEnd!)}'),
                                                            if (listRegis[
                                                                        indexRegis]
                                                                    .status ==
                                                                TrangThai
                                                                    .accept)
                                                              Text(
                                                                'Ngày duyệt: ${GV.readTimestamp(listRegis[indexRegis].repliedAt!)}',
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                      actions:
                                                          listRegis[indexRegis]
                                                                      .status ==
                                                                  TrangThai.wait
                                                              ? [
                                                                  ElevatedButton(
                                                                    child:
                                                                        const Text(
                                                                      "Chấp nhận",
                                                                      style: TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      for (var d
                                                                          in loadTrainee
                                                                              .listRegis!) {
                                                                        if (d.firmId ==
                                                                            userId) {
                                                                          d.status =
                                                                              TrangThai.accept;
                                                                          d.repliedAt =
                                                                              Timestamp.now();
                                                                        }
                                                                      }
                                                                      GV.traineesCol
                                                                          .doc(listRegis[indexRegis]
                                                                              .userId)
                                                                          .update({
                                                                        'listRegis': loadTrainee
                                                                            .listRegis!
                                                                            .map((i) =>
                                                                                i.toMap())
                                                                            .toList(),
                                                                      });
                                                                      listRegis[indexRegis]
                                                                              .status =
                                                                          TrangThai
                                                                              .accept;
                                                                      listRegis[indexRegis]
                                                                              .repliedAt =
                                                                          Timestamp
                                                                              .now();
                                                                      GV.firmsCol
                                                                          .doc(
                                                                              userId)
                                                                          .update({
                                                                        'listRegis': listRegis
                                                                            .map((i) =>
                                                                                i.toMap())
                                                                            .toList(),
                                                                      });
                                                                      Navigator.pop(
                                                                          context);
                                                                      GV.success(
                                                                          context:
                                                                              context,
                                                                          message:
                                                                              'Đã duyệt sinh viên, chờ xác nhận.');
                                                                    },
                                                                  ),
                                                                  ElevatedButton(
                                                                    child:
                                                                        const Text(
                                                                      "Từ chối",
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.red),
                                                                    ),
                                                                    onPressed:
                                                                        () async {
                                                                      for (var d
                                                                          in loadTrainee
                                                                              .listRegis!) {
                                                                        if (d.firmId ==
                                                                            userId) {
                                                                          d.status =
                                                                              TrangThai.reject;
                                                                          d.repliedAt =
                                                                              Timestamp.now();
                                                                        }
                                                                      }
                                                                      GV.traineesCol
                                                                          .doc(listRegis[indexRegis]
                                                                              .userId)
                                                                          .update({
                                                                        'listRegis': loadTrainee
                                                                            .listRegis!
                                                                            .map((i) =>
                                                                                i.toMap())
                                                                            .toList(),
                                                                      });
                                                                      listRegis[indexRegis]
                                                                              .status =
                                                                          TrangThai
                                                                              .reject;
                                                                      listRegis[indexRegis]
                                                                              .repliedAt =
                                                                          Timestamp
                                                                              .now();
                                                                      GV.firmsCol
                                                                          .doc(
                                                                              userId)
                                                                          .update({
                                                                        'listRegis': listRegis
                                                                            .map((i) =>
                                                                                i.toMap())
                                                                            .toList(),
                                                                      });
                                                                      Navigator.pop(
                                                                          context);
                                                                      GV.error(
                                                                          context:
                                                                              context,
                                                                          message:
                                                                              'Đã từ chối nhận sinh viên.');
                                                                    },
                                                                  ),
                                                                ]
                                                              : null,
                                                    ),
                                                  ],
                                                ),
                                              );
                                            });
                                      },
                                    );
                                  },
                                  trailing: listRegis[indexRegis].status ==
                                          TrangThai.accept
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(listRegis[indexRegis].status!),
                                            const Text(
                                              'Chờ xác nhận',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            )
                                          ],
                                        )
                                      : Text(listRegis[indexRegis].status!),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
              : const Padding(
                  padding: EdgeInsets.only(top: 200),
                  child: Center(child: Text('Chưa có sinh viên đăng ký.')),
                );
        } else {
          return const Padding(
            padding: EdgeInsets.only(top: 200),
            child: Loading(),
          );
        }
      },
    );
  }
}
