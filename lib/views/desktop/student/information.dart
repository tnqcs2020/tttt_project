// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tttt_project/data/constant.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/widgets/custom_radio.dart';
import 'package:tttt_project/widgets/header.dart';
import 'package:tttt_project/widgets/line_detail.dart';
import 'package:tttt_project/widgets/user_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/widgets/footer.dart';
import 'package:tttt_project/widgets/menu/menu_left.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({Key? key}) : super(key: key);

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  final GlobalKey<FormState> updateInfoFormKey = GlobalKey<FormState>();
  final currentUser = Get.put(UserController());
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController birthdayCtrl = TextEditingController();
  String gender = "";
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
          await FirebaseFirestore.instance.collection('users').doc(userId).get();
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
    if (currentUser.gender.value == 'Nam') {
      currentUser.selected.value = 0;
      gender = 'Nam';
    } else if (currentUser.gender.value == 'Nữ') {
      currentUser.selected.value = 1;
      gender = 'Nữ';
    } else {
      currentUser.selected.value = 2;
    }
    currentUser.loadIn.value = true;
  }

  @override
  void dispose() {
    addressCtrl.dispose();
    phoneCtrl.dispose();
    birthdayCtrl.dispose();
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
        child: Obx(() => Column(
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
                                      "Thông tin sinh viên",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: screenWidth * 0.5,
                                child: Form(
                                  key: updateInfoFormKey,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            LineDetail(
                                                field: "Họ tên",
                                                display:
                                                    currentUser.userName.value),
                                            LineDetail(
                                                field: "Mã số",
                                                display: currentUser
                                                    .userId.value
                                                    .toUpperCase()),
                                          ],
                                        ),
                                      ),
                                      const Divider(
                                        thickness: 0.2,
                                        height: 0,
                                        color: Colors.black,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            LineDetail(
                                                field: "Khóa",
                                                display:
                                                    currentUser.course.value),
                                            LineDetail(
                                                field: "Ngành",
                                                display:
                                                    currentUser.major.value),
                                          ],
                                        ),
                                      ),
                                      const Divider(
                                        thickness: 0.2,
                                        height: 0,
                                        color: Colors.black,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            LineDetail(
                                                field: "Mã Lớp",
                                                display: currentUser
                                                    .classId.value),
                                            LineDetail(
                                                field: "Lớp",
                                                display: currentUser
                                                    .className.value),
                                          ],
                                        ),
                                      ),
                                      const Divider(
                                        thickness: 0.2,
                                        height: 0,
                                        color: Colors.black,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: screenWidth * 0.07,
                                                  child: const Text(
                                                    'Giới tính',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                    ),
                                                    overflow:
                                                        TextOverflow.visible,
                                                  ),
                                                ),
                                                Obx(
                                                  () => SizedBox(
                                                    width: screenWidth * 0.17,
                                                    child: Row(
                                                      children: [
                                                        CustomRadio(
                                                          title: 'Nam',
                                                          onTap: () {
                                                            setState(() {
                                                              gender = 'Nam';
                                                              currentUser
                                                                  .selected
                                                                  .value = 0;
                                                            });
                                                          },
                                                          selected: currentUser
                                                                  .selected
                                                                  .value ==
                                                              0,
                                                        ),
                                                        CustomRadio(
                                                          title: 'Nữ',
                                                          onTap: () {
                                                            setState(() {
                                                              gender = 'Nữ';
                                                              currentUser
                                                                  .selected
                                                                  .value = 1;
                                                            });
                                                          },
                                                          selected: currentUser
                                                                  .selected
                                                                  .value ==
                                                              1,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            LineDetail(
                                                field: "Email",
                                                display:
                                                    currentUser.email.value),
                                          ],
                                        ),
                                      ),
                                      const Divider(
                                        thickness: 0.2,
                                        height: 0,
                                        color: Colors.black,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            LineDetail(
                                              ctrl: birthdayCtrl,
                                              display: birthdayCtrl.text,
                                              field: "Ngày sinh",
                                              suffixIcon: IconButton(
                                                onPressed: () async {
                                                  final datePick =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime(1900),
                                                    lastDate: DateTime(2100),
                                                    builder: (context, child) {
                                                      double screenHeight =
                                                          MediaQuery.of(context)
                                                              .size
                                                              .height;
                                                      double screenWidth =
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width;
                                                      return Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                          top: screenHeight *
                                                              0.15,
                                                          bottom: screenHeight *
                                                              0.06,
                                                          left:
                                                              screenWidth * 0.4,
                                                          right: screenWidth *
                                                              0.21,
                                                        ),
                                                        child: SizedBox(
                                                          height: 450,
                                                          width: 700,
                                                          child: child,
                                                        ),
                                                      );
                                                    },
                                                  );
                                                  setState(() {
                                                    birthdayCtrl.text =
                                                        DateFormat('dd/MM/yyyy')
                                                            .format(datePick!)
                                                            .toString();
                                                  });
                                                },
                                                icon: const Icon(
                                                    Icons.date_range_outlined),
                                              ),
                                              validator: (p0) => p0!.isEmpty
                                                  ? 'Không được để trống'
                                                  : null,
                                            ),
                                            LineDetail(
                                              ctrl: phoneCtrl,
                                              field: "Điện thoại",
                                              textFormat: <TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              validator: (p0) => p0!.isEmpty
                                                  ? 'Không được để trống'
                                                  : null,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Divider(
                                        thickness: 0.2,
                                        height: 0,
                                        color: Colors.black,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            LineDetail(
                                              ctrl: addressCtrl,
                                              field: "Địa chỉ",
                                              widthForm: 0.25,
                                              validator: (p0) => p0!.isEmpty
                                                  ? 'Không được để trống'
                                                  : null,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 35, bottom: 45),
                                        child: ElevatedButton(
                                            onPressed: () async {
                                              if (updateInfoFormKey
                                                  .currentState!
                                                  .validate()) {
                                                if (gender != '') {
                                                  await firestore
                                                      .collection('users')
                                                      .doc(currentUser
                                                          .userId.value)
                                                      .update({
                                                    "gender": gender,
                                                    "address": addressCtrl.text,
                                                    "phone": phoneCtrl.text,
                                                    "birthday":
                                                        birthdayCtrl.text,
                                                  });
                                                  GV.success(
                                                      context: context,
                                                      message:
                                                          "Cập nhật thành công.");
                                                } else {
                                                  GV.error(
                                                      context: context,
                                                      message:
                                                          "Hãy chọn giới tính.");
                                                }
                                              }
                                            },
                                            style: const ButtonStyle(
                                                elevation:
                                                    MaterialStatePropertyAll(
                                                        5)),
                                            child: const Text('Cập nhật')),
                                      ),
                                    ],
                                  ),
                                ),
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
      ),
    );
  }
}
