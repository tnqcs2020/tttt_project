// ignore_for_file: use_build_context_synchronously

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/widgets/custom_button.dart';
import 'package:tttt_project/widgets/dropdown_style.dart';
import 'package:tttt_project/widgets/header.dart';
import 'package:tttt_project/widgets/loading.dart';
import 'package:tttt_project/widgets/user_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/data/constant.dart';
import 'package:tttt_project/widgets/footer.dart';
import 'package:tttt_project/widgets/menu/menu_left.dart';

class ListUserScreen extends StatefulWidget {
  const ListUserScreen({Key? key}) : super(key: key);

  @override
  State<ListUserScreen> createState() => _ListUserScreenState();
}

class _ListUserScreenState extends State<ListUserScreen> {
  final currentUser = Get.put(UserController());
  List<String> dsnd = [
    NguoiDung.giaovu,
    NguoiDung.covan,
    NguoiDung.cbhd,
    NguoiDung.sinhvien,
  ];
  ValueNotifier<String> selectedND = ValueNotifier<String>('');
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
                          BoxConstraints(minHeight: screenHeight * 0.7),
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
                                                items: dsnd
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
                                                value:
                                                    selectedND.value.isNotEmpty
                                                        ? selectedND.value
                                                        : null,
                                                onChanged: (value) {
                                                  setState(() {
                                                    isLook.value = false;
                                                    selectedND.value = value!;
                                                  });
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
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 35),
                              Container(
                                decoration:
                                    const BoxDecoration(color: Colors.white),
                                height: screenHeight * 0.45,
                                width: screenWidth * 0.55,
                                child: Column(
                                  children: [
                                    Container(
                                      color: Colors.green,
                                      height: screenHeight * 0.04,
                                      child: Row(
                                        children: [
                                          Expanded(
                                              flex: 1,
                                              child: Text('STT',
                                                  textAlign: TextAlign.center)),
                                          Expanded(
                                              flex: 2,
                                              child: Text('MSSV',
                                                  textAlign: TextAlign.center)),
                                          Expanded(
                                              flex: 4,
                                              child: Text('Họ tên',
                                                  textAlign: TextAlign.center)),
                                          Expanded(
                                              flex: 5,
                                              child: Text(
                                                  selectedND.value ==
                                                          NguoiDung.covan
                                                      ? 'Lớp cố vấn'
                                                      : 'Lớp',
                                                  textAlign: TextAlign.center)),
                                          Expanded(
                                              flex: 1,
                                              child: Text('Khóa',
                                                  textAlign: TextAlign.center)),
                                        ],
                                      ),
                                    ),
                                    StreamBuilder(
                                      stream: GV.usersCol
                                          .where('group',
                                              isEqualTo: selectedND.value)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        final List<UserModel> listUser = [];
                                        if (snapshot.hasData &&
                                            isLook.value &&
                                            selectedND.value.isNotEmpty &&
                                            snapshot.connectionState ==
                                                ConnectionState.active) {
                                          snapshot.data?.docs
                                              .forEach((element) {
                                            listUser.add(UserModel.fromMap(
                                                element.data()));
                                          });
                                          return ListView.builder(
                                            itemCount: listUser.length,
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) {
                                              return Container(
                                                decoration:
                                                    const BoxDecoration(),
                                                height: screenHeight * 0.04,
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
                                                              TextAlign.center),
                                                    ),
                                                    Expanded(
                                                      flex: 4,
                                                      child: Text(
                                                          listUser[index]
                                                              .userName!,
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Text(
                                                          selectedND.value ==
                                                                  NguoiDung
                                                                      .covan
                                                              ? '${listUser[index].cvClass!.last.classId} - ${listUser[index].cvClass!.last.className}'
                                                              : '${listUser[index].classId} - ${listUser[index].className}',
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Text(
                                                          selectedND.value ==
                                                                      NguoiDung
                                                                          .sinhvien &&
                                                                  listUser[index]
                                                                          .course !=
                                                                      null
                                                              ? listUser[index]
                                                                  .course!
                                                              : selectedND.value ==
                                                                          NguoiDung
                                                                              .covan &&
                                                                      listUser[index]
                                                                              .cvClass!
                                                                              .last
                                                                              .course !=
                                                                          ""
                                                                  ? '${listUser[index].cvClass!.last.course}'
                                                                  : '-',
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        } else if (isLook.value &&
                                            snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                          return const Loading();
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
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
