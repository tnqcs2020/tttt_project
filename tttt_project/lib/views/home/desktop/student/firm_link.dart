// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tttt_project/routes.dart';
import 'package:tttt_project/widgets/footer.dart';
import 'package:tttt_project/widgets/user_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/data/constant.dart';
import 'package:tttt_project/widgets/menu/menu_left.dart';

// class FirmLink extends StatefulWidget {
//   const FirmLink({Key? key}) : super(key: key);

//   @override
//   State<FirmLink> createState() => _FirmLinkState();
// }

// class _FirmLinkState extends State<FirmLink> {
//   // final ValueListenable _notifier = ValueNotifier(String);
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
//                     "Danh sách các công ty liên kết với trường",
//                     style: TextStyle(
//                         color: Colors.white, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               child: Column(children: [
//                 Row(
//                   children: [
//                     Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(width: 0.1),
//                         // borderRadius: BorderRadius.circular(10),
//                         color: Colors.teal.shade100,
//                       ),
//                       child: TextButton(
//                           onPressed: () {}, child: Text('Danh sách công ty')),
//                     ),
//                     Container(
//                         decoration: BoxDecoration(
//                           border: Border.all(width: 0.1),
//                           // borderRadius: BorderRadius.circular(10),
//                           color: Colors.teal.shade100,
//                         ),
//                         child: TextButton(
//                             onPressed: () {}, child: Text('Thêm công ty'))),
//                     Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(width: 0.1),
//                         // borderRadius: BorderRadius.circular(10),
//                         color: Colors.teal.shade100,
//                       ),
//                       child: TextButton(
//                           onPressed: () {}, child: Text('Công ty đã đăng ký')),
//                     ),
//                     Container(
//                         decoration: BoxDecoration(
//                           border: Border.all(width: 0.1),
//                           // borderRadius: BorderRadius.circular(10),
//                           color: Colors.teal.shade100,
//                         ),
//                         child: TextButton(
//                             onPressed: () {}, child: Text('Cập nhật')))
//                   ],
//                 ),
//               ]),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

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
    print(sharedPref
        .getString(
          'userId',
        )
        .toString());
    if (isLoggedIn == true) {
      // sharedPref.getString('email').toString();
      // sharedPref.getString('password').toString();
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
        print(isExistUser.data()?['group']);
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
            // Obx(
            //   () =>
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
                  // pages[currentUser.group.value]
                  //         ?[currentUser.menuSelected.value] ??
                  //     // pages[currentUser.group.value]!
                  //     const SizedBox(),
                  Expanded(
                    child: Container(
                      constraints:
                          BoxConstraints(minHeight: screenHeight * 0.74),
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
                          Container(
                            child: Column(children: [
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(width: 0.1),
                                      // borderRadius: BorderRadius.circular(10),
                                      color: Colors.teal.shade100,
                                    ),
                                    child: TextButton(
                                        onPressed: () {},
                                        child: Text('Danh sách công ty')),
                                  ),
                                  Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(width: 0.1),
                                        // borderRadius: BorderRadius.circular(10),
                                        color: Colors.teal.shade100,
                                      ),
                                      child: TextButton(
                                          onPressed: () {},
                                          child: Text('Thêm công ty'))),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(width: 0.1),
                                      // borderRadius: BorderRadius.circular(10),
                                      color: Colors.teal.shade100,
                                    ),
                                    child: TextButton(
                                        onPressed: () {},
                                        child: Text('Công ty đã đăng ký')),
                                  ),
                                  Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(width: 0.1),
                                        // borderRadius: BorderRadius.circular(10),
                                        color: Colors.teal.shade100,
                                      ),
                                      child: TextButton(
                                          onPressed: () {},
                                          child: Text('Cập nhật')))
                                ],
                              ),
                            ]),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ),
            const Footer(),
          ],
        ),
      ),
    );
  }
}
