// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/data/constant.dart';
import 'package:tttt_project/models/firm_model.dart';
import 'package:tttt_project/models/register_trainee_model.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/models/work_model.dart';
import 'package:tttt_project/widgets/custom_button.dart';
import 'package:tttt_project/widgets/custom_radio.dart';
import 'package:tttt_project/widgets/loading.dart';
import 'package:tttt_project/widgets/user_controller.dart';

class ListFirm extends StatefulWidget {
  const ListFirm({Key? key}) : super(key: key);

  @override
  State<ListFirm> createState() => _ListFirmState();
}

class _ListFirmState extends State<ListFirm> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<FirmModel> firms = [];
  List<FirmModel> firmResult = [];
  final TextEditingController searchCtrl = TextEditingController();
  ValueNotifier isSearch = ValueNotifier(false);
  String? userId;
  final currentUser = Get.put(UserController());
  bool isRegistered = false;

  @override
  void initState() {
    getJobPosition();
    super.initState();
  }

  getJobPosition() async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    bool? isLoggedIn = sharedPref.getBool("isLoggedIn");
    userId = sharedPref
        .getString(
          'userId',
        )
        .toString();
    if (isLoggedIn == true) {
      currentUser.setCurrentUser(
        setMenuSelected: sharedPref.getInt('menuSelected'),
      );
      DocumentSnapshot<Map<String, dynamic>> isExistUser =
          await firestore.collection('users').doc(userId).get();
      if (isExistUser.data() != null) {
        final loadUser = UserModel.fromMap(isExistUser.data()!);
        DocumentSnapshot<Map<String, dynamic>> isExitTrainee =
            await firestore.collection('trainees').doc(userId).get();
        if (isExitTrainee.data() != null) {
          setState(() {
            isRegistered = true;
          });
        }
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
    currentUser.loadIn.value = true;
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    isSearch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return StreamBuilder(
      stream: firestore.collection('firms').snapshots(),
      builder: (context, snapshotFirm) {
        if (snapshotFirm.hasData) {
          firms = [];
          for (var element in snapshotFirm.data!.docs) {
            firms.add(FirmModel.fromMap(element.data()));
          }
          bool isTrainee = false;
          firms.forEach((e1) => e1.listRegis!.forEach((e2) {
                if (e2.isConfirmed == true) {
                  isTrainee = true;
                }
              }));
          return ValueListenableBuilder(
            valueListenable: isSearch,
            builder: (context, value1, child) {
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
                            onChanged: (value) {
                              setState(() {
                                isSearch.value = false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 15),
                        CustomButton(
                          text: 'Tìm',
                          height: 40,
                          width: 100,
                          onTap: () {
                            if (searchCtrl.text.isNotEmpty) {
                              isSearch.value = true;
                              firmResult = firms
                                  .where((element) => element.firmName!
                                      .contains(searchCtrl.text))
                                  .toList();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  isSearch.value
                      ? firmResult.isNotEmpty
                          ? Container(
                              width: screenWidth * 0.5,
                              padding: const EdgeInsets.only(top: 15),
                              child: ListView.builder(
                                itemCount: firmResult.length,
                                shrinkWrap: true,
                                itemBuilder: (context, indexFirm) {
                                  return Card(
                                    elevation: 5,
                                    child: ListTile(
                                      leading: const Icon(Icons.house),
                                      title:
                                          Text(firmResult[indexFirm].firmName!),
                                      subtitle: Text(
                                        firmResult[indexFirm].describe!,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: firmResult[indexFirm]
                                                  .listRegis!
                                                  .firstWhere((element) =>
                                                      element.userId == userId)
                                                  .status ==
                                              TrangThai.accept
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                if (firmResult[indexFirm]
                                                        .listRegis!
                                                        .firstWhere((element) =>
                                                            element.userId ==
                                                            userId)
                                                        .isConfirmed ==
                                                    false)
                                                  Text(firmResult[indexFirm]
                                                      .listRegis!
                                                      .firstWhere((element) =>
                                                          element.userId ==
                                                          userId)
                                                      .status!),
                                                firmResult[indexFirm]
                                                            .listRegis!
                                                            .firstWhere(
                                                                (element) =>
                                                                    element
                                                                        .userId ==
                                                                    userId)
                                                            .isConfirmed ==
                                                        false
                                                    ? const Text(
                                                        'Chờ xác nhận',
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      )
                                                    : const Text(
                                                        'Công ty thực tập',
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                              ],
                                            )
                                          : Text(firmResult[indexFirm]
                                              .listRegis!
                                              .firstWhere((element) =>
                                                  element.userId == userId)
                                              .status!),
                                      onTap: () {
                                        JobRegisterModel loadRegis =
                                            JobRegisterModel();
                                        for (var d in firmResult[indexFirm]
                                            .listRegis!) {
                                          if (d.userId == userId) {
                                            currentUser.selectedJob.value =
                                                firmResult[indexFirm]
                                                    .listJob!
                                                    .firstWhere((element) =>
                                                        element.jobId ==
                                                        d.jobId);
                                            loadRegis = d;
                                            currentUser.traineeTime.value =
                                                DateTimeRange(
                                              start: DateTime
                                                  .fromMicrosecondsSinceEpoch(d
                                                      .traineeStart!
                                                      .microsecondsSinceEpoch),
                                              end: DateTime
                                                  .fromMicrosecondsSinceEpoch(d
                                                      .traineeEnd!
                                                      .microsecondsSinceEpoch),
                                            );
                                          }
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
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  AlertDialog(
                                                    scrollable: true,
                                                    title: Container(
                                                      color:
                                                          Colors.blue.shade600,
                                                      height: 50,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 10,
                                                          horizontal: 10),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Expanded(
                                                            child: Text(
                                                                'Chi tiết tuyển dụng',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center),
                                                          ),
                                                          IconButton(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          1),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              icon: const Icon(
                                                                  Icons.close))
                                                        ],
                                                      ),
                                                    ),
                                                    titlePadding:
                                                        EdgeInsets.zero,
                                                    shape:
                                                        Border.all(width: 0.5),
                                                    content: ConstrainedBox(
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
                                                            Text(
                                                                'Tên công ty: ${firmResult[indexFirm].firmName!}'),
                                                            Text(
                                                                'Người đại diện: ${firmResult[indexFirm].owner!}'),
                                                            Text(
                                                                'Số điện thoại: ${firmResult[indexFirm].phone!}'),
                                                            Text(
                                                                'Email: ${firmResult[indexFirm].email!}'),
                                                            Text(
                                                                'Địa chỉ: ${firmResult[indexFirm].address!}'),
                                                            Text(
                                                                'Mô tả: ${firmResult[indexFirm].describe!}'),
                                                            if (loadRegis
                                                                        .status ==
                                                                    TrangThai
                                                                        .wait ||
                                                                loadRegis
                                                                        .userId ==
                                                                    null) ...[
                                                              const Text(
                                                                  'Vị trí tuyển dụng:'),
                                                              for (var data
                                                                  in firmResult[
                                                                          indexFirm]
                                                                      .listJob!)
                                                                Obx(
                                                                  () =>
                                                                      CustomRadio(
                                                                    title:
                                                                        '${data.jobName} - SL còn lai: ${data.quantity}',
                                                                    onTap: () =>
                                                                        currentUser
                                                                            .selectedJob
                                                                            .value = data,
                                                                    subtitle:
                                                                        '${data.describeJob}',
                                                                    selected: currentUser
                                                                            .selectedJob
                                                                            .value ==
                                                                        data,
                                                                  ),
                                                                ),
                                                              const Text(
                                                                  'Thời gian thưc tập:'),
                                                              const SizedBox(
                                                                  height: 10),
                                                              Obx(
                                                                () => Padding(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          70),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Expanded(
                                                                          child:
                                                                              ElevatedButton(
                                                                        onPressed:
                                                                            pickDateRange,
                                                                        child: Text(DateFormat('dd/MM/yyyy').format(currentUser
                                                                            .traineeTime
                                                                            .value
                                                                            .start)),
                                                                      )),
                                                                      const SizedBox(
                                                                          width:
                                                                              25),
                                                                      Expanded(
                                                                          child:
                                                                              ElevatedButton(
                                                                        onPressed:
                                                                            pickDateRange,
                                                                        child: Text(DateFormat('dd/MM/yyyy').format(currentUser
                                                                            .traineeTime
                                                                            .value
                                                                            .end)),
                                                                      )),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 15),
                                                              if (isTrainee ==
                                                                  true)
                                                                const Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .only(
                                                                              top: 15),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      Text(
                                                                        'Bạn đã có công ty thực tập không thể ứng tuyển được nữa.',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              Colors.red,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                )
                                                            ] else ...[
                                                              Text(
                                                                  'Vị trí ứng tuyển: ${currentUser.selectedJob.value.jobName} '),
                                                              Text(
                                                                  'Ngày bắt đầu: ${GV.readTimestamp(loadRegis.traineeStart!)} - Ngày kết thúc:  ${GV.readTimestamp(loadRegis.traineeEnd!)}'),
                                                              Text(
                                                                  'Ngày ứng tuyển: ${GV.readTimestamp(loadRegis.createdAt!)}'),
                                                              Text(
                                                                  'Ngày duyệt: ${GV.readTimestamp(loadRegis.repliedAt!)}'),
                                                              if (isTrainee ==
                                                                  false)
                                                                const SizedBox(
                                                                    width: 15),
                                                            ],
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    actions: loadRegis.status ==
                                                                TrangThai
                                                                    .wait &&
                                                            isTrainee == false
                                                        ? [
                                                            ElevatedButton(
                                                              child: const Text(
                                                                "Ứng tuyển",
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                              onPressed:
                                                                  () async {
                                                                if (isRegistered
                                                                    == true) {
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
                                                                        if (d.jobId == currentUser.selectedJob.value.jobId &&
                                                                            d.traineeStart ==
                                                                                Timestamp.fromDate(currentUser
                                                                                    .traineeTime.value.start) &&
                                                                            d.traineeEnd ==
                                                                                Timestamp.fromDate(currentUser
                                                                                    .traineeTime.value.end)) {
                                                                          GV.warning(
                                                                              context: context,
                                                                              message: 'Không có gì thay đổi.');
                                                                        } else if (currentUser.selectedJob.value.jobId ==
                                                                            null) {
                                                                          GV.error(
                                                                              context: context,
                                                                              message: 'Vui lòng chọn vị trí ứng tuyển.');
                                                                        } else if (currentUser.traineeTime.value.start ==
                                                                            currentUser.traineeTime.value.end) {
                                                                          GV.error(
                                                                              context: context,
                                                                              message: 'Vui lòng chọn thời gian phù hợp.');
                                                                        } else {
                                                                          var listRegis =
                                                                              firmResult[indexFirm].listRegis;
                                                                          for (int i = 0;
                                                                              i < listRegis!.length;
                                                                              i++) {
                                                                            if (listRegis[i].userId ==
                                                                                currentUser.userId.value) {
                                                                              if (listRegis[i].jobId != currentUser.selectedJob.value.jobId) {
                                                                                listRegis[i].jobId = currentUser.selectedJob.value.jobId;
                                                                                listRegis[i].jobName = currentUser.selectedJob.value.jobName;
                                                                              }
                                                                              listRegis[i].traineeStart = Timestamp.fromDate(currentUser.traineeTime.value.start);
                                                                              listRegis[i].traineeEnd = Timestamp.fromDate(currentUser.traineeTime.value.end);
                                                                            }
                                                                          }

                                                                          firestore
                                                                              .collection(
                                                                                  'firms')
                                                                              .doc(firmResult[indexFirm]
                                                                                  .firmId)
                                                                              .update({
                                                                            'listRegis':
                                                                                listRegis.map((i) => i.toMap()).toList()
                                                                          });
                                                                          var loadListRegis = await firestore
                                                                              .collection('trainees')
                                                                              .doc(userId)
                                                                              .get();

                                                                          final listUserRegis =
                                                                              RegisterTraineeModel.fromMap(loadListRegis.data()!).listRegis;
                                                                          for (int i = 0;
                                                                              i < listUserRegis!.length;
                                                                              i++) {
                                                                            if (listUserRegis[i].firmId ==
                                                                                firmResult[indexFirm].firmId) {
                                                                              if (listUserRegis[i].jobId != currentUser.selectedJob.value.jobId) {
                                                                                listUserRegis[i].jobId = currentUser.selectedJob.value.jobId;
                                                                                listUserRegis[i].jobName = currentUser.selectedJob.value.jobName;
                                                                              }

                                                                              listUserRegis[i].traineeStart = Timestamp.fromDate(currentUser.traineeTime.value.start);
                                                                              listUserRegis[i].traineeEnd = Timestamp.fromDate(currentUser.traineeTime.value.end);
                                                                            }
                                                                          }
                                                                          firestore
                                                                              .collection('trainees')
                                                                              .doc(userId)
                                                                              .update({
                                                                            'listRegis':
                                                                                listUserRegis.map((i) => i.toMap()).toList(),
                                                                          });
                                                                          Navigator.pop(
                                                                              context);
                                                                          GV.success(
                                                                              context: context,
                                                                              message: 'Đã cập nhật thành công.');
                                                                        }
                                                                      }
                                                                    }
                                                                  } else {
                                                                    if (currentUser
                                                                            .selectedJob
                                                                            .value
                                                                            .jobId ==
                                                                        null) {
                                                                      GV.error(
                                                                          context:
                                                                              context,
                                                                          message:
                                                                              'Vui lòng chọn vị trí ứng tuyển.');
                                                                    } else if (currentUser
                                                                            .traineeTime
                                                                            .value
                                                                            .start ==
                                                                        currentUser
                                                                            .traineeTime
                                                                            .value
                                                                            .end) {
                                                                      GV.error(
                                                                          context:
                                                                              context,
                                                                          message:
                                                                              'Vui lòng chọn thời gian phù hợp.');
                                                                    } else {
                                                                      final regis =
                                                                          JobRegisterModel(
                                                                        userId:
                                                                            userId,
                                                                        jobId: currentUser
                                                                            .selectedJob
                                                                            .value
                                                                            .jobId,
                                                                        userName: currentUser
                                                                            .userName
                                                                            .value,
                                                                        jobName: currentUser
                                                                            .selectedJob
                                                                            .value
                                                                            .jobName,
                                                                        status:
                                                                            TrangThai.wait,
                                                                        createdAt:
                                                                            Timestamp.now(),
                                                                        traineeStart: Timestamp.fromDate(currentUser
                                                                            .traineeTime
                                                                            .value
                                                                            .start),
                                                                        traineeEnd: Timestamp.fromDate(currentUser
                                                                            .traineeTime
                                                                            .value
                                                                            .end),
                                                                      );
                                                                      var listRegis =
                                                                          firmResult[indexFirm]
                                                                              .listRegis;
                                                                      listRegis!
                                                                          .add(
                                                                              regis);
                                                                      firestore
                                                                          .collection(
                                                                              'firms')
                                                                          .doc(firmResult[indexFirm]
                                                                              .firmId)
                                                                          .update({
                                                                        'listRegis': listRegis
                                                                            .map((i) =>
                                                                                i.toMap())
                                                                            .toList()
                                                                      });
                                                                      final userRegis =
                                                                          UserRegisterModel(
                                                                        firmId:
                                                                            firmResult[indexFirm].firmId,
                                                                        jobId: regis
                                                                            .jobId,
                                                                        jobName:
                                                                            regis.jobName,
                                                                        status:
                                                                            TrangThai.wait,
                                                                        createdAt:
                                                                            Timestamp.now(),
                                                                        traineeStart: Timestamp.fromDate(currentUser
                                                                            .traineeTime
                                                                            .value
                                                                            .start),
                                                                        traineeEnd: Timestamp.fromDate(currentUser
                                                                            .traineeTime
                                                                            .value
                                                                            .end),
                                                                      );

                                                                      var loadListRegis = await firestore
                                                                          .collection(
                                                                              'trainees')
                                                                          .doc(
                                                                              userId)
                                                                          .get();

                                                                      final listUserRegis =
                                                                          RegisterTraineeModel.fromMap(loadListRegis.data()!)
                                                                              .listRegis;
                                                                      listUserRegis!
                                                                          .add(
                                                                              userRegis);
                                                                      firestore
                                                                          .collection(
                                                                              'trainees')
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
                                                                      GV.success(
                                                                          context:
                                                                              context,
                                                                          message:
                                                                              'Đăng ký thành công.');
                                                                    }
                                                                  }
                                                                } else {
                                                                  GV.error(
                                                                      context:
                                                                          context,
                                                                      message:
                                                                          'Bạn cần phải đăng ký thực tập trước khi ứng tuyển.');
                                                                }
                                                              },
                                                            ),
                                                          ]
                                                        : loadRegis.status ==
                                                                    TrangThai
                                                                        .accept &&
                                                                loadRegis
                                                                        .isConfirmed ==
                                                                    false &&
                                                                isTrainee ==
                                                                    false
                                                            ? [
                                                                ElevatedButton(
                                                                  onPressed:
                                                                      () async {
                                                                    var loadCBHD = await firestore
                                                                        .collection(
                                                                            'users')
                                                                        .doc(firmResult[indexFirm]
                                                                            .firmId)
                                                                        .get();
                                                                    final cbhdName =
                                                                        UserModel.fromMap(loadCBHD.data()!)
                                                                            .userName;
                                                                    final plan =
                                                                        PlanModel(
                                                                      cbhdId: firmResult[
                                                                              indexFirm]
                                                                          .firmId,
                                                                      cbhdName:
                                                                          cbhdName,
                                                                      listWork: [],
                                                                      userId:
                                                                          userId,
                                                                    );
                                                                    var listRegis =
                                                                        firmResult[indexFirm]
                                                                            .listRegis;
                                                                    for (int i =
                                                                            0;
                                                                        i < listRegis!.length;
                                                                        i++) {
                                                                      if (listRegis[i]
                                                                              .userId ==
                                                                          currentUser
                                                                              .userId
                                                                              .value) {
                                                                        if (listRegis[i].jobId ==
                                                                            currentUser.selectedJob.value.jobId) {
                                                                          listRegis[i].isConfirmed =
                                                                              true;
                                                                          plan.traineeStart =
                                                                              listRegis[i].traineeStart;
                                                                          plan.traineeEnd =
                                                                              listRegis[i].traineeEnd;
                                                                        }
                                                                      }
                                                                    }
                                                                    firestore
                                                                        .collection(
                                                                            'plans')
                                                                        .doc(
                                                                            userId)
                                                                        .set(plan
                                                                            .toMap());
                                                                    firestore
                                                                        .collection(
                                                                            'firms')
                                                                        .doc(firmResult[indexFirm]
                                                                            .firmId)
                                                                        .update({
                                                                      'listRegis': listRegis
                                                                          .map((i) =>
                                                                              i.toMap())
                                                                          .toList()
                                                                    });
                                                                    var loadListRegis = await GV
                                                                        .traineesCol
                                                                        .doc(
                                                                            userId)
                                                                        .get();
                                                                    final listUserRegis =
                                                                        RegisterTraineeModel.fromMap(loadListRegis.data()!)
                                                                            .listRegis;
                                                                    for (int i =
                                                                            0;
                                                                        i < listUserRegis!.length;
                                                                        i++) {
                                                                      if (listUserRegis[i]
                                                                              .firmId ==
                                                                          firmResult[indexFirm]
                                                                              .firmId) {
                                                                        if (listUserRegis[i].jobId ==
                                                                            currentUser.selectedJob.value.jobId) {
                                                                          listUserRegis[i].isConfirmed =
                                                                              true;
                                                                        }
                                                                      }
                                                                    }
                                                                    firestore
                                                                        .collection(
                                                                            'trainees')
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
                                                                    GV.success(
                                                                        context:
                                                                            context,
                                                                        message:
                                                                            'Đã xác nhận công ty thực tập');
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    'Xác nhận',
                                                                    style:
                                                                        TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                                  ),
                                                                ),
                                                                ElevatedButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                    'Để sau',
                                                                    style:
                                                                        TextStyle(
                                                                      color: Colors
                                                                          .red,
                                                                      fontSize:
                                                                          16,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ]
                                                            : null,
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            )
                          : const Text('Không tìm thấy kết quả.')
                      : Container(
                          width: screenWidth * 0.5,
                          padding: const EdgeInsets.only(top: 15),
                          child: ListView.builder(
                            itemCount: firms.length,
                            shrinkWrap: true,
                            itemBuilder: (context, indexFirm) {
                              return Card(
                                elevation: 5,
                                child: ListTile(
                                  leading: const Icon(Icons.house),
                                  title: Text(firms[indexFirm].firmName!),
                                  subtitle: Text(
                                    firms[indexFirm].describe!,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: firms[indexFirm]
                                              .listRegis!
                                              .firstWhere((element) =>
                                                  element.userId == userId)
                                              .status ==
                                          TrangThai.accept
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            if (firms[indexFirm]
                                                    .listRegis!
                                                    .firstWhere((element) =>
                                                        element.userId ==
                                                        userId)
                                                    .isConfirmed ==
                                                false)
                                              Text(firms[indexFirm]
                                                  .listRegis!
                                                  .firstWhere((element) =>
                                                      element.userId == userId)
                                                  .status!),
                                            firms[indexFirm]
                                                        .listRegis!
                                                        .firstWhere((element) =>
                                                            element.userId ==
                                                            userId)
                                                        .isConfirmed ==
                                                    false
                                                ? const Text(
                                                    'Chờ xác nhận',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  )
                                                : const Text(
                                                    'Công ty thực tập',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                          ],
                                        )
                                      : Text(firms[indexFirm]
                                          .listRegis!
                                          .firstWhere((element) =>
                                              element.userId == userId)
                                          .status!),
                                  onTap: () {
                                    JobRegisterModel loadRegis =
                                        JobRegisterModel();
                                    for (var d in firms[indexFirm].listRegis!) {
                                      if (d.userId == userId) {
                                        currentUser.selectedJob.value =
                                            firms[indexFirm]
                                                .listJob!
                                                .firstWhere((element) =>
                                                    element.jobId == d.jobId);
                                        loadRegis = d;
                                        currentUser.traineeTime.value =
                                            DateTimeRange(
                                          start: DateTime
                                              .fromMicrosecondsSinceEpoch(d
                                                  .traineeStart!
                                                  .microsecondsSinceEpoch),
                                          end: DateTime
                                              .fromMicrosecondsSinceEpoch(d
                                                  .traineeEnd!
                                                  .microsecondsSinceEpoch),
                                        );
                                      }
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              AlertDialog(
                                                scrollable: true,
                                                title: Container(
                                                  color: Colors.blue.shade600,
                                                  height: 50,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 10,
                                                      horizontal: 10),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Expanded(
                                                        child: Text(
                                                            'Chi tiết tuyển dụng',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                            textAlign: TextAlign
                                                                .center),
                                                      ),
                                                      IconButton(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 1),
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          icon: const Icon(
                                                              Icons.close))
                                                    ],
                                                  ),
                                                ),
                                                titlePadding: EdgeInsets.zero,
                                                shape: Border.all(width: 0.5),
                                                content: ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                      minWidth:
                                                          screenWidth * 0.35),
                                                  child: Form(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Text(
                                                            'Tên công ty: ${firms[indexFirm].firmName!}'),
                                                        Text(
                                                            'Người đại diện: ${firms[indexFirm].owner!}'),
                                                        Text(
                                                            'Số điện thoại: ${firms[indexFirm].phone!}'),
                                                        Text(
                                                            'Email: ${firms[indexFirm].email!}'),
                                                        Text(
                                                            'Địa chỉ: ${firms[indexFirm].address!}'),
                                                        Text(
                                                            'Mô tả: ${firms[indexFirm].describe!}'),
                                                        if (loadRegis.status ==
                                                                TrangThai
                                                                    .wait ||
                                                            loadRegis.userId ==
                                                                null) ...[
                                                          const Text(
                                                              'Vị trí tuyển dụng:'),
                                                          for (var data
                                                              in firms[
                                                                      indexFirm]
                                                                  .listJob!)
                                                            Obx(
                                                              () => CustomRadio(
                                                                title:
                                                                    '${data.jobName} - SL còn lai: ${data.quantity}',
                                                                onTap: () => currentUser
                                                                    .selectedJob
                                                                    .value = data,
                                                                subtitle:
                                                                    '${data.describeJob}',
                                                                selected: currentUser
                                                                        .selectedJob
                                                                        .value ==
                                                                    data,
                                                              ),
                                                            ),
                                                          const Text(
                                                              'Thời gian thưc tập:'),
                                                          const SizedBox(
                                                              height: 10),
                                                          Obx(
                                                            () => Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          70),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Expanded(
                                                                      child:
                                                                          ElevatedButton(
                                                                    onPressed:
                                                                        pickDateRange,
                                                                    child: Text(DateFormat(
                                                                            'dd/MM/yyyy')
                                                                        .format(currentUser
                                                                            .traineeTime
                                                                            .value
                                                                            .start)),
                                                                  )),
                                                                  const SizedBox(
                                                                      width:
                                                                          25),
                                                                  Expanded(
                                                                      child:
                                                                          ElevatedButton(
                                                                    onPressed:
                                                                        pickDateRange,
                                                                    child: Text(DateFormat(
                                                                            'dd/MM/yyyy')
                                                                        .format(currentUser
                                                                            .traineeTime
                                                                            .value
                                                                            .end)),
                                                                  )),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 15),
                                                          if (isTrainee == true)
                                                            const Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 15),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    'Bạn đã có công ty thực tập không thể ứng tuyển được nữa.',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .red,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                        ] else ...[
                                                          Text(
                                                              'Vị trí ứng tuyển: ${currentUser.selectedJob.value.jobName} '),
                                                          Text(
                                                              'Ngày bắt đầu: ${GV.readTimestamp(loadRegis.traineeStart!)} - Ngày kết thúc:  ${GV.readTimestamp(loadRegis.traineeEnd!)}'),
                                                          Text(
                                                              'Ngày ứng tuyển: ${GV.readTimestamp(loadRegis.createdAt!)}'),
                                                          Text(
                                                              'Ngày duyệt: ${GV.readTimestamp(loadRegis.repliedAt!)}'),
                                                          if (isTrainee ==
                                                              false)
                                                            const SizedBox(
                                                                width: 15),
                                                        ],
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                actions: loadRegis.status ==
                                                            TrangThai.wait &&
                                                        isTrainee == false
                                                    ? [
                                                        ElevatedButton(
                                                          child: const Text(
                                                            "Ứng tuyển",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          onPressed: () async {
                                                            if (isRegistered
                                                                == true) {
                                                              if (firms[
                                                                      indexFirm]
                                                                  .listRegis!
                                                                  .where((element) =>
                                                                      element
                                                                          .userId ==
                                                                      userId)
                                                                  .isNotEmpty) {
                                                                for (var d in firms[
                                                                        indexFirm]
                                                                    .listRegis!) {
                                                                  if (d.userId ==
                                                                      userId) {
                                                                    if (d.jobId ==
                                                                            currentUser
                                                                                .selectedJob.value.jobId &&
                                                                        d.traineeStart ==
                                                                            Timestamp.fromDate(currentUser
                                                                                .traineeTime.value.start) &&
                                                                        d.traineeEnd ==
                                                                            Timestamp.fromDate(currentUser
                                                                                .traineeTime.value.end)) {
                                                                      GV.warning(
                                                                          context:
                                                                              context,
                                                                          message:
                                                                              'Không có gì thay đổi.');
                                                                    } else if (currentUser
                                                                            .selectedJob
                                                                            .value
                                                                            .jobId ==
                                                                        null) {
                                                                      GV.error(
                                                                          context:
                                                                              context,
                                                                          message:
                                                                              'Vui lòng chọn vị trí ứng tuyển.');
                                                                    } else if (currentUser
                                                                            .traineeTime
                                                                            .value
                                                                            .start ==
                                                                        currentUser
                                                                            .traineeTime
                                                                            .value
                                                                            .end) {
                                                                      GV.error(
                                                                          context:
                                                                              context,
                                                                          message:
                                                                              'Vui lòng chọn thời gian phù hợp.');
                                                                    } else {
                                                                      var listRegis =
                                                                          firms[indexFirm]
                                                                              .listRegis;
                                                                      for (int i =
                                                                              0;
                                                                          i < listRegis!.length;
                                                                          i++) {
                                                                        if (listRegis[i].userId ==
                                                                            currentUser.userId.value) {
                                                                          if (listRegis[i].jobId !=
                                                                              currentUser.selectedJob.value.jobId) {
                                                                            listRegis[i].jobId =
                                                                                currentUser.selectedJob.value.jobId;
                                                                            listRegis[i].jobName =
                                                                                currentUser.selectedJob.value.jobName;
                                                                          }
                                                                          listRegis[i].traineeStart = Timestamp.fromDate(currentUser
                                                                              .traineeTime
                                                                              .value
                                                                              .start);
                                                                          listRegis[i].traineeEnd = Timestamp.fromDate(currentUser
                                                                              .traineeTime
                                                                              .value
                                                                              .end);
                                                                        }
                                                                      }
                                                                      firestore
                                                                          .collection(
                                                                              'firms')
                                                                          .doc(firms[indexFirm]
                                                                              .firmId)
                                                                          .update({
                                                                        'listRegis': listRegis
                                                                            .map((i) =>
                                                                                i.toMap())
                                                                            .toList()
                                                                      });
                                                                      var loadListRegis = await firestore
                                                                          .collection(
                                                                              'trainees')
                                                                          .doc(
                                                                              userId)
                                                                          .get();

                                                                      final listUserRegis =
                                                                          RegisterTraineeModel.fromMap(loadListRegis.data()!)
                                                                              .listRegis;
                                                                      for (int i =
                                                                              0;
                                                                          i < listUserRegis!.length;
                                                                          i++) {
                                                                        if (listUserRegis[i].firmId ==
                                                                            firms[indexFirm].firmId) {
                                                                          if (listUserRegis[i].jobId !=
                                                                              currentUser.selectedJob.value.jobId) {
                                                                            listUserRegis[i].jobId =
                                                                                currentUser.selectedJob.value.jobId;
                                                                            listUserRegis[i].jobName =
                                                                                currentUser.selectedJob.value.jobName;
                                                                          }

                                                                          listUserRegis[i].traineeStart = Timestamp.fromDate(currentUser
                                                                              .traineeTime
                                                                              .value
                                                                              .start);
                                                                          listUserRegis[i].traineeEnd = Timestamp.fromDate(currentUser
                                                                              .traineeTime
                                                                              .value
                                                                              .end);
                                                                        }
                                                                      }
                                                                      firestore
                                                                          .collection(
                                                                              'trainees')
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
                                                                      GV.success(
                                                                          context:
                                                                              context,
                                                                          message:
                                                                              'Đã cập nhật thành công.');
                                                                    }
                                                                  }
                                                                }
                                                              } else {
                                                                if (currentUser
                                                                        .selectedJob
                                                                        .value
                                                                        .jobId ==
                                                                    null) {
                                                                  GV.error(
                                                                      context:
                                                                          context,
                                                                      message:
                                                                          'Vui lòng chọn vị trí ứng tuyển.');
                                                                } else if (currentUser
                                                                        .traineeTime
                                                                        .value
                                                                        .start ==
                                                                    currentUser
                                                                        .traineeTime
                                                                        .value
                                                                        .end) {
                                                                  GV.error(
                                                                      context:
                                                                          context,
                                                                      message:
                                                                          'Vui lòng chọn thời gian phù hợp.');
                                                                } else {
                                                                  final regis =
                                                                      JobRegisterModel(
                                                                    userId:
                                                                        userId,
                                                                    jobId: currentUser
                                                                        .selectedJob
                                                                        .value
                                                                        .jobId,
                                                                    userName:
                                                                        currentUser
                                                                            .userName
                                                                            .value,
                                                                    jobName: currentUser
                                                                        .selectedJob
                                                                        .value
                                                                        .jobName,
                                                                    status:
                                                                        TrangThai
                                                                            .wait,
                                                                    createdAt:
                                                                        Timestamp
                                                                            .now(),
                                                                    traineeStart: Timestamp.fromDate(currentUser
                                                                        .traineeTime
                                                                        .value
                                                                        .start),
                                                                    traineeEnd: Timestamp.fromDate(currentUser
                                                                        .traineeTime
                                                                        .value
                                                                        .end),
                                                                  );
                                                                  var listRegis =
                                                                      firms[indexFirm]
                                                                          .listRegis;
                                                                  listRegis!.add(
                                                                      regis);
                                                                  firestore
                                                                      .collection(
                                                                          'firms')
                                                                      .doc(firms[
                                                                              indexFirm]
                                                                          .firmId)
                                                                      .update({
                                                                    'listRegis': listRegis
                                                                        .map((i) =>
                                                                            i.toMap())
                                                                        .toList()
                                                                  });
                                                                  final userRegis =
                                                                      UserRegisterModel(
                                                                    firmId: firms[
                                                                            indexFirm]
                                                                        .firmId,
                                                                    jobId: regis
                                                                        .jobId,
                                                                    jobName: regis
                                                                        .jobName,
                                                                    status:
                                                                        TrangThai
                                                                            .wait,
                                                                    createdAt:
                                                                        Timestamp
                                                                            .now(),
                                                                    traineeStart: Timestamp.fromDate(currentUser
                                                                        .traineeTime
                                                                        .value
                                                                        .start),
                                                                    traineeEnd: Timestamp.fromDate(currentUser
                                                                        .traineeTime
                                                                        .value
                                                                        .end),
                                                                  );
                                                                  var loadListRegis = await firestore
                                                                      .collection(
                                                                          'trainees')
                                                                      .doc(
                                                                          userId)
                                                                      .get();
                                                                  final listUserRegis =
                                                                      RegisterTraineeModel.fromMap(
                                                                              loadListRegis.data()!)
                                                                          .listRegis;
                                                                  listUserRegis!
                                                                      .add(
                                                                          userRegis);
                                                                  firestore
                                                                      .collection(
                                                                          'trainees')
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
                                                                  GV.success(
                                                                      context:
                                                                          context,
                                                                      message:
                                                                          'Đăng ký thành công.');
                                                                }
                                                              }
                                                            } else {
                                                              GV.error(
                                                                  context:
                                                                      context,
                                                                  message:
                                                                      'Bạn cần phải đăng ký thực tập trước khi ứng tuyển.');
                                                            }
                                                          },
                                                        ),
                                                      ]
                                                    : loadRegis.status ==
                                                                TrangThai
                                                                    .accept &&
                                                            loadRegis
                                                                    .isConfirmed ==
                                                                false &&
                                                            isTrainee == false
                                                        ? [
                                                            ElevatedButton(
                                                              onPressed:
                                                                  () async {
                                                                var loadCBHD = await firestore
                                                                    .collection(
                                                                        'users')
                                                                    .doc(firms[
                                                                            indexFirm]
                                                                        .firmId)
                                                                    .get();

                                                                final cbhdName =
                                                                    UserModel.fromMap(
                                                                            loadCBHD.data()!)
                                                                        .userName;
                                                                final plan =
                                                                    PlanModel(
                                                                  cbhdId: firms[
                                                                          indexFirm]
                                                                      .firmId,
                                                                  cbhdName:
                                                                      cbhdName,
                                                                  listWork: [],
                                                                  userId:
                                                                      userId,
                                                                );
                                                                var listRegis =
                                                                    firms[indexFirm]
                                                                        .listRegis;
                                                                for (int i = 0;
                                                                    i <
                                                                        listRegis!
                                                                            .length;
                                                                    i++) {
                                                                  if (listRegis[
                                                                              i]
                                                                          .userId ==
                                                                      currentUser
                                                                          .userId
                                                                          .value) {
                                                                    if (listRegis[i]
                                                                            .jobId ==
                                                                        currentUser
                                                                            .selectedJob
                                                                            .value
                                                                            .jobId) {
                                                                      listRegis[i]
                                                                              .isConfirmed =
                                                                          true;
                                                                      plan.traineeStart =
                                                                          listRegis[i]
                                                                              .traineeStart;
                                                                      plan.traineeEnd =
                                                                          listRegis[i]
                                                                              .traineeEnd;
                                                                    }
                                                                  }
                                                                }
                                                                firestore
                                                                    .collection(
                                                                        'plans')
                                                                    .doc(userId)
                                                                    .set(plan
                                                                        .toMap());
                                                                firestore
                                                                    .collection(
                                                                        'firms')
                                                                    .doc(firms[
                                                                            indexFirm]
                                                                        .firmId)
                                                                    .update({
                                                                  'listRegis': listRegis
                                                                      .map((i) =>
                                                                          i.toMap())
                                                                      .toList()
                                                                });
                                                                var loadListRegis =
                                                                    await GV
                                                                        .traineesCol
                                                                        .doc(
                                                                            userId)
                                                                        .get();
                                                                final listUserRegis =
                                                                    RegisterTraineeModel.fromMap(
                                                                            loadListRegis.data()!)
                                                                        .listRegis;
                                                                for (int i = 0;
                                                                    i <
                                                                        listUserRegis!
                                                                            .length;
                                                                    i++) {
                                                                  if (listUserRegis[
                                                                              i]
                                                                          .firmId ==
                                                                      firms[indexFirm]
                                                                          .firmId) {
                                                                    if (listUserRegis[i]
                                                                            .jobId ==
                                                                        currentUser
                                                                            .selectedJob
                                                                            .value
                                                                            .jobId) {
                                                                      listUserRegis[i]
                                                                              .isConfirmed =
                                                                          true;
                                                                    }
                                                                  }
                                                                }
                                                                firestore
                                                                    .collection(
                                                                        'trainees')
                                                                    .doc(userId)
                                                                    .update({
                                                                  'listRegis': listUserRegis
                                                                      .map((i) =>
                                                                          i.toMap())
                                                                      .toList(),
                                                                });
                                                                Navigator.pop(
                                                                    context);
                                                                GV.success(
                                                                    context:
                                                                        context,
                                                                    message:
                                                                        'Đã xác nhận công ty thực tập');
                                                              },
                                                              child: const Text(
                                                                'Xác nhận',
                                                                style:
                                                                    TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ),
                                                            ElevatedButton(
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: const Text(
                                                                'Để sau',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .red,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ),
                                                          ]
                                                        : null,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        )
                ],
              );
            },
          );
        } else {
          return const Padding(
            padding: EdgeInsets.only(top: 200),
            child: Loading(),
          );
        }
      },
    );
  }

  Future pickDateRange() async {
    DateTimeRange? newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(2025),
      builder: (context, child) {
        double screenHeight = MediaQuery.of(context).size.height;
        double screenWidth = MediaQuery.of(context).size.width;
        return Padding(
          padding: EdgeInsets.only(
            top: screenHeight * 0.15,
            bottom: screenHeight * 0.06,
            left: screenWidth * 0.4,
            right: screenWidth * 0.21,
          ),
          child: SizedBox(
            height: 450,
            width: 700,
            child: child,
          ),
        );
      },
    );
    if (newDateRange == null) return;
    setState(() {
      currentUser.traineeTime.value = newDateRange;
    });
  }
}
