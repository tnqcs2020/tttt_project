// ignore_for_file: use_build_context_synchronously, dead_code

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/views/desktop/canbo/list_student_regis.dart';
import 'package:tttt_project/views/desktop/canbo/list_student_trainee.dart';
import 'package:tttt_project/widgets/footer.dart';
import 'package:tttt_project/widgets/header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/widgets/menu/menu_left.dart';
import 'package:tttt_project/common/user_controller.dart';

class ManageTrainee extends StatefulWidget {
  const ManageTrainee({Key? key}) : super(key: key);

  @override
  State<ManageTrainee> createState() => _ManageTraineeState();
}

class _ManageTraineeState extends State<ManageTrainee> {
  final currentUser = Get.put(UserController());
  ValueNotifier selectedMenu = ValueNotifier(0);
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

  List manageInfo = [
    'Danh sách đăng ký',
    'Danh sách thực tập',
  ];
  List contentInfo = [
    const ListStudentRegis(),
    const ListStudentTrainee(),
  ];

  @override
  void dispose() {
    selectedMenu.dispose();
    super.dispose();
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
              Padding(
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
                            BoxConstraints(minHeight: screenHeight * 0.67),
                        decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            border: Border.all(
                              style: BorderStyle.solid,
                              width: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(5)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: screenHeight * 0.06,
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
                                    "Quản lý thực tập",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ValueListenableBuilder(
                              valueListenable: selectedMenu,
                              builder: (context, value, child) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: screenHeight * 0.05,
                                      child: ListView.builder(
                                        itemCount: manageInfo.length,
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            width: screenWidth * 0.13,
                                            constraints: BoxConstraints(
                                                minWidth: screenWidth * 0.01),
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              border: Border.all(width: 0.1),
                                              color: value == index
                                                  ? Colors.white
                                                  : Colors.teal.shade100,
                                            ),
                                            child: InkWell(
                                              child: Center(
                                                child: Text(
                                                  manageInfo[index],
                                                  style: TextStyle(
                                                    color: value == index
                                                        ? Colors.blue.shade900
                                                        : null,
                                                    fontWeight: value == index
                                                        ? FontWeight.bold
                                                        : null,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  selectedMenu.value = index;
                                                });
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    contentInfo[selectedMenu.value],
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Footer(),
            ],
          )),
    );
  }
}
