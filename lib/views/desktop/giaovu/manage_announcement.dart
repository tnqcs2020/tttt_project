// ignore_for_file: use_build_context_synchronously

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tttt_project/data/constant.dart';
import 'package:tttt_project/models/announcement_model.dart';
import 'package:tttt_project/models/submit_bodel.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/widgets/custom_button.dart';
import 'package:tttt_project/widgets/custom_radio.dart';
import 'package:tttt_project/widgets/dropdown_style.dart';
import 'package:tttt_project/widgets/footer.dart';
import 'package:tttt_project/widgets/header.dart';
import 'package:tttt_project/widgets/line_detail.dart';
import 'package:tttt_project/widgets/loading.dart';
import 'package:tttt_project/widgets/user_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/widgets/menu/menu_left.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;

class ManageAnnouncementScreen extends StatefulWidget {
  const ManageAnnouncementScreen({Key? key}) : super(key: key);

  @override
  State<ManageAnnouncementScreen> createState() =>
      _ManageAnnouncementScreenState();
}

class _ManageAnnouncementScreenState extends State<ManageAnnouncementScreen> {
  final firestore = FirebaseFirestore.instance;
  final currentUser = Get.put(UserController());
  final GlobalKey<FormState> addAnnouncementFormKey = GlobalKey<FormState>();
  List<String> type = [
    "Tin giáo vụ",
    "Tin việc làm",
  ];
  List<String> dshk = [
    HocKy.hk1,
    HocKy.hk2,
    HocKy.hk3,
  ];
  List<NamHoc> dsnh = [NamHoc.n2021, NamHoc.n2122, NamHoc.n2223, NamHoc.n2324];
  ValueNotifier<String> selectedHK = ValueNotifier<String>('');
  ValueNotifier<NamHoc> selectedNH =
      ValueNotifier<NamHoc>(NamHoc(start: "", end: ""));
  ValueNotifier<String> selectedType = ValueNotifier<String>('');
  ValueNotifier<bool> isLook = ValueNotifier<bool>(false);
  List<PlatformFile> fileSelect = [];
  List<FileModel> files = [];
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController contentCtrl = TextEditingController();
  List<AnnouncementModel> loadAnnouncements = [];
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
      final loadAnnouncement =
          await FirebaseFirestore.instance.collection('announcements').get();
      if (loadAnnouncement.docs.isNotEmpty) {
        loadAnnouncement.docs.forEach((element) {
          loadAnnouncements.add(AnnouncementModel.fromMap(element.data()));
        });
      }

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
            // Obx(
            //   () =>
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
                  ValueListenableBuilder(
                      valueListenable: isLook,
                      builder: (context, valueLook, child) {
                        return Expanded(
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
                                        "Quản lý thông báo",
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "Loại thông báo",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(width: 15),
                                          ValueListenableBuilder<String>(
                                            valueListenable: selectedType,
                                            builder:
                                                (context, valueType, child) {
                                              return DropdownButtonHideUnderline(
                                                child: DropdownButton2<String>(
                                                  isExpanded: true,
                                                  hint: Center(
                                                    child: Text(
                                                      "Chọn",
                                                      style: DropdownStyle
                                                          .hintStyle,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  items: type
                                                      .map((String nd) =>
                                                          DropdownMenuItem<
                                                              String>(
                                                            value: nd,
                                                            child: Text(
                                                              nd,
                                                              style:
                                                                  DropdownStyle
                                                                      .itemStyle,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ))
                                                      .toList(),
                                                  value: selectedType
                                                          .value.isNotEmpty
                                                      ? selectedType.value
                                                      : null,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedType.value =
                                                          value!;
                                                    });
                                                    currentUser.isCompleted
                                                        .value = false;
                                                  },
                                                  buttonStyleData: DropdownStyle
                                                      .buttonStyleLong,
                                                  iconStyleData: DropdownStyle
                                                      .iconStyleData,
                                                  dropdownStyleData:
                                                      DropdownStyle
                                                          .dropdownStyleLong,
                                                  menuItemStyleData:
                                                      DropdownStyle
                                                          .menuItemStyleData,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 55),
                                      CustomButton(
                                        text: "Xem",
                                        width: screenWidth * 0.07,
                                        height: screenHeight * 0.06,
                                        onTap: () {
                                          if (selectedType.value.isNotEmpty) {
                                            setState(() {
                                              isLook.value = true;
                                            });
                                            currentUser.isCompleted.value =
                                                true;
                                          }
                                        },
                                      ),
                                      const SizedBox(width: 25),
                                      CustomButton(
                                        width: screenWidth * 0.07,
                                        height: screenHeight * 0.06,
                                        text: 'Thêm thông báo',
                                        onTap: () async {
                                          await editAnnouncement(
                                              context: context, isCreate: true);
                                        },
                                      )
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
                                              child: Text(
                                                'STT',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 5,
                                              child: Text(
                                                'Nội dung',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                'Ngày đăng',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
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
                                      isLook.value &&
                                              currentUser.isCompleted.isTrue
                                          ? StreamBuilder(
                                              stream: firestore
                                                  .collection('announcements')
                                                  .where('type',
                                                      isEqualTo:
                                                          selectedType.value)
                                                  .snapshots(),
                                              builder: (context, snapshot) {
                                                final List<AnnouncementModel>
                                                    listAnnouncement = [];
                                                if (snapshot.hasData &&
                                                    selectedType
                                                        .value.isNotEmpty &&
                                                    snapshot.connectionState ==
                                                        ConnectionState
                                                            .active) {
                                                  snapshot.data?.docs
                                                      .forEach((element) {
                                                    listAnnouncement.add(
                                                        AnnouncementModel
                                                            .fromMap(element
                                                                .data()));
                                                  });
                                                  return listAnnouncement
                                                          .isNotEmpty
                                                      ? ListView.builder(
                                                          itemCount:
                                                              listAnnouncement
                                                                  .length,
                                                          shrinkWrap: true,
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
                                                                        listAnnouncement[index]
                                                                            .title!,
                                                                        textAlign:
                                                                            TextAlign.center),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 3,
                                                                    child: Text(
                                                                        GV.readTimestamp(listAnnouncement[index]
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
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              bottom: 1),
                                                                          onPressed:
                                                                              () async {
                                                                            await editAnnouncement(
                                                                              context: context,
                                                                              announcement: listAnnouncement[index],
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
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              bottom: 1),
                                                                          onPressed:
                                                                              () {},
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
                                                      : const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 150),
                                                          child: Center(
                                                            child: Text(
                                                                'Chưa có thông báo.'),
                                                          ),
                                                        );
                                                } else {
                                                  return const Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 150),
                                                    child: Loading(),
                                                  );
                                                }
                                              },
                                            )
                                          : selectedType.value == ''
                                              ? StreamBuilder(
                                                  stream: firestore
                                                      .collection(
                                                          'announcements')
                                                      .snapshots(),
                                                  builder: (context,
                                                      snapshotAnnouncement) {
                                                    if (snapshotAnnouncement
                                                            .hasData &&
                                                        snapshotAnnouncement
                                                                .connectionState ==
                                                            ConnectionState
                                                                .active) {
                                                      List<AnnouncementModel>
                                                          listAnnouncement = [];
                                                      snapshotAnnouncement
                                                          .data?.docs
                                                          .forEach((element) {
                                                        listAnnouncement.add(
                                                            AnnouncementModel
                                                                .fromMap(element
                                                                    .data()));
                                                      });
                                                      return listAnnouncement
                                                              .isNotEmpty
                                                          ? ListView.builder(
                                                              itemCount:
                                                                  listAnnouncement
                                                                      .length,
                                                              shrinkWrap: true,
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
                                                                            listAnnouncement[index]
                                                                                .title!,
                                                                            textAlign:
                                                                                TextAlign.center),
                                                                      ),
                                                                      Expanded(
                                                                        flex: 3,
                                                                        child: Text(
                                                                            GV.readTimestamp(listAnnouncement[index]
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
                                                                            SizedBox(
                                                                              child: IconButton(
                                                                                padding: const EdgeInsets.only(bottom: 1),
                                                                                onPressed: () async {
                                                                                  await editAnnouncement(
                                                                                    context: context,
                                                                                    announcement: listAnnouncement[index],
                                                                                    isCreate: false,
                                                                                  );
                                                                                },
                                                                                icon: Icon(
                                                                                  Icons.edit_document,
                                                                                  color: Colors.blue.shade900,
                                                                                  size: 20,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            IconButton(
                                                                              padding: const EdgeInsets.only(bottom: 1),
                                                                              onPressed: () async {
                                                                                await deleteAnnouncement(
                                                                                  context: context,
                                                                                  announcement: listAnnouncement[index],
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
                                                          : const Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 150),
                                                              child: Center(
                                                                child: Text(
                                                                    'Chưa có thông báo.'),
                                                              ),
                                                            );
                                                    } else {
                                                      return const Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 150),
                                                        child: Loading(),
                                                      );
                                                    }
                                                  },
                                                )
                                              : const Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 150),
                                                  child: Center(
                                                    child: Text(
                                                        'Vui lòng nhấn vào nút xem để tiếp tục.'),
                                                  ),
                                                ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                ],
              ),
            ),
            // ),
            const Footer(),
          ],
        ),
      ),
    );
  }

  editAnnouncement(
      {required BuildContext context,
      AnnouncementModel? announcement,
      required bool isCreate}) async {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    if (isCreate) {
      currentUser.selectedFiles = RxList();
      currentUser.selectedString.value = '';
      titleCtrl.text = '';
      contentCtrl.text = '';
      files = [];
    } else if (announcement != null) {
      currentUser.selectedString.value = announcement.type!;
      currentUser.selectedFiles.value = announcement.files!;
      titleCtrl.text = announcement.title!;
      contentCtrl.text = announcement.content!;
      files = announcement.files!;
    }
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
                  scrollable: true,
                  title: Container(
                    color: Colors.blue.shade600,
                    height: 50,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: Text('Chi tiết thông báo',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                        ),
                        IconButton(
                            padding: const EdgeInsets.only(bottom: 1),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close))
                      ],
                    ),
                  ),
                  titlePadding: EdgeInsets.zero,
                  shape: Border.all(width: 0.5),
                  content: Container(
                    constraints: BoxConstraints(minWidth: screenWidth * 0.35),
                    padding: const EdgeInsets.only(bottom: 35),
                    child: Form(
                      key: addAnnouncementFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Loại thông báo:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          for (var data in type)
                            Obx(
                              () => CustomRadio(
                                title: data,
                                onTap: () =>
                                    currentUser.selectedString.value = data,
                                selected:
                                    currentUser.selectedString.value == data,
                              ),
                            ),
                          const SizedBox(height: 10),
                          LineDetail(
                            field: 'Tiêu đề',
                            ctrl: titleCtrl,
                            widthForm: 0.25,
                            validator: (p0) =>
                                p0!.isEmpty ? 'Không được để trống.' : null,
                          ),
                          const SizedBox(height: 10),
                          LineDetail(
                            field: 'Nội dung',
                            ctrl: contentCtrl,
                            widthForm: 0.25,
                            validator: (p0) =>
                                p0!.isEmpty ? 'Không được để trống.' : null,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              SizedBox(
                                width: screenWidth * 0.07,
                                child: const Text(
                                  "Tệp đính kèm:",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Obx(
                                () => Expanded(
                                  child: currentUser.selectedFiles.isNotEmpty
                                      ? Row(
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                for (int indexFile = 0;
                                                    indexFile <
                                                        currentUser
                                                            .selectedFiles
                                                            .length;
                                                    indexFile++)
                                                  Row(
                                                    children: [
                                                      Text(
                                                        currentUser
                                                            .selectedFiles[
                                                                indexFile]
                                                            .fileName!,
                                                        style: TextStyle(
                                                          color: Colors
                                                              .blue.shade900,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          decorationColor:
                                                              Colors.blue
                                                                  .shade900,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 15),
                                                      InkWell(
                                                        onTap: () async {
                                                          showDialog(
                                                              context: context,
                                                              barrierColor:
                                                                  Colors
                                                                      .black12,
                                                              builder:
                                                                  (context) {
                                                                return Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .only(
                                                                    top: screenHeight *
                                                                        0.06,
                                                                    bottom:
                                                                        screenHeight *
                                                                            0.02,
                                                                    left:
                                                                        screenWidth *
                                                                            0.27,
                                                                    right:
                                                                        screenWidth *
                                                                            0.08,
                                                                  ),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      AlertDialog(
                                                                        title:
                                                                            Container(
                                                                          color: Colors
                                                                              .blue
                                                                              .shade600,
                                                                          height:
                                                                              50,
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              vertical: 10,
                                                                              horizontal: 10),
                                                                          child:
                                                                              const Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: [
                                                                              Text(
                                                                                'Xóa tài liệu',
                                                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        titlePadding:
                                                                            EdgeInsets.zero,
                                                                        shape: Border.all(
                                                                            width:
                                                                                0.5),
                                                                        content:
                                                                            const Text("Bạn có chắc chắn muốn xóa tài liệu này?"),
                                                                        actions: [
                                                                          TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                            child:
                                                                                const Text(
                                                                              "Hủy",
                                                                              style: TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          TextButton(
                                                                            onPressed:
                                                                                () async {
                                                                              await deleteFile(deleteAt: indexFile);
                                                                            },
                                                                            child:
                                                                                const Text(
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
                                                        },
                                                        child: const Icon(
                                                          Icons.delete_outlined,
                                                          color: Colors.red,
                                                          size: 20,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(width: 15),
                                            IconButton(
                                              onPressed: () async {
                                                await selectMultipleFiles();
                                              },
                                              icon: Icon(
                                                Icons.upload_file_outlined,
                                                color: Colors.blue.shade900,
                                              ),
                                            )
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            const Text("Chưa có tệp!"),
                                            IconButton(
                                              onPressed: () async {
                                                await selectMultipleFiles();
                                              },
                                              icon: Icon(
                                                Icons.upload_file_outlined,
                                                color: Colors.blue.shade900,
                                              ),
                                            )
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          )
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
                                  if (currentUser.selectedString.value == "") {
                                    GV.error(
                                        context: context,
                                        message: 'Phải chọn loại thông báo.');
                                  } else if (addAnnouncementFormKey
                                      .currentState!
                                      .validate()) {
                                    var docId = GV.generateRandomString(20);
                                    await uploadMultipleFiles(docId);
                                    final announcement = AnnouncementModel(
                                      announcementId: docId,
                                      type: currentUser.selectedString.value,
                                      title: titleCtrl.text,
                                      content: contentCtrl.text,
                                      files: files.isNotEmpty ? files : [],
                                      createdAt: Timestamp.now(),
                                    );
                                    firestore
                                        .collection('announcements')
                                        .doc(docId)
                                        .set(announcement.toMap());
                                    loadAnnouncements.add(announcement);
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
                                  if (addAnnouncementFormKey.currentState!
                                      .validate()) {
                                    await uploadMultipleFiles(
                                        announcement!.announcementId!);
                                    final update = AnnouncementModel(
                                      announcementId:
                                          announcement.announcementId!,
                                      type: currentUser.selectedString.value,
                                      title: titleCtrl.text,
                                      content: contentCtrl.text,
                                      files: files.isNotEmpty ? files : [],
                                      createdAt: announcement.createdAt!,
                                    );
                                    await firestore
                                        .collection('announcements')
                                        .doc(announcement.announcementId!)
                                        .update(update.toMap());
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

  deleteAnnouncement({
    required BuildContext context,
    required AnnouncementModel announcement,
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
                          'Xóa tài liệu',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  titlePadding: EdgeInsets.zero,
                  shape: Border.all(width: 0.5),
                  content:
                      const Text("Bạn có chắc chắn muốn xóa thông báo này?"),
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
                        if (announcement.announcementId != null) {
                          firestore
                              .collection('announcements')
                              .doc(announcement.announcementId!)
                              .delete();
                          Navigator.of(context).pop();
                          GV.success(
                              context: context,
                              message: 'Tài liệu đã được xóa.');
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

  selectMultipleFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );
    if (result != null) {
      result.files.forEach((element) {
        setState(() {
          fileSelect.add(element);
        });
        currentUser.selectedFiles.add(FileModel(fileName: element.name));
      });
    }
  }

  uploadMultipleFiles(String docId) async {
    try {
      for (var i = 0; i < fileSelect.length; i++) {
        storage.UploadTask uploadTask;
        storage.Reference ref = storage.FirebaseStorage.instance
            .ref()
            .child('announcements')
            .child('/$docId')
            .child(fileSelect[i].name);
        uploadTask = ref.putData(fileSelect[i].bytes!);
        await uploadTask.whenComplete(() => null);
        var url = await ref.getDownloadURL();
        final fileModel = FileModel(
          fileName: fileSelect[i].name,
          fileUrl: url,
        );
        bool hasFile = false;
        if (files.isNotEmpty) {
          for (int i = 0; i < files.length; i++) {
            if (files[i].fileName == fileModel.fileName) {
              hasFile = true;
              setState(() {
                files[i].fileUrl = url;
              });
            }
          }
        }
        if (hasFile != true) {
          setState(() {
            files.add(fileModel);
          });
        }
      }
    } catch (e) {
      print(e);
      GV.error(context: context, message: 'Đã có lỗi xảy ra.');
    }
  }

  deleteFile({int? deleteAt}) async {
    List<PlatformFile> temp = [];
    if (deleteAt != null) {
      for (var i = 0; i < fileSelect.length; i++) {
        if (i != deleteAt) {
          temp.add(fileSelect[i]);
        }
      }
      setState(() {
        fileSelect = temp;
      });
      currentUser.selectedFiles.removeAt(deleteAt);
      Navigator.of(context).pop();
      GV.success(context: context, message: 'Tài liệu đã được xóa.');
    }
  }
}
