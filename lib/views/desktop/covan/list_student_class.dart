import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/common/constant.dart';
import 'package:tttt_project/common/excel.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/widgets/custom_button.dart';
import 'package:tttt_project/widgets/dropdown_style.dart';
import 'package:tttt_project/widgets/loading.dart';
import 'package:tttt_project/common/user_controller.dart';

class ListStudentClass extends StatefulWidget {
  const ListStudentClass({Key? key}) : super(key: key);

  @override
  State<ListStudentClass> createState() => _ListStudentClassState();
}

class _ListStudentClassState extends State<ListStudentClass> {
  final firestore = FirebaseFirestore.instance;
  final currentUser = Get.put(UserController());
  ValueNotifier<ClassModel> selectedClass =
      ValueNotifier<ClassModel>(ClassModel.empty);
  ValueNotifier<bool> isLook = ValueNotifier<bool>(false);
  ClassModel myClass = ClassModel();
  List<ClassModel> loadAllClass = [];

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
        setState(() {
          loadAllClass = [];
          loadUser.cvClass!.forEach((element) {
            ClassModel c = element;
            loadAllClass.add(c);
          });
          myClass = loadAllClass.last;
          currentUser.loadIn.value = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(left: 50, right: 50, top: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    "Mã lớp",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: 15),
                  ValueListenableBuilder<ClassModel>(
                    valueListenable: selectedClass,
                    builder: (context, valueClass, child) {
                      return DropdownButtonHideUnderline(
                        child: DropdownButton2<ClassModel>(
                          isExpanded: true,
                          hint: Center(
                            child: Obx(
                              () => Text(
                                currentUser.cvClass.isNotEmpty
                                    ? "${currentUser.cvClass.last.classId}"
                                    : "Chọn",
                                style: DropdownStyle.hintStyle,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          items: loadAllClass
                              .map((ClassModel cl) =>
                                  DropdownMenuItem<ClassModel>(
                                    value: cl,
                                    child: Center(
                                      child: Text(
                                        cl.classId!,
                                        style: DropdownStyle.itemStyle,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ))
                              .toList(),
                          value: selectedClass.value != ClassModel.empty
                              ? selectedClass.value
                              : null,
                          onChanged: (value) {
                            setState(() {
                              selectedClass.value = value!;
                            });
                            currentUser.isCompleted.value = false;
                          },
                          buttonStyleData: DropdownStyle.buttonStyleLong,
                          iconStyleData: DropdownStyle.iconStyleData,
                          dropdownStyleData: DropdownStyle.dropdownStyleLong,
                          menuItemStyleData: DropdownStyle.menuItemStyleData,
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
                  if (selectedClass.value != ClassModel.empty) {
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
        Padding(
          padding: const EdgeInsets.only(bottom: 35),
          child: Container(
            decoration: const BoxDecoration(color: Colors.white),
            height: screenHeight * 0.45,
            width: screenWidth * 0.55,
            child: Column(
              children: [
                Container(
                  color: GV.fieldColor,
                  height: screenHeight * 0.04,
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'STT',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'MSSV',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          'Họ tên',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          'Email',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Thao tác',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: isLook.value && currentUser.isCompleted.isTrue
                      ? SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: StreamBuilder(
                            stream: firestore
                                .collection('users')
                                .where('classId',
                                    isEqualTo: selectedClass.value.classId)
                                .snapshots(),
                            builder: (context, snapshot) {
                              List<UserModel> listUser = [];
                              if (snapshot.hasData &&
                                  snapshot.connectionState ==
                                      ConnectionState.active) {
                                snapshot.data?.docs.forEach((element) {
                                  listUser
                                      .add(UserModel.fromMap(element.data()));
                                });
                                listUser.sort(
                                  (a, b) => a.userId!.compareTo(b.userId!),
                                );
                                return listUser.isNotEmpty
                                    ? ListView.builder(
                                        itemCount: listUser.length,
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            height: screenHeight * 0.05,
                                            color: index % 2 == 0
                                                ? Colors.blue.shade50
                                                : null,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Text('${index + 1}',
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
                                                      listUser[index].userName!,
                                                      textAlign:
                                                          TextAlign.justify),
                                                ),
                                                Expanded(
                                                  flex: 4,
                                                  child: Text(
                                                      listUser[index]
                                                              .email!
                                                              .isNotEmpty
                                                          ? '${listUser[index].email}'
                                                          : "-",
                                                      textAlign:
                                                          TextAlign.justify),
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
                                                              'Xem thông tin',
                                                          onPressed: () {
                                                            showInfo(
                                                                context:
                                                                    context,
                                                                user: listUser[
                                                                    index]);
                                                          },
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 1),
                                                          icon: const Icon(
                                                            Icons.info_rounded,
                                                            color: Colors.red,
                                                            size: 20,
                                                          ),
                                                        ),
                                                      ],
                                                    )),
                                              ],
                                            ),
                                          );
                                        },
                                      )
                                    : SizedBox(
                                        height: screenHeight * 0.45,
                                        width: screenWidth * 0.55,
                                        child: const Center(
                                          child: Text('Chưa có sinh viên.'),
                                        ),
                                      );
                              } else {
                                return SizedBox(
                                  height: screenHeight * 0.45,
                                  width: screenWidth * 0.55,
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Loading(),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        )
                      : selectedClass.value == ClassModel.empty
                          ? SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: StreamBuilder(
                                stream: firestore
                                    .collection('users')
                                    .where('classId',
                                        isEqualTo: myClass.classId)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData &&
                                      snapshot.connectionState ==
                                          ConnectionState.active &&
                                      myClass.classId != null) {
                                    List<UserModel> listUser = [];
                                    snapshot.data?.docs.forEach((element) {
                                      listUser.add(
                                          UserModel.fromMap(element.data()));
                                    });
                                    listUser.sort(
                                      (a, b) => a.userId!.compareTo(b.userId!),
                                    );
                                    return listUser.isNotEmpty
                                        ? ListView.builder(
                                            itemCount: listUser.length,
                                            shrinkWrap: true,
                                            scrollDirection: Axis.vertical,
                                            itemBuilder: (context, index) {
                                              return Container(
                                                height: screenHeight * 0.05,
                                                color: index % 2 == 0
                                                    ? Colors.blue.shade50
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
                                                          textAlign: TextAlign
                                                              .justify),
                                                    ),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Text(
                                                          listUser[index]
                                                              .userName!,
                                                          textAlign: TextAlign
                                                              .justify),
                                                    ),
                                                    Expanded(
                                                      flex: 4,
                                                      child: Text(
                                                          listUser[index]
                                                                  .email!
                                                                  .isNotEmpty
                                                              ? '${listUser[index].email}'
                                                              : "-",
                                                          textAlign: TextAlign
                                                              .justify),
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
                                                                'Xem thông tin',
                                                            onPressed: () {
                                                              showInfo(
                                                                  context:
                                                                      context,
                                                                  user: listUser[
                                                                      index]);
                                                            },
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom: 1),
                                                            icon: const Icon(
                                                              Icons
                                                                  .info_rounded,
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
                                        : SizedBox(
                                            height: screenHeight * 0.45,
                                            width: screenWidth * 0.55,
                                            child: const Center(
                                              child: Text('Chưa có sinh viên.'),
                                            ),
                                          );
                                  } else {
                                    return SizedBox(
                                      height: screenHeight * 0.45,
                                      width: screenWidth * 0.55,
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Loading(),
                                        ],
                                      ),
                                    );
                                  }
                                },
                              ),
                            )
                          : const Center(
                              child: Text(
                                  'Vui lòng nhấn vào nút xem để tiếp tục.'),
                            ),
                )
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 35),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomButton(
                text: 'Xuất danh sách',
                width: 100,
                height: 40,
                onTap: () async {
                  List<UserModel> list = [];
                  final loadUser = await firestore
                      .collection('users')
                      .where('classId', isEqualTo: myClass.classId)
                      .get();
                  loadUser.docs.forEach((element) {
                    list.add(UserModel.fromMap(element.data()));
                  });
                  await xuatDSSVGV(
                    classId: myClass.classId!,
                    className: myClass.className!,
                    users: list,
                  );
                },
              ),
            ],
          ),
        )
      ],
    );
  }

  showInfo({
    required BuildContext context,
    required UserModel user,
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
                        child: Text('Thông tin thực tập',
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Mã sinh viên: ${user.userId!.toUpperCase()}'),
                      Text('Họ tên: ${user.userName}'),
                      Text('Ngành: ${user.major} - Khóa: ${user.course}'),
                      Text('Email: ${user.email}'),
                      Text('Số điện thoại: ${user.phone}'),
                      Text('Địa chỉ: ${user.address}'),
                    ],
                  ),
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: const ButtonStyle(
                            elevation: MaterialStatePropertyAll(5),
                          ),
                          child: const Text('Đóng')),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
