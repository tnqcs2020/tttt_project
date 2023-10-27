// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/data/constant.dart';
import 'package:tttt_project/routes.dart';
import 'package:tttt_project/widgets/custom_button.dart';
import 'package:tttt_project/widgets/custom_textfield.dart';
import 'package:tttt_project/widgets/user_controller.dart';

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
            hintText: 'Tài khoản',
          ),
          CustomTextField(
            controller: _pwdCtrl,
            hintText: 'Mật khẩu',
            isPassword: true,
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
                        isExistUser.data()!['group'] == NguoiDung.covan ||
                        isExistUser.data()!['group'] == NguoiDung.cbhd) {
                      str = "${_userIdCtrl.text.toLowerCase()}@cict.ctu.vn";
                      await GV.auth.signInWithEmailAndPassword(
                        email: str,
                        password: _pwdCtrl.text,
                      );
                    } else if (isExistUser.data()!['group'] ==
                        NguoiDung.sinhvien) {
                      str =
                          "${_userIdCtrl.text.toLowerCase()}@student.cict.ctu.vn";
                      await GV.auth.signInWithEmailAndPassword(
                        email: str,
                        password: _pwdCtrl.text,
                      );
                    } else {
                      EasyLoading.showError('Tài khoản không tồn tại!');
                    }
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString(
                      'userId',
                      _userIdCtrl.text,
                    );
                    prefs.setInt('menuSelected', 0);
                    prefs.setBool("isLoggedIn", true);
                    currentUser.setCurrentUser(
                      setUid: isExistUser.data()!['uid'],
                      setUserId: isExistUser.data()!['userId'],
                      setName: isExistUser.data()!['name'],
                      setClassName: isExistUser.data()!['className'],
                      setCourse: isExistUser.data()!['course'],
                      setGroup: isExistUser.data()!['group'],
                      setMajor: isExistUser.data()!['major'],
                      setEmail: isExistUser.data()!['email'],
                      setIsRegistered: isExistUser.data()!['isRegistered'],
                      setPhone: isExistUser.data()!['phone'],
                      setMenuSelected: 0,
                    );
                    Navigator.pushNamed(context, RouteGenerator.home);
                  } else {
                    EasyLoading.showError('Mật khẩu không đúng!');
                  }
                } else {
                  EasyLoading.showError('Tài khoản không tồn tại!');
                }
              } else {
                EasyLoading.showError('Vui lòng điền thông tin đăng nhập!');
              }
            },
          ),
        ],
      ),
    );
  }
}
