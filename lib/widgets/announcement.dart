import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tttt_project/common/constant.dart';
import 'package:tttt_project/models/announcement_model.dart';
import 'package:tttt_project/models/plan_trainee_model.dart';
import 'package:tttt_project/common/user_controller.dart';

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
  List<TBModel> thongbao = [];
  @override
  void initState() {
    getUserData();
    super.initState();
  }

  getUserData() async {
    List<TBModel> tb = [];
    QuerySnapshot<Map<String, dynamic>> announcements =
        await firestore.collection('announcements').get();
    if (announcements.docs.isNotEmpty) {
      for (int i = 0; i < announcements.docs.length; i++) {
        final anct = AnnouncementModel.fromMap(announcements.docs[i].data());
        tb.add(TBModel(title: anct.title, createdAt: anct.createdAt));
      }
    }
    QuerySnapshot<Map<String, dynamic>> planTrainees =
        await firestore.collection('planTrainees').get();
    if (planTrainees.docs.isNotEmpty) {
      for (int i = 0; i < planTrainees.docs.length; i++) {
        final pt = PlanTraineeModel.fromMap(planTrainees.docs[i].data());
        tb.add(TBModel(title: pt.title, createdAt: pt.createdAt));
      }
    }
    tb.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    setState(() {
      thongbao = tb;
    });
  }

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
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Column(
                  children: [
                    ListView.builder(
                      itemCount: thongbao.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {},
                          child: Container(
                            height: screenHeight * 0.04,
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        thongbao[index].title!,
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(
                                          color: Colors.blue.shade900,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.fiber_new_outlined,
                                        color: Colors.red,
                                        size: 25,
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    GV.readTimestamp(
                                        thongbao[index].createdAt!),
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
