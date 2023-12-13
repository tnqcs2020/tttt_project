// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/common/constant.dart';
import 'package:tttt_project/models/firm_model.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/widgets/custom_button.dart';
import 'package:tttt_project/widgets/custom_radio.dart';
import 'package:tttt_project/widgets/line_detail.dart';
import 'package:tttt_project/widgets/loading.dart';
import 'package:tttt_project/common/user_controller.dart';

class InfoFirm extends StatefulWidget {
  const InfoFirm({
    super.key,
  });

  @override
  State<InfoFirm> createState() => _InfoFirmState();
}

class _InfoFirmState extends State<InfoFirm> {
  final currentUser = Get.put(UserController());
  final GlobalKey<FormState> firmFormKey = GlobalKey<FormState>();
  final TextEditingController nameFirmCtrl = TextEditingController();
  final TextEditingController ownerCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController describeCtrl = TextEditingController();
  final ValueNotifier totalJob = ValueNotifier(1);
  List<TextEditingController> positions = [TextEditingController()];
  List<TextEditingController> describes = [TextEditingController()];
  List<String> ids = [GV.generateRandomString(10)];
  List<JobPositionModel> jobs = [];
  int temp = 0;
  FirmModel loadFirm = FirmModel();
  bool loadData = false;
  List<ValueNotifier<int>> tieuChi = [];

  @override
  void initState() {
    getJobPosition();
    super.initState();
  }

  getJobPosition() async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    final userId = sharedPref
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
      DocumentSnapshot<Map<String, dynamic>> isExistFirm =
          await FirebaseFirestore.instance
              .collection('firms')
              .doc(userId)
              .get();
      if (isExistFirm.data() != null) {
        loadFirm = FirmModel.fromMap(isExistFirm.data()!);
        nameFirmCtrl.text = loadFirm.firmName ?? '';
        ownerCtrl.text = loadFirm.owner ?? '';
        phoneCtrl.text = loadFirm.phone ?? '';
        emailCtrl.text = loadFirm.email ?? '';
        addressCtrl.text = loadFirm.address ?? '';
        describeCtrl.text = loadFirm.describe ?? '';
        if (loadFirm.listJob != null && loadFirm.listJob!.isNotEmpty) {
          setState(() {
            positions = [];
            describes = [];
            ids = [];
            temp = 0;
            loadFirm.listJob!.forEach((element) {
              positions.add(TextEditingController(text: element.jobName));
              describes.add(TextEditingController(text: element.describeJob));
              ids.add(element.jobId!);
              temp++;
            });
            totalJob.value = temp;
            loadData = true;
          });
        } else {
          setState(() {
            loadData = true;
          });
        }
      } else {
        setState(() {
          loadData = true;
        });
      }
    }
  }

  @override
  void dispose() {
    nameFirmCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    ownerCtrl.dispose();
    addressCtrl.dispose();
    describeCtrl.dispose();
    positions.forEach((element) => element.dispose());
    describes.forEach((element) => element.dispose());
    totalJob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return StreamBuilder(
      stream: GV.firmsCol.doc(currentUser.userId.value).snapshots(),
      builder: (context, snapshotFirm) {
        FirmModel firm = FirmModel();
        tieuChi = [];
        if (snapshotFirm.data != null && snapshotFirm.data!.data() != null) {
          firm = FirmModel.fromMap(snapshotFirm.data!.data()!);
          firm.tieuChi!.forEach((element) {
            tieuChi.add(ValueNotifier(element));
          });
        }
        if (snapshotFirm.hasData && loadData) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: Form(
              key: firmFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: screenWidth * 0.5,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black,
                          width: 0.5,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 15, bottom: 5),
                    child: const Text(
                      'Thông tin',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      LineDetail(
                        field: "Tên công ty",
                        ctrl: nameFirmCtrl,
                        validator: (p0) =>
                            p0!.isEmpty ? 'Không được để trống' : null,
                      ),
                      LineDetail(
                        field: "Người đại diện",
                        ctrl: ownerCtrl,
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      LineDetail(
                        field: "Điện thoại",
                        ctrl: phoneCtrl,
                      ),
                      LineDetail(
                        field: "Email",
                        ctrl: emailCtrl,
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      LineDetail(
                        field: "Địa chỉ",
                        ctrl: addressCtrl,
                      ),
                      LineDetail(
                        field: "Mô tả chung",
                        ctrl: describeCtrl,
                        minLines: 1,
                        validator: (p0) =>
                            p0!.isEmpty ? 'Không được để trống' : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: screenWidth * 0.5,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black,
                          width: 0.5,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 15, bottom: 5),
                    child: const Text(
                      'Yêu cầu tổng quan về kỹ năng',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: screenWidth * 0.4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            lineTieuChi(title: 'Ngoại ngữ', index: 0),
                            lineTieuChi(title: 'Kỹ năng lập trình', index: 1),
                            lineTieuChi(
                                title: 'Kỹ năng làm việc nhóm', index: 2),
                            lineTieuChi(title: 'Máy học, AI', index: 3),
                            lineTieuChi(title: 'Website', index: 4),
                            lineTieuChi(title: 'Ứng dụng di động', index: 5),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: screenWidth * 0.5,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.black,
                          width: 0.5,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 15, bottom: 5),
                    child: const Text(
                      'Vị trí tuyển dụng',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 5),
                  ValueListenableBuilder(
                      valueListenable: totalJob,
                      builder: (context, vTotalJob, child) {
                        return ListView.builder(
                            itemCount: vTotalJob,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    LineDetail(
                                      field: 'Vị trí',
                                      widthField: 0.03,
                                      widthForm: 0.1,
                                      ctrl: positions[index],
                                    ),
                                    SizedBox(width: screenWidth * 0.015),
                                    LineDetail(
                                      field: 'Mô tả/Yêu cầu',
                                      widthField: 0.07,
                                      widthForm: 0.25,
                                      ctrl: describes[index],
                                    ),
                                    SizedBox(width: screenWidth * 0.015),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15),
                                      child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              totalJob.value--;
                                              positions.removeAt(index);
                                              describes.removeAt(index);
                                              ids.removeAt(index);
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.remove_circle_outlined,
                                            size: 30,
                                            color: Colors.red,
                                          )),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15),
                                      child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              totalJob.value++;
                                              positions.insert(index + 1,
                                                  TextEditingController());
                                              describes.insert(index + 1,
                                                  TextEditingController());
                                              ids.insert(index + 1,
                                                  GV.generateRandomString(10));
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.add_circle_outlined,
                                            size: 30,
                                            color: Colors.green,
                                          )),
                                    ),
                                  ],
                                ),
                              );
                            });
                      }),
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: CustomButton(
                      text: "Lưu",
                      width: screenWidth * 0.1,
                      height: screenHeight * 0.07,
                      onTap: () async {
                        if (firmFormKey.currentState!.validate()) {
                          jobs = [];
                          if (positions.length == describes.length) {
                            for (int i = 0; i < totalJob.value; i++) {
                              if (positions[i].text != '' ||
                                  describes[i].text != '') {
                                jobs.add(JobPositionModel(
                                    jobName: positions[i].text,
                                    describeJob: describes[i].text,
                                    jobId: ids[i]));
                              }
                            }
                          }
                          List<int> tc = [];
                          for (int i = 0; i < tieuChi.length; i++) {
                            tc.add(tieuChi[i].value);
                          }
                          FirmModel firmModel = FirmModel(
                            firmId: currentUser.userId.value,
                            firmName: nameFirmCtrl.text != ""
                                ? nameFirmCtrl.text
                                : null,
                            owner: ownerCtrl.text != "" ? ownerCtrl.text : null,
                            phone: phoneCtrl.text != "" ? phoneCtrl.text : null,
                            email: emailCtrl.text != "" ? emailCtrl.text : null,
                            address: addressCtrl.text != ""
                                ? addressCtrl.text
                                : null,
                            describe: describeCtrl.text,
                            listJob: jobs.isNotEmpty ? jobs : [],
                            listRegis: loadFirm.listRegis ?? [],
                            tieuChi: tc,
                          );
                          DocumentSnapshot<Map<String, dynamic>> isExistFirm =
                              await GV.firmsCol
                                  .doc(currentUser.userId.value)
                                  .get();
                          if (isExistFirm.data() != null) {
                            GV.firmsCol
                                .doc(currentUser.userId.value)
                                .update(firmModel.toMap());
                            GV.success(
                                context: context,
                                message: 'Cập nhật thành công!');
                          } else {
                            GV.firmsCol
                                .doc(currentUser.userId.value)
                                .set(firmModel.toMap());
                            GV.success(
                                context: context, message: 'Thêm thành công!');
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const Padding(
          padding: EdgeInsets.only(top: 180),
          child: Center(child: Loading()),
        );
      },
    );
  }

  lineTieuChi({required String title, required int index}) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: screenWidth * 0.1,
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(width: screenWidth * 0.05),
        ValueListenableBuilder(
            valueListenable: tieuChi[index],
            builder: (context, tieuChiVal, child) {
              return Row(
                children: [
                  for (int i = 0; i < 5; i++)
                    CustomRadio(
                      title: '${i + 1}',
                      onTap: () => tieuChi[index].value = i + 1,
                      selected: tieuChi[index].value == i + 1,
                    ),
                ],
              );
            })
      ],
    );
  }
}
