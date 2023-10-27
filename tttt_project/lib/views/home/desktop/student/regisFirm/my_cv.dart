// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/data/constant.dart';
import 'package:tttt_project/models/cv_model.dart';
import 'package:tttt_project/widgets/custom_button.dart';
import 'package:tttt_project/widgets/line_detail.dart';
import 'package:tttt_project/widgets/loading.dart';
import 'package:tttt_project/widgets/user_controller.dart';

class MyCV extends StatefulWidget {
  const MyCV({
    super.key,
  });

  @override
  State<MyCV> createState() => _MyCVState();
}

class _MyCVState extends State<MyCV> {
  final TextEditingController skillCtrl = TextEditingController();
  final TextEditingController achieveCtrl = TextEditingController();
  final TextEditingController hobbyCtrl = TextEditingController();
  final TextEditingController wishCtrl = TextEditingController();
  final currentUser = Get.put(UserController());
  String? userId;
  CVModel loadCV = CVModel();
  @override
  void initState() {
    getJobPosition();
    super.initState();
  }

  getJobPosition() async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    userId = sharedPref
        .getString(
          'userId',
        )
        .toString();
    DocumentSnapshot<Map<String, dynamic>> isExistCV =
        await FirebaseFirestore.instance.collection('cvs').doc(userId).get();
    if (isExistCV.data() != null) {
      loadCV = CVModel.fromMap(isExistCV.data()!);
      skillCtrl.text = loadCV.skill ?? '';
      achieveCtrl.text = loadCV.achieve ?? '';
      hobbyCtrl.text = loadCV.hobby ?? '';
      wishCtrl.text = loadCV.wish ?? '';
    }
  }

  @override
  void dispose() {
    skillCtrl.dispose();
    hobbyCtrl.dispose();
    achieveCtrl.dispose();
    wishCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return StreamBuilder(
        stream: GV.cvsCol.doc(userId).snapshots(),
        builder: (context, snapshotCV) {
          if (snapshotCV.hasData &&
              snapshotCV.data != null &&
              snapshotCV.connectionState == ConnectionState.active) {
            return Obx(
              () => Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 50),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        LineDetail(
                            field: "Họ tên", display: currentUser.name.value),
                        LineDetail(
                            field: "Mã số",
                            display: currentUser.userId.value.toUpperCase()),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        LineDetail(
                            field: "Lớp", display: currentUser.className.value),
                        LineDetail(
                            field: "Khóa", display: currentUser.course.value),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        LineDetail(field: "Kỹ năng", ctrl: skillCtrl),
                        LineDetail(field: "Thành tích", ctrl: achieveCtrl),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        LineDetail(field: "Sở thích", ctrl: hobbyCtrl),
                        LineDetail(field: "Nguyện vọng", ctrl: wishCtrl),
                      ],
                    ),
                    const SizedBox(height: 55),
                    CustomButton(
                      text: "Lưu",
                      width: screenWidth * 0.1,
                      height: screenHeight * 0.07,
                      onTap: () async {
                        DocumentSnapshot<Map<String, dynamic>> isExistCV =
                            await GV.cvsCol.doc(userId).get();
                        if (isExistCV.data() != null &&
                            (skillCtrl.text != '' ||
                                achieveCtrl.text != '' ||
                                hobbyCtrl.text != '' ||
                                wishCtrl.text != '')) {
                          final myCV = CVModel(
                              uid: currentUser.userId.value,
                              skill: skillCtrl.text,
                              achieve: achieveCtrl.text,
                              hobby: hobbyCtrl.text,
                              wish: wishCtrl.text);
                          final json = myCV.toMap();
                          GV.cvsCol.doc(myCV.uid).update(json);
                          // EasyLoading.showSuccess();
                          GV.success(
                              context: context,
                              message: 'Thông tin đã được cập nhật.');
                        } else if (skillCtrl.text != '' ||
                            achieveCtrl.text != '' ||
                            hobbyCtrl.text != '' ||
                            wishCtrl.text != '') {
                          final myCV = CVModel(
                              uid: currentUser.userId.value,
                              skill: skillCtrl.text,
                              achieve: achieveCtrl.text,
                              hobby: hobbyCtrl.text,
                              wish: wishCtrl.text);
                          final json = myCV.toMap();
                          GV.cvsCol.doc(myCV.uid).set(json);
                          GV.success(
                              context: context,
                              message: 'Đã thêm các thông tin.');
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Padding(
              padding: EdgeInsets.only(top: 150),
              child: Loading(),
            );
          }
        });
  }
}
