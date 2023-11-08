// ignore_for_file: use_build_context_synchronously

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tttt_project/models/register_trainee_model.dart';
import 'package:tttt_project/models/user_model.dart';
// import 'package:tttt_project/models/user_model.dart';
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
  final firestore = FirebaseFirestore.instance;
  final currentUser = Get.put(UserController());
  String selectedHK = HocKy.empty;
  NamHoc selectedNH = NamHoc.empty;
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
                                      "Danh Sách Sinh Viên Đăng Ký Thực Tập",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
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
                                            DropdownButtonHideUnderline(
                                              child: DropdownButton2<String>(
                                                isExpanded: true,
                                                hint: Center(
                                                  child: Text(
                                                    'Chọn',
                                                    style:
                                                        DropdownStyle.hintStyle,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                items: dshkAll
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
                                                value: selectedHK.isNotEmpty
                                                    ? selectedHK
                                                    : null,
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedHK = value!;
                                                  });
                                                  currentUser.isCompleted
                                                      .value = false;
                                                },
                                                buttonStyleData: DropdownStyle
                                                    .buttonStyleShort,
                                                iconStyleData:
                                                    DropdownStyle.iconStyleData,
                                                dropdownStyleData: DropdownStyle
                                                    .dropdownStyleShort,
                                                menuItemStyleData: DropdownStyle
                                                    .menuItemStyleData,
                                              ),
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
                                            DropdownButtonHideUnderline(
                                              child: DropdownButton2<NamHoc>(
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
                                                items: dsnhAll
                                                    .map((NamHoc nh) =>
                                                        DropdownMenuItem<
                                                            NamHoc>(
                                                          value: nh,
                                                          child: Text(
                                                            nh.start == nh.end
                                                                ? nh.start
                                                                : "${nh.start} - ${nh.end}",
                                                            style: DropdownStyle
                                                                .itemStyle,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ))
                                                    .toList(),
                                                value: selectedNH
                                                            .start.isNotEmpty &&
                                                        selectedNH
                                                            .end.isNotEmpty
                                                    ? selectedNH
                                                    : null,
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedNH = value!;
                                                  });
                                                  currentUser.isCompleted
                                                      .value = false;
                                                },
                                                buttonStyleData: DropdownStyle
                                                    .buttonStyleMedium,
                                                iconStyleData:
                                                    DropdownStyle.iconStyleData,
                                                dropdownStyleData: DropdownStyle
                                                    .dropdownStyleMedium,
                                                menuItemStyleData: DropdownStyle
                                                    .menuItemStyleData,
                                              ),
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
                                        if (selectedHK != HocKy.empty &&
                                            selectedNH != NamHoc.empty) {
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
                                      height: screenHeight * 0.04,
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
                                            flex: 4,
                                            child: Text(
                                              'Họ tên',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 5,
                                            child: Text(
                                              'Học phần',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              'Khóa',
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
                                                  .collection('trainees')
                                                  .where('term',
                                                      isEqualTo: selectedHK)
                                                  .where('yearStart',
                                                      isEqualTo:
                                                          selectedNH.start)
                                                  .where('yearEnd',
                                                      isEqualTo: selectedNH.end)
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                List<RegisterTraineeModel>
                                                    loadTrainee = [];
                                                List<RegisterTraineeModel>
                                                    dstttt = [];
                                                if (snapshot.hasData &&
                                                    snapshot.connectionState ==
                                                        ConnectionState
                                                            .active) {
                                                  snapshot.data?.docs
                                                      .forEach((element) {
                                                    loadTrainee.add(
                                                        RegisterTraineeModel
                                                            .fromMap(element
                                                                .data()));
                                                  });
                                                  if (selectedHK ==
                                                          HocKy.tatca &&
                                                      selectedNH ==
                                                          NamHoc.tatca) {
                                                    loadTrainee.forEach((e) {
                                                      dstttt.add(e);
                                                    });
                                                  } else if (selectedHK ==
                                                      HocKy.tatca) {
                                                    loadTrainee.forEach((e) {
                                                      if (e.yearStart ==
                                                          selectedNH.start) {
                                                        dstttt.add(e);
                                                      }
                                                    });
                                                  } else if (selectedNH ==
                                                      NamHoc.tatca) {
                                                    loadTrainee.forEach((e) {
                                                      if (e.term ==
                                                          selectedHK) {
                                                        dstttt.add(e);
                                                      }
                                                    });
                                                  } else {
                                                    loadTrainee.forEach((e) {
                                                      if (e.term ==
                                                              selectedHK &&
                                                          e.yearStart ==
                                                              selectedNH
                                                                  .start) {
                                                        dstttt.add(e);
                                                      }
                                                    });
                                                  }
                                                  dstttt.sort(
                                                    (a, b) => a.userId!
                                                        .compareTo(b.userId!),
                                                  );
                                                  return dstttt.isNotEmpty
                                                      ? ListView.builder(
                                                          itemCount:
                                                              dstttt.length,
                                                          shrinkWrap: true,
                                                          scrollDirection:
                                                              Axis.vertical,
                                                          itemBuilder:
                                                              (context, index) {
                                                            return Container(
                                                              height:
                                                                  screenHeight *
                                                                      0.05,
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
                                                                        dstttt[index]
                                                                            .userId!
                                                                            .toUpperCase(),
                                                                        textAlign:
                                                                            TextAlign.center),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 4,
                                                                    child: Text(
                                                                        dstttt[index]
                                                                            .studentName!,
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
                                                                        dstttt[index]
                                                                            .course!,
                                                                        textAlign:
                                                                            TextAlign.center),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        )
                                                      : const Center(
                                                          child: Text(
                                                              'Chưa có sinh viên đăng ký.'),
                                                        );
                                                } else {
                                                  return const Center(
                                                      child: Loading());
                                                }
                                              },
                                            )
                                          : selectedHK.isEmpty &&
                                                  selectedNH.start.isEmpty &&
                                                  selectedNH.end.isEmpty
                                              ? StreamBuilder(
                                                  stream: firestore
                                                      .collection('trainees')
                                                      .snapshots(),
                                                  builder: (context, snapshot) {
                                                    List<RegisterTraineeModel>
                                                        dstttt = [];
                                                    if (snapshot.hasData &&
                                                        snapshot.connectionState ==
                                                            ConnectionState
                                                                .active) {
                                                      snapshot.data?.docs
                                                          .forEach((element) {
                                                        dstttt.add(
                                                            RegisterTraineeModel
                                                                .fromMap(element
                                                                    .data()));
                                                      });
                                                      dstttt.sort(
                                                        (a, b) => a.userId!
                                                            .compareTo(
                                                                b.userId!),
                                                      );
                                                      return dstttt.isNotEmpty
                                                          ? ListView.builder(
                                                              itemCount:
                                                                  dstttt.length,
                                                              shrinkWrap: true,
                                                              scrollDirection:
                                                                  Axis.vertical,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                return Container(
                                                                  height:
                                                                      screenHeight *
                                                                          0.05,
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
                                                                            dstttt[index]
                                                                                .userId!
                                                                                .toUpperCase(),
                                                                            textAlign:
                                                                                TextAlign.center),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 4,
                                                                        child: Text(
                                                                            dstttt[index]
                                                                                .studentName!,
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
                                                                            dstttt[index]
                                                                                .course!,
                                                                            textAlign:
                                                                                TextAlign.center),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            )
                                                          : const Center(
                                                              child: Text(
                                                                  'Chưa có sinh viên đăng ký.'),
                                                            );
                                                    } else {
                                                      return const Center(
                                                          child: Loading());
                                                    }
                                                  },
                                                )
                                              : const Center(
                                                  child: Text(
                                                      'Vui lòng chọn học kỳ và năm học sau đó nhấn vào nút xem để tiếp tục.'),
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
