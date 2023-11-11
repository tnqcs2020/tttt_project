// ignore_for_file: use_build_context_synchronously

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tttt_project/models/register_trainee_model.dart';
import 'package:tttt_project/models/setting_trainee_model.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/widgets/custom_button.dart';
import 'package:tttt_project/widgets/date_inputformatter.dart';
import 'package:tttt_project/widgets/dropdown_style.dart';
import 'package:tttt_project/widgets/header.dart';
import 'package:tttt_project/widgets/loading.dart';
import 'package:tttt_project/widgets/user_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/data/constant.dart';
import 'package:tttt_project/widgets/footer.dart';
import 'package:tttt_project/widgets/menu/menu_left.dart';

class SettingTraineeScreen extends StatefulWidget {
  const SettingTraineeScreen({Key? key}) : super(key: key);

  @override
  State<SettingTraineeScreen> createState() => _SettingTraineeScreenState();
}

class _SettingTraineeScreenState extends State<SettingTraineeScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final firestore = FirebaseFirestore.instance;
  final currentUser = Get.put(UserController());
  String selectedHK = HocKy.empty;
  NamHoc selectedNH = NamHoc.empty;
  ValueNotifier<bool> isLook = ValueNotifier<bool>(false);
  ValueNotifier<String> _selectedHK = ValueNotifier(HocKy.empty);
  ValueNotifier<NamHoc> _selectedNH = ValueNotifier(NamHoc.empty);
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
  void dispose() {
    _selectedHK.dispose();
    _selectedNH.dispose();
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
                                      "Quản lý các mốc thời gian thực tập",
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
                                              "Học kỳ",
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
                                                value: selectedHK != HocKy.empty
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
                                    const SizedBox(width: 25),
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Năm học",
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
                                                value:
                                                    selectedNH != NamHoc.empty
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
                                    const SizedBox(width: 45),
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
                                    const SizedBox(width: 15),
                                    CustomButton(
                                      text: "Thêm thiết lập",
                                      width: screenWidth * 0.07,
                                      height: screenHeight * 0.06,
                                      onTap: () {
                                        addAndEditSetting(
                                            context: context, isCreate: true);
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
                                              'Học kỳ',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'Năm học',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              'Thời gian thực tập',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'Khóa điểm',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'Thao tác',
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
                                                  .collection('settingTrainees')
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                List<SettingTraineeModel>
                                                    loadTrainee = [];
                                                List<SettingTraineeModel>
                                                    setTrainees = [];
                                                if (snapshot.hasData &&
                                                    snapshot.connectionState ==
                                                        ConnectionState
                                                            .active) {
                                                  snapshot.data?.docs
                                                      .forEach((element) {
                                                    loadTrainee.add(
                                                        SettingTraineeModel
                                                            .fromMap(element
                                                                .data()));
                                                  });
                                                  if (selectedHK ==
                                                          HocKy.tatca &&
                                                      selectedNH ==
                                                          NamHoc.tatca) {
                                                    loadTrainee.forEach((e) {
                                                      setTrainees.add(e);
                                                    });
                                                  } else if (selectedHK ==
                                                      HocKy.tatca) {
                                                    loadTrainee.forEach((e) {
                                                      if (e.yearStart ==
                                                          selectedNH.start) {
                                                        setTrainees.add(e);
                                                      }
                                                    });
                                                  } else if (selectedNH ==
                                                      NamHoc.tatca) {
                                                    loadTrainee.forEach((e) {
                                                      if (e.term ==
                                                          selectedHK) {
                                                        setTrainees.add(e);
                                                      }
                                                    });
                                                  } else {
                                                    loadTrainee.forEach((e) {
                                                      if (e.term ==
                                                              selectedHK &&
                                                          e.yearStart ==
                                                              selectedNH
                                                                  .start) {
                                                        setTrainees.add(e);
                                                      }
                                                    });
                                                  }
                                                  setTrainees.sort((a, b) {
                                                    final compare =
                                                        Comparable.compare(
                                                            a.yearStart!,
                                                            b.yearStart!);
                                                    return compare == 0
                                                        ? Comparable.compare(
                                                            a.term!, b.term!)
                                                        : compare;
                                                  });
                                                  return setTrainees.isNotEmpty
                                                      ? ListView.builder(
                                                          itemCount: setTrainees
                                                              .length,
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
                                                                        setTrainees[index]
                                                                            .term!,
                                                                        textAlign:
                                                                            TextAlign.center),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 2,
                                                                    child: Text(
                                                                      '${setTrainees[index].yearStart!} - ${setTrainees[index].yearEnd!}',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 3,
                                                                    child: Text(
                                                                        '${GV.readTimestamp(setTrainees[index].traineeStart!)} - ${GV.readTimestamp(setTrainees[index].traineeEnd!)}',
                                                                        textAlign:
                                                                            TextAlign.center),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 2,
                                                                    child: Text(
                                                                        GV.readTimestamp(setTrainees[index]
                                                                            .isClockPoint!),
                                                                        textAlign:
                                                                            TextAlign.center),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 2,
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        IconButton(
                                                                            tooltip:
                                                                                'Chỉnh sửa các mốc thời gian',
                                                                            onPressed:
                                                                                () async {
                                                                              await addAndEditSetting(context: context, settingTrainee: setTrainees[index], isCreate: false);
                                                                            },
                                                                            padding:
                                                                                const EdgeInsets.only(bottom: 1),
                                                                            icon: Icon(
                                                                              Icons.edit_square,
                                                                              color: Colors.blue.shade900,
                                                                            )),
                                                                        IconButton(
                                                                            tooltip:
                                                                                'Xóa thiết lập',
                                                                            onPressed:
                                                                                () {
                                                                              deleteSetting(context: context, settingId: setTrainees[index].settingId!);
                                                                            },
                                                                            padding:
                                                                                const EdgeInsets.only(bottom: 1),
                                                                            icon: const Icon(
                                                                              Icons.delete,
                                                                              color: Colors.red,
                                                                            )),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        )
                                                      : const Center(
                                                          child: Text(
                                                              'Chưa có thiết lập thời gian.'),
                                                        );
                                                } else {
                                                  return const Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Loading(),
                                                    ],
                                                  );
                                                }
                                              },
                                            )
                                          : selectedHK == HocKy.empty &&
                                                  selectedNH == NamHoc.empty
                                              ? StreamBuilder(
                                                  stream: firestore
                                                      .collection(
                                                          'settingTrainees')
                                                      .snapshots(),
                                                  builder: (context, snapshot) {
                                                    List<SettingTraineeModel>
                                                        setTrainees = [];
                                                    if (snapshot.hasData &&
                                                        snapshot.connectionState ==
                                                            ConnectionState
                                                                .active) {
                                                      snapshot.data?.docs
                                                          .forEach((element) {
                                                        setTrainees.add(
                                                            SettingTraineeModel
                                                                .fromMap(element
                                                                    .data()));
                                                      });
                                                      setTrainees.sort((a, b) {
                                                        final compare =
                                                            Comparable.compare(
                                                                a.yearStart!,
                                                                b.yearStart!);
                                                        return compare == 0
                                                            ? Comparable
                                                                .compare(
                                                                    a.term!,
                                                                    b.term!)
                                                            : compare;
                                                      });
                                                      return setTrainees
                                                              .isNotEmpty
                                                          ? ListView.builder(
                                                              itemCount:
                                                                  setTrainees
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
                                                                            setTrainees[index]
                                                                                .term!,
                                                                            textAlign:
                                                                                TextAlign.center),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 2,
                                                                        child:
                                                                            Text(
                                                                          '${setTrainees[index].yearStart!} - ${setTrainees[index].yearEnd!}',
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                        ),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 3,
                                                                        child: Text(
                                                                            '${GV.readTimestamp(setTrainees[index].traineeStart!)} - ${GV.readTimestamp(setTrainees[index].traineeEnd!)}',
                                                                            textAlign:
                                                                                TextAlign.center),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 2,
                                                                        child: Text(
                                                                            GV.readTimestamp(setTrainees[index]
                                                                                .isClockPoint!),
                                                                            textAlign:
                                                                                TextAlign.center),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 2,
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            IconButton(
                                                                                tooltip: 'Chỉnh sửa các mốc thời gian',
                                                                                onPressed: () async {
                                                                                  await addAndEditSetting(context: context, settingTrainee: setTrainees[index], isCreate: false);
                                                                                },
                                                                                padding: const EdgeInsets.only(bottom: 1),
                                                                                icon: Icon(
                                                                                  Icons.edit_square,
                                                                                  color: Colors.blue.shade900,
                                                                                )),
                                                                            IconButton(
                                                                                tooltip: 'Xóa thiết lập',
                                                                                onPressed: () {
                                                                                  deleteSetting(context: context, settingId: setTrainees[index].settingId!);
                                                                                },
                                                                                padding: const EdgeInsets.only(bottom: 1),
                                                                                icon: const Icon(
                                                                                  Icons.delete,
                                                                                  color: Colors.red,
                                                                                )),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            )
                                                          : const Center(
                                                              child: Text(
                                                                  'Chưa có thiết lập thời gian.'),
                                                            );
                                                    } else {
                                                      return const Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Loading(),
                                                        ],
                                                      );
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

  addAndEditSetting(
      {required BuildContext context,
      SettingTraineeModel? settingTrainee,
      required bool isCreate}) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    TextEditingController isClockPointCtrl = TextEditingController();
    TextEditingController traineeStartCtrl = TextEditingController();
    TextEditingController traineeEndCtrl = TextEditingController();
    TextEditingController regisStartCtrl = TextEditingController();
    TextEditingController regisEndCtrl = TextEditingController();
    TextEditingController submitEndCtrl = TextEditingController();
    TextEditingController pointCVEndCtrl = TextEditingController();
    TextEditingController pointCBEndCtrl = TextEditingController();

    if (isCreate == false && settingTrainee != null) {
      setState(() {
        _selectedHK.value = settingTrainee.term!;
        dsnh.forEach((element) {
          if (element.start == settingTrainee.yearStart &&
              element.end == settingTrainee.yearEnd) {
            _selectedNH.value = element;
          }
        });
      });
      isClockPointCtrl.text = GV.readTimestamp(settingTrainee.isClockPoint!);
      traineeStartCtrl.text = GV.readTimestamp(settingTrainee.traineeStart!);
      traineeEndCtrl.text = GV.readTimestamp(settingTrainee.traineeEnd!);
      regisStartCtrl.text = GV.readTimestamp(settingTrainee.regisStart!);
      regisEndCtrl.text = GV.readTimestamp(settingTrainee.regisEnd!);
      submitEndCtrl.text = GV.readTimestamp(settingTrainee.submitEnd!);
      pointCVEndCtrl.text = GV.readTimestamp(settingTrainee.pointCVEnd!);
      pointCBEndCtrl.text = GV.readTimestamp(settingTrainee.pointCBEnd!);
    }

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
                      Expanded(
                        child: Text(
                            isCreate ? 'Thêm học phần' : 'Cập nhật học phần',
                            style: const TextStyle(fontWeight: FontWeight.bold),
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
                content: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  constraints: BoxConstraints(minWidth: screenWidth * 0.3),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
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
                                ValueListenableBuilder(
                                    valueListenable: _selectedHK,
                                    builder: (context, selectedHKVal, child) {
                                      return DropdownButtonHideUnderline(
                                        child: DropdownButton2<String>(
                                          isExpanded: true,
                                          hint: Center(
                                            child: Text(
                                              'Chọn',
                                              style: DropdownStyle.hintStyle,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          items: dshk
                                              .map((String hk) =>
                                                  DropdownMenuItem<String>(
                                                    value: hk,
                                                    child: Text(
                                                      hk,
                                                      style: DropdownStyle
                                                          .itemStyle,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ))
                                              .toList(),
                                          value:
                                              _selectedHK.value != HocKy.empty
                                                  ? _selectedHK.value
                                                  : null,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedHK.value = value!;
                                            });
                                          },
                                          buttonStyleData:
                                              DropdownStyle.buttonStyleShort,
                                          iconStyleData:
                                              DropdownStyle.iconStyleData,
                                          dropdownStyleData:
                                              DropdownStyle.dropdownStyleShort,
                                          menuItemStyleData:
                                              DropdownStyle.menuItemStyleData,
                                        ),
                                      );
                                    }),
                              ],
                            ),
                            const SizedBox(width: 35),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
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
                                ValueListenableBuilder(
                                    valueListenable: _selectedNH,
                                    builder: (context, selectedNHVal, child) {
                                      return DropdownButtonHideUnderline(
                                        child: DropdownButton2<NamHoc>(
                                          isExpanded: true,
                                          hint: Center(
                                            child: Text(
                                              "Chọn",
                                              style: DropdownStyle.hintStyle,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          items: dsnh
                                              .map((NamHoc nh) =>
                                                  DropdownMenuItem<NamHoc>(
                                                    value: nh,
                                                    child: Text(
                                                      "${nh.start} - ${nh.end}",
                                                      style: DropdownStyle
                                                          .itemStyle,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ))
                                              .toList(),
                                          value:
                                              _selectedNH.value != NamHoc.empty
                                                  ? _selectedNH.value
                                                  : null,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedNH.value = value!;
                                            });
                                          },
                                          buttonStyleData:
                                              DropdownStyle.buttonStyleMedium,
                                          iconStyleData:
                                              DropdownStyle.iconStyleData,
                                          dropdownStyleData:
                                              DropdownStyle.dropdownStyleMedium,
                                          menuItemStyleData:
                                              DropdownStyle.menuItemStyleData,
                                        ),
                                      );
                                    }),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        lineDetail(
                            title: 'Thời gian đăng ký học phần',
                            ctrl1: regisStartCtrl,
                            ctrl2: regisEndCtrl),
                        const SizedBox(height: 10),
                        lineDetail(
                            title: 'Thời gian thực tập',
                            ctrl1: traineeStartCtrl,
                            ctrl2: traineeEndCtrl),
                        const SizedBox(height: 10),
                        lineDetail(
                            title: 'Thời gian nộp tài liệu',
                            ctrl1: submitEndCtrl),
                        const SizedBox(height: 10),
                        lineDetail(
                            title: 'Thời gian khóa điểm của cán bộ hướng dẫn',
                            ctrl1: pointCBEndCtrl),
                        const SizedBox(height: 10),
                        lineDetail(
                            title: 'Thời gian khóa điểm của giảng viên',
                            ctrl1: pointCVEndCtrl),
                        const SizedBox(height: 10),
                        lineDetail(
                            title: 'Thời gian khóa điểm',
                            ctrl1: isClockPointCtrl),
                      ],
                    ),
                  ),
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      isCreate
                          ? ElevatedButton(
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  if (_selectedHK.value != HocKy.empty &&
                                      _selectedNH.value != NamHoc.empty) {
                                    final docId = GV.generateRandomString(20);
                                    final isExist = await firestore
                                        .collection('settingTrainees')
                                        .where('term',
                                            isEqualTo: _selectedHK.value)
                                        .where('yearStart',
                                            isEqualTo: _selectedNH.value.start)
                                        .get();
                                    if (isExist.docs.isEmpty) {
                                      const duration = Duration(
                                          hours: 23, minutes: 59, seconds: 59);
                                      final setting = SettingTraineeModel(
                                        settingId: docId,
                                        term: _selectedHK.value,
                                        yearStart: _selectedNH.value.start,
                                        yearEnd: _selectedNH.value.end,
                                        regisStart: Timestamp.fromDate(
                                            DateFormat('dd/MM/yyyy')
                                                .parse(regisStartCtrl.text)),
                                        regisEnd: Timestamp.fromDate(
                                          DateFormat('dd/MM/yyyy')
                                              .parse(regisEndCtrl.text)
                                              .add(duration),
                                        ),
                                        traineeStart: Timestamp.fromDate(
                                            DateFormat('dd/MM/yyyy')
                                                .parse(traineeStartCtrl.text)),
                                        traineeEnd: Timestamp.fromDate(
                                            DateFormat('dd/MM/yyyy')
                                                .parse(traineeEndCtrl.text)
                                                .add(duration)),
                                        submitEnd: Timestamp.fromDate(
                                            DateFormat('dd/MM/yyyy')
                                                .parse(submitEndCtrl.text)
                                                .add(duration)),
                                        pointCBEnd: Timestamp.fromDate(
                                            DateFormat('dd/MM/yyyy')
                                                .parse(pointCBEndCtrl.text)
                                                .add(duration)),
                                        pointCVEnd: Timestamp.fromDate(
                                            DateFormat('dd/MM/yyyy')
                                                .parse(pointCVEndCtrl.text)
                                                .add(duration)),
                                        isClockPoint: Timestamp.fromDate(
                                            DateFormat('dd/MM/yyyy')
                                                .parse(isClockPointCtrl.text)
                                                .add(duration)),
                                      );
                                      firestore
                                          .collection('settingTrainees')
                                          .doc(docId)
                                          .set(setting.toMap());

                                      final updateTimeTrainee = await firestore
                                          .collection('trainees')
                                          .where('term',
                                              isEqualTo: _selectedHK.value)
                                          .where('yearStart',
                                              isEqualTo:
                                                  _selectedNH.value.start)
                                          .where('yearEnd',
                                              isEqualTo: _selectedNH.value.end)
                                          .get();

                                      if (updateTimeTrainee.docs.isNotEmpty) {
                                        List<RegisterTraineeModel>
                                            traineeUpdates = [];
                                        updateTimeTrainee.docs.forEach(
                                            (element) => traineeUpdates.add(
                                                RegisterTraineeModel.fromMap(
                                                    element.data())));

                                        traineeUpdates.forEach((element) {
                                          element.traineeStart =
                                              setting.traineeStart;
                                          element.traineeEnd =
                                              setting.traineeEnd;
                                        });
                                        if (traineeUpdates.isNotEmpty) {
                                          traineeUpdates.forEach((element) {
                                            firestore
                                                .collection('trainees')
                                                .doc(element.userId)
                                                .update({
                                              'traineeStart':
                                                  element.traineeStart,
                                              'traineeEnd': element.traineeEnd,
                                            });
                                          });
                                        }
                                      }
                                      Navigator.of(context).pop();
                                      GV.success(
                                          context: context,
                                          message: 'Đã thêm thành công.');
                                    } else {
                                      GV.error(
                                          context: context,
                                          message:
                                              'Đã thiết lập thời gian cho học kỳ này.');
                                    }
                                  } else {
                                    GV.error(
                                        context: context,
                                        message: 'Cần chọn khóa và ngành.');
                                  }
                                }
                              },
                              style: const ButtonStyle(
                                  elevation: MaterialStatePropertyAll(5)),
                              child: const Text('Thêm',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            )
                          : ElevatedButton(
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  const duration = Duration(
                                      hours: 23, minutes: 59, seconds: 59);
                                  final setting = SettingTraineeModel(
                                    settingId: settingTrainee!.settingId!,
                                    term: _selectedHK.value,
                                    yearStart: _selectedNH.value.start,
                                    yearEnd: _selectedNH.value.end,
                                    regisStart: Timestamp.fromDate(
                                        DateFormat('dd/MM/yyyy')
                                            .parse(regisStartCtrl.text)),
                                    regisEnd: Timestamp.fromDate(
                                      DateFormat('dd/MM/yyyy')
                                          .parse(regisEndCtrl.text)
                                          .add(duration),
                                    ),
                                    traineeStart: Timestamp.fromDate(
                                        DateFormat('dd/MM/yyyy')
                                            .parse(traineeStartCtrl.text)),
                                    traineeEnd: Timestamp.fromDate(
                                        DateFormat('dd/MM/yyyy')
                                            .parse(traineeEndCtrl.text)
                                            .add(duration)),
                                    submitEnd: Timestamp.fromDate(
                                        DateFormat('dd/MM/yyyy')
                                            .parse(submitEndCtrl.text)
                                            .add(duration)),
                                    pointCBEnd: Timestamp.fromDate(
                                        DateFormat('dd/MM/yyyy')
                                            .parse(pointCBEndCtrl.text)
                                            .add(duration)),
                                    pointCVEnd: Timestamp.fromDate(
                                        DateFormat('dd/MM/yyyy')
                                            .parse(pointCVEndCtrl.text)
                                            .add(duration)),
                                    isClockPoint: Timestamp.fromDate(
                                        DateFormat('dd/MM/yyyy')
                                            .parse(isClockPointCtrl.text)
                                            .add(duration)),
                                  );
                                  firestore
                                      .collection('settingTrainees')
                                      .doc(setting.settingId)
                                      .set(setting.toMap());
                                  final updateTimeTrainee = await firestore
                                      .collection('trainees')
                                      .where('term',
                                          isEqualTo: _selectedHK.value)
                                      .where('yearStart',
                                          isEqualTo: _selectedNH.value.start)
                                      .where('yearEnd',
                                          isEqualTo: _selectedNH.value.end)
                                      .get();
                                  if (updateTimeTrainee.docs.isNotEmpty) {
                                    List<RegisterTraineeModel> traineeUpdates =
                                        [];
                                    updateTimeTrainee.docs.forEach((element) =>
                                        traineeUpdates.add(
                                            RegisterTraineeModel.fromMap(
                                                element.data())));

                                    traineeUpdates.forEach((element) {
                                      element.traineeStart =
                                          setting.traineeStart;
                                      element.traineeEnd = setting.traineeEnd;
                                    });
                                    if (traineeUpdates.isNotEmpty) {
                                      traineeUpdates.forEach((element) {
                                        firestore
                                            .collection('trainees')
                                            .doc(element.userId)
                                            .update({
                                          'traineeStart': element.traineeStart,
                                          'traineeEnd': element.traineeEnd,
                                        });
                                      });
                                    }
                                  }
                                  Navigator.of(context).pop();
                                  GV.success(
                                      context: context,
                                      message: 'Đã thêm thành công.');
                                }
                              },
                              style: const ButtonStyle(
                                  elevation: MaterialStatePropertyAll(5)),
                              child: const Text('Cập nhật',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                    ],
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget lineDetail(
      {required String title,
      required TextEditingController ctrl1,
      TextEditingController? ctrl2}) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        ctrl2 != null
            ? Padding(
                padding: const EdgeInsets.only(top: 5, left: 35),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: screenWidth * 0.1,
                      child: TextFormField(
                        controller: ctrl1,
                        validator: (value) => value!.isNotEmpty
                            ? value.length < 10
                                ? "Sai định dạng"
                                : null
                            : 'Không được để trống',
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp("[0-9/]")),
                          LengthLimitingTextInputFormatter(10),
                          DateFormatter(),
                        ],
                        decoration: const InputDecoration(
                          hintText: 'DD/MM/YYYY',
                          isDense: true,
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 25),
                    SizedBox(
                      width: screenWidth * 0.1,
                      child: TextFormField(
                        controller: ctrl2,
                        validator: (value) => value!.isNotEmpty
                            ? value.length < 10
                                ? "Sai định dạng"
                                : null
                            : 'Không được để trống',
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp("[0-9/]")),
                          LengthLimitingTextInputFormatter(10),
                          DateFormatter(),
                        ],
                        decoration: const InputDecoration(
                          hintText: 'DD/MM/YYYY',
                          isDense: true,
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(top: 5, left: 35),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: screenWidth * 0.15,
                      child: TextFormField(
                        controller: ctrl1,
                        validator: (value) => value!.isNotEmpty
                            ? value.length < 10
                                ? "Sai định dạng"
                                : null
                            : 'Không được để trống',
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp("[0-9/]")),
                          LengthLimitingTextInputFormatter(10),
                          DateFormatter(),
                        ],
                        decoration: const InputDecoration(
                          hintText: 'DD/MM/YYYY',
                          isDense: true,
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ],
    );
  }

  deleteSetting({
    required BuildContext context,
    required String settingId,
  }) async {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    showDialog(
        context: context,
        barrierColor: Colors.black12,
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
                  title: Container(
                    color: Colors.blue.shade600,
                    height: 50,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Xóa thiết lập thời gian',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  titlePadding: EdgeInsets.zero,
                  shape: Border.all(width: 0.5),
                  content:
                      const Text("Bạn có chắc chắn muốn xóa thiết lập này?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "Hủy",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        firestore
                            .collection('settingTrainees')
                            .doc(settingId)
                            .delete();
                        Navigator.of(context).pop();
                        GV.success(
                            context: context, message: 'Đã xóa thiết lập.');
                      },
                      child: const Text(
                        "Đồng ý",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}
