// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tttt_project/data/constant.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/widgets/custom_button.dart';
import 'package:tttt_project/widgets/custom_textfield.dart';
import 'package:tttt_project/widgets/dropdown_style.dart';
import 'package:tttt_project/widgets/header.dart';
import 'package:tttt_project/widgets/user_controller.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/widgets/footer.dart';
import 'package:tttt_project/widgets/menu/menu_left.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({Key? key}) : super(key: key);

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final currentUser = Get.put(UserController());
  final GlobalKey<FormState> _signUpFormKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _userIdCtrl = TextEditingController();
  final TextEditingController _classIdCtrl = TextEditingController();
  final TextEditingController _classNameCtrl = TextEditingController();
  final TextEditingController _pwdCtrl =
      TextEditingController(text: "Abc@123456");
  final TextEditingController _courseCtrl = TextEditingController();
  final TextEditingController _majorCtrl = TextEditingController();
  List<String> dsnd = [
    NguoiDung.giaovu,
    NguoiDung.covan,
    // NguoiDung.congty,
    NguoiDung.cbhd,
    NguoiDung.sinhvien,
  ];
  String? selectedND;

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _userIdCtrl.dispose();
    _classIdCtrl.dispose();
    _classNameCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
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
                                  "Tạo tài khoản",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Form(
                              key: _signUpFormKey,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: screenWidth * 0.07,
                                        child: const Text(
                                          "Nhóm người dùng:",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black,
                                          ),
                                          // overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 30),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton2<String>(
                                            isExpanded: true,
                                            hint: Center(
                                              child: Text(
                                                'Chọn',
                                                style: DropdownStyle.hintStyle,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            items: dsnd
                                                .map((String nd) =>
                                                    DropdownMenuItem<String>(
                                                      value: nd,
                                                      child: Text(
                                                        nd,
                                                        style: DropdownStyle
                                                            .itemStyle,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ))
                                                .toList(),
                                            value: selectedND,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedND = value;
                                              });
                                            },
                                            buttonStyleData:
                                                DropdownStyle.buttonStyleLong,
                                            iconStyleData:
                                                DropdownStyle.iconStyleData,
                                            dropdownStyleData:
                                                DropdownStyle.dropdownStyleLong,
                                            menuItemStyleData:
                                                DropdownStyle.menuItemStyleData,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: screenWidth * 0.07,
                                                child: const Text(
                                                  "Tài khoản:",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              CustomTextField(
                                                hintText: "Mã số",
                                                controller: _userIdCtrl,
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: screenWidth * 0.07,
                                                child: const Text(
                                                  "Mật khẩu:",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              CustomTextField(
                                                hintText: "Mật khẩu",
                                                controller: _pwdCtrl,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: screenWidth * 0.07,
                                        child: const Text(
                                          "Họ tên:",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      CustomTextField(
                                        hintText: "Họ tên",
                                        controller: _nameCtrl,
                                      ),
                                    ],
                                  ),
                                  if (selectedND == NguoiDung.sinhvien)
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: screenWidth * 0.07,
                                          child: const Text(
                                            "Mã lớp:",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        CustomTextField(
                                          hintText: "Mã lớp",
                                          controller: _classIdCtrl,
                                        ),
                                      ],
                                    ),
                                  if (selectedND == NguoiDung.sinhvien)
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: screenWidth * 0.07,
                                          child: const Text(
                                            "Tên lớp:",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        CustomTextField(
                                          hintText: "Tên lớp",
                                          controller: _classNameCtrl,
                                        ),
                                      ],
                                    ),
                                  if (selectedND == NguoiDung.sinhvien)
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: screenWidth * 0.07,
                                          child: const Text(
                                            "Ngành:",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        CustomTextField(
                                          hintText: "Ngành",
                                          controller: _majorCtrl,
                                        ),
                                      ],
                                    ),
                                  if (selectedND == NguoiDung.sinhvien)
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: screenWidth * 0.07,
                                          child: const Text(
                                            "Khóa:",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        CustomTextField(
                                          hintText: "Khóa",
                                          controller: _courseCtrl,
                                        ),
                                      ],
                                    ),
                                  CustomButton(
                                    text: 'Tạo',
                                    width: Get.width * 0.1,
                                    onTap: () async {
                                      if (_signUpFormKey.currentState!
                                          .validate()) {
                                        DocumentSnapshot<Map<String, dynamic>>
                                            isExistUser = await GV.usersCol
                                                .doc(_userIdCtrl.text
                                                    .toLowerCase())
                                                .get();
                                        if (isExistUser.data() == null) {
                                          String str = "";
                                          if (selectedND == NguoiDung.giaovu ||
                                              selectedND == NguoiDung.covan ||
                                              selectedND == NguoiDung.cbhd) {
                                            str =
                                                "${_userIdCtrl.text.toLowerCase()}@cict.ctu.vn";
                                          } else if (selectedND ==
                                              NguoiDung.sinhvien) {
                                            str =
                                                "${_userIdCtrl.text.toLowerCase()}@student.cict.ctu.vn";
                                          }
                                          FirebaseApp secondaryApp =
                                              await Firebase.initializeApp(
                                                  name: 'secondaryApp',
                                                  options:
                                                      Firebase.app().options);
                                          final UserCredential newUser =
                                              await FirebaseAuth.instanceFor(
                                                      app: secondaryApp)
                                                  .createUserWithEmailAndPassword(
                                            email: str,
                                            password: _pwdCtrl.text,
                                          );
                                          await secondaryApp.delete();
                                          UserModel userModel;
                                          if (selectedND ==
                                              NguoiDung.sinhvien) {
                                            userModel = UserModel(
                                              uid: newUser.user!.uid,
                                              userId: _userIdCtrl.text
                                                  .toLowerCase(),
                                              name: _nameCtrl.text,
                                              password: _pwdCtrl.text.isEmpty
                                                  ? "Abc@123456"
                                                  : _pwdCtrl.text,
                                              classId: _classIdCtrl.text,
                                              className: _classNameCtrl.text,
                                              course: _courseCtrl.text,
                                              major: _majorCtrl.text,
                                              group: selectedND,
                                            );
                                          } else {
                                            userModel = UserModel(
                                              uid: newUser.user!.uid,
                                              userId: _userIdCtrl.text
                                                  .toLowerCase(),
                                              name: _nameCtrl.text,
                                              password: _pwdCtrl.text.isEmpty
                                                  ? "Abc@123456"
                                                  : _pwdCtrl.text,
                                              group: selectedND,
                                            );
                                          }
                                          final docUser =
                                              GV.usersCol.doc(userModel.userId);
                                          final json = userModel.toMap();
                                          await docUser.set(json);
                                          if (selectedND ==
                                              NguoiDung.sinhvien) {
                                            currentUser.setCurrentUser(
                                                setUid: userModel.uid,
                                                setUserId: userModel.userId,
                                                setName: userModel.name,
                                                setClassId: userModel.classId,
                                                setCourse: userModel.course,
                                                setGroup: userModel.group!,
                                                setMajor: userModel.major,
                                                setEmail: userModel.email,
                                                setPhone: userModel.phone,
                                                setClassName:
                                                    userModel.className);
                                          } else {
                                            currentUser.setCurrentUser(
                                              setUid: userModel.uid,
                                              setUserId: userModel.userId,
                                              setName: userModel.name,
                                              setGroup: userModel.group!,
                                              setEmail: userModel.email,
                                              setPhone: userModel.phone,
                                            );
                                          }
                                          currentUser.menuSelected.value = 1;
                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          prefs.setInt('menuSelected', 1);
                                          Navigator.pushNamed(
                                              context, pageQuanTri[1]);
                                          EasyLoading.showError(
                                              'Tạo thành công!');
                                        } else {
                                          EasyLoading.showError(
                                              'Tài khoản email đã tồn tại!!');
                                        }
                                      } else {
                                        EasyLoading.showError(
                                            'Điền đầy đủ thông tin!');
                                      }
                                    },
                                  ),
                                ],
                              ),
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
