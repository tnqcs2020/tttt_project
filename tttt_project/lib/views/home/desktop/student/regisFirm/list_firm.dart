// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/data/constant.dart';
import 'package:tttt_project/models/firm_model.dart';
import 'package:tttt_project/models/register_trainee_model.dart';
import 'package:tttt_project/widgets/custom_button.dart';
import 'package:tttt_project/widgets/loading.dart';

class ListFirm extends StatefulWidget {
  const ListFirm({Key? key}) : super(key: key);

  @override
  State<ListFirm> createState() => _ListFirmState();
}

class _ListFirmState extends State<ListFirm> {
  List<FirmModel> firms = [];
  List<FirmModel> firmResult = [];
  final TextEditingController searchCtrl = TextEditingController();
  ValueNotifier isSearch = ValueNotifier(false);
  ValueNotifier selectedJob = ValueNotifier(JobPositionModel());
  String? userId;

  @override
  void initState() {
    getJobPosition();
    super.initState();
  }

  getJobPosition() async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    userId = sharedPref
        .getString(
          'userId',
        )
        .toString();
    // Stream<QuerySnapshot<Map<String, dynamic>>> snapshotFirm =
    //     GV.firmsCol.snapshots();
    // if (snapshotFirm.map((event) =>) != null) {
    //   loadFirm = FirmModel.fromMap(isExistFirm.data()!);
    // }
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return StreamBuilder(
      stream: GV.firmsCol.snapshots(),
      builder: (context, snapshotFirm) {
        if (snapshotFirm.hasData) {
          firms = [];
          for (var element in snapshotFirm.data!.docs) {
            firms.add(FirmModel.fromMap(element.data()));
          }
          return ValueListenableBuilder(
            valueListenable: isSearch,
            builder: (context, value, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 40,
                          width: 350,
                          child: TextFormField(
                            controller: searchCtrl,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    searchCtrl.clear();
                                    isSearch.value = false;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              filled: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        CustomButton(
                          text: 'Tìm',
                          height: 40,
                          width: 70,
                          onTap: () {
                            if (searchCtrl.text.isNotEmpty) {
                              isSearch.value = true;
                              firmResult = firms
                                  .where((element) =>
                                      element.name!.contains(searchCtrl.text))
                                  .toList();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  isSearch.value
                      ? firmResult.isNotEmpty
                          ? SizedBox(
                              width: 750,
                              child: ListView.builder(
                                itemCount: firmResult.length,
                                shrinkWrap: true,
                                itemBuilder: (context, indexFirm) {
                                  return Card(
                                    child: ListTile(
                                      leading: const Icon(Icons.abc),
                                      title: Text(firmResult[indexFirm].name!),
                                      subtitle: Text(
                                        firmResult[indexFirm].describe!,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      onTap: () {
                                        for (var d in firmResult[indexFirm]
                                            .listRegis!) {
                                          if (d.userId == userId) {
                                            setState(() {
                                              selectedJob.value =
                                                  firmResult[indexFirm]
                                                      .listJob!
                                                      .firstWhere((element) =>
                                                          element.jobId ==
                                                          d.jobId);
                                            });
                                          }
                                        }
                                        showDialog(
                                          context: context,
                                          barrierColor: Colors.transparent,
                                          builder: (context) {
                                            return ValueListenableBuilder(
                                                valueListenable: selectedJob,
                                                builder:
                                                    (context, value, child) {
                                                  return Padding(
                                                    padding: EdgeInsets.only(
                                                      top: screenHeight * 0.06,
                                                      bottom:
                                                          screenHeight * 0.02,
                                                      left: screenWidth * 0.27,
                                                      right: screenWidth * 0.08,
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        AlertDialog(
                                                          scrollable: true,
                                                          title: Container(
                                                            color: Colors
                                                                .blue.shade600,
                                                            height: 50,
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        10),
                                                            child: const Text(
                                                                'Chi tiết tuyển dụng',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center),
                                                          ),
                                                          titlePadding:
                                                              EdgeInsets.zero,
                                                          shape: Border.all(),
                                                          content:
                                                              ConstrainedBox(
                                                            constraints:
                                                                BoxConstraints(
                                                                    minWidth:
                                                                        screenWidth *
                                                                            0.35),
                                                            child: Form(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <Widget>[
                                                                  Text(firmResult[
                                                                          indexFirm]
                                                                      .name!),
                                                                  Text(
                                                                    firmResult[
                                                                            indexFirm]
                                                                        .owner!,
                                                                  ),
                                                                  Text(
                                                                    firmResult[
                                                                            indexFirm]
                                                                        .phone!,
                                                                  ),
                                                                  Text(
                                                                    firmResult[
                                                                            indexFirm]
                                                                        .email!,
                                                                  ),
                                                                  Text(
                                                                    firmResult[
                                                                            indexFirm]
                                                                        .address!,
                                                                  ),
                                                                  Text(
                                                                    firmResult[
                                                                            indexFirm]
                                                                        .describe!,
                                                                  ),
                                                                  for (var data
                                                                      in firmResult[
                                                                              indexFirm]
                                                                          .listJob!)
                                                                    RadioListTile<
                                                                        JobPositionModel>(
                                                                      value:
                                                                          data,
                                                                      groupValue:
                                                                          selectedJob
                                                                              .value,
                                                                      title: Text(
                                                                          '${data.name} (Số lượng còn lại: ${data.quantity})'),
                                                                      subtitle:
                                                                          Text(data
                                                                              .describeJob!),
                                                                      onChanged:
                                                                          (val) {
                                                                        setState(
                                                                            () {
                                                                          selectedJob.value =
                                                                              val;
                                                                        });
                                                                      },
                                                                    ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          actions: [
                                                            ElevatedButton(
                                                              child: const Text(
                                                                  "Ứng tuyển"),
                                                              onPressed:
                                                                  () async {
                                                                if (selectedJob
                                                                        .value
                                                                        .jobId !=
                                                                    null) {
                                                                  if (firmResult[
                                                                          indexFirm]
                                                                      .listRegis!
                                                                      .where((element) =>
                                                                          element
                                                                              .userId ==
                                                                          userId)
                                                                      .isNotEmpty) {
                                                                    for (var d in firmResult[
                                                                            indexFirm]
                                                                        .listRegis!) {
                                                                      if (d.userId ==
                                                                          userId) {
                                                                        if (d.jobId ==
                                                                            selectedJob.value.jobId) {
                                                                          EasyLoading.showInfo(
                                                                              'Bạn đã ứng tuyển vị trí này trước đó.');
                                                                        } else {
                                                                          var listRegis =
                                                                              firmResult[indexFirm].listRegis;
                                                                          for (int i = 0;
                                                                              i < listRegis!.length;
                                                                              i++) {
                                                                            if (listRegis[i].jobId !=
                                                                                selectedJob.value.jobId) {
                                                                              listRegis[i].jobId = selectedJob.value.jobId;
                                                                              listRegis[i].name = selectedJob.value.name;
                                                                            }
                                                                          }
                                                                          GV.firmsCol
                                                                              .doc(firmResult[indexFirm]
                                                                                  .firmId)
                                                                              .update({
                                                                            'listRegis':
                                                                                listRegis.map((i) => i.toMap()).toList()
                                                                          });
                                                                          var loadListRegis = await GV
                                                                              .traineesCol
                                                                              .doc(userId)
                                                                              .get();

                                                                          final listUserRegis =
                                                                              RegisterTraineeModel.fromMap(loadListRegis.data()!).listRegis;
                                                                          for (int i = 0;
                                                                              i < listUserRegis!.length;
                                                                              i++) {
                                                                            if (listUserRegis[i].jobId !=
                                                                                selectedJob.value.jobId) {
                                                                              listUserRegis[i].jobId = selectedJob.value.jobId;
                                                                              listUserRegis[i].name = selectedJob.value.name;
                                                                            }
                                                                          }
                                                                          GV.traineesCol
                                                                              .doc(userId)
                                                                              .update({
                                                                            'listRegis':
                                                                                listUserRegis.map((i) => i.toMap()).toList(),
                                                                          });
                                                                          Navigator.pop(
                                                                              context);
                                                                          EasyLoading.showSuccess(
                                                                              'Đã cập nhật vị trí ứng tuyển.');
                                                                        }
                                                                      }
                                                                    }
                                                                  } else {
                                                                    final regis = JobRegisterModel(
                                                                        userId:
                                                                            userId,
                                                                        jobId: selectedJob
                                                                            .value
                                                                            .jobId,
                                                                        name: selectedJob
                                                                            .value
                                                                            .name);
                                                                    var listRegis =
                                                                        firmResult[indexFirm]
                                                                            .listRegis;
                                                                    listRegis!.add(
                                                                        regis);
                                                                    GV.firmsCol
                                                                        .doc(firmResult[indexFirm]
                                                                            .firmId)
                                                                        .update({
                                                                      'listRegis': listRegis
                                                                          .map((i) =>
                                                                              i.toMap())
                                                                          .toList()
                                                                    });
                                                                    final userRegis = UserRegisterModel(
                                                                        firmId: firmResult[indexFirm]
                                                                            .firmId,
                                                                        jobId: regis
                                                                            .jobId,
                                                                        name: regis
                                                                            .name);

                                                                    var loadListRegis = await GV
                                                                        .traineesCol
                                                                        .doc(
                                                                            userId)
                                                                        .get();

                                                                    final listUserRegis =
                                                                        RegisterTraineeModel.fromMap(loadListRegis.data()!)
                                                                            .listRegis;
                                                                    listUserRegis!
                                                                        .add(
                                                                            userRegis);
                                                                    GV.traineesCol
                                                                        .doc(
                                                                            userId)
                                                                        .update({
                                                                      'listRegis': listUserRegis
                                                                          .map((i) =>
                                                                              i.toMap())
                                                                          .toList(),
                                                                    });
                                                                    Navigator.pop(
                                                                        context);
                                                                    EasyLoading
                                                                        .showSuccess(
                                                                            'Đăng ký thành công.');
                                                                  }
                                                                } else {
                                                                  EasyLoading
                                                                      .showError(
                                                                          'Vui lòng chọn vị trí ứng tuyển.');
                                                                }
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                });
                                          },
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            )
                          : const Text('Không tìm thấy kết quả.')
                      : const Text('Danh sách các công ty.')
                ],
              );
            },
          );
        } else {
          return const Loading();
        }
      },
    );
  }
}
