// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/common/constant.dart';
import 'package:tttt_project/common/date_time_extension.dart';
import 'package:tttt_project/models/firm_model.dart';
import 'package:tttt_project/models/register_trainee_model.dart';
import 'package:tttt_project/models/setting_trainee_model.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/models/plan_work_model.dart';
import 'package:tttt_project/widgets/custom_button.dart';
import 'package:tttt_project/widgets/custom_radio.dart';
import 'package:tttt_project/common/user_controller.dart';
import 'package:tttt_project/widgets/field_detail.dart';
import 'package:tttt_project/widgets/loading.dart';

class ListFirm extends StatefulWidget {
  const ListFirm({Key? key}) : super(key: key);

  @override
  State<ListFirm> createState() => _ListFirmState();
}

class _ListFirmState extends State<ListFirm> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<FirmModel> firms = [];
  List<FirmModel> firmResult = [];
  final TextEditingController searchCtrl = TextEditingController();
  ValueNotifier isSearch = ValueNotifier(false);
  String? userId;
  final currentUser = Get.put(UserController());
  bool isRegistered = false;
  RegisterTraineeModel trainee = RegisterTraineeModel();
  SettingTraineeModel setting = SettingTraineeModel();

  @override
  void initState() {
    getJobPosition();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  getJobPosition() async {
    currentUser.loadIn.value = false;
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    bool? isLoggedIn = sharedPref.getBool("isLoggedIn");
    userId = sharedPref
        .getString(
          'userId',
        )
        .toString();
    if (isLoggedIn == true) {
      currentUser.setCurrentUser(
        setMenuSelected: sharedPref.getInt('menuSelected'),
      );
      DocumentSnapshot<Map<String, dynamic>> isExistUser =
          await firestore.collection('users').doc(userId).get();
      if (isExistUser.data() != null) {
        final loadUser = UserModel.fromMap(isExistUser.data()!);
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
        DocumentSnapshot<Map<String, dynamic>> isExitTrainee =
            await firestore.collection('trainees').doc(userId).get();
        if (isExitTrainee.data() != null) {
          setState(() {
            isRegistered = true;
          });
          final loadTrainee =
              RegisterTraineeModel.fromMap(isExitTrainee.data()!);
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
      currentUser.loadIn.value = true;
    }
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    isSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Obx(() => currentUser.loadIn.isTrue
        ? ValueListenableBuilder(
            valueListenable: isSearch,
            builder: (context, value1, child) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 40,
                          width: 350,
                          child: TextFormField(
                            controller: searchCtrl,
                            decoration: InputDecoration(
                              hintText: 'Tên công ty',
                              isDense: false,
                              contentPadding: EdgeInsets.zero,
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    searchCtrl.clear();
                                    isSearch.value = false;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              filled: true,
                            ),
                            onChanged: (value) {
                              setState(() {
                                isSearch.value = false;
                              });
                            },
                            onFieldSubmitted: (p0) {
                              if (searchCtrl.text.isNotEmpty) {
                                isSearch.value = true;
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 15),
                        CustomButton(
                          text: 'Tìm',
                          height: 40,
                          width: 100,
                          onTap: () {
                            if (searchCtrl.text.isNotEmpty) {
                              isSearch.value = true;
                            }
                          },
                        ),
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
                            color: GV.fieldColor,
                            height: screenHeight * 0.04,
                            child: const Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'STT',
                                    textAlign: TextAlign.center,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    'Tên công ty',
                                    textAlign: TextAlign.center,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    'Liên hệ',
                                    textAlign: TextAlign.center,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'Đăng ký',
                                    textAlign: TextAlign.center,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Thao tác',
                                    textAlign: TextAlign.center,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          isSearch.value
                              ? Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: StreamBuilder(
                                        stream: firestore
                                            .collection('firms')
                                            .snapshots(),
                                        builder: (context, snapshotFirm) {
                                          if (snapshotFirm.hasData &&
                                              snapshotFirm.data != null) {
                                            firms = [];
                                            for (var element
                                                in snapshotFirm.data!.docs) {
                                              firms.add(FirmModel.fromMap(
                                                  element.data()));
                                            }
                                            firmResult = firms
                                                .where((element) => element
                                                    .firmName!
                                                    .toLowerCase()
                                                    .contains(searchCtrl.text
                                                        .toLowerCase()))
                                                .toList();
                                            bool isTrainee = false;
                                            firms.forEach((e1) =>
                                                e1.listRegis!.forEach((e2) {
                                                  if (e2.isConfirmed == true &&
                                                      e2.userId == userId) {
                                                    isTrainee = true;
                                                  }
                                                }));
                                            return firmResult.isNotEmpty
                                                ? ListView.builder(
                                                    itemCount:
                                                        firmResult.length,
                                                    shrinkWrap: true,
                                                    itemBuilder:
                                                        (context, indexFirm) {
                                                      bool check = false;
                                                      firmResult[indexFirm]
                                                          .listRegis!
                                                          .forEach((element) {
                                                        if (element.userId ==
                                                            userId) {
                                                          check = true;
                                                        }
                                                      });
                                                      return Container(
                                                        height: screenHeight *
                                                            0.075,
                                                        color:
                                                            indexFirm % 2 == 0
                                                                ? Colors.blue
                                                                    .shade50
                                                                : null,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 5),
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                '${indexFirm + 1}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 5),
                                                            Expanded(
                                                              flex: 6,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    '${firmResult[indexFirm].firmName}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .justify,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                  Text(
                                                                    'Mô tả: ${firmResult[indexFirm].describe}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .justify,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            13),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 5),
                                                            Expanded(
                                                              flex: 3,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  if (firmResult[
                                                                          indexFirm]
                                                                      .phone!
                                                                      .isNotEmpty)
                                                                    Text(
                                                                      '${firmResult[indexFirm].phone}',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .justify,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  if (firmResult[
                                                                          indexFirm]
                                                                      .email!
                                                                      .isNotEmpty)
                                                                    Text(
                                                                      '${firmResult[indexFirm].email}',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .justify,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  if (firmResult[
                                                                              indexFirm]
                                                                          .phone!
                                                                          .isEmpty &&
                                                                      firmResult[
                                                                              indexFirm]
                                                                          .email!
                                                                          .isEmpty)
                                                                    const Text(
                                                                      'Chưa có thông tin liên hệ.',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                width: 5),
                                                            Expanded(
                                                              flex: 1,
                                                              child: check
                                                                  ? const Icon(
                                                                      Icons
                                                                          .check_circle_rounded,
                                                                      size: 20,
                                                                      color: Colors
                                                                          .green,
                                                                    )
                                                                  : const SizedBox(),
                                                            ),
                                                            const SizedBox(
                                                                width: 5),
                                                            Expanded(
                                                                flex: 2,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    IconButton(
                                                                        tooltip:
                                                                            'Thông tin và ứng tuyển',
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            bottom:
                                                                                1),
                                                                        onPressed:
                                                                            () {
                                                                          JobRegisterModel
                                                                              loadRegis =
                                                                              JobRegisterModel();
                                                                          currentUser
                                                                              .selectedJob
                                                                              .value = JobPositionModel();
                                                                          for (var d
                                                                              in firmResult[indexFirm].listRegis!) {
                                                                            if (d.userId ==
                                                                                userId) {
                                                                              currentUser.selectedJob.value = firmResult[indexFirm].listJob!.firstWhere((element) => element.jobId == d.jobId);
                                                                              loadRegis = d;
                                                                            }
                                                                          }
                                                                          regisFirm(
                                                                            context:
                                                                                context,
                                                                            firm:
                                                                                firmResult[indexFirm],
                                                                            loadRegis:
                                                                                loadRegis,
                                                                            isTrainee:
                                                                                isTrainee,
                                                                          );
                                                                        },
                                                                        icon:
                                                                            const Icon(
                                                                          CupertinoIcons
                                                                              .pencil_outline,
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
                                                : SizedBox(
                                                    height: screenHeight * 0.45,
                                                    width: screenWidth * 0.55,
                                                    child: const Center(
                                                      child: Text(
                                                          'Không tìm thấy kết quả.'),
                                                    ),
                                                  );
                                          }
                                          return const SizedBox.shrink();
                                        }),
                                  ),
                                )
                              : Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: StreamBuilder(
                                        stream: firestore
                                            .collection('firms')
                                            .snapshots(),
                                        builder: (context, snapshotFirm) {
                                          if (snapshotFirm.hasData &&
                                              snapshotFirm.data != null) {
                                            firms = [];
                                            for (var element
                                                in snapshotFirm.data!.docs) {
                                              firms.add(FirmModel.fromMap(
                                                  element.data()));
                                            }
                                            bool isTrainee = false;
                                            firms.forEach((e1) =>
                                                e1.listRegis!.forEach((e2) {
                                                  if (e2.isConfirmed == true &&
                                                      e2.userId == userId) {
                                                    isTrainee = true;
                                                  }
                                                }));
                                            return ListView.builder(
                                              itemCount: firms.length,
                                              shrinkWrap: true,
                                              itemBuilder:
                                                  (context, indexFirm) {
                                                bool check = false;
                                                firms[indexFirm]
                                                    .listRegis!
                                                    .forEach((element) {
                                                  if (element.userId ==
                                                      userId) {
                                                    check = true;
                                                  }
                                                });
                                                return Container(
                                                  height: screenHeight * 0.075,
                                                  color: indexFirm % 2 == 0
                                                      ? Colors.blue.shade50
                                                      : null,
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 5),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          '${indexFirm + 1}',
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Expanded(
                                                        flex: 6,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              '${firms[indexFirm].firmName}',
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            Text(
                                                              'Mô tả: ${firms[indexFirm].describe}',
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Expanded(
                                                        flex: 3,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            if (firms[indexFirm]
                                                                .phone!
                                                                .isNotEmpty)
                                                              Text(
                                                                '${firms[indexFirm].phone}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .justify,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            if (firms[indexFirm]
                                                                .email!
                                                                .isNotEmpty)
                                                              Text(
                                                                '${firms[indexFirm].email}',
                                                                textAlign:
                                                                    TextAlign
                                                                        .justify,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            if (firms[indexFirm]
                                                                    .phone!
                                                                    .isEmpty &&
                                                                firms[indexFirm]
                                                                    .email!
                                                                    .isEmpty)
                                                              const Text(
                                                                'Chưa có thông tin liên hệ.',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              )
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Expanded(
                                                          flex: 1,
                                                          child: check
                                                              ? const Icon(
                                                                  Icons
                                                                      .check_circle_rounded,
                                                                  size: 20,
                                                                  color: Colors
                                                                      .green,
                                                                )
                                                              : const SizedBox()),
                                                      const SizedBox(width: 5),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            IconButton(
                                                                tooltip:
                                                                    'Thông tin và ứng tuyển',
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            1),
                                                                onPressed: () {
                                                                  JobRegisterModel
                                                                      loadRegis =
                                                                      JobRegisterModel();
                                                                  currentUser
                                                                          .selectedJob
                                                                          .value =
                                                                      JobPositionModel();
                                                                  for (var d in firms[
                                                                          indexFirm]
                                                                      .listRegis!) {
                                                                    if (d.userId ==
                                                                        userId) {
                                                                      currentUser
                                                                          .selectedJob
                                                                          .value = firms[
                                                                              indexFirm]
                                                                          .listJob!
                                                                          .firstWhere((element) =>
                                                                              element.jobId ==
                                                                              d.jobId);
                                                                      loadRegis =
                                                                          d;
                                                                    }
                                                                  }
                                                                  regisFirm(
                                                                    context:
                                                                        context,
                                                                    firm: firms[
                                                                        indexFirm],
                                                                    loadRegis:
                                                                        loadRegis,
                                                                    isTrainee:
                                                                        isTrainee,
                                                                  );
                                                                },
                                                                icon:
                                                                    const Icon(
                                                                  CupertinoIcons
                                                                      .pencil_outline,
                                                                  size: 22,
                                                                  color: Colors
                                                                      .red,
                                                                ))
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        }),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  )
                ],
              );
            },
          )
        : SizedBox(
            height: screenHeight * 0.45,
            width: screenWidth * 0.67,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Loading(),
              ],
            ),
          ));
  }

  regisFirm({
    required BuildContext context,
    required FirmModel firm,
    required JobRegisterModel loadRegis,
    required bool isTrainee,
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
                        child: Text('Chi tiết tuyển dụng',
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
                  constraints: BoxConstraints(
                      minWidth: screenWidth * 0.35,
                      maxWidth: screenWidth * 0.5),
                  child: Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        FieldDetail(
                            field: 'Tên công ty', content: firm.firmName!),
                        FieldDetail(
                            field: 'Người đại diện',
                            content:
                                '${firm.owner != '' ? firm.owner : 'Chưa có thông tin'}'),
                        FieldDetail(
                            field: 'Số điện thoại',
                            content:
                                '${firm.phone != '' ? firm.phone : 'Chưa có thông tin'}'),
                        FieldDetail(
                            field: 'Email',
                            content:
                                '${firm.email != '' ? firm.email : 'Chưa có thông tin'}'),
                        FieldDetail(
                            field: 'Địa chỉ',
                            content:
                                '${firm.address != '' ? firm.address : 'Chưa có thông tin'}'),
                        FieldDetail(
                            field: 'Mô tả',
                            content:
                                '${firm.describe != '' ? firm.describe : 'Chưa có thông tin'}'),
                        const Text(
                          'Yêu cầu kỹ năng (mức độ thông thạo kỹ năng, được đánh giá trên thang điểm từ 1 đến 5)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
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
                                      '${firm.tieuChi![0]}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text('Kỹ năng lập trình: '),
                                    Text(
                                      '${firm.tieuChi![1]}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text('Kỹ năng làm việc nhóm: '),
                                    Text(
                                      '${firm.tieuChi![2]}',
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
                                      '${firm.tieuChi![3]}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text('Website: '),
                                    Text(
                                      '${firm.tieuChi![4]}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text('Ứng dụng di động: '),
                                    Text(
                                      '${firm.tieuChi![5]}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ]),
                            ],
                          ),
                        ),
                        if (setting.settingId != null &&
                            DateTime.now()
                                .isBeforeTimestamp(setting.traineeStart!)) ...[
                          if (isRegistered == false) ...[
                            const Text(
                              'Vị trí tuyển dụng:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            for (var job in firm.listJob!)
                              Padding(
                                padding: const EdgeInsets.only(left: 25),
                                child: ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    '${job.jobName}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: job.describeJob!.isNotEmpty
                                      ? Text('${job.describeJob}')
                                      : null,
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
                          ] else if (setting.term != trainee.term &&
                              setting.traineeStart != trainee.traineeStart) ...[
                            const Text(
                              'Vị trí tuyển dụng:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            for (var job in firm.listJob!)
                              Padding(
                                padding: const EdgeInsets.only(left: 25),
                                child: ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    '${job.jobName}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: job.describeJob!.isNotEmpty
                                      ? Text('${job.describeJob}')
                                      : null,
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
                          ] else if (loadRegis.status == TrangThai.reject) ...[
                            const Text(
                              'Vị trí tuyển dụng:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            for (var job in firm.listJob!)
                              Padding(
                                padding: const EdgeInsets.only(left: 25),
                                child: ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    '${job.jobName}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: job.describeJob!.isNotEmpty
                                      ? Text('${job.describeJob}')
                                      : null,
                                ),
                              ),
                            const Padding(
                              padding: EdgeInsets.only(top: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Công ty đã từ chối bạn.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else if (isTrainee && loadRegis.isConfirmed! ||
                              !isTrainee &&
                                  !loadRegis.isConfirmed! &&
                                  loadRegis.status == TrangThai.accept) ...[
                            const Text(
                              'Vị trí tuyển dụng:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            for (var job in firm.listJob!)
                              Padding(
                                padding: const EdgeInsets.only(left: 25),
                                child: ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    '${job.jobName}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: job.describeJob!.isNotEmpty
                                      ? Text('${job.describeJob}')
                                      : null,
                                ),
                              ),
                            if (loadRegis.createdAt != null)
                              FieldDetail(
                                  field: 'Vị trí ứng tuyển',
                                  content:
                                      '${currentUser.selectedJob.value.jobName}'),
                            if (loadRegis.createdAt != null)
                              FieldDetail(
                                  field: 'Ngày ứng tuyển',
                                  content:
                                      GV.readTimestamp(loadRegis.createdAt!)),
                            if (loadRegis.repliedAt != null)
                              FieldDetail(
                                  field: 'Ngày duyệt',
                                  content:
                                      GV.readTimestamp(loadRegis.repliedAt!)),
                            if (trainee.traineeStart != null)
                              FieldDetail(
                                  field: 'Thời gian thực tập',
                                  content:
                                      'Từ ngày ${GV.readTimestamp(trainee.traineeStart!)} - Đến ngày: ${GV.readTimestamp(trainee.traineeEnd!)}'),
                            if (loadRegis.isConfirmed!)
                              const Padding(
                                padding: EdgeInsets.only(top: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Công ty bạn đang thực tập.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                          ] else if (isTrainee) ...[
                            const Text(
                              'Vị trí tuyển dụng:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            for (var job in firm.listJob!)
                              Padding(
                                padding: const EdgeInsets.only(left: 25),
                                child: ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    '${job.jobName}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: job.describeJob!.isNotEmpty &&
                                          job.describeJob != null
                                      ? Text('${job.describeJob}')
                                      : null,
                                ),
                              ),
                            if (loadRegis.createdAt != null)
                              FieldDetail(
                                  field: 'Vị trí ứng tuyển',
                                  content:
                                      '${currentUser.selectedJob.value.jobName}'),
                            if (loadRegis.createdAt != null)
                              FieldDetail(
                                  field: 'Ngày ứng tuyển',
                                  content:
                                      GV.readTimestamp(loadRegis.createdAt!)),
                            if (loadRegis.repliedAt != null &&
                                loadRegis.status == TrangThai.accept)
                              FieldDetail(
                                  field: 'Ngày duyệt',
                                  content:
                                      GV.readTimestamp(loadRegis.repliedAt!))
                            else if (loadRegis.status != null)
                              FieldDetail(
                                  field: 'Trạng thái',
                                  content: '${loadRegis.status}'),
                            const Padding(
                              padding: EdgeInsets.only(top: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Bạn đã có công ty thực tập không thể ứng tuyển hoặc thay đổi vị trí ứng tuyển.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ] else if (loadRegis.status == TrangThai.wait ||
                              loadRegis.userId == null) ...[
                            const Text(
                              'Vị trí tuyển dụng:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            for (var data in firm.listJob!)
                              Obx(
                                () => CustomRadio(
                                  title: '${data.jobName}',
                                  onTap: () =>
                                      currentUser.selectedJob.value = data,
                                  subtitle: data.describeJob!.isNotEmpty
                                      ? data.describeJob
                                      : null,
                                  selected:
                                      currentUser.selectedJob.value == data,
                                ),
                              ),
                          ]
                        ] else ...[
                          if (loadRegis.status == TrangThai.reject) ...[
                            const Text(
                              'Vị trí tuyển dụng:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            for (var job in firm.listJob!)
                              Padding(
                                padding: const EdgeInsets.only(left: 25),
                                child: ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    '${job.jobName}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: job.describeJob!.isNotEmpty
                                      ? Text('${job.describeJob}')
                                      : null,
                                ),
                              ),
                            const Padding(
                              padding: EdgeInsets.only(top: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Công ty đã từ chối bạn.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ] else if (isTrainee && loadRegis.isConfirmed! ||
                              !isTrainee &&
                                  !loadRegis.isConfirmed! &&
                                  loadRegis.status == TrangThai.accept) ...[
                            const Text(
                              'Vị trí tuyển dụng:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            for (var job in firm.listJob!)
                              Padding(
                                padding: const EdgeInsets.only(left: 25),
                                child: ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    '${job.jobName}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: job.describeJob!.isNotEmpty
                                      ? Text('${job.describeJob}')
                                      : null,
                                ),
                              ),
                            if (loadRegis.createdAt != null)
                              FieldDetail(
                                  field: 'Vị trí ứng tuyển',
                                  content:
                                      '${currentUser.selectedJob.value.jobName}'),
                            if (loadRegis.createdAt != null)
                              FieldDetail(
                                  field: 'Ngày ứng tuyển',
                                  content:
                                      GV.readTimestamp(loadRegis.createdAt!)),
                            if (loadRegis.repliedAt != null)
                              FieldDetail(
                                  field: 'Ngày duyệt',
                                  content:
                                      GV.readTimestamp(loadRegis.repliedAt!)),
                            if (trainee.traineeStart != null)
                              FieldDetail(
                                  field: 'Thời gian thực tập',
                                  content:
                                      'Từ ngày ${GV.readTimestamp(trainee.traineeStart!)} - Đến ngày: ${GV.readTimestamp(trainee.traineeEnd!)}'),
                          ] else if (isTrainee) ...[
                            const Text(
                              'Vị trí tuyển dụng:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            for (var job in firm.listJob!)
                              Padding(
                                padding: const EdgeInsets.only(left: 25),
                                child: ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    '${job.jobName}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: job.describeJob!.isNotEmpty
                                      ? Text('${job.describeJob}')
                                      : null,
                                ),
                              ),
                            if (loadRegis.createdAt != null)
                              FieldDetail(
                                  field: 'Vị trí ứng tuyển',
                                  content:
                                      '${currentUser.selectedJob.value.jobName}'),
                            if (loadRegis.createdAt != null)
                              FieldDetail(
                                  field: 'Ngày ứng tuyển',
                                  content:
                                      GV.readTimestamp(loadRegis.createdAt!)),
                            if (loadRegis.repliedAt != null &&
                                loadRegis.status == TrangThai.accept)
                              FieldDetail(
                                  field: 'Ngày duyệt',
                                  content:
                                      GV.readTimestamp(loadRegis.repliedAt!))
                            else if (loadRegis.status != null)
                              FieldDetail(
                                  field: 'Trạng thái',
                                  content: '${loadRegis.status}'),
                          ] else ...[
                            const Text(
                              'Vị trí tuyển dụng:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            for (var job in firm.listJob!)
                              Padding(
                                padding: const EdgeInsets.only(left: 25),
                                child: ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    '${job.jobName}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: job.describeJob!.isNotEmpty
                                      ? Text('${job.describeJob}')
                                      : null,
                                ),
                              ),
                          ],
                          isTrainee && loadRegis.isConfirmed!
                              ? const Padding(
                                  padding: EdgeInsets.only(top: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Công ty bạn đang thực tập.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const Padding(
                                  padding: EdgeInsets.only(top: 15),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Đã bắt đầu thực tập không thể đăng ký hoặc thay đổi vị trí ứng tuyển.',
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
                actions: setting.settingId != null &&
                        setting.term != trainee.term &&
                        setting.traineeStart != trainee.traineeStart
                    ? null
                    : DateTime.now().isBeforeTimestamp(setting.traineeStart!)
                        ? isTrainee
                            ? null
                            : (loadRegis.status == null ||
                                        loadRegis.status == TrangThai.wait) &&
                                    isTrainee == false
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
                                          if (firm.listRegis!
                                              .where((element) =>
                                                  element.userId == userId)
                                              .isNotEmpty) {
                                            for (var d in firm.listRegis!) {
                                              if (d.userId == userId) {
                                                if (d.jobId ==
                                                    currentUser.selectedJob
                                                        .value.jobId) {
                                                  GV.warning(
                                                      context: context,
                                                      message:
                                                          'Không có gì thay đổi.');
                                                } else {
                                                  var listRegis =
                                                      firm.listRegis;
                                                  for (int i = 0;
                                                      i < listRegis!.length;
                                                      i++) {
                                                    if (listRegis[i].userId ==
                                                        currentUser
                                                            .userId.value) {
                                                      if (listRegis[i].jobId !=
                                                          currentUser
                                                              .selectedJob
                                                              .value
                                                              .jobId) {
                                                        listRegis[i].jobId =
                                                            currentUser
                                                                .selectedJob
                                                                .value
                                                                .jobId;
                                                        listRegis[i].jobName =
                                                            currentUser
                                                                .selectedJob
                                                                .value
                                                                .jobName;
                                                        listRegis[i].createdAt =
                                                            Timestamp.now();
                                                      }
                                                    }
                                                  }
                                                  await firestore
                                                      .collection('firms')
                                                      .doc(firm.firmId)
                                                      .update({
                                                    'listRegis': listRegis
                                                        .map((i) => i.toMap())
                                                        .toList(),
                                                  });
                                                  var loadListRegis =
                                                      await firestore
                                                          .collection(
                                                              'trainees')
                                                          .doc(userId)
                                                          .get();

                                                  final listUserRegis =
                                                      RegisterTraineeModel
                                                              .fromMap(
                                                                  loadListRegis
                                                                      .data()!)
                                                          .listRegis;
                                                  for (int i = 0;
                                                      i < listUserRegis!.length;
                                                      i++) {
                                                    if (listUserRegis[i]
                                                            .firmId ==
                                                        firm.firmId) {
                                                      if (listUserRegis[i]
                                                              .jobId !=
                                                          currentUser
                                                              .selectedJob
                                                              .value
                                                              .jobId) {
                                                        listUserRegis[i].jobId =
                                                            currentUser
                                                                .selectedJob
                                                                .value
                                                                .jobId;
                                                        listUserRegis[i]
                                                                .jobName =
                                                            currentUser
                                                                .selectedJob
                                                                .value
                                                                .jobName;
                                                        listUserRegis[i]
                                                                .createdAt =
                                                            Timestamp.now();
                                                      }
                                                    }
                                                  }
                                                  await firestore
                                                      .collection('trainees')
                                                      .doc(userId)
                                                      .update({
                                                    'listRegis': listUserRegis
                                                        .map((i) => i.toMap())
                                                        .toList(),
                                                  });
                                                  Navigator.pop(context);
                                                  GV.success(
                                                      context: context,
                                                      message:
                                                          'Đã cập nhật thành công.');
                                                }
                                              }
                                            }
                                          } else {
                                            if (currentUser
                                                    .selectedJob.value.jobId ==
                                                null) {
                                              GV.error(
                                                  context: context,
                                                  message:
                                                      'Vui lòng chọn vị trí ứng tuyển.');
                                            } else if (trainee
                                                    .listRegis!.length ==
                                                3) {
                                              GV.error(
                                                  context: context,
                                                  message:
                                                      'Bạn chỉ có thể đăng ký tối đa 3 công ty.');
                                            } else {
                                              showDialog(
                                                  context: context,
                                                  barrierColor: Colors.black12,
                                                  barrierDismissible: false,
                                                  builder: (context) {
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
                                                              height:
                                                                  screenHeight *
                                                                      0.06,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
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
                                                                      'Xác nhận đăng ký',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              Colors.white),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
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
                                                            shape: Border.all(
                                                                width: 0.5),
                                                            content:
                                                                ConstrainedBox(
                                                                    constraints:
                                                                        BoxConstraints(
                                                                      minWidth:
                                                                          screenWidth *
                                                                              0.35,
                                                                      maxWidth:
                                                                          screenWidth *
                                                                              0.5,
                                                                    ),
                                                                    child: const Text(
                                                                        'Bạn chỉ có thể đăng ký tối đa 3 công ty và không thể xóa công ty đã đăng ký, bạn có chắc muốn đăng ký công ty này?')),
                                                            actions: [
                                                              ElevatedButton(
                                                                onPressed:
                                                                    () async {
                                                                  final regis =
                                                                      JobRegisterModel(
                                                                    userId:
                                                                        userId,
                                                                    jobId: currentUser
                                                                        .selectedJob
                                                                        .value
                                                                        .jobId,
                                                                    userName: currentUser
                                                                        .userName
                                                                        .value,
                                                                    jobName: currentUser
                                                                        .selectedJob
                                                                        .value
                                                                        .jobName,
                                                                    status:
                                                                        TrangThai
                                                                            .wait,
                                                                    createdAt:
                                                                        Timestamp
                                                                            .now(),
                                                                  );
                                                                  var listRegis =
                                                                      firm.listRegis;
                                                                  listRegis!.add(
                                                                      regis);
                                                                  await firestore
                                                                      .collection(
                                                                          'firms')
                                                                      .doc(firm
                                                                          .firmId)
                                                                      .update({
                                                                    'listRegis': listRegis
                                                                        .map((i) =>
                                                                            i.toMap())
                                                                        .toList()
                                                                  });
                                                                  final userRegis =
                                                                      UserRegisterModel(
                                                                    firmId: firm
                                                                        .firmId,
                                                                    jobId: regis
                                                                        .jobId,
                                                                    jobName: regis
                                                                        .jobName,
                                                                    status:
                                                                        TrangThai
                                                                            .wait,
                                                                    firmName: firm
                                                                        .firmName,
                                                                    createdAt:
                                                                        Timestamp
                                                                            .now(),
                                                                  );
                                                                  var loadListRegis = await firestore
                                                                      .collection(
                                                                          'trainees')
                                                                      .doc(
                                                                          userId)
                                                                      .get();
                                                                  final listUserRegis =
                                                                      RegisterTraineeModel.fromMap(
                                                                              loadListRegis.data()!)
                                                                          .listRegis;
                                                                  listUserRegis!
                                                                      .add(
                                                                          userRegis);
                                                                  await firestore
                                                                      .collection(
                                                                          'trainees')
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
                                                                  Navigator.pop(
                                                                      context);
                                                                  GV.success(
                                                                      context:
                                                                          context,
                                                                      message:
                                                                          'Đăng ký thành công.');
                                                                },
                                                                child:
                                                                    const Text(
                                                                  'Chắc chắn',
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        16,
                                                                  ),
                                                                ),
                                                              ),
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child:
                                                                    const Text(
                                                                  'Để sau',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .red,
                                                                    fontSize:
                                                                        16,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  });
                                            }
                                          }
                                        } else {
                                          GV.error(
                                              context: context,
                                              message:
                                                  'Bạn cần phải đăng ký thực tập trước khi ứng tuyển.');
                                        }
                                      },
                                    ),
                                  ]
                                : loadRegis.status == TrangThai.accept &&
                                        loadRegis.isConfirmed == false
                                    ? [
                                        ElevatedButton(
                                          onPressed: () async {
                                            showDialog(
                                                context: context,
                                                barrierColor: Colors.black12,
                                                barrierDismissible: false,
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
                                                            height:
                                                                screenHeight *
                                                                    0.06,
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
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
                                                                    'Xác nhận thực tập',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: Colors
                                                                            .white),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
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
                                                          shape: Border.all(
                                                              width: 0.5),
                                                          content:
                                                              ConstrainedBox(
                                                                  constraints:
                                                                      BoxConstraints(
                                                                    minWidth:
                                                                        screenWidth *
                                                                            0.35,
                                                                    maxWidth:
                                                                        screenWidth *
                                                                            0.35,
                                                                  ),
                                                                  child: const Text(
                                                                      'Bạn chỉ có thể xác nhận thực tập tại một công ty duy nhất và không thể thay đổi, bạn có chắc muốn thực tập tại công ty này?')),
                                                          actions: [
                                                            ElevatedButton(
                                                              onPressed:
                                                                  () async {
                                                                var loadCBHD = await firestore
                                                                    .collection(
                                                                        'users')
                                                                    .doc(firm
                                                                        .firmId)
                                                                    .get();
                                                                final cbhdName =
                                                                    UserModel.fromMap(
                                                                            loadCBHD.data()!)
                                                                        .userName;
                                                                final plan =
                                                                    PlanWorkModel(
                                                                  cbhdId: firm
                                                                      .firmId,
                                                                  cbhdName:
                                                                      cbhdName,
                                                                  listWork: [],
                                                                  userId:
                                                                      userId,
                                                                );
                                                                var listRegis =
                                                                    firm.listRegis;
                                                                for (int i = 0;
                                                                    i <
                                                                        listRegis!
                                                                            .length;
                                                                    i++) {
                                                                  if (listRegis[
                                                                              i]
                                                                          .userId ==
                                                                      currentUser
                                                                          .userId
                                                                          .value) {
                                                                    if (listRegis[i]
                                                                            .jobId ==
                                                                        currentUser
                                                                            .selectedJob
                                                                            .value
                                                                            .jobId) {
                                                                      listRegis[i]
                                                                              .isConfirmed =
                                                                          true;
                                                                      plan.traineeStart =
                                                                          trainee
                                                                              .traineeStart;
                                                                      plan.traineeEnd =
                                                                          trainee
                                                                              .traineeEnd;
                                                                    }
                                                                  }
                                                                }
                                                                await firestore
                                                                    .collection(
                                                                        'plans')
                                                                    .doc(userId)
                                                                    .set(plan
                                                                        .toMap());
                                                                await firestore
                                                                    .collection(
                                                                        'firms')
                                                                    .doc(firm
                                                                        .firmId)
                                                                    .update({
                                                                  'listRegis': listRegis
                                                                      .map((i) =>
                                                                          i.toMap())
                                                                      .toList()
                                                                });
                                                                var loadListRegis =
                                                                    await GV
                                                                        .traineesCol
                                                                        .doc(
                                                                            userId)
                                                                        .get();
                                                                final listUserRegis =
                                                                    RegisterTraineeModel.fromMap(
                                                                            loadListRegis.data()!)
                                                                        .listRegis;
                                                                for (int i = 0;
                                                                    i <
                                                                        listUserRegis!
                                                                            .length;
                                                                    i++) {
                                                                  if (listUserRegis[
                                                                              i]
                                                                          .firmId ==
                                                                      firm.firmId) {
                                                                    if (listUserRegis[i]
                                                                            .jobId ==
                                                                        currentUser
                                                                            .selectedJob
                                                                            .value
                                                                            .jobId) {
                                                                      listUserRegis[i]
                                                                              .isConfirmed =
                                                                          true;
                                                                    }
                                                                  }
                                                                }
                                                                await firestore
                                                                    .collection(
                                                                        'trainees')
                                                                    .doc(userId)
                                                                    .update({
                                                                  'listRegis': listUserRegis
                                                                      .map((i) =>
                                                                          i.toMap())
                                                                      .toList(),
                                                                });
                                                                Navigator.pop(
                                                                    context);
                                                                Navigator.pop(
                                                                    context);
                                                                GV.success(
                                                                    context:
                                                                        context,
                                                                    message:
                                                                        'Đã xác nhận công ty thực tập');
                                                              },
                                                              child: const Text(
                                                                'Chắc chắn',
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ),
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: const Text(
                                                                'Để sau',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                });
                                          },
                                          child: const Text(
                                            'Xác nhận thực tập',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
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
  }
}
