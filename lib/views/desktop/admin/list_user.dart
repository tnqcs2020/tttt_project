// ignore_for_file: use_build_context_synchronously

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/widgets/custom_button.dart';
import 'package:tttt_project/widgets/dropdown_style.dart';
import 'package:tttt_project/widgets/header.dart';
import 'package:tttt_project/widgets/loading.dart';
import 'package:tttt_project/common/user_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/common/constant.dart';
import 'package:tttt_project/widgets/footer.dart';
import 'package:tttt_project/widgets/menu/menu_left.dart';

class ListUserScreen extends StatefulWidget {
  const ListUserScreen({Key? key}) : super(key: key);

  @override
  State<ListUserScreen> createState() => _ListUserScreenState();
}

class _ListUserScreenState extends State<ListUserScreen> {
  final firestore = FirebaseFirestore.instance;
  final currentUser = Get.put(UserController());
  ValueNotifier<String> selectedND = ValueNotifier<String>(NguoiDung.empty);
  ValueNotifier<bool> isLook = ValueNotifier<bool>(false);
  @override
  void initState() {
    getUserData();
    super.initState();
  }

  getUserData() async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    String? userId = sharedPref
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
                          BoxConstraints(minHeight: screenHeight * 0.67),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          border: Border.all(
                            style: BorderStyle.solid,
                            width: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(5)),
                      child: ValueListenableBuilder<bool>(
                        valueListenable: isLook,
                        builder: (context, value, child) {
                          return Column(
                            children: [
                              Container(
                                height: 35,
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
                                      "Danh sách người dùng",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(
                                    left: 50, right: 50, top: 15),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Nhóm người dùng",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(width: 15),
                                        ValueListenableBuilder<String>(
                                          valueListenable: selectedND,
                                          builder: (context, valueND, child) {
                                            return DropdownButtonHideUnderline(
                                              child: DropdownButton2<String>(
                                                isExpanded: true,
                                                hint: Center(
                                                  child: Text(
                                                    "Chọn",
                                                    style:
                                                        DropdownStyle.hintStyle,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                items: dsndAll
                                                    .map((String nd) =>
                                                        DropdownMenuItem<
                                                            String>(
                                                          value: nd,
                                                          child: Text(
                                                            nd,
                                                            style: DropdownStyle
                                                                .itemStyle,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ))
                                                    .toList(),
                                                value: selectedND.value !=
                                                        NguoiDung.empty
                                                    ? selectedND.value
                                                    : null,
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedND.value = value!;
                                                  });
                                                  currentUser.isCompleted
                                                      .value = false;
                                                },
                                                buttonStyleData: DropdownStyle
                                                    .buttonStyleLong,
                                                iconStyleData:
                                                    DropdownStyle.iconStyleData,
                                                dropdownStyleData: DropdownStyle
                                                    .dropdownStyleLong,
                                                menuItemStyleData: DropdownStyle
                                                    .menuItemStyleData,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 75),
                                    CustomButton(
                                      text: "Xem",
                                      width: screenWidth * 0.07,
                                      height: screenHeight * 0.06,
                                      onTap: () {
                                        if (selectedND.value.isNotEmpty) {
                                          setState(() {
                                            isLook.value = true;
                                          });
                                          currentUser.isCompleted.value = true;
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                decoration:
                                    const BoxDecoration(color: Colors.white),
                                height: screenHeight * 0.45,
                                width: screenWidth * 0.55,
                                child: Column(
                                  children: [
                                    Container(
                                      color: Colors.green,
                                      height: screenHeight * 0.035,
                                      child: const Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'STT',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'MSSV',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              'Họ tên',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              'Email',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: isLook.value &&
                                              currentUser.isCompleted.isTrue
                                          ? StreamBuilder(
                                              stream: firestore
                                                  .collection('users')
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                List<UserModel> loadUser = [];
                                                List<UserModel> listUser = [];
                                                if (snapshot.hasData &&
                                                    snapshot.connectionState ==
                                                        ConnectionState
                                                            .active) {
                                                  snapshot.data?.docs
                                                      .forEach((element) {
                                                    loadUser.add(
                                                        UserModel.fromMap(
                                                            element.data()));
                                                  });
                                                  if (selectedND.value ==
                                                      NguoiDung.tatca) {
                                                    loadUser.forEach((element) {
                                                      listUser.add(element);
                                                    });
                                                  } else {
                                                    loadUser.forEach((element) {
                                                      if (element.group ==
                                                          selectedND.value) {
                                                        listUser.add(element);
                                                      }
                                                    });
                                                  }
                                                  listUser.sort(
                                                    (a, b) => a.userId!
                                                        .compareTo(b.userId!),
                                                  );
                                                  return listUser.isNotEmpty
                                                      ? ListView.builder(
                                                          itemCount:
                                                              listUser.length,
                                                          shrinkWrap: true,
                                                          scrollDirection:
                                                              Axis.vertical,
                                                          itemBuilder:
                                                              (context, index) {
                                                            return Container(
                                                              height:
                                                                  screenHeight *
                                                                      0.04,
                                                              color: index %
                                                                          2 ==
                                                                      0
                                                                  ? Colors.blue
                                                                      .shade50
                                                                  : null,
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: Text(
                                                                        '${index + 1}',
                                                                        textAlign:
                                                                            TextAlign.center),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 2,
                                                                    child: Text(
                                                                        listUser[index]
                                                                            .userId!
                                                                            .toUpperCase(),
                                                                        textAlign:
                                                                            TextAlign.justify),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 3,
                                                                    child: Text(
                                                                        listUser[index]
                                                                            .userName!,
                                                                        textAlign:
                                                                            TextAlign.justify),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 4,
                                                                    child: Text(
                                                                        listUser[index].email!.isNotEmpty
                                                                            ? '${listUser[index].email}'
                                                                            : "-",
                                                                        textAlign:
                                                                            TextAlign.justify),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        )
                                                      : const Center(
                                                          child: Text(
                                                              'Chưa có thông báo.'),
                                                        );
                                                } else {
                                                  return const Center(
                                                      child: Loading());
                                                }
                                              },
                                            )
                                          : selectedND.value.isEmpty
                                              ? StreamBuilder(
                                                  stream: firestore
                                                      .collection('users')
                                                      .snapshots(),
                                                  builder: (context, snapshot) {
                                                    List<UserModel> listUser =
                                                        [];
                                                    if (snapshot.hasData &&
                                                        snapshot.connectionState ==
                                                            ConnectionState
                                                                .active) {
                                                      snapshot.data?.docs
                                                          .forEach((element) {
                                                        listUser.add(
                                                            UserModel.fromMap(
                                                                element
                                                                    .data()));
                                                      });
                                                      listUser.sort(
                                                        (a, b) => a.userId!
                                                            .compareTo(
                                                                b.userId!),
                                                      );
                                                      return listUser.isNotEmpty
                                                          ? ListView.builder(
                                                              itemCount:
                                                                  listUser
                                                                      .length,
                                                              shrinkWrap: true,
                                                              scrollDirection:
                                                                  Axis.vertical,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                return Container(
                                                                  height:
                                                                      screenHeight *
                                                                          0.035,
                                                                  color: index %
                                                                              2 ==
                                                                          0
                                                                      ? Colors
                                                                          .blue
                                                                          .shade50
                                                                      : null,
                                                                  child: Row(
                                                                    children: [
                                                                      Expanded(
                                                                        flex: 1,
                                                                        child: Text(
                                                                            '${index + 1}',
                                                                            textAlign:
                                                                                TextAlign.center),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 2,
                                                                        child: Text(
                                                                            listUser[index]
                                                                                .userId!
                                                                                .toUpperCase(),
                                                                            textAlign:
                                                                                TextAlign.justify),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 3,
                                                                        child: Text(
                                                                            listUser[index]
                                                                                .userName!,
                                                                            textAlign:
                                                                                TextAlign.justify),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 4,
                                                                        child: Text(
                                                                            listUser[index].email!.isNotEmpty
                                                                                ? '${listUser[index].email}'
                                                                                : "-",
                                                                            textAlign:
                                                                                TextAlign.justify),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            )
                                                          : const Center(
                                                              child: Text(
                                                                  'Chưa có thông báo.'),
                                                            );
                                                    } else {
                                                      return const Center(
                                                          child: Loading());
                                                    }
                                                  },
                                                )
                                              : const Center(
                                                  child: Text(
                                                      'Vui lòng nhấn vào nút xem để tiếp tục.'),
                                                ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
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
}
