// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tttt_project/models/firm_model.dart';
import 'package:tttt_project/models/register_trainee_model.dart';
import 'package:tttt_project/models/setting_trainee_model.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/widgets/custom_button.dart';
import 'package:tttt_project/widgets/footer.dart';
import 'package:tttt_project/widgets/header.dart';
import 'package:tttt_project/common/user_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/widgets/menu/menu_left.dart';

class ListFirmCommon extends StatefulWidget {
  const ListFirmCommon({Key? key}) : super(key: key);

  @override
  State<ListFirmCommon> createState() => _FirmLinkState();
}

class _FirmLinkState extends State<ListFirmCommon> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<FirmModel> firms = [];
  List<FirmModel> firmResult = [];
  final TextEditingController searchCtrl = TextEditingController();
  ValueNotifier isSearch = ValueNotifier(false);
  String? userId;
  final currentUser = Get.put(UserController());
  bool isRegistered = false;
  RegisterTraineeModel trainee = RegisterTraineeModel();
  SettingTraineeModel setting = SettingTraineeModel();
  @override
  void initState() {
    getUserData();
    super.initState();
  }

  getUserData() async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    userId = sharedPref
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
    isSearch.dispose();
    searchCtrl.dispose();
    super.dispose();
  }

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
            const Header(),
            Padding(
              padding: EdgeInsets.only(
                top: screenHeight * 0.02,
                bottom: screenHeight * 0.02,
                left: screenWidth * 0.08,
                right: screenWidth * 0.08,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MenuLeft(),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: Container(
                      constraints:
                          BoxConstraints(minHeight: screenHeight * 0.7),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          border: Border.all(
                            style: BorderStyle.solid,
                            width: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(5)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: screenHeight * 0.06,
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
                                  "Danh sách các công ty",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ValueListenableBuilder(
                            valueListenable: isSearch,
                            builder: (context, value1, child) {
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 40,
                                          width: 350,
                                          child: TextFormField(
                                            controller: searchCtrl,
                                            decoration: InputDecoration(
                                              isDense: false,
                                              contentPadding: EdgeInsets.zero,
                                              prefixIcon:
                                                  const Icon(Icons.search),
                                              suffixIcon: IconButton(
                                                icon: const Icon(Icons.clear),
                                                onPressed: () {
                                                  setState(() {
                                                    searchCtrl.clear();
                                                    isSearch.value = false;
                                                  });
                                                },
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(25),
                                              ),
                                              filled: true,
                                            ),
                                            onChanged: (value) {
                                              setState(() {
                                                isSearch.value = false;
                                              });
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 15),
                                        CustomButton(
                                          text: 'Tìm',
                                          height: 40,
                                          width: 100,
                                          onTap: () {
                                            if (searchCtrl.text.isNotEmpty) {
                                              isSearch.value = true;
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                          color: Colors.white),
                                      height: screenHeight * 0.45,
                                      width: screenWidth * 0.55,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            color: Colors.green,
                                            height: screenHeight * 0.04,
                                            child: const Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    'STT',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                Expanded(
                                                  flex: 6,
                                                  child: Text(
                                                    'Tên công ty',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    'Liên hệ',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                SizedBox(width: 5),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    'Thao tác',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          isSearch.value
                                              ? Expanded(
                                                  child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    child: StreamBuilder(
                                                        stream: firestore
                                                            .collection('firms')
                                                            .snapshots(),
                                                        builder: (context,
                                                            snapshotFirm) {
                                                          if (snapshotFirm
                                                              .hasData) {
                                                            firms = [];
                                                            for (var element
                                                                in snapshotFirm
                                                                    .data!
                                                                    .docs) {
                                                              firms.add(FirmModel
                                                                  .fromMap(element
                                                                      .data()));
                                                            }
                                                            firmResult = firms
                                                                .where((element) => element
                                                                    .firmName!
                                                                    .contains(
                                                                        searchCtrl
                                                                            .text))
                                                                .toList();

                                                            return firmResult
                                                                    .isNotEmpty
                                                                ? ListView
                                                                    .builder(
                                                                    itemCount:
                                                                        firmResult
                                                                            .length,
                                                                    shrinkWrap:
                                                                        true,
                                                                    itemBuilder:
                                                                        (context,
                                                                            indexFirm) {
                                                                      return Container(
                                                                        height: screenHeight *
                                                                            0.075,
                                                                        color: indexFirm % 2 ==
                                                                                0
                                                                            ? Colors.blue.shade50
                                                                            : null,
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            vertical:
                                                                                5),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Expanded(
                                                                              child: Text(
                                                                                '${indexFirm + 1}',
                                                                                textAlign: TextAlign.center,
                                                                              ),
                                                                            ),
                                                                            const SizedBox(width: 5),
                                                                            Expanded(
                                                                              flex: 6,
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Text(
                                                                                    '${firmResult[indexFirm].firmName}',
                                                                                    textAlign: TextAlign.justify,
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                  ),
                                                                                  Text(
                                                                                    'Mô tả: ${firmResult[indexFirm].describe}',
                                                                                    textAlign: TextAlign.justify,
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                    style: const TextStyle(fontSize: 13),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            const SizedBox(width: 5),
                                                                            Expanded(
                                                                              flex: 2,
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  if (firmResult[indexFirm].phone!.isNotEmpty)
                                                                                    Text(
                                                                                      '${firmResult[indexFirm].phone}',
                                                                                    ),
                                                                                  if (firmResult[indexFirm].email!.isNotEmpty)
                                                                                    Text(
                                                                                      '${firmResult[indexFirm].email}',
                                                                                    ),
                                                                                  if (firmResult[indexFirm].phone!.isEmpty && firmResult[indexFirm].email!.isEmpty)
                                                                                    const Text(
                                                                                      'Chưa có thông tin liên hệ.',
                                                                                      textAlign: TextAlign.center,
                                                                                    ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            const SizedBox(width: 5),
                                                                            Expanded(
                                                                              flex: 2,
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  IconButton(
                                                                                      tooltip: 'Thông tin công ty',
                                                                                      padding: const EdgeInsets.only(bottom: 1),
                                                                                      onPressed: () {
                                                                                        regisFirm(
                                                                                          context: context,
                                                                                          firm: firmResult[indexFirm],
                                                                                        );
                                                                                      },
                                                                                      icon: const Icon(
                                                                                        CupertinoIcons.info_circle_fill,
                                                                                        size: 22,
                                                                                        color: Colors.red,
                                                                                      ))
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      );
                                                                    },
                                                                  )
                                                                : const Padding(
                                                                    padding: EdgeInsets
                                                                        .only(
                                                                            top:
                                                                                150),
                                                                    child: Text(
                                                                        'Không tìm thấy kết quả.'),
                                                                  );
                                                          }
                                                          return const SizedBox
                                                              .shrink();
                                                        }),
                                                  ),
                                                )
                                              : Expanded(
                                                  child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.vertical,
                                                    child: StreamBuilder(
                                                        stream: firestore
                                                            .collection('firms')
                                                            .snapshots(),
                                                        builder: (context,
                                                            snapshotFirm) {
                                                          if (snapshotFirm
                                                              .hasData) {
                                                            firms = [];
                                                            for (var element
                                                                in snapshotFirm
                                                                    .data!
                                                                    .docs) {
                                                              firms.add(FirmModel
                                                                  .fromMap(element
                                                                      .data()));
                                                            }
                                                            return firms
                                                                    .isNotEmpty
                                                                ? ListView
                                                                    .builder(
                                                                    itemCount: firms
                                                                        .length,
                                                                    shrinkWrap:
                                                                        true,
                                                                    itemBuilder:
                                                                        (context,
                                                                            indexFirm) {
                                                                      return Container(
                                                                        height: screenHeight *
                                                                            0.075,
                                                                        color: indexFirm % 2 ==
                                                                                0
                                                                            ? Colors.blue.shade50
                                                                            : null,
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            vertical:
                                                                                5),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Expanded(
                                                                              child: Text(
                                                                                '${indexFirm + 1}',
                                                                                textAlign: TextAlign.center,
                                                                              ),
                                                                            ),
                                                                            const SizedBox(width: 5),
                                                                            Expanded(
                                                                              flex: 6,
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Text(
                                                                                    '${firms[indexFirm].firmName}',
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                  ),
                                                                                  Text(
                                                                                    'Mô tả: ${firms[indexFirm].describe}',
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                    style: const TextStyle(fontSize: 13),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            const SizedBox(width: 5),
                                                                            Expanded(
                                                                              flex: 2,
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  if (firms[indexFirm].phone!.isNotEmpty)
                                                                                    Text(
                                                                                      '${firms[indexFirm].phone}',
                                                                                    ),
                                                                                  if (firms[indexFirm].email!.isNotEmpty)
                                                                                    Text(
                                                                                      '${firms[indexFirm].email}',
                                                                                    ),
                                                                                  if (firms[indexFirm].phone!.isEmpty && firms[indexFirm].email!.isEmpty)
                                                                                    const Text(
                                                                                      'Chưa có thông tin liên hệ.',
                                                                                      textAlign: TextAlign.center,
                                                                                    )
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            const SizedBox(width: 5),
                                                                            Expanded(
                                                                              flex: 2,
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  IconButton(
                                                                                      tooltip: 'Thông tin công ty',
                                                                                      padding: const EdgeInsets.only(bottom: 1),
                                                                                      onPressed: () {
                                                                                        regisFirm(
                                                                                          context: context,
                                                                                          firm: firms[indexFirm],
                                                                                        );
                                                                                      },
                                                                                      icon: const Icon(
                                                                                        CupertinoIcons.info_circle_fill,
                                                                                        size: 22,
                                                                                        color: Colors.red,
                                                                                      ))
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      );
                                                                    },
                                                                  )
                                                                : const Padding(
                                                                    padding: EdgeInsets
                                                                        .only(
                                                                            top:
                                                                                150),
                                                                    child: Text(
                                                                        'Chưa có công ty.'),
                                                                  );
                                                          }
                                                          return const SizedBox
                                                              .shrink();
                                                        }),
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Footer(),
          ],
        ),
      ),
    );
  }

  regisFirm({
    required BuildContext context,
    required FirmModel firm,
  }) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    showDialog(
      context: context,
      barrierColor: Colors.black12,
      barrierDismissible: false,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: screenHeight * 0.06,
            bottom: screenHeight * 0.02,
            left: screenWidth * 0.27,
            right: screenWidth * 0.08,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AlertDialog(
                scrollable: true,
                title: Container(
                  color: Colors.blue.shade600,
                  height: screenHeight * 0.06,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 30,
                      ),
                      const Expanded(
                        child: Text('Chi tiết tuyển dụng',
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                      ),
                      SizedBox(
                        width: 30,
                        child: IconButton(
                            padding: const EdgeInsets.only(bottom: 1),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close)),
                      )
                    ],
                  ),
                ),
                titlePadding: EdgeInsets.zero,
                shape: Border.all(width: 0.5),
                content: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: screenWidth * 0.35),
                  child: Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Tên công ty: ${firm.firmName!}'),
                        Text('Người đại diện: ${firm.owner!}'),
                        Text('Số điện thoại: ${firm.phone!}'),
                        Text('Email: ${firm.email!}'),
                        Text('Địa chỉ: ${firm.address!}'),
                        Text('Mô tả: ${firm.describe!}'),
                        const Text('Vị trí tuyển dụng:'),
                        for (var job in firm.listJob!)
                          Padding(
                            padding: const EdgeInsets.only(left: 25),
                            child: ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text('${job.jobName}'),
                              subtitle: Text('${job.describeJob}'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
