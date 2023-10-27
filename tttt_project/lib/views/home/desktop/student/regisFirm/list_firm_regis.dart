// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/data/constant.dart';
import 'package:tttt_project/models/firm_model.dart';
import 'package:tttt_project/models/register_trainee_model.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/widgets/custom_radio.dart';
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
      currentUser.setCurrentUser(
        setMenuSelected: sharedPref.getInt('menuSelected'),
      );
      DocumentSnapshot<Map<String, dynamic>> isExistUser =
          await GV.usersCol.doc(userId).get();
      if (isExistUser.data() != null) {
        final loadUser = UserModel.fromMap(isExistUser.data()!);
        // setState(() {
        //   user = loadUser;
        // });
        DocumentSnapshot<Map<String, dynamic>> isExitTrainee =
            await GV.traineesCol.doc(userId).get();
        if (isExitTrainee.data() != null) {
          final loadTrainee =
              RegisterTraineeModel.fromMap(isExitTrainee.data()!);
          // setState(() {
          //   trainee = loadTrainee;
          // });
          currentUser.setCurrentUser(
            setUid: loadUser.uid,
            setUserId: loadUser.userId,
            setName: loadUser.name,
            setClassName: loadUser.className,
            setCourse: loadUser.course,
            setGroup: loadUser.group,
            setMajor: loadUser.major,
            setEmail: loadUser.email,
            setIsRegistered: loadUser.isRegistered,
            setReachedStep: loadTrainee.reachedStep,
            setSelectedStep: loadTrainee.reachedStep,
          );
        } else {
          currentUser.setCurrentUser(
            setUid: loadUser.uid,
            setUserId: loadUser.userId,
            setName: loadUser.name,
            setClassName: loadUser.className,
            setCourse: loadUser.course,
            setGroup: loadUser.group,
            setMajor: loadUser.major,
            setEmail: loadUser.email,
            setIsRegistered: loadUser.isRegistered,
          );
        }
      }
    }
    currentUser.loadIn.value = true;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Obx(
      () => StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('trainees')
            .where('userId', isEqualTo: currentUser.userId.value)
            .snapshots(),
        builder: (context, snapshotTrainee) {
          if (snapshotTrainee.hasData &&
              snapshotTrainee.data != null &&
              snapshotTrainee.connectionState == ConnectionState.active) {
            List<RegisterTraineeModel> loadTrainees = [];
            snapshotTrainee.data?.docs.forEach((element) {
              loadTrainees.add(RegisterTraineeModel.fromMap(element.data()));
            });
            for (var element in loadTrainees) {
              if (element.userId == userId) {
                listRegis = element.listRegis!;
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
                              return StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('firms')
                                      .doc(listRegis[indexRegis].firmId)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.data != null &&
                                        snapshot.data!.data() != null) {
                                      FirmModel firm = FirmModel.fromMap(
                                          snapshot.data!.data()!);
                                      return SizedBox(
                                        width: screenWidth * 0.5,
                                        child: Card(
                                          child: ListTile(
                                            title: Text('${firm.firmName}'),
                                            leading: const Icon(Icons.work),
                                            subtitle: Text(
                                                'Vị trí ứng tuyển: ${listRegis[indexRegis].jobName}'),
                                            onTap: () {
                                              loadFirms.forEach((element) {
                                                if (element.firmId ==
                                                    listRegis[indexRegis]
                                                        .firmId) {
                                                  firm = element;
                                                }
                                              });
                                              for (var d in listRegis) {
                                                if (d.firmId == firm.firmId) {
                                                  currentUser
                                                          .selectedJob.value =
                                                      firm.listJob!.firstWhere(
                                                          (element) =>
                                                              element.jobId ==
                                                              d.jobId);
                                                  currentUser.traineeTime
                                                      .value = DateTimeRange(
                                                    start: DateTime
                                                        .fromMicrosecondsSinceEpoch(d
                                                            .traineeStart!
                                                            .microsecondsSinceEpoch),
                                                    end: DateTime
                                                        .fromMicrosecondsSinceEpoch(d
                                                            .traineeEnd!
                                                            .microsecondsSinceEpoch),
                                                  );
                                                }
                                              }
                                              showDialog(
                                                context: context,
                                                barrierColor: Colors.black26,
                                                builder: (context) {
                                                  return Padding(
                                                    padding: EdgeInsets.only(
                                                      top: screenHeight * 0.06,
                                                      bottom:
                                                          screenHeight * 0.02,
                                                      left: screenWidth * 0.27,
                                                      right: screenWidth * 0.08,
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        AlertDialog(
                                                          scrollable: true,
                                                          title: Container(
                                                            color: Colors
                                                                .blue.shade600,
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
                                                                          TextAlign
                                                                              .center),
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
                                                                      'Tên công ty: ${firm.firmName!}'),
                                                                  Text(
                                                                      'Người đại diện: ${firm.owner!}'),
                                                                  Text(
                                                                      'Số điện thoại: ${firm.phone!}'),
                                                                  Text(
                                                                      'Email: ${firm.email!}'),
                                                                  Text(
                                                                      'Địa chỉ: ${firm.address!}'),
                                                                  Text(
                                                                      'Mô tả: ${firm.describe!}'),
                                                                  if (listRegis[
                                                                              indexRegis]
                                                                          .status ==
                                                                      TrangThai
                                                                          .wait) ...[
                                                                    const Text(
                                                                        'Vị trí tuyển dụng:'),
                                                                    for (var data
                                                                        in firm
                                                                            .listJob!)
                                                                      Obx(
                                                                        () =>
                                                                            CustomRadio(
                                                                          title:
                                                                              '${data.jobName} - SL còn lai: ${data.quantity}',
                                                                          onTap: () => currentUser
                                                                              .selectedJob
                                                                              .value = data,
                                                                          subtitle:
                                                                              '${data.describeJob}',
                                                                          selected:
                                                                              currentUser.selectedJob.value == data,
                                                                        ),
                                                                      ),
                                                                  ] else ...[
                                                                    Text(
                                                                        'Vị trí ứng tuyển: ${currentUser.selectedJob.value.jobName} '),
                                                                    Text(
                                                                        'Ngày ứng tuyển: ${GV.readTimestamp(listRegis[indexRegis].createdAt!)}'),
                                                                    Text(
                                                                        'Ngày duyệt: ${GV.readTimestamp(listRegis[indexRegis].repliedAt!)}'),
                                                                  ],
                                                                  const Text(
                                                                      'Thời gian thưc tập:'),
                                                                  const SizedBox(
                                                                      height:
                                                                          10),
                                                                  Obx(
                                                                    () => Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Expanded(
                                                                            child:
                                                                                ElevatedButton(
                                                                          onPressed:
                                                                              pickDateRange,
                                                                          child: Text(DateFormat('dd/MM/yyyy').format(currentUser
                                                                              .traineeTime
                                                                              .value
                                                                              .start)),
                                                                        )),
                                                                        const SizedBox(
                                                                            width:
                                                                                10),
                                                                        Expanded(
                                                                            child:
                                                                                ElevatedButton(
                                                                          onPressed:
                                                                              pickDateRange,
                                                                          child: Text(DateFormat('dd/MM/yyyy').format(currentUser
                                                                              .traineeTime
                                                                              .value
                                                                              .end)),
                                                                        )),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          actions: listRegis[
                                                                          indexRegis]
                                                                      .status ==
                                                                  TrangThai.wait
                                                              ? [
                                                                  ElevatedButton(
                                                                    child: const Text(
                                                                        "Ứng tuyển"),
                                                                    onPressed:
                                                                        () async {
                                                                      if (firm
                                                                          .listRegis!
                                                                          .where((element) =>
                                                                              element.userId ==
                                                                              userId)
                                                                          .isNotEmpty) {
                                                                        for (var d
                                                                            in firm.listRegis!) {
                                                                          if (d.userId ==
                                                                              userId) {
                                                                            if (d.jobId == currentUser.selectedJob.value.jobId &&
                                                                                d.traineeStart == Timestamp.fromDate(currentUser.traineeTime.value.start) &&
                                                                                d.traineeEnd == Timestamp.fromDate(currentUser.traineeTime.value.end)) {
                                                                              GV.warning(context: context, message: 'Không có gì thay đổi.');
                                                                            } else if (currentUser.selectedJob.value.jobId == null) {
                                                                              GV.error(context: context, message: 'Vui lòng chọn vị trí ứng tuyển.');
                                                                            } else if (currentUser.traineeTime.value.start == currentUser.traineeTime.value.end) {
                                                                              GV.error(context: context, message: 'Vui lòng chọn thời gian phù hợp.');
                                                                            } else {
                                                                              var listRegis = firm.listRegis;
                                                                              for (int i = 0; i < listRegis!.length; i++) {
                                                                                if (listRegis[i].jobId != currentUser.selectedJob.value.jobId) {
                                                                                  listRegis[i].jobId = currentUser.selectedJob.value.jobId;
                                                                                  listRegis[i].jobName = currentUser.selectedJob.value.jobName;
                                                                                }
                                                                                listRegis[i].traineeStart = Timestamp.fromDate(currentUser.traineeTime.value.start);
                                                                                listRegis[i].traineeEnd = Timestamp.fromDate(currentUser.traineeTime.value.end);
                                                                              }
                                                                              GV.firmsCol.doc(firm.firmId).update({
                                                                                'listRegis': listRegis.map((i) => i.toMap()).toList()
                                                                              });
                                                                              var loadListRegis = await GV.traineesCol.doc(userId).get();
                                                                              final listUserRegis = RegisterTraineeModel.fromMap(loadListRegis.data()!).listRegis;
                                                                              for (int i = 0; i < listUserRegis!.length; i++) {
                                                                                if (listUserRegis[i].jobId != currentUser.selectedJob.value.jobId && listUserRegis[i].firmId == firm.firmId) {
                                                                                  listUserRegis[i].jobId = currentUser.selectedJob.value.jobId;
                                                                                  listUserRegis[i].jobName = currentUser.selectedJob.value.jobName;
                                                                                }
                                                                                if (listUserRegis[i].firmId == firm.firmId) {
                                                                                  listUserRegis[i].traineeStart = Timestamp.fromDate(currentUser.traineeTime.value.start);
                                                                                  listUserRegis[i].traineeEnd = Timestamp.fromDate(currentUser.traineeTime.value.end);
                                                                                }
                                                                              }
                                                                              GV.traineesCol.doc(userId).update({
                                                                                'listRegis': listUserRegis.map((i) => i.toMap()).toList(),
                                                                              });
                                                                              Navigator.pop(context);
                                                                              GV.success(context: context, message: 'Đã cập nhật vị trí ứng tuyển.');
                                                                            }
                                                                          }
                                                                        }
                                                                      }
                                                                    },
                                                                  ),
                                                                ]
                                                              : [],
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            trailing: listRegis[indexRegis]
                                                        .status ==
                                                    TrangThai.accept
                                                ? Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(listRegis[indexRegis]
                                                          .status!),
                                                      const Text(
                                                        'Chờ xác nhận',
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      )
                                                    ],
                                                  )
                                                : Text(listRegis[indexRegis]
                                                    .status!),
                                          ),
                                        ),
                                      );
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  });
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : const Padding(
                    padding: EdgeInsets.only(top: 200),
                    child: Center(child: Text('Bạn chưa đăng ký công ty.')),
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

  Future pickDateRange() async {
    DateTimeRange? newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2025),
      builder: (context, child) {
        double screenHeight = MediaQuery.of(context).size.height;
        double screenWidth = MediaQuery.of(context).size.width;
        return Padding(
          padding: EdgeInsets.only(
            top: screenHeight * 0.15,
            bottom: screenHeight * 0.06,
            left: screenWidth * 0.4,
            right: screenWidth * 0.21,
          ),
          child: SizedBox(
            height: 450,
            width: 700,
            child: child,
          ),
        );
      },
    );
    if (newDateRange == null) return;
    setState(() {
      currentUser.traineeTime.value = newDateRange;
    });
  }
}
