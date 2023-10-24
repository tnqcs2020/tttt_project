import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/data/constant.dart';
import 'package:tttt_project/models/firm_model.dart';
import 'package:tttt_project/widgets/custom_button.dart';
import 'package:tttt_project/widgets/line_detail.dart';
import 'package:tttt_project/widgets/loading.dart';
import 'package:tttt_project/widgets/user_controller.dart';

class InfoFirm extends StatefulWidget {
  const InfoFirm({
    super.key,
  });

  @override
  State<InfoFirm> createState() => _InfoFirmState();
}

class _InfoFirmState extends State<InfoFirm> {
  final currentUser = Get.put(UserController());
  final TextEditingController nameFirmCtrl = TextEditingController();
  final TextEditingController ownerCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController describeCtrl = TextEditingController();
  final ValueNotifier totalJob = ValueNotifier(1);
  List<TextEditingController> positions = [TextEditingController()];
  List<TextEditingController> quantities = [TextEditingController()];
  List<TextEditingController> describes = [TextEditingController()];
  List<JobPositionModel> jobs = [];
  int temp = 0;
  FirmModel loadFirm = FirmModel();
  bool loadData = false;

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
    DocumentSnapshot<Map<String, dynamic>> isExistFirm =
        await FirebaseFirestore.instance.collection('firms').doc(userId).get();
    if (isExistFirm.data() != null) {
      loadFirm = FirmModel.fromMap(isExistFirm.data()!);
      nameFirmCtrl.text = loadFirm.name ?? '';
      ownerCtrl.text = loadFirm.owner ?? '';
      phoneCtrl.text = loadFirm.phone ?? '';
      emailCtrl.text = loadFirm.email ?? '';
      addressCtrl.text = loadFirm.address ?? '';
      describeCtrl.text = loadFirm.describe ?? '';
      if (loadFirm.listJob != null && loadFirm.listJob!.isNotEmpty) {
        setState(() {
          positions = [];
          quantities = [];
          describes = [];
          temp = 0;
          loadFirm.listJob!.forEach((element) {
            positions.add(TextEditingController(text: element.name));
            quantities.add(TextEditingController(text: element.quantity));
            describes.add(TextEditingController(text: element.describeJob));
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

  @override
  void dispose() {
    nameFirmCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    ownerCtrl.dispose();
    addressCtrl.dispose();
    describeCtrl.dispose();
    positions.forEach((element) => element.dispose());
    quantities.forEach((element) => element.dispose());
    describes.forEach((element) => element.dispose());
    totalJob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return loadData
        ? StreamBuilder(
            stream: GV.firmsCol.doc(currentUser.userId.value).snapshots(),
            builder: (context, snapshotFirm) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 70),
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
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        LineDetail(
                          field: "Tên công ty",
                          ctrl: nameFirmCtrl,
                        ),
                        LineDetail(
                          field: "Người đại diện",
                          ctrl: ownerCtrl,
                        ),
                      ],
                    ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        LineDetail(
                          field: "Địa chỉ",
                          ctrl: addressCtrl,
                        ),
                        LineDetail(
                          field: "Giới thiệu",
                          ctrl: describeCtrl,
                          minLines: 2,
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
                        'Tuyển dụng',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    ValueListenableBuilder(
                        valueListenable: totalJob,
                        builder: (context, vTotalJob, child) {
                          return ListView.builder(
                              itemCount: vTotalJob,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, index) {
                                return Row(
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
                                      field: 'Số lượng',
                                      widthField: 0.03,
                                      widthForm: 0.05,
                                      ctrl: quantities[index],
                                      textFormat: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'[0-9]'),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: screenWidth * 0.015),
                                    LineDetail(
                                      field: 'Mô tả',
                                      widthField: 0.03,
                                      widthForm: 0.15,
                                      ctrl: describes[index],
                                    ),
                                    SizedBox(width: screenWidth * 0.015),
                                    if (index == vTotalJob - 1) ...[
                                      Padding(
                                        padding: const EdgeInsets.only(top: 15),
                                        child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                totalJob.value--;
                                                quantities.removeAt(index);
                                                positions.removeAt(index);
                                                describes.removeAt(index);
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.remove_circle_outlined,
                                              size: 30,
                                              color: Colors.red,
                                            )),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.only(top: 15),
                                        width: 50,
                                        child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                totalJob.value++;
                                                quantities.add(
                                                    TextEditingController());
                                                positions.add(
                                                    TextEditingController());
                                                describes.add(
                                                    TextEditingController());
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.add_circle_outlined,
                                              size: 30,
                                              color: Colors.green,
                                            )),
                                      ),
                                    ] else ...[
                                      Padding(
                                        padding: const EdgeInsets.only(top: 15),
                                        child: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                totalJob.value--;
                                                quantities.removeAt(index);
                                                positions.removeAt(index);
                                                describes.removeAt(index);
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.remove_circle_outlined,
                                              size: 30,
                                              color: Colors.red,
                                            )),
                                      ),
                                      const SizedBox(width: 50),
                                    ]
                                  ],
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
                          jobs = [];
                          if (positions.length == quantities.length &&
                              positions.length == describes.length) {
                            for (int i = 0; i < totalJob.value; i++) {
                              if (positions[i].text != '' ||
                                  quantities[i].text != '' ||
                                  describes[i].text != '') {
                                jobs.add(JobPositionModel(
                                    name: positions[i].text,
                                    quantity: quantities[i].text,
                                    describeJob: describes[i].text,
                                    jobId: GV.generateRandomString(10)));
                              }
                            }
                          }

                          FirmModel firmModel = FirmModel(
                            firmId: currentUser.userId.value,
                            name: nameFirmCtrl.text != ""
                                ? nameFirmCtrl.text
                                : null,
                            owner: ownerCtrl.text != "" ? ownerCtrl.text : null,
                            phone: phoneCtrl.text != "" ? phoneCtrl.text : null,
                            email: emailCtrl.text != "" ? emailCtrl.text : null,
                            address: addressCtrl.text != ""
                                ? addressCtrl.text
                                : null,
                            describe: describeCtrl.text != ""
                                ? describeCtrl.text
                                : null,
                            listJob: jobs.isNotEmpty ? jobs : [],
                            listRegis: [],
                          );
                          DocumentSnapshot<Map<String, dynamic>> isExistFirm =
                              await GV.firmsCol
                                  .doc(currentUser.userId.value)
                                  .get();
                          if (isExistFirm.data() != null) {
                            GV.firmsCol
                                .doc(currentUser.userId.value)
                                .update(firmModel.toMap());
                            EasyLoading.showSuccess('Cập nhật thành công!');
                          } else {
                            GV.firmsCol
                                .doc(currentUser.userId.value)
                                .set(firmModel.toMap());
                            EasyLoading.showSuccess('Thêm thành công!');
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          )
        : const Loading();
  }
}
