import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tttt_project/views/login/form_sign_in.dart';
import 'package:tttt_project/widgets/announcement.dart';
import 'package:tttt_project/widgets/footer.dart';
import 'package:tttt_project/common/user_controller.dart';

class LogInScreen extends StatelessWidget {
  LogInScreen({Key? key}) : super(key: key);
  final GlobalKey<FormState> _signInFormKey = GlobalKey<FormState>();
  final TextEditingController _userIdCtrl = TextEditingController();
  final TextEditingController _pwdCtrl = TextEditingController();
  final currentUser = Get.put(UserController());
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
              height: screenHeight * 0.15,
              padding: EdgeInsets.only(
                left: screenWidth * 0.1,
                right: screenWidth * 0.1,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image(
                          image: AssetImage('assets/images/LOGO CICT-06.png')),
                      SizedBox(width: 5),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hệ thống quản lý thực tập thực tế",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                          Text(
                            "Trường Công nghệ Thông tin và Truyền thông",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: screenHeight * 0.03,
                bottom: screenHeight * 0.05,
                left: screenWidth * 0.13,
                right: screenWidth * 0.13,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Announcement(),
                  // SizedBox(width: screenWidth * 0.05),
                  Container(
                    width: screenWidth * 0.25,
                    constraints: BoxConstraints(minHeight: screenHeight * 0.2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border.all(style: BorderStyle.solid, width: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade600,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10.0),
                              topRight: Radius.circular(10.0),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'ĐĂNG NHẬP',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            children: [
                              FormSignIn(
                                signInFormKey: _signInFormKey,
                                userIdCtrl: _userIdCtrl,
                                passwordCtrl: _pwdCtrl,
                              ),
                              const SizedBox(height: 10),
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  'Quên mật khẩu?',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const Footer(isLogin: true),
          ],
        ),
      ),
    );
  }
}
