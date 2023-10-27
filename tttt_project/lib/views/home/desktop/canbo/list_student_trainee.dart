// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/data/constant.dart';
import 'package:tttt_project/models/firm_model.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/widgets/loading.dart';
import 'package:tttt_project/widgets/user_controller.dart';

class ListStudentTrainee extends StatefulWidget {
  const ListStudentTrainee({
    super.key,
  });

  @override
  State<ListStudentTrainee> createState() => _ListStudentTraineeState();
}

class _ListStudentTraineeState extends State<ListStudentTrainee> {
  final currentUser = Get.put(UserController());
  String? userId;
  List<UserModel> loadUsers = [];
  List<JobRegisterModel> listRegis = [];
  ValueNotifier selectedJob = ValueNotifier(TrangThai.wait);
  UserModel user = UserModel(
    uid: null,
    userId: null,
    name: null,
    password: null,
    group: null,
  );

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
      DocumentSnapshot<Map<String, dynamic>> isExistUser = await GV.usersCol
          .doc(sharedPref
              .getString(
                'userId',
              )
              .toString())
          .get();
      if (isExistUser.data() != null) {
        currentUser.setCurrentUser(
          setUid: isExistUser.data()?['uid'],
          setUserId: isExistUser.data()?['userId'],
          setName: isExistUser.data()?['name'],
          setClassName: isExistUser.data()?['className'],
          setCourse: isExistUser.data()?['course'],
          setGroup: isExistUser.data()?['group'],
          setMajor: isExistUser.data()?['major'],
          setEmail: isExistUser.data()?['email'],
          setMenuSelected: sharedPref.getInt('menuSelected'),
          setIsRegistered: isExistUser.data()!['isRegistered'],
        );
      }
    }
  }

  // getTrainee(String userId) async {
  //   RegisterTraineeModel loadTrainee = RegisterTraineeModel();
  //   var load = await GV.traineesCol.doc(userId).get();
  //   if (load.data() != null) {
  //     loadTrainee = RegisterTraineeModel.fromMap(load.data()!);
  //   }
  //   return loadTrainee;
  // }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Obx(
      () => StreamBuilder(
        stream: GV.firmsCol
            .where('firmId', isEqualTo: currentUser.userId.value)
            .snapshots(),
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
                  if (e.isConfirmed == true) {
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
                                  child: ListTile(
                                    title:
                                        Text(listRegis[indexRegis].userName!),
                                    subtitle: Text(
                                        'Vị trí ứng tuyển: ${listRegis[indexRegis].jobName}'),
                                    onTap: () async {
                                      loadUsers.forEach((element) {
                                        if (element.userId ==
                                            listRegis[indexRegis].userId) {
                                          user = element;
                                        }
                                      });
                                      for (var d in listRegis) {
                                        if (d.userId == user.userId) {
                                          setState(() {
                                            selectedJob.value = d.status;
                                          });
                                        }
                                      }
                                      showDialog(
                                        context: context,
                                        barrierColor: Colors.transparent,
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
                                                // RegisterTraineeModel loadTrainee =
                                                //     RegisterTraineeModel();
                                                // if (snapshotTrainee.data != null) {
                                                //   loadTrainee =
                                                //       RegisterTraineeModel.fromMap(
                                                //           snapshotTrainee
                                                //               .data!.docs.first
                                                //               .data());
                                                // }
                                                return ValueListenableBuilder(
                                                  valueListenable: selectedJob,
                                                  builder:
                                                      (context, value, child) {
                                                    return Padding(
                                                      padding: EdgeInsets.only(
                                                        top:
                                                            screenHeight * 0.06,
                                                        bottom:
                                                            screenHeight * 0.02,
                                                        left:
                                                            screenWidth * 0.27,
                                                        right:
                                                            screenWidth * 0.08,
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          AlertDialog(
                                                            scrollable: true,
                                                            title: Container(
                                                              color: Colors.blue
                                                                  .shade600,
                                                              height: 50,
                                                              padding:
                                                                  const EdgeInsets
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
                                                                  const SizedBox(
                                                                    width: 30,
                                                                  ),
                                                                  const Expanded(
                                                                    child: Text(
                                                                        'Thông tin ứng tuyển',
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight
                                                                                .bold),
                                                                        textAlign:
                                                                            TextAlign.center),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 30,
                                                                    child: IconButton(
                                                                        padding: const EdgeInsets.only(bottom: 1),
                                                                        onPressed: () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        icon: const Icon(Icons.close)),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            titlePadding:
                                                                EdgeInsets.zero,
                                                            shape: Border.all(),
                                                            content:
                                                                ConstrainedBox(
                                                              constraints:
                                                                  BoxConstraints(
                                                                      minWidth:
                                                                          screenWidth *
                                                                              0.35),
                                                              child: Form(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: <Widget>[
                                                                    Text(
                                                                        'Mã sinh viên: ${user.userId!}'),
                                                                    Text(
                                                                      'Họ tên${user.name!}',
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
                                                                      'Ngày đăng ký: ${listRegis[indexRegis].createdAt.toString()}',
                                                                    ),
                                                                    Text(
                                                                      'Ngày duyệt: ${listRegis[indexRegis].createdAt.toString()}',
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            actions: [],
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              });
                                        },
                                      );
                                    },
                                    trailing:
                                        Text(listRegis[indexRegis].status!),
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
                    child: Center(child: Text('Chưa có sinh viên thực tập.')),
                  );
          } else {
            return const Padding(
              padding: EdgeInsets.only(top: 200),
              child: Loading(),
            );
          }
        },
      ),
    );
  }
}
