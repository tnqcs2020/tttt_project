// ignore_for_file: use_build_context_synchronously

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tttt_project/models/credit_model.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/widgets/custom_button.dart';
import 'package:tttt_project/widgets/dropdown_style.dart';
import 'package:tttt_project/widgets/header.dart';
import 'package:tttt_project/widgets/line_detail.dart';
import 'package:tttt_project/widgets/loading.dart';
import 'package:tttt_project/common/user_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/common/constant.dart';
import 'package:tttt_project/widgets/footer.dart';
import 'package:tttt_project/widgets/menu/menu_left.dart';

class ManageCreditScreen extends StatefulWidget {
  const ManageCreditScreen({Key? key}) : super(key: key);

  @override
  State<ManageCreditScreen> createState() => _ManageCreditScreenState();
}

class _ManageCreditScreenState extends State<ManageCreditScreen> {
  final firestore = FirebaseFirestore.instance;
  final currentUser = Get.put(UserController());
  String selectedMajor = '';
  String selectedCourse = '';
  ValueNotifier<bool> isLook = ValueNotifier<bool>(false);
  TextEditingController idCtrl = TextEditingController();
  TextEditingController nameCtrl = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
                                      "Quản lý học phần",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
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
                                          "Khóa",
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
                                                "Chọn",
                                                style: DropdownStyle.hintStyle,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            items: coursesAll
                                                .map((String course) =>
                                                    DropdownMenuItem<String>(
                                                      value: course,
                                                      child: Text(
                                                        course,
                                                        style: DropdownStyle
                                                            .itemStyle,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ))
                                                .toList(),
                                            value: selectedCourse != ''
                                                ? selectedCourse
                                                : null,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedCourse = value!;
                                              });
                                              currentUser.isCompleted.value =
                                                  false;
                                            },
                                            buttonStyleData:
                                                DropdownStyle.buttonStyleShort,
                                            iconStyleData:
                                                DropdownStyle.iconStyleData,
                                            dropdownStyleData: DropdownStyle
                                                .dropdownStyleShort,
                                            menuItemStyleData:
                                                DropdownStyle.menuItemStyleData,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 25),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Ngành",
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
                                                "Chọn",
                                                style: DropdownStyle.hintStyle,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            items: majorsAll
                                                .map((String major) =>
                                                    DropdownMenuItem<String>(
                                                      value: major,
                                                      child: Text(
                                                        major,
                                                        style: DropdownStyle
                                                            .itemStyle,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ))
                                                .toList(),
                                            value: selectedMajor != ''
                                                ? selectedMajor
                                                : null,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedMajor = value!;
                                              });
                                              currentUser.isCompleted.value =
                                                  false;
                                            },
                                            buttonStyleData:
                                                DropdownStyle.buttonStyleLong,
                                            iconStyleData:
                                                DropdownStyle.iconStyleData,
                                            dropdownStyleData:
                                                DropdownStyle.dropdownStyleLong,
                                            menuItemStyleData:
                                                DropdownStyle.menuItemStyleData,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 45),
                                    CustomButton(
                                      text: "Xem",
                                      width: screenWidth * 0.07,
                                      height: screenHeight * 0.06,
                                      onTap: () {
                                        if (selectedCourse.isNotEmpty &&
                                            selectedMajor.isNotEmpty) {
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
                                      text: 'Thêm học phần',
                                      onTap: () async {
                                        await addAndEditCredit(isCreate: true);
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
                                              'Mã học phần',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              'Tên học phần',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              'Ngành',
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
                                                      .collection('credits')
                                                      .snapshots(),
                                                  builder: (context, snapshot) {
                                                    List<CreditModel>
                                                        loadCredit = [];
                                                    List<CreditModel>
                                                        listCredit = [];
                                                    if (snapshot.hasData &&
                                                        snapshot.connectionState ==
                                                            ConnectionState
                                                                .active) {
                                                      snapshot.data?.docs
                                                          .forEach((element) {
                                                        loadCredit.add(
                                                            CreditModel.fromMap(
                                                                element
                                                                    .data()));
                                                      });
                                                      if (selectedCourse ==
                                                              'Tất cả' &&
                                                          selectedMajor ==
                                                              'Tất cả') {
                                                        loadCredit
                                                            .forEach((element) {
                                                          listCredit
                                                              .add(element);
                                                        });
                                                      } else if (selectedCourse ==
                                                          'Tất cả') {
                                                        loadCredit
                                                            .forEach((element) {
                                                          if (element.major ==
                                                              selectedMajor) {
                                                            listCredit
                                                                .add(element);
                                                          }
                                                        });
                                                      } else if (selectedMajor ==
                                                          'Tất cả') {
                                                        loadCredit
                                                            .forEach((element) {
                                                          if (element.course ==
                                                              selectedCourse) {
                                                            listCredit
                                                                .add(element);
                                                          }
                                                        });
                                                      }
                                                      listCredit.sort(
                                                        (a, b) => a.creditId
                                                            .compareTo(
                                                                b.creditId),
                                                      );
                                                      return listCredit
                                                              .isNotEmpty
                                                          ? ListView.builder(
                                                              itemCount:
                                                                  listCredit
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
                                                                            listCredit[index]
                                                                                .creditId
                                                                                .toUpperCase(),
                                                                            textAlign:
                                                                                TextAlign.justify),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 3,
                                                                        child: Text(
                                                                            listCredit[index]
                                                                                .creditName,
                                                                            textAlign:
                                                                                TextAlign.justify,
                                                                            overflow: TextOverflow.ellipsis),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 4,
                                                                        child: Text(
                                                                            listCredit[index]
                                                                                .major,
                                                                            textAlign:
                                                                                TextAlign.justify,
                                                                            overflow: TextOverflow.ellipsis),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 1,
                                                                        child: Text(
                                                                            listCredit[index]
                                                                                .course,
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
                                                                                tooltip: 'Cập nhật thông tin học phần',
                                                                                onPressed: () async {
                                                                                  await addAndEditCredit(credit: listCredit[index], isCreate: false);
                                                                                },
                                                                                padding: const EdgeInsets.only(bottom: 1),
                                                                                icon: Icon(
                                                                                  Icons.edit_square,
                                                                                  color: Colors.blue.shade900,
                                                                                )),
                                                                            IconButton(
                                                                                tooltip: 'Xóa học phần',
                                                                                onPressed: () {
                                                                                  deleteCredit(context: context, creditId: listCredit[index].creditId);
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
                                                                  'Chưa có học phần.'),
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
                                              : selectedCourse.isEmpty &&
                                                      selectedMajor.isEmpty
                                                  ? StreamBuilder(
                                                      stream: firestore
                                                          .collection('credits')
                                                          .snapshots(),
                                                      builder:
                                                          (context, snapshot) {
                                                        List<CreditModel>
                                                            listCredit = [];
                                                        if (snapshot.hasData &&
                                                            snapshot.connectionState ==
                                                                ConnectionState
                                                                    .active) {
                                                          snapshot.data?.docs
                                                              .forEach(
                                                                  (element) {
                                                            listCredit.add(
                                                                CreditModel.fromMap(
                                                                    element
                                                                        .data()));
                                                          });
                                                          listCredit.sort(
                                                            (a, b) => a.creditId
                                                                .compareTo(
                                                                    b.creditId),
                                                          );
                                                          return listCredit
                                                                  .isNotEmpty
                                                              ? ListView
                                                                  .builder(
                                                                  itemCount:
                                                                      listCredit
                                                                          .length,
                                                                  shrinkWrap:
                                                                      true,
                                                                  scrollDirection:
                                                                      Axis.vertical,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return Container(
                                                                      height:
                                                                          screenHeight *
                                                                              0.05,
                                                                      color: index % 2 ==
                                                                              0
                                                                          ? Colors
                                                                              .blue
                                                                              .shade50
                                                                          : null,
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Expanded(
                                                                            flex:
                                                                                1,
                                                                            child:
                                                                                Text('${index + 1}', textAlign: TextAlign.center),
                                                                          ),
                                                                          Expanded(
                                                                            flex:
                                                                                2,
                                                                            child:
                                                                                Text(listCredit[index].creditId.toUpperCase(), textAlign: TextAlign.justify),
                                                                          ),
                                                                          Expanded(
                                                                            flex:
                                                                                3,
                                                                            child: Text(listCredit[index].creditName,
                                                                                textAlign: TextAlign.justify,
                                                                                overflow: TextOverflow.ellipsis),
                                                                          ),
                                                                          Expanded(
                                                                            flex:
                                                                                4,
                                                                            child: Text(listCredit[index].major,
                                                                                textAlign: TextAlign.justify,
                                                                                overflow: TextOverflow.ellipsis),
                                                                          ),
                                                                          Expanded(
                                                                            flex:
                                                                                1,
                                                                            child:
                                                                                Text(listCredit[index].course, textAlign: TextAlign.center),
                                                                          ),
                                                                          Expanded(
                                                                            flex:
                                                                                2,
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                IconButton(
                                                                                    tooltip: 'Cập nhật thông tin học phần',
                                                                                    onPressed: () async {
                                                                                      await addAndEditCredit(credit: listCredit[index], isCreate: false);
                                                                                    },
                                                                                    padding: const EdgeInsets.only(bottom: 1),
                                                                                    icon: Icon(
                                                                                      Icons.edit_square,
                                                                                      color: Colors.blue.shade900,
                                                                                    )),
                                                                                IconButton(
                                                                                    tooltip: 'Xóa học phần',
                                                                                    onPressed: () {
                                                                                      deleteCredit(context: context, creditId: listCredit[index].creditId);
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
                                                                      'Chưa có học phần.'),
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
                                                          'Vui lòng chọn khóa và ngành sau đó nhấn vào nút xem để tiếp tục.'),
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

  addAndEditCredit({CreditModel? credit, required bool isCreate}) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    setState(() {
      idCtrl = TextEditingController();
      nameCtrl = TextEditingController();
    });
    ValueNotifier<String> _selectedMajor = ValueNotifier<String>('');
    ValueNotifier<String> _selectedCourse = ValueNotifier<String>('');
    if (isCreate == false) {
      _selectedCourse.value = credit!.course;
      _selectedMajor.value = credit.major;
      setState(() {
        idCtrl.text = credit.creditId;
        nameCtrl.text = credit.creditName;
      });
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
                        LineDetail(
                          field: 'Mã học phần',
                          ctrl: idCtrl,
                          validator: (p0) =>
                              p0!.isEmpty ? 'Không được để trống.' : null,
                        ),
                        const SizedBox(height: 5),
                        LineDetail(
                          field: 'Tên học phần',
                          ctrl: nameCtrl,
                          validator: (p0) =>
                              p0!.isEmpty ? 'Không được để trống.' : null,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: screenWidth * 0.07,
                              child: const Text(
                                "Khóa",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            ValueListenableBuilder(
                                valueListenable: _selectedCourse,
                                builder: (context, val, child) {
                                  return DropdownButtonHideUnderline(
                                    child: DropdownButton2<String>(
                                      isExpanded: true,
                                      hint: Center(
                                        child: Text(
                                          "Chọn",
                                          style: DropdownStyle.hintStyle,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      items: courses
                                          .map((String course) =>
                                              DropdownMenuItem<String>(
                                                value: course,
                                                child: Text(
                                                  course,
                                                  style:
                                                      DropdownStyle.itemStyle,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ))
                                          .toList(),
                                      value: _selectedCourse.value.isNotEmpty
                                          ? _selectedCourse.value
                                          : null,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedCourse.value = value!;
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
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: screenWidth * 0.07,
                              child: const Text(
                                "Ngành",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            ValueListenableBuilder(
                                valueListenable: _selectedMajor,
                                builder: (context, val, child) {
                                  return DropdownButtonHideUnderline(
                                    child: DropdownButton2<String>(
                                      isExpanded: true,
                                      hint: Center(
                                        child: Text(
                                          "Chọn",
                                          style: DropdownStyle.hintStyle,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      items: majors
                                          .map((String major) =>
                                              DropdownMenuItem<String>(
                                                value: major,
                                                child: Text(
                                                  major,
                                                  style:
                                                      DropdownStyle.itemStyle,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ))
                                          .toList(),
                                      value: _selectedMajor.value.isNotEmpty
                                          ? _selectedMajor.value
                                          : null,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedMajor.value = value!;
                                        });
                                      },
                                      buttonStyleData:
                                          DropdownStyle.buttonStyleLong,
                                      iconStyleData:
                                          DropdownStyle.iconStyleData,
                                      dropdownStyleData:
                                          DropdownStyle.dropdownStyleLong,
                                      menuItemStyleData:
                                          DropdownStyle.menuItemStyleData,
                                    ),
                                  );
                                }),
                          ],
                        ),
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
                                  if (_selectedCourse.value.isNotEmpty &&
                                      _selectedMajor.value.isNotEmpty) {
                                    final isExist = await firestore
                                        .collection('credits')
                                        .where('creditId',
                                            isEqualTo: idCtrl.text)
                                        .where('course',
                                            isEqualTo: _selectedCourse.value)
                                        .get();
                                    if (isExist.docs.isEmpty) {
                                      final credit = CreditModel(
                                          creditId: idCtrl.text,
                                          creditName: nameCtrl.text,
                                          course: _selectedCourse.value,
                                          major: _selectedMajor.value);
                                      firestore
                                          .collection('credits')
                                          .doc(idCtrl.text)
                                          .set(credit.toMap());
                                      Navigator.of(context).pop();
                                      GV.success(
                                          context: context,
                                          message: 'Đã thêm học phần.');
                                    } else {
                                      GV.error(
                                          context: context,
                                          message: 'Học phần đã tồn tại.');
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
                                  final credit = CreditModel(
                                      creditId: idCtrl.text,
                                      creditName: nameCtrl.text,
                                      course: _selectedCourse.value,
                                      major: _selectedMajor.value);
                                  firestore
                                      .collection('credits')
                                      .doc(idCtrl.text)
                                      .update(credit.toMap());
                                  Navigator.of(context).pop();
                                  GV.success(
                                      context: context,
                                      message: 'Đã cập nhật học phần.');
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

  deleteCredit({
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
                      const Text("Bạn có chắc chắn muốn xóa học phần này?"),
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
                        firestore.collection('credits').doc(creditId).delete();
                        Navigator.of(context).pop();
                        GV.success(
                            context: context, message: 'Đã xóa học phần.');
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
