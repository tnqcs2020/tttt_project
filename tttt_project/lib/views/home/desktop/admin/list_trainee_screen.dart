// ignore_for_file: use_build_context_synchronously

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tttt_project/models/register_trainee_model.dart';
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

class ListTraineeScreen extends StatefulWidget {
  const ListTraineeScreen({Key? key}) : super(key: key);

  @override
  State<ListTraineeScreen> createState() => _ListTraineeScreenState();
}

class _ListTraineeScreenState extends State<ListTraineeScreen> {
  final currentUser = Get.put(UserController());
  List<String> dshk = [
    HocKy.hk1,
    HocKy.hk2,
    HocKy.hk3,
  ];
  List<NamHoc> dsnh = [NamHoc.n2021, NamHoc.n2122, NamHoc.n2223, NamHoc.n2324];

  ValueNotifier<String> selectedHK = ValueNotifier<String>('');
  ValueNotifier<NamHoc> selectedNH =
      ValueNotifier<NamHoc>(NamHoc(start: "", end: ""));
  ValueNotifier<bool> isLook = ValueNotifier<bool>(false);
  @override
  void initState() {
    getUserData();
    super.initState();
  }

  getUserData() async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    bool? isLoggedIn = sharedPref.getBool("isLoggedIn");
    print(sharedPref
        .getString(
          'userId',
        )
        .toString());
    if (isLoggedIn == true) {
      // sharedPref.getString('email').toString();
      // sharedPref.getString('password').toString();
      DocumentSnapshot<Map<String, dynamic>> isExistUser =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(sharedPref
                  .getString(
                    'userId',
                  )
                  .toString())
              .get();
      if (isExistUser.data() != null) {
        currentUser.setCurrentUser(
          setUid: isExistUser.data()?['uid'],
          setUserId: isExistUser.data()?['userId'],
          setName: isExistUser.data()?['name'],
          setClassName: isExistUser.data()?['className'],
          setCourse: isExistUser.data()?['course'],
          setGroup: isExistUser.data()?['group'],
          setMajor: isExistUser.data()?['major'],
          setEmail: isExistUser.data()?['email'],
          setMenuSelected: sharedPref.getInt('menuSelected'),
          setIsRegistered: isExistUser.data()!['isRegistered'],
        );
        print(isExistUser.data()?['group']);
      }
    }
  }
  // getUserData() async {
  //   final SharedPreferences sharedPref = await SharedPreferences.getInstance();
  //   bool? isLoggedIn = sharedPref.getBool("isLoggedIn");
  //   String userId = sharedPref
  //       .getString(
  //         'userId',
  //       )
  //       .toString();
  //   if (isLoggedIn == true) {
  //     DocumentSnapshot<Map<String, dynamic>> isExistUser =
  //         await GV.usersCol.doc(userId).get();
  //     if (isExistUser.data() != null) {
  //       final loadUser = UserModel.fromMap(isExistUser.data()!);
  //       currentUser.setCurrentUser(
  //         setUid: loadUser.uid,
  //         setUserId: loadUser.userId,
  //         setName: loadUser.name,
  //         setClassName: loadUser.className,
  //         setCourse: loadUser.course,
  //         setGroup: loadUser.group,
  //         setMajor: loadUser.major,
  //         setEmail: loadUser.email,
  //         setMenuSelected: sharedPref.getInt('menuSelected'),
  //         setIsRegistered: loadUser.isRegistered,
  //       );
  //     }
  //   }
  // }

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
                          BoxConstraints(minHeight: screenHeight * 0.74),
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
                                      "Danh sách sinh viên đăng ký thực tập",
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
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Học Kỳ",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.black,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(width: 15),
                                            ValueListenableBuilder<String>(
                                              valueListenable: selectedHK,
                                              builder:
                                                  (context, valueHK, child) {
                                                return DropdownButtonHideUnderline(
                                                  child:
                                                      DropdownButton2<String>(
                                                    isExpanded: true,
                                                    hint: Center(
                                                      child: Text(
                                                        'Chọn',
                                                        style: DropdownStyle
                                                            .hintStyle,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    items: dshk
                                                        .map((String hk) =>
                                                            DropdownMenuItem<
                                                                String>(
                                                              value: hk,
                                                              child: Text(
                                                                hk,
                                                                style: DropdownStyle
                                                                    .itemStyle,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ))
                                                        .toList(),
                                                    value: selectedHK
                                                            .value.isNotEmpty
                                                        ? selectedHK.value
                                                        : null,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        isLook.value = false;
                                                        selectedHK.value =
                                                            value!;
                                                      });
                                                    },
                                                    buttonStyleData:
                                                        DropdownStyle
                                                            .buttonStyleShort,
                                                    iconStyleData: DropdownStyle
                                                        .iconStyleData,
                                                    dropdownStyleData:
                                                        DropdownStyle
                                                            .dropdownStyleShort,
                                                    menuItemStyleData:
                                                        DropdownStyle
                                                            .menuItemStyleData,
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 35),
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Năm Học",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.black,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(width: 15),
                                            ValueListenableBuilder<NamHoc>(
                                              valueListenable: selectedNH,
                                              builder:
                                                  (context, valueNH, child) {
                                                return DropdownButtonHideUnderline(
                                                  child:
                                                      DropdownButton2<NamHoc>(
                                                    isExpanded: true,
                                                    hint: Center(
                                                      child: Text(
                                                        "Chọn",
                                                        style: DropdownStyle
                                                            .hintStyle,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    items: dsnh
                                                        .map((NamHoc nh) =>
                                                            DropdownMenuItem<
                                                                NamHoc>(
                                                              value: nh,
                                                              child: Text(
                                                                "${nh.start} - ${nh.end}",
                                                                style: DropdownStyle
                                                                    .itemStyle,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ))
                                                        .toList(),
                                                    value: selectedNH
                                                                .value
                                                                .start
                                                                .isNotEmpty &&
                                                            selectedNH.value.end
                                                                .isNotEmpty
                                                        ? selectedNH.value
                                                        : null,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        isLook.value = false;
                                                        selectedNH.value =
                                                            value!;
                                                      });
                                                    },
                                                    buttonStyleData:
                                                        DropdownStyle
                                                            .buttonStyleMedium,
                                                    iconStyleData: DropdownStyle
                                                        .iconStyleData,
                                                    dropdownStyleData:
                                                        DropdownStyle
                                                            .dropdownStyleMedium,
                                                    menuItemStyleData:
                                                        DropdownStyle
                                                            .menuItemStyleData,
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 75),
                                    CustomButton(
                                      text: "Xem",
                                      width: screenWidth * 0.07,
                                      height: screenHeight * 0.06,
                                      onTap: () {
                                        if (selectedHK.value.isNotEmpty &&
                                            selectedNH.value.start.isNotEmpty &&
                                            selectedNH.value.end.isNotEmpty) {
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
                                      child: const Row(
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
                                              child: Text('Học phần',
                                                  textAlign: TextAlign.center)),
                                          Expanded(
                                              flex: 1,
                                              child: Text('Khóa',
                                                  textAlign: TextAlign.center)),
                                        ],
                                      ),
                                    ),
                                    StreamBuilder(
                                      stream: GV.traineesCol
                                          .where('term',
                                              isEqualTo: selectedHK.value)
                                          .where('yearStart',
                                              isEqualTo: selectedNH.value.start)
                                          .where('yearEnd',
                                              isEqualTo: selectedNH.value.end)
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        final List<RegisterTraineeModel>
                                            dstttt = [];
                                        snapshot.data?.docs.forEach((element) {
                                          dstttt.add(
                                              RegisterTraineeModel.fromMap(
                                                  element.data()));
                                        });
                                        if (snapshot.hasData &&
                                            isLook.value &&
                                            selectedHK.value.isNotEmpty &&
                                            selectedNH.value.start.isNotEmpty &&
                                            selectedNH.value.end.isNotEmpty &&
                                            snapshot.connectionState ==
                                                ConnectionState.active) {
                                          return ListView.builder(
                                            itemCount: dstttt.length,
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
                                                          dstttt[index]
                                                              .uid
                                                              .toUpperCase(),
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                                    Expanded(
                                                      flex: 4,
                                                      child: Text(
                                                          dstttt[index]
                                                              .studentName,
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Text(
                                                          '${dstttt[index].creditId} - ${dstttt[index].creditName}',
                                                          textAlign:
                                                              TextAlign.center),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Text(
                                                          dstttt[index].course,
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
                                        return SizedBox();
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
