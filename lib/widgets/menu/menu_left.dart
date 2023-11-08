// ignore_for_file: use_build_context_synchronously, must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/data/constant.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/widgets/user_controller.dart';

class MenuLeft extends StatefulWidget {
  MenuLeft({
    super.key,
    this.user,
  });
  UserModel? user;

  @override
  State<MenuLeft> createState() => _MenuLeftState();
}

class _MenuLeftState extends State<MenuLeft> {
  final currentUser = Get.put(UserController());

  List<String> checkMenuTitle() {
    List<String> titles = [];
    final group =
        widget.user != null ? widget.user?.group : currentUser.group.value;
    if (group == NguoiDung.sinhvien) {
      titles = menuSinhVien;
    } else if (group == NguoiDung.quantri) {
      titles = menuQuanTri;
    } else if (group == NguoiDung.cbhd) {
      titles = menuCanBo;
    } else if (group == NguoiDung.covan) {
      titles = menuCoVan;
    } else if (group == NguoiDung.giaovu) {
      titles = menuGiaoVu;
    }
    return titles;
  }

  List<String> checkMenuPage() {
    List<String> pages = [];
    final group =
        widget.user != null ? widget.user?.group : currentUser.group.value;
    if (group == NguoiDung.sinhvien) {
      pages = pageSinhVien;
    } else if (group == NguoiDung.quantri) {
      pages = pageQuanTri;
    } else if (group == NguoiDung.cbhd) {
      pages = pageCanBo;
    } else if (group == NguoiDung.covan) {
      pages = pageCoVan;
    } else if (group == NguoiDung.giaovu) {
      pages = pageGiaoVu;
    }
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          border: Border.all(style: BorderStyle.solid, width: 0.1),
          borderRadius: BorderRadius.circular(5),
        ),
        constraints: BoxConstraints(
            minHeight: screenHeight * 0.35, maxHeight: screenHeight * 0.5),
        // height: screenHeight * 0.35,
        width: screenWidth * 0.16,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(left: 5),
              height: screenHeight * 0.05,
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5.0),
                  topRight: Radius.circular(5.0),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.menu,
                    color: Colors.white,
                  ),
                  SizedBox(width: 5),
                  Text(
                    "Menu",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListView.builder(
              itemCount: checkMenuTitle().length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    ListTile(
                      title: Text(checkMenuTitle()[index]),
                      onTap: () async {
                        currentUser.menuSelected.value = index;
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setInt('menuSelected', index);
                        Navigator.pushNamed(context, checkMenuPage()[index]);
                      },
                      selected: currentUser.menuSelected.value == index,
                    ),
                    if (index != checkMenuTitle().length - 1)
                      const Divider(
                        thickness: 0.5,
                        height: 1,
                      ),
                  ],
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
