import 'package:flutter/material.dart';
// import 'package:tttt_project/widgets/navigation_bar/custom_tab.dart';
// import 'package:tttt_project/widgets/navigation_bar/navbar_item.dart';

class NavBarDesktop extends StatelessWidget {
  const NavBarDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      color: Colors.teal.shade200,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hệ thống quản lý thực tập thực tế",
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  "Trường Công nghệ Thông tin và Truyền thông",
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 25, top: 30),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // CustomTab(title: 'Trang chủ'),
                // SizedBox(
                //   width: 10,
                // ),
                // CustomTab(title: 'Đăng ký thực tập'),
                // SizedBox(
                //   width: 10,
                // ),
                // CustomTab(title: 'Danh sách công ty'),
                // SizedBox(
                //   width: 10,
                // ),
                // CustomTab(title: 'Đăng nhập'),
                // NavBarItem(title: 'Trang chủ', fontSize: 16),
                // SizedBox(
                //   width: 10,
                // ),
                // NavBarItem(title: 'Đăng ký thực tập', fontSize: 16),
                // SizedBox(
                //   width: 10,
                // ),
                // NavBarItem(title: 'Danh sách công ty', fontSize: 16),
                // SizedBox(
                //   width: 10,
                // ),
                // NavBarItem(title: 'Đăng nhập', fontSize: 16),
              ],
            ),
          )
        ],
      ),
    );
  }
}
