// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tttt_project/widgets/line_detail.dart';
import 'package:tttt_project/widgets/user_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/data/constant.dart';
import 'package:tttt_project/routes.dart';
import 'package:tttt_project/widgets/footer.dart';
import 'package:tttt_project/widgets/menu/menu_left.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({Key? key}) : super(key: key);

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
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
            Container(
              color: Colors.blue.shade600,
              height: screenHeight * 0.12,
              padding: EdgeInsets.only(
                left: screenWidth * 0.08,
                right: screenWidth * 0.08,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hệ thống quản lý thực tập thực tế",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "Trường Công nghệ Thông tin và Truyền thông",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  Container(
                    constraints: const BoxConstraints(minWidth: 100),
                    padding: const EdgeInsets.only(top: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            ElevatedButton(
                                onPressed: () async {
                                  final SharedPreferences sharedPref =
                                      await SharedPreferences.getInstance();
                                  await sharedPref.remove('email');
                                  await sharedPref.remove('userId');
                                  await sharedPref.remove('password');
                                  await sharedPref.setBool("isLoggedIn", false);
                                  await sharedPref.remove('menuSelected');
                                  await GV.auth.signOut();
                                  Navigator.pushNamedAndRemoveUntil(context,
                                      RouteGenerator.login, (route) => false);
                                  // Get.toNamed(RouteGenerator.login);
                                },
                                child: const Text("Thoát"))
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Text(
                              "Xin chào, ",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            Obx(
                              () => Text(
                                currentUser.name.value,
                                style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
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
                                    "Thông tin sinh viên",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                LineDetail(
                                    field: "Họ tên",
                                    value: currentUser.name.value),
                                const Divider(
                                  thickness: 0.2,
                                  height: 0,
                                  color: Colors.black,
                                ),
                                LineDetail(
                                    field: "Mã số",
                                    value:
                                        currentUser.userId.value.toUpperCase()),
                                const Divider(
                                  thickness: 0.2,
                                  height: 0,
                                  color: Colors.black,
                                ),
                                LineDetail(
                                    field: "Khóa",
                                    value: currentUser.course.value),
                                const Divider(
                                  thickness: 0.2,
                                  height: 0,
                                  color: Colors.black,
                                ),
                                LineDetail(
                                    field: "Ngành",
                                    value: currentUser.major.value),
                                const Divider(
                                  thickness: 0.2,
                                  height: 0,
                                  color: Colors.black,
                                ),
                                LineDetail(
                                    field: "Lớp",
                                    value: currentUser.className.value),
                                const Divider(
                                  thickness: 0.2,
                                  height: 0,
                                  color: Colors.black,
                                ),
                                LineDetail(
                                    field: "Ngày sinh",
                                    value: currentUser.birthday.value),
                                const Divider(
                                  thickness: 0.2,
                                  height: 0,
                                  color: Colors.black,
                                ),
                                LineDetail(
                                    field: "Giới tính",
                                    value: currentUser.gender.value),
                                const Divider(
                                  thickness: 0.2,
                                  height: 0,
                                  color: Colors.black,
                                ),
                                LineDetail(
                                    field: "Điện thoại",
                                    value: currentUser.phone.value),
                                const Divider(
                                  thickness: 0.2,
                                  height: 0,
                                  color: Colors.black,
                                ),
                                LineDetail(
                                    field: "Email",
                                    value: currentUser.email.value),
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
// class Information extends StatelessWidget {
//   Information({Key? key}) : super(key: key);
//   final currentUser = Get.put(UserController());

//   @override
//   Widget build(BuildContext context) {
//     double screenHeight = MediaQuery.of(context).size.height;
//     // double screenWidth = MediaQuery.of(context).size.width;
//     return Expanded(
//       child: Container(
//         constraints: BoxConstraints(minHeight: screenHeight * 0.74),
//         decoration: BoxDecoration(
//             color: Colors.grey.shade100,
//             border: Border.all(
//               style: BorderStyle.solid,
//               width: 0.1,
//             ),
//             borderRadius: BorderRadius.circular(5)),
//         child: Column(
//           children: [
//             Container(
//               height: 35,
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade600,
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(5.0),
//                   topRight: Radius.circular(5.0),
//                 ),
//               ),
//               child: const Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "Thông tin sinh viên",
//                     style: TextStyle(
//                         color: Colors.white, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//             Column(
//               children: [
//                 LineDetail(field: "Họ tên", value: currentUser.name.value),
//                 const Divider(
//                   thickness: 0.2,
//                   height: 0,
//                   color: Colors.black,
//                 ),
//                 LineDetail(
//                     field: "Mã số",
//                     value: currentUser.userId.value.toUpperCase()),
//                 const Divider(
//                   thickness: 0.2,
//                   height: 0,
//                   color: Colors.black,
//                 ),
//                 LineDetail(field: "Khóa", value: currentUser.course.value),
//                 const Divider(
//                   thickness: 0.2,
//                   height: 0,
//                   color: Colors.black,
//                 ),
//                 LineDetail(field: "Ngành", value: currentUser.major.value),
//                 const Divider(
//                   thickness: 0.2,
//                   height: 0,
//                   color: Colors.black,
//                 ),
//                 LineDetail(field: "Lớp", value: currentUser.className.value),
//                 const Divider(
//                   thickness: 0.2,
//                   height: 0,
//                   color: Colors.black,
//                 ),
//                 LineDetail(
//                     field: "Ngày sinh", value: currentUser.birthday.value),
//                 const Divider(
//                   thickness: 0.2,
//                   height: 0,
//                   color: Colors.black,
//                 ),
//                 LineDetail(field: "Giới tính", value: currentUser.gender.value),
//                 const Divider(
//                   thickness: 0.2,
//                   height: 0,
//                   color: Colors.black,
//                 ),
//                 LineDetail(field: "Điện thoại", value: currentUser.phone.value),
//                 const Divider(
//                   thickness: 0.2,
//                   height: 0,
//                   color: Colors.black,
//                 ),
//                 LineDetail(field: "Email", value: currentUser.email.value),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
