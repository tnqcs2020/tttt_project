// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/data/constant.dart';
import 'package:tttt_project/models/firm_model.dart';
import 'package:tttt_project/models/register_trainee_model.dart';
import 'package:tttt_project/widgets/loading.dart';
import 'package:tttt_project/widgets/user_controller.dart';

class ListFirmRegis extends StatefulWidget {
  const ListFirmRegis({
    super.key,
  });

  @override
  State<ListFirmRegis> createState() => _ListFirmRegisState();
}

class _ListFirmRegisState extends State<ListFirmRegis> {
  final currentUser = Get.put(UserController());
  String? userId;
  List<FirmModel> loadFirms = [];
  List<UserRegisterModel> listRegis = [];
  FirmModel firm = FirmModel();
  ValueNotifier selectedJob = ValueNotifier(JobPositionModel());

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
    var loadData = await GV.firmsCol.get();
    if (loadData.docs.isNotEmpty) {
      loadFirms =
          loadData.docs.map((e) => FirmModel.fromMap(e.data())).toList();
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

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Obx(
      () => StreamBuilder(
        stream: GV.traineesCol
            .where('userId', isEqualTo: currentUser.userId.value)
            .snapshots(),
        builder: (context, snapshotTrainee) {
          List<RegisterTraineeModel> loadTrainees = [];
          if (snapshotTrainee.hasData &&
              snapshotTrainee.connectionState == ConnectionState.active) {
            if (snapshotTrainee.data != null) {
              snapshotTrainee.data?.docs.forEach((element) {
                loadTrainees.add(RegisterTraineeModel.fromMap(element.data()));
              });
              for (var element in loadTrainees) {
                if (element.userId == userId) {
                  listRegis = element.listRegis!;
                }
              }
              return Padding(
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
                                title: Text(listRegis[indexRegis].name!),
                                subtitle: Text(
                                    'Vị trí ứng tuyển: ${listRegis[indexRegis].name}'),
                                onTap: () {
                                  loadFirms.forEach((element) {
                                    if (element.firmId ==
                                        listRegis[indexRegis].firmId) {
                                      firm = element;
                                    }
                                  });
                                  for (var d in listRegis) {
                                    if (d.firmId == firm.firmId) {
                                      setState(() {
                                        selectedJob.value = firm.listJob!
                                            .firstWhere((element) =>
                                                element.jobId == d.jobId);
                                      });
                                    }
                                  }
                                  showDialog(
                                    context: context,
                                    barrierColor: Colors.transparent,
                                    builder: (context) {
                                      return ValueListenableBuilder(
                                        valueListenable: selectedJob,
                                        builder: (context, value, child) {
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
                                                    color: Colors.blue.shade600,
                                                    height: 50,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 10),
                                                    child: const Text(
                                                        'Chi tiết tuyển dụng',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        textAlign:
                                                            TextAlign.center),
                                                  ),
                                                  titlePadding: EdgeInsets.zero,
                                                  shape: Border.all(),
                                                  content: ConstrainedBox(
                                                    constraints: BoxConstraints(
                                                        minWidth:
                                                            screenWidth * 0.35),
                                                    child: Form(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Text(firm.name!),
                                                          Text(
                                                            firm.owner!,
                                                          ),
                                                          Text(
                                                            firm.phone!,
                                                          ),
                                                          Text(
                                                            firm.email!,
                                                          ),
                                                          Text(
                                                            firm.address!,
                                                          ),
                                                          Text(
                                                            firm.describe!,
                                                          ),
                                                          for (var data
                                                              in firm.listJob!)
                                                            RadioListTile<
                                                                JobPositionModel>(
                                                              value: data,
                                                              groupValue:
                                                                  selectedJob
                                                                      .value,
                                                              title: Text(
                                                                  '${data.name} (Số lượng còn lại: ${data.quantity})'),
                                                              subtitle: Text(data
                                                                  .describeJob!),
                                                              onChanged: (val) {
                                                                setState(() {
                                                                  selectedJob
                                                                          .value =
                                                                      val;
                                                                });
                                                              },
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  actions: [
                                                    ElevatedButton(
                                                      child: const Text(
                                                          "Ứng tuyển"),
                                                      onPressed: () async {
                                                        if (selectedJob
                                                                .value.jobId !=
                                                            null) {
                                                          if (firm.listRegis!
                                                              .where((element) =>
                                                                  element
                                                                      .userId ==
                                                                  userId)
                                                              .isNotEmpty) {
                                                            for (var d in firm
                                                                .listRegis!) {
                                                              if (d.userId ==
                                                                  userId) {
                                                                if (d.jobId ==
                                                                    selectedJob
                                                                        .value
                                                                        .jobId) {
                                                                  MotionToast
                                                                      .warning(
                                                                    title:
                                                                        const Text(
                                                                      'Chú ý',
                                                                      style: TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                    description:
                                                                        const Text(
                                                                      'Bạn đã ứng tuyển vị trí này trước đó.',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              12),
                                                                    ),
                                                                    toastDuration:
                                                                        const Duration(
                                                                            milliseconds:
                                                                                1500),
                                                                    animationType:
                                                                        AnimationType
                                                                            .fromLeft,
                                                                    padding:
                                                                        EdgeInsets
                                                                            .only(
                                                                      left: screenWidth *
                                                                          0.6,
                                                                      bottom:
                                                                          20,
                                                                    ),
                                                                    width:
                                                                        screenWidth *
                                                                            0.24,
                                                                    height:
                                                                        screenHeight *
                                                                            0.1,
                                                                  ).show(
                                                                      context);
                                                                } else {
                                                                  var listRegis =
                                                                      firm.listRegis;
                                                                  for (int i =
                                                                          0;
                                                                      i <
                                                                          listRegis!
                                                                              .length;
                                                                      i++) {
                                                                    if (listRegis[i]
                                                                            .jobId !=
                                                                        selectedJob
                                                                            .value
                                                                            .jobId) {
                                                                      listRegis[i]
                                                                              .jobId =
                                                                          selectedJob
                                                                              .value
                                                                              .jobId;
                                                                      listRegis[i]
                                                                              .name =
                                                                          selectedJob
                                                                              .value
                                                                              .name;
                                                                    }
                                                                  }
                                                                  GV.firmsCol
                                                                      .doc(firm
                                                                          .firmId)
                                                                      .update({
                                                                    'listRegis': listRegis
                                                                        .map((i) =>
                                                                            i.toMap())
                                                                        .toList()
                                                                  });
                                                                  var loadListRegis = await GV
                                                                      .traineesCol
                                                                      .doc(
                                                                          userId)
                                                                      .get();

                                                                  final listUserRegis =
                                                                      RegisterTraineeModel.fromMap(
                                                                              loadListRegis.data()!)
                                                                          .listRegis;
                                                                  for (int i =
                                                                          0;
                                                                      i <
                                                                          listUserRegis!
                                                                              .length;
                                                                      i++) {
                                                                    if (listUserRegis[i]
                                                                            .jobId !=
                                                                        selectedJob
                                                                            .value
                                                                            .jobId) {
                                                                      listUserRegis[i]
                                                                              .jobId =
                                                                          selectedJob
                                                                              .value
                                                                              .jobId;
                                                                      listUserRegis[i]
                                                                              .name =
                                                                          selectedJob
                                                                              .value
                                                                              .name;
                                                                    }
                                                                  }
                                                                  GV.traineesCol
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
                                                                  MotionToast
                                                                      .success(
                                                                    title:
                                                                        const Text(
                                                                      'Thành công',
                                                                      style: TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                    description:
                                                                        const Text(
                                                                      'Đã cập nhật vị trí ứng tuyển.',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              12),
                                                                    ),
                                                                    toastDuration:
                                                                        const Duration(
                                                                            milliseconds:
                                                                                1500),
                                                                    animationType:
                                                                        AnimationType
                                                                            .fromLeft,
                                                                    padding:
                                                                        EdgeInsets
                                                                            .only(
                                                                      left: screenWidth *
                                                                          0.6,
                                                                      bottom:
                                                                          20,
                                                                    ),
                                                                    width:
                                                                        screenWidth *
                                                                            0.24,
                                                                    height:
                                                                        screenHeight *
                                                                            0.1,
                                                                  ).show(
                                                                      context);
                                                                }
                                                              }
                                                            }
                                                          }
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                                trailing: Text(listRegis[indexRegis].isAccepted!
                                    ? 'Trạng thái: Đã duyệt'
                                    : 'Trạng thái: Chờ duyệt'),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const Text('Chua dang ky cong ty');
            }
          } else {
            return const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Loading(),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
