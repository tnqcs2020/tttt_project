import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:tttt_project/data/constant.dart';
import 'package:tttt_project/widgets/custom_button.dart';
import 'package:tttt_project/widgets/line_detail.dart';
import 'package:tttt_project/widgets/user_controller.dart';

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
    nameCBCtrl.text = currentUser.name.value;
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
                    field: "Mã cbhd",
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
                  if (nameCBCtrl.text != currentUser.name.value ||
                      phoneCBCtrl.text != currentUser.phone.value ||
                      emailCBCtrl.text != currentUser.email.value) {
                    GV.usersCol.doc(currentUser.userId.value).update({
                      'name': nameCBCtrl.text,
                      'phone': phoneCBCtrl.text,
                      'email': emailCBCtrl.text
                    });
                    currentUser.setCurrentUser(
                      setName: nameCBCtrl.text,
                      setEmail: emailCBCtrl.text,
                      setPhone: phoneCBCtrl.text,
                    );
                    EasyLoading.showSuccess('Thay đổi thành công!');
                  } else if (nameCBCtrl.text == currentUser.name.value &&
                      phoneCBCtrl.text == currentUser.phone.value &&
                      emailCBCtrl.text == currentUser.email.value) {
                    EasyLoading.showError('Không có gì thay đổi!');
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
