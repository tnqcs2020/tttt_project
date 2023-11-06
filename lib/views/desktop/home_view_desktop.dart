// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/data/constant.dart';
import 'package:tttt_project/models/announcement_model.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/widgets/footer.dart';
import 'package:tttt_project/widgets/header.dart';
import 'package:tttt_project/widgets/loading.dart';
import 'package:tttt_project/widgets/menu/menu_left.dart';
import 'package:tttt_project/widgets/user_controller.dart';
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
                        readAnnouncement.value.announcementId == null
                            ? Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(
                                          minHeight: screenHeight * 0.35),
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
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue.shade600,
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(5.0),
                                                      topRight:
                                                          Radius.circular(5.0),
                                                    ),
                                                  ),
                                                  child: const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        "Tin Giáo Vụ Khoa",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          StreamBuilder(
                                            stream: firestore
                                                .collection('announcements')
                                                .where('type',
                                                    isEqualTo: 'Tin giáo vụ')
                                                .snapshots(),
                                            builder: (context, snapshot) {
                                              final List<AnnouncementModel>
                                                  listAnnouncement = [];
                                              if (snapshot.hasData &&
                                                  snapshot.connectionState ==
                                                      ConnectionState.active) {
                                                snapshot.data?.docs
                                                    .forEach((element) {
                                                  listAnnouncement.add(
                                                      AnnouncementModel.fromMap(
                                                          element.data()));
                                                });
                                                return listAnnouncement
                                                        .isNotEmpty
                                                    ? ListView.builder(
                                                        itemCount:
                                                            listAnnouncement
                                                                .length,
                                                        shrinkWrap: true,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                                readAnnouncement
                                                                        .value =
                                                                    listAnnouncement[
                                                                        index];
                                                              });
                                                            },
                                                            child: Container(
                                                              height:
                                                                  screenHeight *
                                                                      0.05,
                                                              color: index %
                                                                          2 ==
                                                                      0
                                                                  ? Colors.blue
                                                                      .shade50
                                                                  : null,
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: Text(
                                                                        '${index + 1}',
                                                                        textAlign:
                                                                            TextAlign.center),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 5,
                                                                    child: Text(
                                                                        listAnnouncement[index]
                                                                            .title!,
                                                                        textAlign:
                                                                            TextAlign.center),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 3,
                                                                    child: Text(
                                                                        GV.readTimestamp(listAnnouncement[index]
                                                                            .createdAt!),
                                                                        textAlign:
                                                                            TextAlign.center),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      )
                                                    : const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 150),
                                                        child: Center(
                                                          child: Text(
                                                              'Chưa có thông báo.'),
                                                        ),
                                                      );
                                              } else {
                                                return const Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 150),
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
                                          minHeight: screenHeight * 0.35),
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
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue.shade600,
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(5.0),
                                                      topRight:
                                                          Radius.circular(5.0),
                                                    ),
                                                  ),
                                                  child: const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        "Tin Việc Làm",
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          StreamBuilder(
                                            stream: firestore
                                                .collection('announcements')
                                                .where('type',
                                                    isEqualTo: 'Tin việc làm')
                                                .snapshots(),
                                            builder: (context, snapshot) {
                                              final List<AnnouncementModel>
                                                  listAnnouncement = [];
                                              if (snapshot.hasData &&
                                                  snapshot.connectionState ==
                                                      ConnectionState.active) {
                                                snapshot.data?.docs
                                                    .forEach((element) {
                                                  listAnnouncement.add(
                                                      AnnouncementModel.fromMap(
                                                          element.data()));
                                                });
                                                return listAnnouncement
                                                        .isNotEmpty
                                                    ? ListView.builder(
                                                        itemCount:
                                                            listAnnouncement
                                                                .length,
                                                        shrinkWrap: true,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                                readAnnouncement
                                                                        .value =
                                                                    listAnnouncement[
                                                                        index];
                                                              });
                                                            },
                                                            child: Container(
                                                              height:
                                                                  screenHeight *
                                                                      0.05,
                                                              color: index %
                                                                          2 ==
                                                                      0
                                                                  ? Colors.blue
                                                                      .shade50
                                                                  : null,
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: Text(
                                                                        '${index + 1}',
                                                                        textAlign:
                                                                            TextAlign.center),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 5,
                                                                    child: Text(
                                                                        listAnnouncement[index]
                                                                            .title!,
                                                                        textAlign:
                                                                            TextAlign.center),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 3,
                                                                    child: Text(
                                                                        GV.readTimestamp(listAnnouncement[index]
                                                                            .createdAt!),
                                                                        textAlign:
                                                                            TextAlign.center),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      )
                                                    : const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 110),
                                                        child: Center(
                                                          child: Text(
                                                              'Chưa có thông báo.'),
                                                        ),
                                                      );
                                              } else {
                                                return const Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 150),
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
                            : Expanded(
                                child: Column(
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(
                                          minHeight: screenHeight * 0.35),
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
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue.shade600,
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(5.0),
                                                      topRight:
                                                          Radius.circular(5.0),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 35),
                                                        child: SizedBox(
                                                          width: 30,
                                                          child: IconButton(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom: 1),
                                                            onPressed: () {
                                                              setState(() {
                                                                readAnnouncement
                                                                        .value =
                                                                    AnnouncementModel();
                                                              });
                                                            },
                                                            icon: const Icon(Icons
                                                                .arrow_back_outlined),
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
                                                              "Chi Tiết Tin",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(width: 30),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 30, horizontal: 50),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                        'Tiêu đề: ${readAnnouncement.value.title} - ${GV.readTimestamp(readAnnouncement.value.createdAt!)}'),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                        'Nội dung: ${readAnnouncement.value.content}'),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    const Text(
                                                        'Tệp đính kèm: '),
                                                    Expanded(
                                                      child: Column(
                                                        children: [
                                                          ListView.builder(
                                                            itemCount:
                                                                readAnnouncement
                                                                    .value
                                                                    .files!
                                                                    .length,
                                                            shrinkWrap: true,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              return InkWell(
                                                                onTap: () {
                                                                  openInANewTab(readAnnouncement
                                                                      .value
                                                                      .files![
                                                                          index]
                                                                      .fileUrl);
                                                                },
                                                                child: Text(
                                                                  '${readAnnouncement.value.files![index].fileName}',
                                                                  style:
                                                                      TextStyle(
                                                                    decoration:
                                                                        TextDecoration
                                                                            .underline,
                                                                    color: Colors
                                                                        .blue
                                                                        .shade900,
                                                                  ),
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
                              ),
                      ],
                    ),
                  );
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
