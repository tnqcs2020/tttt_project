// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/widgets/custom_button.dart';
import 'package:tttt_project/widgets/footer.dart';
import 'package:tttt_project/widgets/header.dart';
import 'package:tttt_project/widgets/line_detail.dart';
import 'package:tttt_project/widgets/user_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/widgets/menu/menu_left.dart';

class CVScreen extends StatefulWidget {
  const CVScreen({Key? key}) : super(key: key);

  @override
  State<CVScreen> createState() => _CVScreenState();
}

class _CVScreenState extends State<CVScreen> {
  final currentUser = Get.put(UserController());

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  getUserData() async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    bool? isLoggedIn = sharedPref.getBool("isLoggedIn");
    if (isLoggedIn == true) {
      currentUser.setCurrentUser(
        setMenuSelected: sharedPref.getInt('menuSelected'),
      );
      DocumentSnapshot<Map<String, dynamic>> isExistUser =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(sharedPref
                  .getString(
                    'userId',
                  )
                  .toString())
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
            Obx(
              () => Padding(
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
                    Expanded(
                      child: Container(
                        constraints:
                            BoxConstraints(minHeight: screenHeight * 0.7),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            border: Border.all(
                              style: BorderStyle.solid,
                              width: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(5)),
                        child: Column(
                          children: [
                            Container(
                              height: 35,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade600,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(5.0),
                                  topRight: Radius.circular(5.0),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Hồ sơ của bạn",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(children: [
                                        LineDetail(
                                            field: "Họ tên",
                                            display: currentUser.userName.value)
                                      ]),
                                      Column(children: [
                                        LineDetail(
                                            field: "Mã số",
                                            display: currentUser.userId.value)
                                      ]),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(children: [
                                        LineDetail(
                                            field: "Lớp",
                                            display: currentUser.className.value)
                                      ]),
                                      Column(children: [
                                        LineDetail(
                                            field: "Khóa",
                                            display: currentUser.course.value)
                                      ]),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              color: Colors.purpleAccent,
                                              child: SizedBox(
                                                width: screenWidth * 0.07,
                                                child: const Text(
                                                  "Kỹ năng",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              color: Colors.amberAccent,
                                              child: SizedBox(
                                                width: screenWidth * 0.15,
                                                child: TextFormField(),
                                              ),
                                            )
                                          ],
                                        )
                                      ]),
                                      // SizedBox(
                                      //   width: 1,
                                      // ),
                                      Column(children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              color: Colors.purpleAccent,
                                              child: SizedBox(
                                                width: screenWidth * 0.07,
                                                child: const Text(
                                                  "Thành tích",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              color: Colors.amberAccent,
                                              child: SizedBox(
                                                width: screenWidth * 0.15,
                                                child: TextFormField(),
                                              ),
                                            )
                                          ],
                                        )
                                      ]),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              color: Colors.purpleAccent,
                                              child: SizedBox(
                                                width: screenWidth * 0.07,
                                                child: const Text(
                                                  "Sở thích",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              color: Colors.amberAccent,
                                              child: SizedBox(
                                                width: screenWidth * 0.15,
                                                child: TextFormField(),
                                              ),
                                            )
                                          ],
                                        )
                                      ]),
                                      Column(children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              color: Colors.purpleAccent,
                                              child: SizedBox(
                                                width: screenWidth * 0.07,
                                                child: const Text(
                                                  "Nguyện vọng",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              color: Colors.amberAccent,
                                              child: SizedBox(
                                                width: screenWidth * 0.15,
                                                child: TextFormField(),
                                              ),
                                            )
                                          ],
                                        )
                                      ]),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 55),
                                CustomButton(
                                  text: "Lưu",
                                  width: screenWidth * 0.1,
                                  height: screenHeight * 0.07,
                                  onTap: () {},
                                ),
                                const SizedBox(height: 20)
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Footer(),
          ],
        ),
      ),
    );
  }
}
