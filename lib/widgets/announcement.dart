import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tttt_project/widgets/user_controller.dart';
import 'dart:html' as html;

class Announcement extends StatefulWidget {
  const Announcement({
    super.key,
  });

  @override
  State<Announcement> createState() => _AnnouncementState();
}

class _AnnouncementState extends State<Announcement> {
  final currentUser = Get.put(UserController());
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(style: BorderStyle.solid, width: 0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      height: screenHeight * 0.35,
      width: screenWidth * 0.4,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 5),
            height: 30,
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5.0),
                topRight: Radius.circular(5.0),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Thông báo",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            itemCount: 5,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      html.window.open('/#/tin-tuc', "_blank");
                    },
                    child: Text("Tin Tức $index"),
                  ),
                  const Divider(
                    thickness: 0.5,
                    height: 1,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  openInANewTab(url) {
    html.window.open(url, 'PlaceholderName');
  }
}
