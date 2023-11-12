// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/common/constant.dart';
import 'package:tttt_project/models/announcement_model.dart';
import 'package:tttt_project/models/plan_trainee_model.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/widgets/footer.dart';
import 'package:tttt_project/widgets/header.dart';
import 'package:tttt_project/widgets/loading.dart';
import 'package:tttt_project/widgets/menu/menu_left.dart';
import 'package:tttt_project/common/user_controller.dart';
import 'dart:html' as html;

class HomeViewDesktop extends StatefulWidget {
  const HomeViewDesktop({Key? key}) : super(key: key);

  @override
  State<HomeViewDesktop> createState() => _HomeViewDesktopState();
}

class _HomeViewDesktopState extends State<HomeViewDesktop> {
  final firestore = FirebaseFirestore.instance;
  final currentUser = Get.put(UserController());
  ValueNotifier<AnnouncementModel> readAnnouncement =
      ValueNotifier(AnnouncementModel());
  ValueNotifier<PlanTraineeModel> readPlanTrainee =
      ValueNotifier(PlanTraineeModel());
  @override
  void initState() {
    getUserData();
    super.initState();
  }

  getUserData() async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    String? userId = sharedPref
        .getString(
          'userId',
        )
        .toString();
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
    return Scaffold(
      backgroundColor: Colors.cyan.shade50,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            const Header(),
            ValueListenableBuilder(
                valueListenable: readAnnouncement,
                builder: (context, readAnnouncementVal, child) {
                  return ValueListenableBuilder(
                      valueListenable: readPlanTrainee,
                      builder: (context, readPlanTraineeVal, child) {
                        return Padding(
                          padding: EdgeInsets.only(
                            top: screenHeight * 0.02,
                            bottom: screenHeight * 0.02,
                            left: screenWidth * 0.08,
                            right: screenWidth * 0.08,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MenuLeft(),
                              SizedBox(width: screenWidth * 0.03),
                              readAnnouncement.value.announcementId == null &&
                                      readPlanTrainee.value.planTraineeId ==
                                          null
                                  ? Expanded(
                                      child: Column(
                                        children: [
                                          Container(
                                            constraints: BoxConstraints(
                                                minHeight: screenHeight * 0.3),
                                            decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                border: Border.all(
                                                  style: BorderStyle.solid,
                                                  width: 0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        height:
                                                            screenHeight * 0.05,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .blue.shade600,
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    5.0),
                                                            topRight:
                                                                Radius.circular(
                                                                    5.0),
                                                          ),
                                                        ),
                                                        child: const Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              "Tin tức giáo vụ và việc làm",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 18,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                StreamBuilder(
                                                  stream: firestore
                                                      .collection(
                                                          'announcements')
                                                      .snapshots(),
                                                  builder: (context, snapshot) {
                                                    final List<
                                                            AnnouncementModel>
                                                        listAnnouncement = [];
                                                    if (snapshot.hasData &&
                                                        snapshot.connectionState ==
                                                            ConnectionState
                                                                .active) {
                                                      snapshot.data?.docs
                                                          .forEach((element) {
                                                        listAnnouncement.add(
                                                            AnnouncementModel
                                                                .fromMap(element
                                                                    .data()));
                                                      });
                                                      return listAnnouncement
                                                              .isNotEmpty
                                                          ? ListView.builder(
                                                              itemCount:
                                                                  listAnnouncement
                                                                      .length,
                                                              shrinkWrap: true,
                                                              scrollDirection:
                                                                  Axis.vertical,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                return InkWell(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      readAnnouncement
                                                                              .value =
                                                                          listAnnouncement[
                                                                              index];
                                                                    });
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    height:
                                                                        screenHeight *
                                                                            0.05,
                                                                    color: index %
                                                                                2 ==
                                                                            0
                                                                        ? Colors
                                                                            .blue
                                                                            .shade50
                                                                        : null,
                                                                    child: Row(
                                                                      children: [
                                                                        Expanded(
                                                                          flex:
                                                                              1,
                                                                          child: Text(
                                                                              '${index + 1}',
                                                                              textAlign: TextAlign.center),
                                                                        ),
                                                                        Expanded(
                                                                          flex:
                                                                              5,
                                                                          child: Text(
                                                                              listAnnouncement[index].title!,
                                                                              textAlign: TextAlign.justify),
                                                                        ),
                                                                        Expanded(
                                                                          flex:
                                                                              2,
                                                                          child: Text(
                                                                              listAnnouncement[index].type!,
                                                                              textAlign: TextAlign.justify),
                                                                        ),
                                                                        Expanded(
                                                                          flex:
                                                                              3,
                                                                          child: Text(
                                                                              'Ngày đăng: ${GV.readTimestamp(listAnnouncement[index].createdAt!)}',
                                                                              textAlign: TextAlign.center),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            )
                                                          : const Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 150),
                                                              child: Center(
                                                                child: Text(
                                                                    'Chưa có thông báo.'),
                                                              ),
                                                            );
                                                    } else {
                                                      return const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 150),
                                                        child: Loading(),
                                                      );
                                                    }
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Container(
                                            constraints: BoxConstraints(
                                                minHeight: screenHeight * 0.3),
                                            decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                border: Border.all(
                                                  style: BorderStyle.solid,
                                                  width: 0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(5)),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        height:
                                                            screenHeight * 0.05,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .blue.shade600,
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    5.0),
                                                            topRight:
                                                                Radius.circular(
                                                                    5.0),
                                                          ),
                                                        ),
                                                        child: const Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              "Kế hoạch thực tập",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 18,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                StreamBuilder(
                                                  stream: firestore
                                                      .collection(
                                                          'planTrainees')
                                                      .snapshots(),
                                                  builder: (context, snapshot) {
                                                    final List<PlanTraineeModel>
                                                        listPlanTrainee = [];
                                                    if (snapshot.hasData &&
                                                        snapshot.connectionState ==
                                                            ConnectionState
                                                                .active) {
                                                      snapshot.data?.docs
                                                          .forEach((element) {
                                                        listPlanTrainee.add(
                                                            PlanTraineeModel
                                                                .fromMap(element
                                                                    .data()));
                                                      });
                                                      return listPlanTrainee
                                                              .isNotEmpty
                                                          ? ListView.builder(
                                                              itemCount:
                                                                  listPlanTrainee
                                                                      .length,
                                                              shrinkWrap: true,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                return InkWell(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      readPlanTrainee
                                                                              .value =
                                                                          listPlanTrainee[
                                                                              index];
                                                                    });
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    height:
                                                                        screenHeight *
                                                                            0.05,
                                                                    color: index %
                                                                                2 ==
                                                                            0
                                                                        ? Colors
                                                                            .blue
                                                                            .shade50
                                                                        : null,
                                                                    child: Row(
                                                                      children: [
                                                                        Expanded(
                                                                          flex:
                                                                              1,
                                                                          child: Text(
                                                                              '${index + 1}',
                                                                              textAlign: TextAlign.center),
                                                                        ),
                                                                        Expanded(
                                                                          flex:
                                                                              5,
                                                                          child: Text(
                                                                              listPlanTrainee[index].title!,
                                                                              textAlign: TextAlign.justify),
                                                                        ),
                                                                        Expanded(
                                                                          flex:
                                                                              3,
                                                                          child: Text(
                                                                              GV.readTimestamp(listPlanTrainee[index].createdAt!),
                                                                              textAlign: TextAlign.center),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            )
                                                          : const Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 100),
                                                              child: Center(
                                                                child: Text(
                                                                    'Chưa có thông báo.'),
                                                              ),
                                                            );
                                                    } else {
                                                      return const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 150),
                                                        child: Loading(),
                                                      );
                                                    }
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : readAnnouncement.value.announcementId !=
                                              null &&
                                          readPlanTrainee.value.planTraineeId ==
                                              null
                                      ? Expanded(
                                          child: Column(
                                            children: [
                                              Container(
                                                constraints: BoxConstraints(
                                                    minHeight:
                                                        screenHeight * 0.55),
                                                decoration: BoxDecoration(
                                                    color: Colors.grey.shade100,
                                                    border: Border.all(
                                                      style: BorderStyle.solid,
                                                      width: 0.1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Container(
                                                            height:
                                                                screenHeight *
                                                                    0.06,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors.blue
                                                                  .shade600,
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        5.0),
                                                                topRight: Radius
                                                                    .circular(
                                                                        5.0),
                                                              ),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              25),
                                                                  child:
                                                                      SizedBox(
                                                                    width: 30,
                                                                    child:
                                                                        IconButton(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              1),
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          readAnnouncement.value =
                                                                              AnnouncementModel();
                                                                        });
                                                                      },
                                                                      icon:
                                                                          const Icon(
                                                                        Icons
                                                                            .arrow_back_outlined,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            30,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const Expanded(
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(
                                                                        "Chi tiết tin",
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          fontSize:
                                                                              18,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 30),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 30,
                                                          horizontal: 70),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                '${readAnnouncement.value.title} - ${GV.readTimestamp(readAnnouncement.value.createdAt!)}',
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 22,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                              width:
                                                                  screenWidth *
                                                                      0.35,
                                                              child: Divider()),
                                                          const SizedBox(
                                                              height: 15),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  'Nội dung: ${readAnnouncement.value.content}',
                                                                  maxLines: 100,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .clip,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          Row(
                                                            children: [
                                                              SizedBox(
                                                                width:
                                                                    screenWidth *
                                                                        0.1,
                                                                child:
                                                                    const Text(
                                                                  'Tệp đính kèm: ',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .clip,
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Column(
                                                                  children: [
                                                                    ListView
                                                                        .builder(
                                                                      itemCount: readAnnouncement
                                                                          .value
                                                                          .files!
                                                                          .length,
                                                                      shrinkWrap:
                                                                          true,
                                                                      itemBuilder:
                                                                          (context,
                                                                              index) {
                                                                        return InkWell(
                                                                          onTap:
                                                                              () {
                                                                            openInANewTab(readAnnouncement.value.files![index].fileUrl);
                                                                          },
                                                                          child:
                                                                              Text(
                                                                            '${readAnnouncement.value.files![index].fileName}',
                                                                            style:
                                                                                TextStyle(
                                                                              decoration: TextDecoration.underline,
                                                                              color: Colors.blue.shade900,
                                                                              fontSize: 18,
                                                                            ),
                                                                            overflow:
                                                                                TextOverflow.clip,
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Expanded(
                                          child: Column(
                                            children: [
                                              Container(
                                                constraints: BoxConstraints(
                                                    minHeight:
                                                        screenHeight * 0.55),
                                                decoration: BoxDecoration(
                                                    color: Colors.grey.shade100,
                                                    border: Border.all(
                                                      style: BorderStyle.solid,
                                                      width: 0.1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Container(
                                                            height:
                                                                screenHeight *
                                                                    0.06,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors.blue
                                                                  .shade600,
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        5.0),
                                                                topRight: Radius
                                                                    .circular(
                                                                        5.0),
                                                              ),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              25),
                                                                  child:
                                                                      SizedBox(
                                                                    width: 30,
                                                                    child:
                                                                        IconButton(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          bottom:
                                                                              1),
                                                                      onPressed:
                                                                          () {
                                                                        setState(
                                                                            () {
                                                                          readPlanTrainee.value =
                                                                              PlanTraineeModel();
                                                                        });
                                                                      },
                                                                      icon:
                                                                          const Icon(
                                                                        Icons
                                                                            .arrow_back_outlined,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            30,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                const Expanded(
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(
                                                                        "Chi tiết tin",
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.white,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          fontSize:
                                                                              18,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 30),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 30,
                                                          horizontal: 70),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                '${readPlanTrainee.value.title} - ${GV.readTimestamp(readPlanTrainee.value.createdAt!)}',
                                                                style:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 22,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                              width:
                                                                  screenWidth *
                                                                      0.35,
                                                              child: Divider()),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              Text(
                                                                'Học kỳ: ${readPlanTrainee.value.term}',
                                                                maxLines: 100,
                                                                overflow:
                                                                    TextOverflow
                                                                        .clip,
                                                              ),
                                                              Text(
                                                                'Năm học: ${readPlanTrainee.value.yearStart} - ${readPlanTrainee.value.yearEnd}',
                                                                maxLines: 100,
                                                                overflow:
                                                                    TextOverflow
                                                                        .clip,
                                                              ),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    top: 15),
                                                            child: Table(
                                                              border:
                                                                  TableBorder
                                                                      .all(),
                                                              columnWidths:
                                                                  Map.from({
                                                                0: const FlexColumnWidth(
                                                                    11),
                                                                1: const FlexColumnWidth(
                                                                    5),
                                                              }),
                                                              children: [
                                                                TableRow(
                                                                  children: [
                                                                    Container(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            10),
                                                                        child:
                                                                            const Text(
                                                                          'Nội Dung',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                          style:
                                                                              TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        )),
                                                                    Container(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          10),
                                                                      child:
                                                                          const Text(
                                                                        'Thời Gian',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                for (var i = 0;
                                                                    i <
                                                                        readPlanTrainee
                                                                            .value
                                                                            .listContent!
                                                                            .length;
                                                                    i++)
                                                                  TableRow(
                                                                    children: [
                                                                      TableCell(
                                                                        verticalAlignment:
                                                                            TableCellVerticalAlignment.middle,
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              10),
                                                                          child:
                                                                              Text(
                                                                            '${readPlanTrainee.value.listContent![i].content}',
                                                                            textAlign:
                                                                                TextAlign.justify,
                                                                            maxLines:
                                                                                100,
                                                                            overflow:
                                                                                TextOverflow.clip,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      TableCell(
                                                                        verticalAlignment:
                                                                            TableCellVerticalAlignment.middle,
                                                                        child:
                                                                            Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              10),
                                                                          child:
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              if (readPlanTrainee.value.listContent![i].note!.isNotEmpty) ...[
                                                                                Text(
                                                                                  '${readPlanTrainee.value.listContent![i].note}',
                                                                                  maxLines: 100,
                                                                                  overflow: TextOverflow.clip,
                                                                                ),
                                                                                const SizedBox(height: 10),
                                                                              ],
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                children: [
                                                                                  if (readPlanTrainee.value.listContent![i].dayStart != null)
                                                                                    Expanded(
                                                                                      flex: 5,
                                                                                      child: Text(
                                                                                        'Từ ${GV.readTimestamp(readPlanTrainee.value.listContent![i].dayStart!)}',
                                                                                        maxLines: 100,
                                                                                        overflow: TextOverflow.clip,
                                                                                      ),
                                                                                    ),
                                                                                  if (readPlanTrainee.value.listContent![i].dayEnd != null)
                                                                                    Expanded(
                                                                                      flex: 5,
                                                                                      child: Text(
                                                                                        'Đến ${GV.readTimestamp(readPlanTrainee.value.listContent![i].dayEnd!)}',
                                                                                        maxLines: 100,
                                                                                        overflow: TextOverflow.clip,
                                                                                      ),
                                                                                    ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 15),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'Ghi chú: ${readPlanTrainee.value.notice}',
                                                                maxLines: 100,
                                                                overflow:
                                                                    TextOverflow
                                                                        .clip,
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                            ],
                          ),
                        );
                      });
                }),
            const Footer(),
          ],
        ),
      ),
    );
  }

  openInANewTab(url) {
    html.window.open(url, 'PlaceholderName');
  }
}
