import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/data/constant.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/widgets/custom_button.dart';
import 'package:tttt_project/widgets/footer.dart';
import 'package:tttt_project/widgets/header.dart';
import 'package:tttt_project/widgets/line_detail.dart';
import 'package:tttt_project/widgets/menu/menu_left.dart';
import 'package:tttt_project/widgets/user_controller.dart';

class InfoCV extends StatefulWidget {
  const InfoCV({
    super.key,
  });

  @override
  State<InfoCV> createState() => _InfoCVState();
}

class _InfoCVState extends State<InfoCV> {
  final currentUser = Get.put(UserController());
  final TextEditingController nameCVCtrl = TextEditingController();
  final TextEditingController phoneCVCtrl = TextEditingController();
  String email = '';
  String classId = '';
  String className = '';

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
        nameCVCtrl.text = currentUser.userName.value;
        phoneCVCtrl.text = currentUser.phone.value;
        setState(() {
          email = currentUser.email.value;
          classId = currentUser.cvClass.last.classId!;
          className = currentUser.cvClass.last.className!;
        });
      }
    }
    currentUser.loadIn.value = true;
  }

  @override
  void dispose() {
    nameCVCtrl.dispose();
    phoneCVCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        backgroundColor: Colors.cyan.shade50,
        body: Column(
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
                                  "Quản lý thông tin",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StreamBuilder<Object>(
                              stream: null,
                              builder: (context, snapshot) {
                                return Container(
                                  padding: const EdgeInsets.only(
                                    left: 100,
                                    top: 20,
                                    right: 100,
                                  ),
                                  width: screenWidth * 0.7,
                                  constraints: BoxConstraints(
                                      minHeight: screenHeight * 0.15),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          LineDetail(
                                            field: "Mã cố vấn",
                                            display: currentUser.userId.value
                                                .toUpperCase(),
                                          ),
                                          LineDetail(
                                            field: "Họ tên",
                                            ctrl: nameCVCtrl,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 25),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          LineDetail(
                                            field: "Điện thoại",
                                            ctrl: phoneCVCtrl,
                                            textFormat: <TextInputFormatter>[
                                              FilteringTextInputFormatter
                                                  .digitsOnly
                                            ],
                                          ),
                                          LineDetail(
                                            field: "Email",
                                            display: email,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 25),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          LineDetail(
                                            field: "Mã lớp cố vấn",
                                            display: classId,
                                          ),
                                          LineDetail(
                                            field: "Tên lớp cố vấn",
                                            display: className,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 25),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 50),
                                        child: CustomButton(
                                          text: "Lưu",
                                          width: screenWidth * 0.1,
                                          height: screenHeight * 0.07,
                                          onTap: () async {
                                            if (nameCVCtrl.text !=
                                                    currentUser
                                                        .userName.value ||
                                                phoneCVCtrl.text !=
                                                    currentUser.phone.value) {
                                              GV.usersCol
                                                  .doc(currentUser.userId.value)
                                                  .update({
                                                'name': nameCVCtrl.text,
                                                'phone': phoneCVCtrl.text,
                                              });
                                              currentUser.setCurrentUser(
                                                setUserName: nameCVCtrl.text,
                                                setPhone: phoneCVCtrl.text,
                                              );
                                              GV.success(
                                                  context: context,
                                                  message:
                                                      'Thay đổi thành công!');
                                            } else if (nameCVCtrl.text ==
                                                    currentUser
                                                        .userName.value &&
                                                phoneCVCtrl.text ==
                                                    currentUser.phone.value) {
                                              GV.error(
                                                  context: context,
                                                  message:
                                                      'Không có gì thay đổi!');
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Footer(),
          ],
        ));
  }
}
