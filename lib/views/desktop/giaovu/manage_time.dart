// ignore_for_file: use_build_context_synchronously

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tttt_project/data/constant.dart';
import 'package:tttt_project/models/plan_trainee_model.dart'; 
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/widgets/custom_button.dart';
import 'package:tttt_project/widgets/date_inputformatter.dart';
import 'package:tttt_project/widgets/dropdown_style.dart';
import 'package:tttt_project/widgets/footer.dart';
import 'package:tttt_project/widgets/header.dart';
import 'package:tttt_project/widgets/line_detail.dart';
import 'package:tttt_project/widgets/loading.dart';
import 'package:tttt_project/widgets/user_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/widgets/menu/menu_left.dart';

class ManageTimeScreen extends StatefulWidget {
  const ManageTimeScreen({Key? key}) : super(key: key);

  @override
  State<ManageTimeScreen> createState() => _ManageTimeScreenState();
}

class _ManageTimeScreenState extends State<ManageTimeScreen> {
  final firestore = FirebaseFirestore.instance;
  final currentUser = Get.put(UserController());
  final GlobalKey<FormState> planTraineeFormKey = GlobalKey<FormState>();
  String selectedHK = HocKy.empty;
  NamHoc selectedNH = NamHoc.empty;
  ValueNotifier<bool> isLook = ValueNotifier<bool>(false);
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController noticeCtrl = TextEditingController();
  ValueNotifier<String> _selectedHK = ValueNotifier('');
  ValueNotifier<NamHoc> _selectedNH = ValueNotifier(NamHoc.empty);
  final ValueNotifier totalContent = ValueNotifier(0);
  List<TextEditingController> contents = [];
  List<TextEditingController> timeNotes = [];
  List<TextEditingController> dayStart = [];
  List<TextEditingController> dayEnd = [];

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  getUserData() async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    bool? isLoggedIn = sharedPref.getBool("isLoggedIn");
    String? userId = sharedPref
        .getString(
          'userId',
        )
        .toString();
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
                      child: Column(
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
                                  "Quản lý các kế hoạch thực tập",
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                            style: DropdownStyle.hintStyle,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        items: dshkAll
                                            .map((String hk) =>
                                                DropdownMenuItem<String>(
                                                  value: hk,
                                                  child: Text(
                                                    hk,
                                                    style:
                                                        DropdownStyle.itemStyle,
                                                    overflow:
                                                        TextOverflow.ellipsis,
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
                                          currentUser.isCompleted.value = false;
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
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 35),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                            style: DropdownStyle.hintStyle,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        items: dsnhAll
                                            .map((NamHoc nh) =>
                                                DropdownMenuItem<NamHoc>(
                                                  value: nh,
                                                  child: Text(
                                                    nh.start == nh.end
                                                        ? nh.start
                                                        : "${nh.start} - ${nh.end}",
                                                    style:
                                                        DropdownStyle.itemStyle,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ))
                                            .toList(),
                                        value: selectedNH != NamHoc.empty
                                            ? selectedNH
                                            : null,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedNH = value!;
                                          });
                                          currentUser.isCompleted.value = false;
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
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 55),
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
                                const SizedBox(width: 25),
                                CustomButton(
                                  width: screenWidth * 0.07,
                                  height: screenHeight * 0.06,
                                  text: 'Tạo kế hoạch',
                                  onTap: () async {
                                    await editPlanTrainee(
                                        context: context, isCreate: true);
                                  },
                                )
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
                                        flex: 5,
                                        child: Text(
                                          'Nội dung',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Ngày tạo',
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
                                  child:
                                      isLook.value &&
                                              currentUser.isCompleted.isTrue
                                          ? StreamBuilder(
                                              stream: firestore
                                                  .collection('planTrainees')
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                List<PlanTraineeModel>
                                                    loadPlanTrainee = [];
                                                List<PlanTraineeModel> dskh =
                                                    [];
                                                if (snapshot.hasData &&
                                                    snapshot.connectionState ==
                                                        ConnectionState
                                                            .active) {
                                                  snapshot.data?.docs
                                                      .forEach((element) {
                                                    loadPlanTrainee.add(
                                                        PlanTraineeModel
                                                            .fromMap(element
                                                                .data()));
                                                  });
                                                  if (selectedHK ==
                                                          HocKy.tatca &&
                                                      selectedNH ==
                                                          NamHoc.tatca) {
                                                    loadPlanTrainee
                                                        .forEach((e) {
                                                      dskh.add(e);
                                                    });
                                                  } else if (selectedHK ==
                                                      HocKy.tatca) {
                                                    loadPlanTrainee
                                                        .forEach((e) {
                                                      if (e.yearStart ==
                                                          selectedNH.start) {
                                                        dskh.add(e);
                                                      }
                                                    });
                                                  } else if (selectedNH ==
                                                      NamHoc.tatca) {
                                                    loadPlanTrainee
                                                        .forEach((e) {
                                                      if (e.term ==
                                                          selectedHK) {
                                                        dskh.add(e);
                                                      }
                                                    });
                                                  } else {
                                                    loadPlanTrainee
                                                        .forEach((e) {
                                                      if (e.term ==
                                                              selectedHK &&
                                                          e.yearStart ==
                                                              selectedNH
                                                                  .start) {
                                                        dskh.add(e);
                                                      }
                                                    });
                                                  }
                                                  dskh.sort(
                                                    (a, b) => a.createdAt!
                                                        .compareTo(
                                                            b.createdAt!),
                                                  );
                                                  return dskh.isNotEmpty
                                                      ? ListView.builder(
                                                          itemCount:
                                                              dskh.length,
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
                                                                    flex: 5,
                                                                    child: Text(
                                                                        dskh[index]
                                                                            .title!,
                                                                        textAlign:
                                                                            TextAlign.justify),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 2,
                                                                    child: Text(
                                                                        GV.readTimestamp(dskh[index]
                                                                            .createdAt!),
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
                                                                              'Chỉnh sửa kế hoạch',
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              bottom: 1),
                                                                          onPressed:
                                                                              () async {
                                                                            await editPlanTrainee(
                                                                              context: context,
                                                                              planTrainee: dskh[index],
                                                                              isCreate: false,
                                                                            );
                                                                          },
                                                                          icon:
                                                                              Icon(
                                                                            Icons.edit_document,
                                                                            color:
                                                                                Colors.blue.shade900,
                                                                            size:
                                                                                20,
                                                                          ),
                                                                        ),
                                                                        IconButton(
                                                                          tooltip:
                                                                              'Xóa kế hoạch',
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              bottom: 1),
                                                                          onPressed:
                                                                              () async {
                                                                            await deletePlanTrainee(
                                                                              context: context,
                                                                              planTrainee: dskh[index],
                                                                            );
                                                                          },
                                                                          icon:
                                                                              const Icon(
                                                                            Icons.delete_rounded,
                                                                            color:
                                                                                Colors.red,
                                                                            size:
                                                                                20,
                                                                          ),
                                                                        ),
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
                                                              'Chưa có sinh viên đăng ký.'),
                                                        );
                                                } else {
                                                  return const Center(
                                                      child: Loading());
                                                }
                                              },
                                            )
                                          : selectedHK == HocKy.empty &&
                                                  selectedNH == NamHoc.empty
                                              ? StreamBuilder(
                                                  stream: firestore
                                                      .collection(
                                                          'planTrainees')
                                                      .snapshots(),
                                                  builder: (context, snapshot) {
                                                    List<PlanTraineeModel>
                                                        dskh = [];
                                                    if (snapshot.hasData &&
                                                        snapshot.connectionState ==
                                                            ConnectionState
                                                                .active) {
                                                      snapshot.data?.docs
                                                          .forEach((element) {
                                                        dskh.add(
                                                            PlanTraineeModel
                                                                .fromMap(element
                                                                    .data()));
                                                      });
                                                      dskh.sort(
                                                        (a, b) => a.createdAt!
                                                            .compareTo(
                                                                b.createdAt!),
                                                      );
                                                      return dskh.isNotEmpty
                                                          ? ListView.builder(
                                                              itemCount:
                                                                  dskh.length,
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
                                                                        flex: 5,
                                                                        child: Text(
                                                                            dskh[index]
                                                                                .title!,
                                                                            textAlign:
                                                                                TextAlign.justify),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 2,
                                                                        child: Text(
                                                                            GV.readTimestamp(dskh[index]
                                                                                .createdAt!),
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
                                                                              tooltip: 'Chỉnh sửa kế hoạch',
                                                                              padding: const EdgeInsets.only(bottom: 1),
                                                                              onPressed: () async {
                                                                                await editPlanTrainee(
                                                                                  context: context,
                                                                                  planTrainee: dskh[index],
                                                                                  isCreate: false,
                                                                                );
                                                                              },
                                                                              icon: Icon(
                                                                                Icons.edit_document,
                                                                                color: Colors.blue.shade900,
                                                                                size: 20,
                                                                              ),
                                                                            ),
                                                                            IconButton(
                                                                              tooltip: 'Xóa kế hoạch',
                                                                              padding: const EdgeInsets.only(bottom: 1),
                                                                              onPressed: () async {
                                                                                await deletePlanTrainee(
                                                                                  context: context,
                                                                                  planTrainee: dskh[index],
                                                                                );
                                                                              },
                                                                              icon: const Icon(
                                                                                Icons.delete_rounded,
                                                                                color: Colors.red,
                                                                                size: 20,
                                                                              ),
                                                                            ),
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
                                                                  'Chưa có kế hoạch nào trong khoản thời gian bạn chọn.'),
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
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomButton(
                                text: 'Thiết lập thời gian thực tập',
                                width: screenWidth * 0.07,
                                height: screenHeight * 0.06,
                                onTap: () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 35),
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

  showSetTime({
    required BuildContext context,
    required String creditId,
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
                          'Thiết lập thời gian thực tập',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  titlePadding: EdgeInsets.zero,
                  shape: Border.all(width: 0.5),
                  content:
                      const Text("Bạn có chắc chắn muốn xóa kế hoạch này?"),
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
                            .collection('planTrainees')
                            .doc(creditId)
                            .delete();
                        Navigator.of(context).pop();
                        GV.success(
                            context: context, message: 'Đã xóa kế hoạch.');
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

  editPlanTrainee({
    required BuildContext context,
    PlanTraineeModel? planTrainee,
    required bool isCreate,
  }) async {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    if (isCreate) {
      _selectedHK.value = '';
      _selectedNH.value = NamHoc.empty;
      titleCtrl.text = '';
      noticeCtrl.text = '';
      contents = [];
      timeNotes = [];
      dayStart = [];
      dayEnd = [];
      contentsPlan.forEach((element) {
        contents.add(TextEditingController(text: element));
        timeNotes.add(TextEditingController());
        dayStart.add(TextEditingController());
        dayEnd.add(TextEditingController());
      });
      totalContent.value = contentsPlan.length;
    } else if (planTrainee != null) {
      dsnh.forEach((element) {
        if (element.start == planTrainee.yearStart &&
            element.end == planTrainee.yearEnd) {
          _selectedNH.value = element;
        }
      });
      _selectedHK.value = planTrainee.term!;
      titleCtrl.text = planTrainee.title!;
      noticeCtrl.text = planTrainee.notice!;
      contents = [];
      timeNotes = [];
      dayStart = [];
      dayEnd = [];
      if (planTrainee.listContent != null) {
        planTrainee.listContent!.forEach((element) {
          contents.add(TextEditingController(
              text: element.content == "" ? null : element.content));
          timeNotes.add(TextEditingController(
              text: element.note == "" ? null : element.note));
          dayStart.add(TextEditingController(
              text: element.dayStart == null
                  ? null
                  : GV.readTimestamp(element.dayStart!)));
          dayEnd.add(TextEditingController(
              text: element.dayEnd == null
                  ? null
                  : GV.readTimestamp(element.dayEnd!)));
        });
        totalContent.value = planTrainee.listContent!.length;
      }
    }
    showDialog(
        context: context,
        barrierColor: Colors.black12,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              top: screenHeight * 0.06,
              bottom: screenHeight * 0.02,
              left: screenWidth * 0.25,
              right: screenWidth * 0.06,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AlertDialog(
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
                          child: Text('Chi tiết kế hoạch',
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
                  contentPadding: EdgeInsets.zero,
                  shape: Border.all(width: 0.5),
                  content: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Container(
                      constraints: BoxConstraints(minWidth: screenWidth * 0.6),
                      padding: const EdgeInsets.only(
                          top: 15, bottom: 15, left: 20, right: 20),
                      child: Form(
                        key: planTraineeFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                        builder:
                                            (context, selectedHKVal, child) {
                                          return DropdownButtonHideUnderline(
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
                                              items: dshk
                                                  .map((String hk) =>
                                                      DropdownMenuItem<String>(
                                                        value: hk,
                                                        child: Text(
                                                          hk,
                                                          style: DropdownStyle
                                                              .itemStyle,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ))
                                                  .toList(),
                                              value:
                                                  _selectedHK.value.isNotEmpty
                                                      ? _selectedHK.value
                                                      : null,
                                              onChanged: (value) {
                                                setState(() {
                                                  _selectedHK.value = value!;
                                                });
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
                                        builder:
                                            (context, selectedNHVal, child) {
                                          return DropdownButtonHideUnderline(
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
                                              items: dsnh
                                                  .map((NamHoc nh) =>
                                                      DropdownMenuItem<NamHoc>(
                                                        value: nh,
                                                        child: Text(
                                                          "${nh.start} - ${nh.end}",
                                                          style: DropdownStyle
                                                              .itemStyle,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ))
                                                  .toList(),
                                              value: _selectedNH.value.start
                                                          .isNotEmpty &&
                                                      _selectedNH
                                                          .value.end.isNotEmpty
                                                  ? _selectedNH.value
                                                  : null,
                                              onChanged: (value) {
                                                setState(() {
                                                  _selectedNH.value = value!;
                                                });
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
                                          );
                                        }),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            LineDetail(
                              field: 'Tiêu Đề',
                              ctrl: titleCtrl,
                              widthForm: 0.35,
                              validator: (p0) =>
                                  p0!.isEmpty ? 'Không được để trống.' : null,
                            ),
                            ValueListenableBuilder(
                                valueListenable: totalContent,
                                builder: (context, val, child) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 15),
                                    child: Table(
                                      border: TableBorder.all(),
                                      columnWidths: Map.from({
                                        0: const FlexColumnWidth(6),
                                        1: const FlexColumnWidth(3),
                                        2: const FlexColumnWidth(1)
                                      }),
                                      children: [
                                        TableRow(
                                          children: [
                                            Container(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: const Text(
                                                  'Nội Dung',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )),
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              child: const Text(
                                                'Thời Gian',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox.shrink(),
                                          ],
                                        ),
                                        for (var i = 0;
                                            i < totalContent.value;
                                            i++)
                                          TableRow(
                                            children: [
                                              TableCell(
                                                verticalAlignment:
                                                    TableCellVerticalAlignment
                                                        .middle,
                                                child: TextFormField(
                                                  controller: contents[i],
                                                  minLines: 1,
                                                  maxLines: 10,
                                                  style: const TextStyle(
                                                      fontSize: 15),
                                                  decoration:
                                                      const InputDecoration(
                                                    border: OutlineInputBorder(
                                                      borderSide:
                                                          BorderSide.none,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              TableCell(
                                                verticalAlignment:
                                                    TableCellVerticalAlignment
                                                        .middle,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Column(
                                                    children: [
                                                      TextFormField(
                                                        controller:
                                                            timeNotes[i],
                                                        minLines: 1,
                                                        maxLines: 10,
                                                        decoration:
                                                            const InputDecoration(
                                                          hintText:
                                                              'Ghi chú (nếu có)',
                                                          isDense: true,
                                                          contentPadding:
                                                              EdgeInsets.all(5),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(
                                                              Radius.circular(
                                                                  5),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          Expanded(
                                                            flex: 5,
                                                            child:
                                                                TextFormField(
                                                              controller:
                                                                  dayStart[i],
                                                              decoration:
                                                                  const InputDecoration(
                                                                hintText:
                                                                    'DD/MM/YYYY',
                                                                isDense: true,
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .all(5),
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .all(
                                                                    Radius
                                                                        .circular(
                                                                            5),
                                                                  ),
                                                                ),
                                                              ),
                                                              validator: (value) =>
                                                                  value!.isNotEmpty &&
                                                                          value.length <
                                                                              10
                                                                      ? "Sai định dạng"
                                                                      : null,
                                                              inputFormatters: [
                                                                FilteringTextInputFormatter
                                                                    .allow(RegExp(
                                                                        "[0-9/]")),
                                                                LengthLimitingTextInputFormatter(
                                                                    10),
                                                                DateFormatter(),
                                                              ],
                                                            ),
                                                          ),
                                                          const Expanded(
                                                              child: Center(
                                                                  child: Text(
                                                                      '-'))),
                                                          Expanded(
                                                            flex: 5,
                                                            child:
                                                                TextFormField(
                                                              controller:
                                                                  dayEnd[i],
                                                              decoration:
                                                                  const InputDecoration(
                                                                hintText:
                                                                    'DD/MM/YYYY',
                                                                isDense: true,
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .all(5),
                                                                border:
                                                                    OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .all(
                                                                    Radius
                                                                        .circular(
                                                                            5),
                                                                  ),
                                                                ),
                                                              ),
                                                              validator: (value) =>
                                                                  value!.isNotEmpty &&
                                                                          value.length <
                                                                              10
                                                                      ? "Sai định dạng"
                                                                      : null,
                                                              inputFormatters: [
                                                                FilteringTextInputFormatter
                                                                    .allow(RegExp(
                                                                        "[0-9/]")),
                                                                LengthLimitingTextInputFormatter(
                                                                    10),
                                                                DateFormatter(),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              TableCell(
                                                  verticalAlignment:
                                                      TableCellVerticalAlignment
                                                          .middle,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      IconButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            contents
                                                                .removeAt(i);
                                                            timeNotes
                                                                .removeAt(i);
                                                            dayStart
                                                                .removeAt(i);
                                                            dayEnd.removeAt(i);
                                                            totalContent
                                                                .value--;
                                                          });
                                                        },
                                                        icon: const Icon(
                                                          Icons.remove_circle,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                      IconButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            contents.insertAll(
                                                                i + 1, [
                                                              TextEditingController()
                                                            ]);
                                                            timeNotes.insertAll(
                                                                i + 1, [
                                                              TextEditingController()
                                                            ]);
                                                            dayStart.insertAll(
                                                                i + 1, [
                                                              TextEditingController()
                                                            ]);
                                                            dayEnd.insertAll(
                                                                i + 1, [
                                                              TextEditingController()
                                                            ]);
                                                            totalContent
                                                                .value++;
                                                          });
                                                        },
                                                        icon: const Icon(
                                                          Icons.add_circle,
                                                          color: Colors.green,
                                                        ),
                                                      )
                                                    ],
                                                  ))
                                            ],
                                          ),
                                      ],
                                    ),
                                  );
                                }),
                            const SizedBox(height: 15),
                            LineDetail(
                              field: 'Ghi chú',
                              ctrl: noticeCtrl,
                              widthForm: 0.25,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  actionsPadding: const EdgeInsets.only(top: 15, bottom: 25),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        isCreate
                            ? ElevatedButton(
                                onPressed: () async {
                                  if (_selectedHK.value.isEmpty ||
                                      _selectedNH.value.start.isEmpty) {
                                    GV.error(
                                        context: context,
                                        message:
                                            'Vui lòng chọn học kỳ và năm học.');
                                  } else if (planTraineeFormKey.currentState!
                                      .validate()) {
                                    List<ContentModel> listContent = [];
                                    for (var i = 0; i < contents.length; i++) {
                                      listContent.add(ContentModel(
                                        content: contents[i].text,
                                        note: timeNotes[i].text,
                                        dayStart: dayStart[i].text.isNotEmpty
                                            ? Timestamp.fromDate(
                                                DateFormat('dd/MM/yyyy')
                                                    .parse(dayStart[i].text))
                                            : null,
                                        dayEnd: dayEnd[i].text.isNotEmpty
                                            ? Timestamp.fromDate(
                                                DateFormat('dd/MM/yyyy')
                                                    .parse(dayEnd[i].text))
                                            : null,
                                      ));
                                    }
                                    var docId = GV.generateRandomString(20);
                                    final planTrainee = PlanTraineeModel(
                                      planTraineeId: docId,
                                      title: titleCtrl.text,
                                      term: _selectedHK.value,
                                      yearStart: _selectedNH.value.start,
                                      yearEnd: _selectedNH.value.end,
                                      createdAt: Timestamp.now(),
                                      listContent: listContent,
                                      notice: noticeCtrl.text,
                                    );
                                    firestore
                                        .collection('planTrainees')
                                        .doc(docId)
                                        .set(planTrainee.toMap());
                                    Navigator.of(context).pop();
                                    GV.success(
                                        context: context,
                                        message: 'Đã thêm thành công.');
                                  }
                                },
                                child: const Text("Thêm thông báo"),
                              )
                            : ElevatedButton(
                                onPressed: () async {
                                  if (planTraineeFormKey.currentState!
                                      .validate()) {
                                    List<ContentModel> listContent = [];
                                    for (var i = 0; i < contents.length; i++) {
                                      listContent.add(ContentModel(
                                        content: contents[i].text,
                                        note: timeNotes[i].text,
                                        dayStart: dayStart[i].text.isNotEmpty
                                            ? Timestamp.fromDate(
                                                DateFormat('dd/MM/yyyy')
                                                    .parse(dayStart[i].text))
                                            : null,
                                        dayEnd: dayEnd[i].text.isNotEmpty
                                            ? Timestamp.fromDate(
                                                DateFormat('dd/MM/yyyy')
                                                    .parse(dayEnd[i].text))
                                            : null,
                                      ));
                                    }
                                    final planTraineeModel = PlanTraineeModel(
                                      planTraineeId:
                                          planTrainee!.planTraineeId!,
                                      title: titleCtrl.text,
                                      term: _selectedHK.value,
                                      yearStart: _selectedNH.value.start,
                                      yearEnd: _selectedNH.value.end,
                                      listContent: listContent,
                                      notice: noticeCtrl.text,
                                      createdAt: planTrainee.createdAt,
                                    );
                                    firestore
                                        .collection('planTrainees')
                                        .doc(planTrainee.planTraineeId!)
                                        .update(planTraineeModel.toMap());
                                    Navigator.of(context).pop();
                                    GV.success(
                                        context: context,
                                        message: 'Cập nhật thành công.');
                                  }
                                },
                                child: const Text("Cập nhật"))
                      ],
                    )
                  ],
                ),
              ],
            ),
          );
        });
  }

  deletePlanTrainee({
    required BuildContext context,
    required PlanTraineeModel planTrainee,
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
                          'Xóa Kế Hoạch',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  titlePadding: EdgeInsets.zero,
                  shape: Border.all(width: 0.5),
                  content:
                      const Text("Bạn có chắc chắn muốn xóa kế hoạch này?"),
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
                      onPressed: () async {
                        if (planTrainee.planTraineeId != null) {
                          firestore
                              .collection('planTrainees')
                              .doc(planTrainee.planTraineeId!)
                              .delete();
                          Navigator.of(context).pop();
                          GV.success(
                              context: context, message: 'Đã xóa kế hoạch.');
                        }
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
