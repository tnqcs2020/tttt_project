// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/data/constant.dart';
import 'package:tttt_project/routes.dart';
import 'package:tttt_project/widgets/user_controller.dart';

class Header extends StatelessWidget {
  const Header({super.key, this.userName});
  final String? userName;
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    final currentUser = Get.put(UserController());
    return Container(
      color: Colors.blue.shade600,
      height: screenHeight * 0.12,
      padding: EdgeInsets.only(
        left: screenWidth * 0.08,
        right: screenWidth * 0.08,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hệ thống quản lý thực tập thực tế",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              Text(
                "Trường Công nghệ Thông tin và Truyền thông",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 100),
            padding: const EdgeInsets.only(top: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    ElevatedButton(
                        onPressed: () async {
                          final SharedPreferences sharedPref =
                              await SharedPreferences.getInstance();
                          await sharedPref.remove('userId');
                          await sharedPref.setBool("isLoggedIn", false);
                          await sharedPref.remove('menuSelected');
                          await GV.auth.signOut();
                          Navigator.pushNamedAndRemoveUntil(
                              context, RouteGenerator.login, (route) => false);
                          // Get.toNamed(RouteGenerator.login);
                        },
                        child: const Text("Thoát"))
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Text(
                      "Xin chào, ",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    if (userName != null)
                      Text(
                        userName!,
                        style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      )
                    else
                      Obx(
                        () => Text(
                          currentUser.name.value,
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
