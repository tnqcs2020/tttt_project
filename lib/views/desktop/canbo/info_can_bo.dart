import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/common/constant.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/widgets/custom_button.dart';
import 'package:tttt_project/widgets/line_detail.dart';
import 'package:tttt_project/common/user_controller.dart';

class InfoCB extends StatefulWidget {
  const InfoCB({
    super.key,
  });

  @override
  State<InfoCB> createState() => _InfoCBState();
}

class _InfoCBState extends State<InfoCB> {
  final currentUser = Get.put(UserController());
  final TextEditingController nameCBCtrl = TextEditingController();
  final TextEditingController phoneCBCtrl = TextEditingController();
  final TextEditingController emailCBCtrl = TextEditingController();

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

  @override
  void dispose() {
    nameCBCtrl.dispose();
    phoneCBCtrl.dispose();
    emailCBCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    nameCBCtrl.text = currentUser.userName.value;
    phoneCBCtrl.text = currentUser.phone.value;
    emailCBCtrl.text = currentUser.email.value;
    return Obx(
      () => Container(
        padding: const EdgeInsets.only(
          left: 100,
          top: 20,
          right: 100,
        ),
        width: screenWidth * 0.7,
        constraints: BoxConstraints(minHeight: screenHeight * 0.15),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 50, top: 15),
              child: Column(
                children: [
                  LineDetail(
                    field: "Họ tên",
                    ctrl: nameCBCtrl,
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 50, top: 15),
              child: Column(
                children: [
                  LineDetail(
                    field: "Mã cán bộ",
                    display: currentUser.userId.value.toUpperCase(),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 50, top: 15),
              child: Column(
                children: [
                  LineDetail(
                    field: "Điện thoại",
                    ctrl: phoneCBCtrl,
                    textFormat: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 50, top: 15),
              child: Column(
                children: [
                  LineDetail(
                    field: "Email",
                    ctrl: emailCBCtrl,
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: CustomButton(
                text: "Lưu",
                width: screenWidth * 0.1,
                height: screenHeight * 0.07,
                onTap: () async {
                  if (nameCBCtrl.text != currentUser.userName.value ||
                      phoneCBCtrl.text != currentUser.phone.value ||
                      emailCBCtrl.text != currentUser.email.value) {
                    GV.usersCol.doc(currentUser.userId.value).update({
                      'name': nameCBCtrl.text,
                      'phone': phoneCBCtrl.text,
                      'email': emailCBCtrl.text
                    });
                    currentUser.setCurrentUser(
                      setUserName: nameCBCtrl.text,
                      setEmail: emailCBCtrl.text,
                      setPhone: phoneCBCtrl.text,
                    );
                    GV.success(
                        context: context, message: 'Thay đổi thành công!');
                  } else if (nameCBCtrl.text == currentUser.userName.value &&
                      phoneCBCtrl.text == currentUser.phone.value &&
                      emailCBCtrl.text == currentUser.email.value) {
                    GV.error(
                        context: context, message: 'Không có gì thay đổi!');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
