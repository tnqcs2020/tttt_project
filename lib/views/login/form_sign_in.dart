// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/common/constant.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/routes.dart';
import 'package:tttt_project/widgets/custom_button.dart';
import 'package:tttt_project/widgets/custom_textfield.dart';
import 'package:tttt_project/common/user_controller.dart';

class FormSignIn extends StatelessWidget {
  FormSignIn({
    super.key,
    required GlobalKey<FormState> signInFormKey,
    required TextEditingController userIdCtrl,
    required TextEditingController passwordCtrl,
  })  : _signInFormKey = signInFormKey,
        _userIdCtrl = userIdCtrl,
        _pwdCtrl = passwordCtrl;

  final GlobalKey<FormState> _signInFormKey;
  final TextEditingController _userIdCtrl;
  final TextEditingController _pwdCtrl;
  final currentUser = Get.put(UserController());
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Form(
      key: _signInFormKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _userIdCtrl,
            label: 'Tài khoản',
            hintText: 'Mã số cá nhân',
            validator: (value) =>
                value == "" ? 'Vui lòng điền tài khoản' : null,
            onFieldSubmitted: (p0) async {
              if (_signInFormKey.currentState!.validate()) {
                DocumentSnapshot<Map<String, dynamic>> isExistUser =
                    await GV.usersCol.doc(_userIdCtrl.text.toLowerCase()).get();
                if (isExistUser.data() != null) {
                  if (isExistUser.data()!['password'] == _pwdCtrl.text) {
                    String str = "";
                    if (isExistUser.data()!['group'] == NguoiDung.quantri ||
                        isExistUser.data()!['group'] == NguoiDung.giaovu ||
                        isExistUser.data()!['group'] == NguoiDung.covan ||
                        isExistUser.data()!['group'] == NguoiDung.cbhd) {
                      str = "${_userIdCtrl.text.toLowerCase()}@ctu.edu.vn";
                      await GV.auth.signInWithEmailAndPassword(
                        email: str,
                        password: _pwdCtrl.text,
                      );
                    } else if (isExistUser.data()!['group'] ==
                        NguoiDung.sinhvien) {
                      str =
                          "${_userIdCtrl.text.toLowerCase()}@student.ctu.edu.vn";
                      await GV.auth.signInWithEmailAndPassword(
                        email: str,
                        password: _pwdCtrl.text,
                      );
                    } else {
                      GV.error(
                          context: context,
                          message: 'Tài khoản không tồn tại!');
                    }
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString(
                      'userId',
                      _userIdCtrl.text,
                    );
                    prefs.setInt('menuSelected', 0);
                    prefs.setBool("isLoggedIn", true);
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
                      setMenuSelected: 0,
                    );
                    Navigator.pushNamed(context, RouteGenerator.home);
                  } else {
                    GV.error(context: context, message: 'Mật khẩu không đúng!');
                  }
                } else {
                  GV.error(
                      context: context, message: 'Tài khoản không tồn tại!');
                }
              }
            },
          ),
          CustomTextField(
            controller: _pwdCtrl,
            label: 'Mật khẩu',
            hintText: 'Mật khẩu',
            isPassword: true,
            validator: (value) =>
                value == "" ? 'Vui lòng điền mật khẩu.' : null,
            onFieldSubmitted: (p0) async {
              if (_signInFormKey.currentState!.validate()) {
                DocumentSnapshot<Map<String, dynamic>> isExistUser =
                    await GV.usersCol.doc(_userIdCtrl.text.toLowerCase()).get();
                if (isExistUser.data() != null) {
                  if (isExistUser.data()!['password'] == _pwdCtrl.text) {
                    String str = "";
                    if (isExistUser.data()!['group'] == NguoiDung.quantri ||
                        isExistUser.data()!['group'] == NguoiDung.giaovu ||
                        isExistUser.data()!['group'] == NguoiDung.covan ||
                        isExistUser.data()!['group'] == NguoiDung.cbhd) {
                      str = "${_userIdCtrl.text.toLowerCase()}@ctu.edu.vn";
                      await GV.auth.signInWithEmailAndPassword(
                        email: str,
                        password: _pwdCtrl.text,
                      );
                    } else if (isExistUser.data()!['group'] ==
                        NguoiDung.sinhvien) {
                      str =
                          "${_userIdCtrl.text.toLowerCase()}@student.ctu.edu.vn";
                      await GV.auth.signInWithEmailAndPassword(
                        email: str,
                        password: _pwdCtrl.text,
                      );
                    } else {
                      GV.error(
                          context: context,
                          message: 'Tài khoản không tồn tại!');
                    }
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString(
                      'userId',
                      _userIdCtrl.text,
                    );
                    prefs.setInt('menuSelected', 0);
                    prefs.setBool("isLoggedIn", true);
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
                      setMenuSelected: 0,
                    );
                    Navigator.pushNamed(context, RouteGenerator.home);
                  } else {
                    GV.error(context: context, message: 'Mật khẩu không đúng!');
                  }
                } else {
                  GV.error(
                      context: context, message: 'Tài khoản không tồn tại!');
                }
              }
            },
          ),
          const SizedBox(height: 15),
          CustomButton(
            text: 'Đăng Nhập',
            width: screenWidth * 0.1,
            height: screenHeight * 0.07,
            borderRadius: 15,
            onTap: () async {
              if (_signInFormKey.currentState!.validate()) {
                DocumentSnapshot<Map<String, dynamic>> isExistUser =
                    await GV.usersCol.doc(_userIdCtrl.text.toLowerCase()).get();
                if (isExistUser.data() != null) {
                  if (isExistUser.data()!['password'] == _pwdCtrl.text) {
                    String str = "";
                    if (isExistUser.data()!['group'] == NguoiDung.quantri ||
                        isExistUser.data()!['group'] == NguoiDung.giaovu ||
                        isExistUser.data()!['group'] == NguoiDung.covan ) {
                      str = "${_userIdCtrl.text.toLowerCase()}@ctu.edu.vn";
                      await GV.auth.signInWithEmailAndPassword(
                        email: str,
                        password: _pwdCtrl.text,
                      );
                    } else if (isExistUser.data()!['group'] ==
                        NguoiDung.sinhvien) {
                      str =
                          "${_userIdCtrl.text.toLowerCase()}@student.ctu.edu.vn";
                      await GV.auth.signInWithEmailAndPassword(
                        email: str,
                        password: _pwdCtrl.text,
                      );
                    } else {
                      GV.error(
                          context: context,
                          message: 'Tài khoản không tồn tại!');
                    }
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString(
                      'userId',
                      _userIdCtrl.text,
                    );
                    prefs.setInt('menuSelected', 0);
                    prefs.setBool("isLoggedIn", true);
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
                      setMenuSelected: 0,
                    );
                    Navigator.pushNamed(context, RouteGenerator.home);
                  } else {
                    GV.error(context: context, message: 'Mật khẩu không đúng!');
                  }
                } else {
                  GV.error(
                      context: context, message: 'Tài khoản không tồn tại!');
                }
              } else {
                GV.error(
                    context: context,
                    message: 'Vui lòng điền thông tin đăng nhập!');
              }
            },
          ),
        ],
      ),
    );
  }
}
