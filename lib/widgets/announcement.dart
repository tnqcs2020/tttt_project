import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tttt_project/data/constant.dart';
import 'package:tttt_project/models/announcement_model.dart';
import 'package:tttt_project/models/plan_trainee_model.dart';
import 'package:tttt_project/widgets/loading.dart';
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
  final firestore = FirebaseFirestore.instance;
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Column(
              children: [
                StreamBuilder(
                  stream: firestore.collection('announcements').snapshots(),
                  builder: (context, snapshot) {
                    final List<AnnouncementModel> listAnnouncement = [];
                    if (snapshot.hasData &&
                        snapshot.connectionState == ConnectionState.active) {
                      snapshot.data?.docs.forEach((element) {
                        listAnnouncement
                            .add(AnnouncementModel.fromMap(element.data()));
                      });
                      return listAnnouncement.isNotEmpty
                          ? ListView.builder(
                              itemCount: listAnnouncement.length,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {},
                                  child: Container(
                                    height: screenHeight * 0.035,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: Text(
                                            listAnnouncement[index].title!,
                                            textAlign: TextAlign.justify,
                                            style: TextStyle(
                                              color: Colors.blue.shade900,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            GV.readTimestamp(
                                                listAnnouncement[index]
                                                    .createdAt!),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.blue.shade900,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          : const SizedBox.shrink();
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
                StreamBuilder(
                  stream: firestore.collection('planTrainees').snapshots(),
                  builder: (context, snapshot) {
                    final List<PlanTraineeModel> listPlanTrainee = [];
                    if (snapshot.hasData &&
                        snapshot.connectionState == ConnectionState.active) {
                      snapshot.data?.docs.forEach((element) {
                        listPlanTrainee
                            .add(PlanTraineeModel.fromMap(element.data()));
                      });
                      return listPlanTrainee.isNotEmpty
                          ? ListView.builder(
                              itemCount: listPlanTrainee.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {},
                                  child: Container(
                                    height: screenHeight * 0.035,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 5,
                                          child: Text(
                                            listPlanTrainee[index].title!,
                                            textAlign: TextAlign.justify,
                                            style: TextStyle(
                                              color: Colors.blue.shade900,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            GV.readTimestamp(
                                                listPlanTrainee[index]
                                                    .createdAt!),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.blue.shade900,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          : const SizedBox.shrink();
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  openInANewTab(url) {
    html.window.open(url, 'PlaceholderName');
  }
}
