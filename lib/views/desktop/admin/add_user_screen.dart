// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tiengviet/tiengviet.dart';
import 'package:tttt_project/data/constant.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/widgets/custom_button.dart';
import 'package:tttt_project/widgets/custom_textfield.dart';
import 'package:tttt_project/widgets/dropdown_style.dart';
import 'package:tttt_project/widgets/header.dart';
import 'package:tttt_project/widgets/loading.dart';
import 'package:tttt_project/widgets/user_controller.dart';
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
  final GlobalKey<FormState> addUserFormKey = GlobalKey<FormState>();
  final TextEditingController _userNameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _userIdCtrl = TextEditingController();
  final TextEditingController _classIdCtrl = TextEditingController();
  final TextEditingController _classNameCtrl = TextEditingController();
  final TextEditingController _pwdCtrl =
      TextEditingController(text: "Abc@123456");
  final TextEditingController _courseCtrl = TextEditingController();
  final TextEditingController _majorCtrl = TextEditingController();
  final TextEditingController _cvIdCtrl = TextEditingController();
  final TextEditingController _cvChucVuCtrl = TextEditingController();
  final TextEditingController _cvNameCtrl = TextEditingController();
  ValueNotifier idEmail = ValueNotifier("");
  ValueNotifier nameEmail = ValueNotifier("");
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
    _userNameCtrl.dispose();
    _emailCtrl.dispose();
    _userIdCtrl.dispose();
    _classIdCtrl.dispose();
    _classNameCtrl.dispose();
    _pwdCtrl.dispose();
    _courseCtrl.dispose();
    _majorCtrl.dispose();
    _cvIdCtrl.dispose();
    _cvChucVuCtrl.dispose();
    _cvNameCtrl.dispose();
    idEmail.dispose();
    nameEmail.dispose();
    super.dispose();
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

  getNameEmail(String name) {
    final normalName = TiengViet.parse(name).toLowerCase();
    List<String> words = normalName.split(" ");
    String lastWord = words[words.length - 1];
    return lastWord;
  }

  getEmail(String name) {
    final normalName = TiengViet.parse(name).toLowerCase();
    List<String> words = normalName.split(" ");
    String lastWord = words[words.length - 1];
    String temp = "";
    for (int i = 0; i < words.length - 1; i++) {
      temp += words[i].substring(0, 1);
    }
    return temp + lastWord;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.cyan.shade50,
        body: currentUser.userName.value != ''
            ? SingleChildScrollView(
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
                              constraints: BoxConstraints(
                                  minHeight: screenHeight * 0.74),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 50),
                                    child: Form(
                                      key: addUserFormKey,
                                      child: ValueListenableBuilder(
                                          valueListenable: nameEmail,
                                          builder:
                                              (context, nameEmailVal, child) {
                                            return ValueListenableBuilder(
                                                valueListenable: idEmail,
                                                builder: (context, idEmailVal,
                                                    child) {
                                                  return Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          SizedBox(
                                                            width: screenWidth *
                                                                0.1,
                                                            child: const Text(
                                                              "Nhóm người dùng:",
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              // overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 30),
                                                            child:
                                                                DropdownButtonHideUnderline(
                                                              child:
                                                                  DropdownButton2<
                                                                      String>(
                                                                isExpanded:
                                                                    true,
                                                                hint: Center(
                                                                  child: Text(
                                                                    'Chọn',
                                                                    style: DropdownStyle
                                                                        .hintStyle,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                                items: dsnd
                                                                    .map((String
                                                                            nd) =>
                                                                        DropdownMenuItem<
                                                                            String>(
                                                                          value:
                                                                              nd,
                                                                          child:
                                                                              Text(
                                                                            nd,
                                                                            style:
                                                                                DropdownStyle.itemStyle,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ))
                                                                    .toList(),
                                                                value:
                                                                    selectedND,
                                                                onChanged:
                                                                    (value) {
                                                                  setState(() {
                                                                    selectedND =
                                                                        value;
                                                                    _userNameCtrl
                                                                        .text = "";
                                                                    _emailCtrl
                                                                        .text = "";
                                                                    _userIdCtrl
                                                                        .text = "";
                                                                    _classIdCtrl
                                                                        .text = "";
                                                                    _classNameCtrl
                                                                        .text = "";
                                                                    _pwdCtrl.text =
                                                                        "Abc@123456";
                                                                    _courseCtrl
                                                                        .text = "";
                                                                    _majorCtrl
                                                                        .text = "";
                                                                    _cvIdCtrl
                                                                        .text = "";
                                                                    _cvChucVuCtrl
                                                                        .text = "";
                                                                    _cvNameCtrl
                                                                        .text = "";
                                                                    idEmail.value =
                                                                        "";
                                                                    nameEmail
                                                                        .value = "";
                                                                  });
                                                                },
                                                                buttonStyleData:
                                                                    DropdownStyle
                                                                        .buttonStyleLong,
                                                                iconStyleData:
                                                                    DropdownStyle
                                                                        .iconStyleData,
                                                                dropdownStyleData:
                                                                    DropdownStyle
                                                                        .dropdownStyleLong,
                                                                menuItemStyleData:
                                                                    DropdownStyle
                                                                        .menuItemStyleData,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                          height: 15),
                                                      if (selectedND == null)
                                                        const Row(
                                                          children: [
                                                            Text(
                                                                'Vui lòng chọn nhóm người dung để tiếp tục'),
                                                          ],
                                                        ),
                                                      if (selectedND ==
                                                          NguoiDung
                                                              .sinhvien) ...[
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                      screenWidth *
                                                                          0.07,
                                                                  child:
                                                                      const Text(
                                                                    "Tài khoản:",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                                CustomTextField(
                                                                  hintText:
                                                                      "Mã số",
                                                                  controller:
                                                                      _userIdCtrl,
                                                                  validator: (p0) =>
                                                                      p0!.isEmpty
                                                                          ? 'Không được để trống'
                                                                          : null,
                                                                  onChanged: (val) =>
                                                                      idEmail.value =
                                                                          val,
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                      screenWidth *
                                                                          0.07,
                                                                  child:
                                                                      const Text(
                                                                    "Mật khẩu:",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                                CustomTextField(
                                                                  hintText:
                                                                      "Mật khẩu",
                                                                  controller:
                                                                      _pwdCtrl,
                                                                  validator: (p0) =>
                                                                      p0!.isEmpty
                                                                          ? 'Không được để trống'
                                                                          : null,
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                      screenWidth *
                                                                          0.07,
                                                                  child:
                                                                      const Text(
                                                                    "Họ tên:",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                                CustomTextField(
                                                                  hintText:
                                                                      "Họ tên",
                                                                  controller:
                                                                      _userNameCtrl,
                                                                  validator: (p0) =>
                                                                      p0!.isEmpty
                                                                          ? 'Không được để trống'
                                                                          : null,
                                                                  onChanged: (val) => nameEmail
                                                                          .value =
                                                                      getNameEmail(
                                                                          val!),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                      screenWidth *
                                                                          0.07,
                                                                  child:
                                                                      const Text(
                                                                    "Email:",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                                CustomTextField(
                                                                  isEmail: true,
                                                                  hintText:
                                                                      '${nameEmail.value}${idEmail.value}@student.ctu.edu.vn',
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                      screenWidth *
                                                                          0.07,
                                                                  child:
                                                                      const Text(
                                                                    "Mã lớp:",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                                CustomTextField(
                                                                  hintText:
                                                                      "Mã lớp",
                                                                  controller:
                                                                      _classIdCtrl,
                                                                  validator: (p0) =>
                                                                      p0!.isEmpty
                                                                          ? 'Không được để trống'
                                                                          : null,
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                      screenWidth *
                                                                          0.07,
                                                                  child:
                                                                      const Text(
                                                                    "Tên lớp:",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                                CustomTextField(
                                                                  hintText:
                                                                      "Tên lớp",
                                                                  controller:
                                                                      _classNameCtrl,
                                                                  validator: (p0) =>
                                                                      p0!.isEmpty
                                                                          ? 'Không được để trống'
                                                                          : null,
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                      screenWidth *
                                                                          0.07,
                                                                  child:
                                                                      const Text(
                                                                    "Ngành:",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                                CustomTextField(
                                                                  hintText:
                                                                      "Ngành",
                                                                  controller:
                                                                      _majorCtrl,
                                                                  validator: (p0) =>
                                                                      p0!.isEmpty
                                                                          ? 'Không được để trống'
                                                                          : null,
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                      screenWidth *
                                                                          0.07,
                                                                  child:
                                                                      const Text(
                                                                    "Khóa:",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                                CustomTextField(
                                                                  hintText:
                                                                      "Khóa",
                                                                  controller:
                                                                      _courseCtrl,
                                                                  validator: (p0) =>
                                                                      p0!.isEmpty
                                                                          ? 'Không được để trống'
                                                                          : null,
                                                                  inputFormatters: [
                                                                    FilteringTextInputFormatter
                                                                        .digitsOnly
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                      screenWidth *
                                                                          0.07,
                                                                  child:
                                                                      const Text(
                                                                    "Mã cố vấn:",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                                CustomTextField(
                                                                  hintText:
                                                                      "Mã số cố vấn học tập",
                                                                  controller:
                                                                      _cvIdCtrl,
                                                                  validator: (p0) =>
                                                                      p0!.isEmpty
                                                                          ? 'Không được để trống'
                                                                          : null,
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                      screenWidth *
                                                                          0.07,
                                                                  child:
                                                                      const Text(
                                                                    "Họ tên cố vấn:",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                                CustomTextField(
                                                                  hintText:
                                                                      "Họ tên cố vấn",
                                                                  controller:
                                                                      _cvNameCtrl,
                                                                  validator: (p0) =>
                                                                      p0!.isEmpty
                                                                          ? 'Không được để trống'
                                                                          : null,
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                      if (selectedND ==
                                                          NguoiDung.covan) ...[
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                      screenWidth *
                                                                          0.07,
                                                                  child:
                                                                      const Text(
                                                                    "Tài khoản:",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                                CustomTextField(
                                                                  hintText:
                                                                      "Mã số",
                                                                  controller:
                                                                      _userIdCtrl,
                                                                  validator: (p0) =>
                                                                      p0!.isEmpty
                                                                          ? 'Không được để trống'
                                                                          : null,
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                      screenWidth *
                                                                          0.07,
                                                                  child:
                                                                      const Text(
                                                                    "Mật khẩu:",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                                CustomTextField(
                                                                  hintText:
                                                                      "Mật khẩu",
                                                                  controller:
                                                                      _pwdCtrl,
                                                                  validator: (p0) =>
                                                                      p0!.isEmpty
                                                                          ? 'Không được để trống'
                                                                          : null,
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                      screenWidth *
                                                                          0.07,
                                                                  child:
                                                                      const Text(
                                                                    "Họ tên:",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                                CustomTextField(
                                                                  hintText:
                                                                      "Họ tên",
                                                                  controller:
                                                                      _userNameCtrl,
                                                                  validator: (p0) =>
                                                                      p0!.isEmpty
                                                                          ? 'Không được để trống'
                                                                          : null,
                                                                  onChanged:
                                                                      (val) {
                                                                    nameEmail
                                                                            .value =
                                                                        getEmail(
                                                                            val!);
                                                                    _emailCtrl
                                                                        .text = getEmail(
                                                                            val) +
                                                                        '@ctu.edu.vn';
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                      screenWidth *
                                                                          0.07,
                                                                  child:
                                                                      const Text(
                                                                    "Email:",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                                CustomTextField(
                                                                  hintText:
                                                                      '${nameEmail.value}@ctu.edu.vn',
                                                                  controller:
                                                                      _emailCtrl,
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                      screenWidth *
                                                                          0.07,
                                                                  child:
                                                                      const Text(
                                                                    "Mã lớp cố vấn:",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                                CustomTextField(
                                                                  hintText:
                                                                      "Mã lớp",
                                                                  controller:
                                                                      _classIdCtrl,
                                                                  validator: (p0) =>
                                                                      p0!.isEmpty
                                                                          ? 'Không được để trống'
                                                                          : null,
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                      screenWidth *
                                                                          0.07,
                                                                  child:
                                                                      const Text(
                                                                    "Tên lớp cố vấn:",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                                CustomTextField(
                                                                  hintText:
                                                                      "Tên lớp",
                                                                  controller:
                                                                      _classNameCtrl,
                                                                  validator: (p0) =>
                                                                      p0!.isEmpty
                                                                          ? 'Không được để trống'
                                                                          : null,
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                      if (selectedND ==
                                                              NguoiDung.cbhd ||
                                                          selectedND ==
                                                              NguoiDung
                                                                  .giaovu) ...[
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                      screenWidth *
                                                                          0.07,
                                                                  child:
                                                                      const Text(
                                                                    "Tài khoản:",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                                CustomTextField(
                                                                  hintText:
                                                                      "Mã số",
                                                                  controller:
                                                                      _userIdCtrl,
                                                                  validator: (p0) =>
                                                                      p0!.isEmpty
                                                                          ? 'Không được để trống'
                                                                          : null,
                                                                  onChanged: (p0) =>
                                                                      idEmail.value =
                                                                          p0,
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                      screenWidth *
                                                                          0.07,
                                                                  child:
                                                                      const Text(
                                                                    "Mật khẩu:",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                                CustomTextField(
                                                                  hintText:
                                                                      "Mật khẩu",
                                                                  controller:
                                                                      _pwdCtrl,
                                                                  validator: (p0) =>
                                                                      p0!.isEmpty
                                                                          ? 'Không được để trống'
                                                                          : null,
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                      screenWidth *
                                                                          0.07,
                                                                  child:
                                                                      const Text(
                                                                    "Họ tên:",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                                CustomTextField(
                                                                  hintText:
                                                                      "Họ tên",
                                                                  controller:
                                                                      _userNameCtrl,
                                                                  validator: (p0) =>
                                                                      p0!.isEmpty
                                                                          ? 'Không được để trống'
                                                                          : null,
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                      screenWidth *
                                                                          0.07,
                                                                  child:
                                                                      const Text(
                                                                    "Email:",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                                CustomTextField(
                                                                  controller:
                                                                      _emailCtrl,
                                                                  hintText:
                                                                      'Email cá nhân',
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                      const SizedBox(
                                                          height: 35),
                                                      if (selectedND != null)
                                                        CustomButton(
                                                          text: 'Tạo',
                                                          width:
                                                              Get.width * 0.1,
                                                          onTap: () async {
                                                            if (addUserFormKey
                                                                .currentState!
                                                                .validate()) {
                                                              DocumentSnapshot<
                                                                      Map<String,
                                                                          dynamic>>
                                                                  isExistUser =
                                                                  await GV
                                                                      .usersCol
                                                                      .doc(_userIdCtrl
                                                                          .text
                                                                          .toLowerCase())
                                                                      .get();
                                                              if (selectedND !=
                                                                  null) {
                                                                if (isExistUser
                                                                        .data() ==
                                                                    null) {
                                                                  String str =
                                                                      "";
                                                                  if (selectedND == NguoiDung.giaovu ||
                                                                      selectedND ==
                                                                          NguoiDung
                                                                              .covan ||
                                                                      selectedND ==
                                                                          NguoiDung
                                                                              .cbhd) {
                                                                    str =
                                                                        "${_userIdCtrl.text.toLowerCase()}@ctu.edu.vn";
                                                                  } else if (selectedND ==
                                                                      NguoiDung
                                                                          .sinhvien) {
                                                                    str =
                                                                        "${_userIdCtrl.text.toLowerCase()}@student.ctu.edu.vn";
                                                                  }
                                                                  FirebaseApp
                                                                      secondaryApp =
                                                                      await Firebase.initializeApp(
                                                                          name:
                                                                              'secondaryApp',
                                                                          options:
                                                                              Firebase.app().options);
                                                                  final UserCredential
                                                                      newUser =
                                                                      await FirebaseAuth
                                                                          .instance
                                                                          .createUserWithEmailAndPassword(
                                                                    email: str,
                                                                    password:
                                                                        _pwdCtrl
                                                                            .text,
                                                                  );
                                                                  await secondaryApp
                                                                      .delete();
                                                                  UserModel
                                                                      userModel;
                                                                  if (selectedND ==
                                                                      NguoiDung
                                                                          .sinhvien) {
                                                                    userModel =
                                                                        UserModel(
                                                                      uid: newUser
                                                                          .user!
                                                                          .uid,
                                                                      userId: _userIdCtrl
                                                                          .text
                                                                          .toLowerCase(),
                                                                      userName:
                                                                          _userNameCtrl
                                                                              .text,
                                                                      password: _pwdCtrl
                                                                              .text
                                                                              .isEmpty
                                                                          ? "Abc@123456"
                                                                          : _pwdCtrl
                                                                              .text,
                                                                      classId:
                                                                          _classIdCtrl
                                                                              .text,
                                                                      className:
                                                                          _classNameCtrl
                                                                              .text,
                                                                      course: _courseCtrl
                                                                          .text,
                                                                      major: _majorCtrl
                                                                          .text,
                                                                      group:
                                                                          selectedND,
                                                                      email:
                                                                          "${nameEmail.value.toLowerCase()}${idEmail.value.toLowerCase()}@student.ctu.edu.vn",
                                                                      cvId: _cvIdCtrl
                                                                          .text,
                                                                      cvName: _cvNameCtrl
                                                                          .text,
                                                                      cvClass: [],
                                                                    );
                                                                  } else if (selectedND ==
                                                                      NguoiDung
                                                                          .covan) {
                                                                    List<ClassModel>
                                                                        cvClass =
                                                                        [
                                                                      ClassModel(
                                                                        classId:
                                                                            _classIdCtrl.text,
                                                                        className:
                                                                            _classNameCtrl.text,
                                                                        cvId: _userIdCtrl
                                                                            .text,
                                                                      )
                                                                    ];
                                                                    userModel =
                                                                        UserModel(
                                                                      uid: newUser
                                                                          .user!
                                                                          .uid,
                                                                      userId: _userIdCtrl
                                                                          .text
                                                                          .toLowerCase(),
                                                                      userName:
                                                                          _userNameCtrl
                                                                              .text,
                                                                      password: _pwdCtrl
                                                                              .text
                                                                              .isEmpty
                                                                          ? "Abc@123456"
                                                                          : _pwdCtrl
                                                                              .text,
                                                                      email:
                                                                          "${nameEmail.value}@ctu.edu.vn",
                                                                      group:
                                                                          selectedND,
                                                                      cvClass:
                                                                          cvClass,
                                                                    );
                                                                  } else {
                                                                    userModel =
                                                                        UserModel(
                                                                      uid: newUser
                                                                          .user!
                                                                          .uid,
                                                                      userId: _userIdCtrl
                                                                          .text
                                                                          .toLowerCase(),
                                                                      userName:
                                                                          _userNameCtrl
                                                                              .text,
                                                                      password: _pwdCtrl
                                                                              .text
                                                                              .isEmpty
                                                                          ? "Abc@123456"
                                                                          : _pwdCtrl
                                                                              .text,
                                                                      group:
                                                                          selectedND,
                                                                      cvClass: [],
                                                                      email: selectedND ==
                                                                              NguoiDung.giaovu
                                                                          ? "${nameEmail.value}@ctu.edu.vn"
                                                                          : _emailCtrl.text,
                                                                    );
                                                                  }
                                                                  final docUser = GV
                                                                      .usersCol
                                                                      .doc(userModel
                                                                          .userId);
                                                                  final json =
                                                                      userModel
                                                                          .toMap();
                                                                  await docUser
                                                                      .set(
                                                                          json);
                                                                  setState(() {
                                                                    selectedND =
                                                                        null;
                                                                    _userNameCtrl
                                                                        .text = "";
                                                                    _emailCtrl
                                                                        .text = "";
                                                                    _userIdCtrl
                                                                        .text = "";
                                                                    _classIdCtrl
                                                                        .text = "";
                                                                    _classNameCtrl
                                                                        .text = "";
                                                                    _pwdCtrl.text =
                                                                        "Abc@123456";
                                                                    _courseCtrl
                                                                        .text = "";
                                                                    _majorCtrl
                                                                        .text = "";
                                                                    _cvIdCtrl
                                                                        .text = "";
                                                                    _cvChucVuCtrl
                                                                        .text = "";
                                                                    _cvNameCtrl
                                                                        .text = "";
                                                                    idEmail.value =
                                                                        "";
                                                                    nameEmail
                                                                        .value = "";
                                                                  });
                                                                  GV.success(
                                                                      context:
                                                                          context,
                                                                      message:
                                                                          'Tạo thành công!');
                                                                } else {
                                                                  GV.error(
                                                                      context:
                                                                          context,
                                                                      message:
                                                                          'Tài khoản đã tồn tại!');
                                                                }
                                                              } else {
                                                                GV.error(
                                                                    context:
                                                                        context,
                                                                    message:
                                                                        'Chọn nhóm người dùng');
                                                              }
                                                            } else {
                                                              GV.error(
                                                                  context:
                                                                      context,
                                                                  message:
                                                                      'Điền đầy đủ thông tin!');
                                                            }
                                                          },
                                                        ),
                                                      const SizedBox(height: 25)
                                                    ],
                                                  );
                                                });
                                          }),
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
              )
            : const Padding(
                padding: EdgeInsets.only(top: 25),
                child: Column(
                  children: [
                    Loading(),
                  ],
                ),
              ),
      ),
    );
  }
}
