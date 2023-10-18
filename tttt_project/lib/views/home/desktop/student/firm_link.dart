// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tttt_project/widgets/footer.dart';
import 'package:tttt_project/widgets/header.dart';
import 'package:tttt_project/widgets/user_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/data/constant.dart';
import 'package:tttt_project/widgets/menu/menu_left.dart';

class FirmLink extends StatefulWidget {
  const FirmLink({Key? key}) : super(key: key);

  @override
  State<FirmLink> createState() => _FirmLinkState();
}

class _FirmLinkState extends State<FirmLink> {
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
                                  "Danh sách các công ty liên kết với trường",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Obx(
                            () => Container(
                              child: Column(children: [
                                Row(
                                  children: [
                                    if (currentUser.group.value ==
                                        NguoiDung.sinhvien)
                                      Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(width: 0.1),
                                            // borderRadius: BorderRadius.circular(10),
                                            color: Colors.teal.shade100,
                                          ),
                                          child: TextButton(
                                              onPressed: () {},
                                              child: const Text(
                                                  'Hồ sơ xin việc'))),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(width: 0.1),
                                        // borderRadius: BorderRadius.circular(10),
                                        color: Colors.teal.shade100,
                                      ),
                                      child: TextButton(
                                          onPressed: () {},
                                          child:
                                              const Text('Danh sách công ty')),
                                    ),
                                    if (currentUser.group.value ==
                                        NguoiDung.quantri)
                                      Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(width: 0.1),
                                            // borderRadius: BorderRadius.circular(10),
                                            color: Colors.teal.shade100,
                                          ),
                                          child: TextButton(
                                              onPressed: () {},
                                              child:
                                                  const Text('Thêm công ty'))),
                                    if (currentUser.group.value ==
                                        NguoiDung.sinhvien)
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(width: 0.1),
                                          // borderRadius: BorderRadius.circular(10),
                                          color: Colors.teal.shade100,
                                        ),
                                        child: TextButton(
                                            onPressed: () {},
                                            child: const Text(
                                                'Công ty đã đăng ký')),
                                      ),
                                  ],
                                ),
                              ]),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Footer(),
          ],
        ),
      ),
    );
  }
}
