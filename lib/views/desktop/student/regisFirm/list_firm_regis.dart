// ignore_for_file: use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/common/constant.dart';
import 'package:tttt_project/common/date_time_extension.dart';
import 'package:tttt_project/models/firm_model.dart';
import 'package:tttt_project/models/register_trainee_model.dart';
import 'package:tttt_project/models/setting_trainee_model.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:tttt_project/models/plan_work_model.dart';
import 'package:tttt_project/widgets/custom_radio.dart';
import 'package:tttt_project/widgets/field_detail.dart';
import 'package:tttt_project/widgets/loading.dart';
import 'package:tttt_project/common/user_controller.dart';

class ListFirmRegis extends StatefulWidget {
  const ListFirmRegis({
    super.key,
  });

  @override
  State<ListFirmRegis> createState() => _ListFirmRegisState();
}

class _ListFirmRegisState extends State<ListFirmRegis> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final currentUser = Get.put(UserController());
  String? userId;
  List<FirmModel> loadFirms = [];
  List<UserRegisterModel> listRegis = [];
  FirmModel firm = FirmModel();
  bool isRegistered = false;
  RegisterTraineeModel trainee = RegisterTraineeModel();
  SettingTraineeModel setting = SettingTraineeModel();

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  getData() async {
    final SharedPreferences sharedPref = await SharedPreferences.getInstance();
    userId = sharedPref
        .getString(
          'userId',
        )
        .toString();
    var loadData = await firestore.collection('firms').get();
    if (loadData.docs.isNotEmpty) {
      loadFirms =
          loadData.docs.map((e) => FirmModel.fromMap(e.data())).toList();
    }
    bool? isLoggedIn = sharedPref.getBool("isLoggedIn");
    if (isLoggedIn == true) {
      currentUser.setCurrentUser(
        setMenuSelected: sharedPref.getInt('menuSelected'),
      );
      DocumentSnapshot<Map<String, dynamic>> isExistUser =
          await firestore.collection('users').doc(userId).get();
      if (isExistUser.data() != null) {
        final loadUser = UserModel.fromMap(isExistUser.data()!);
        DocumentSnapshot<Map<String, dynamic>> atMoment =
            await firestore.collection('atMoment').doc('now').get();
        if (atMoment.data() != null) {
          QuerySnapshot<Map<String, dynamic>> isExistSettingTrainee =
              await firestore
                  .collection('settingTrainees')
                  .where('term', isEqualTo: atMoment.data()!['term'])
                  .where('yearStart', isEqualTo: atMoment.data()!['yearStart'])
                  .get();
          if (isExistSettingTrainee.docs.isNotEmpty) {
            final settingTrainee = SettingTraineeModel.fromMap(
                isExistSettingTrainee.docs.first.data());
            setState(() {
              setting = settingTrainee;
            });
          }
        }
        DocumentSnapshot<Map<String, dynamic>> isExitTrainee =
            await firestore.collection('trainees').doc(userId).get();
        if (isExitTrainee.data() != null) {
          setState(() {
            isRegistered = true;
          });
          final loadTrainee =
              RegisterTraineeModel.fromMap(isExitTrainee.data()!);
          if (loadTrainee.traineeStart == null &&
              loadTrainee.traineeEnd == null) {
            QuerySnapshot<Map<String, dynamic>> isExistSettingTrainee =
                await firestore
                    .collection('settingTrainees')
                    .where('term', isEqualTo: loadTrainee.term)
                    .where('yearStart', isEqualTo: loadTrainee.yearStart)
                    .where('yearEnd', isEqualTo: loadTrainee.yearEnd)
                    .get();
            if (isExistSettingTrainee.docs.isNotEmpty) {
              final setting = SettingTraineeModel.fromMap(
                  isExistSettingTrainee.docs.first.data());
              firestore.collection('trainees').doc(userId).update({
                'traineeStart': setting.traineeStart,
                'traineeEnd': setting.traineeEnd,
              });
              setState(() {
                loadTrainee.traineeStart = setting.traineeStart;
                loadTrainee.traineeEnd = setting.traineeEnd;
              });
            }
          }
          setState(() {
            trainee = loadTrainee;
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
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Container(
            decoration: const BoxDecoration(color: Colors.white),
            height: screenHeight * 0.45,
            width: screenWidth * 0.55,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  color: GV.fieldColor,
                  height: screenHeight * 0.04,
                  child: const Row(
                    children: [
                      Expanded(
                        child: Text(
                          'STT',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Text(
                          'Tên công ty',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          'Vị trí ứng tuyển',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Trạng thái',
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
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: StreamBuilder(
                      stream: firestore
                          .collection('trainees')
                          .where('userId', isEqualTo: userId)
                          .snapshots(),
                      builder: (context, snapshotTrainee) {
                        if (snapshotTrainee.hasData) {
                          List<RegisterTraineeModel> loadTrainees = [];
                          snapshotTrainee.data?.docs.forEach((element) {
                            loadTrainees.add(
                                RegisterTraineeModel.fromMap(element.data()));
                          });
                          for (var element in loadTrainees) {
                            if (element.userId == userId) {
                              listRegis = element.listRegis!;
                            }
                          }
                          bool isTrainee = false;
                          loadTrainees
                              .forEach((e1) => e1.listRegis!.forEach((e2) {
                                    if (e2.isConfirmed == true) {
                                      isTrainee = true;
                                    }
                                  }));
                          return listRegis.isNotEmpty
                              ? ListView.builder(
                                  itemCount: listRegis.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, indexRegis) {
                                    bool check = false;
                                    if (listRegis[indexRegis].isConfirmed!) {
                                      check = true;
                                    }
                                    return Container(
                                      height: screenHeight * 0.05,
                                      color: indexRegis % 2 == 0
                                          ? Colors.blue.shade50
                                          : null,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${indexRegis + 1}',
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            flex: 5,
                                            child: Text(
                                              '${listRegis[indexRegis].firmName}',
                                              textAlign: TextAlign.justify,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              '${listRegis[indexRegis].jobName}',
                                              textAlign: TextAlign.justify,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              check
                                                  ? 'Thực tập'
                                                  : '${listRegis[indexRegis].status}',
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  color: Colors.red),
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Expanded(
                                              flex: 2,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  IconButton(
                                                      tooltip:
                                                          'Thông tin và ứng tuyển',
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 1),
                                                      onPressed: () {
                                                        loadFirms
                                                            .forEach((element) {
                                                          if (element.firmId ==
                                                              listRegis[
                                                                      indexRegis]
                                                                  .firmId) {
                                                            firm = element;
                                                          }
                                                        });
                                                        for (var d
                                                            in listRegis) {
                                                          if (d.firmId ==
                                                              firm.firmId) {
                                                            currentUser
                                                                    .selectedJob
                                                                    .value =
                                                                firm.listJob!
                                                                    .firstWhere(
                                                              (element) =>
                                                                  element
                                                                      .jobId ==
                                                                  d.jobId,
                                                              orElse: () =>
                                                                  JobPositionModel(),
                                                            );
                                                          }
                                                        }
                                                        showDialog(
                                                          context: context,
                                                          barrierColor:
                                                              Colors.black12,
                                                          barrierDismissible:
                                                              false,
                                                          builder: (context) {
                                                            return Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(
                                                                top:
                                                                    screenHeight *
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
                                                                    scrollable:
                                                                        true,
                                                                    title:
                                                                        Container(
                                                                      color: Colors
                                                                          .blue
                                                                          .shade600,
                                                                      height:
                                                                          screenHeight *
                                                                              0.06,
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              10),
                                                                      child:
                                                                          Row(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          const SizedBox(
                                                                            width:
                                                                                30,
                                                                          ),
                                                                          const Expanded(
                                                                            child: Text('Thông tin ứng tuyển',
                                                                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                                                                textAlign: TextAlign.center),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                30,
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
                                                                    titlePadding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                    shape: Border.all(
                                                                        width:
                                                                            0.5),
                                                                    content:
                                                                        ConstrainedBox(
                                                                      constraints: BoxConstraints(
                                                                          minWidth: screenWidth *
                                                                              0.35,
                                                                          maxWidth:
                                                                              screenWidth * 0.5),
                                                                      child:
                                                                          Form(
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: <Widget>[
                                                                            FieldDetail(
                                                                                field: 'Tên công ty',
                                                                                content: '${firm.firmName!}'),
                                                                            FieldDetail(
                                                                                field: 'Người đại diện',
                                                                                content: '${firm.owner != '' ? firm.owner : 'Chưa có thông tin'}'),
                                                                            FieldDetail(
                                                                                field: 'Số điện thoại',
                                                                                content: '${firm.phone != '' ? firm.phone : 'Chưa có thông tin'}'),
                                                                            FieldDetail(
                                                                                field: 'Email',
                                                                                content: '${firm.email != '' ? firm.email : 'Chưa có thông tin'}'),
                                                                            FieldDetail(
                                                                                field: 'Địa chỉ',
                                                                                content: '${firm.address != '' ? firm.address : 'Chưa có thông tin'}'),
                                                                            FieldDetail(
                                                                                field: 'Mô tả',
                                                                                content: '${firm.describe != '' ? firm.describe : 'Chưa có thông tin'}'),
                                                                            const Text(
                                                                              'Yêu cầu kỹ năng (mức độ thông thạo kỹ năng, được đánh giá trên thang điểm từ 1 đến 5)',
                                                                              style: TextStyle(fontWeight: FontWeight.bold),
                                                                            ),
                                                                            if (firm.tieuChi !=
                                                                                null)
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(left: 15),
                                                                                child: Table(
                                                                                  columnWidths: Map.from({
                                                                                    0: const FlexColumnWidth(2),
                                                                                    1: const FlexColumnWidth(2),
                                                                                    2: const FlexColumnWidth(3),
                                                                                  }),
                                                                                  children: [
                                                                                    TableRow(children: [
                                                                                      Row(
                                                                                        children: [
                                                                                          const Text('Ngoại ngữ: '),
                                                                                          Text(
                                                                                            '${firm.tieuChi![0]}',
                                                                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                                                                          )
                                                                                        ],
                                                                                      ),
                                                                                      Row(
                                                                                        children: [
                                                                                          const Text('Kỹ năng lập trình: '),
                                                                                          Text(
                                                                                            '${firm.tieuChi![1]}',
                                                                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                                                                          )
                                                                                        ],
                                                                                      ),
                                                                                      Row(
                                                                                        children: [
                                                                                          const Text('Kỹ năng làm việc nhóm: '),
                                                                                          Text(
                                                                                            '${firm.tieuChi![2]}',
                                                                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                                                                          )
                                                                                        ],
                                                                                      ),
                                                                                    ]),
                                                                                    TableRow(children: [
                                                                                      Row(
                                                                                        children: [
                                                                                          const Text('Máy học, AI: '),
                                                                                          Text(
                                                                                            '${firm.tieuChi![3]}',
                                                                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                                                                          )
                                                                                        ],
                                                                                      ),
                                                                                      Row(
                                                                                        children: [
                                                                                          const Text('Website: '),
                                                                                          Text(
                                                                                            '${firm.tieuChi![4]}',
                                                                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                                                                          )
                                                                                        ],
                                                                                      ),
                                                                                      Row(
                                                                                        children: [
                                                                                          const Text('Ứng dụng di động: '),
                                                                                          Text(
                                                                                            '${firm.tieuChi![5]}',
                                                                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                                                                          )
                                                                                        ],
                                                                                      ),
                                                                                    ]),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            if (setting.settingId != null &&
                                                                                DateTime.now().isBeforeTimestamp(setting.traineeStart!)) ...[
                                                                              if (listRegis[indexRegis].status == TrangThai.reject) ...[
                                                                                const Text(
                                                                                  'Vị trí tuyển dụng:',
                                                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                                                ),
                                                                                for (var job in firm.listJob!)
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(left: 25),
                                                                                    child: ListTile(
                                                                                      dense: true,
                                                                                      contentPadding: EdgeInsets.zero,
                                                                                      title: Text(
                                                                                        '${job.jobName}',
                                                                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                                                                      ),
                                                                                      subtitle: job.describeJob != '' ? Text('${job.describeJob}') : null,
                                                                                    ),
                                                                                  ),
                                                                              ] else if (isTrainee && listRegis[indexRegis].isConfirmed! || !isTrainee && !listRegis[indexRegis].isConfirmed! && listRegis[indexRegis].status == TrangThai.accept) ...[
                                                                                const Text(
                                                                                  'Vị trí tuyển dụng:',
                                                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                                                ),
                                                                                for (var job in firm.listJob!)
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(left: 25),
                                                                                    child: ListTile(
                                                                                      dense: true,
                                                                                      contentPadding: EdgeInsets.zero,
                                                                                      title: Text(
                                                                                        '${job.jobName}',
                                                                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                                                                      ),
                                                                                      subtitle: job.describeJob != '' ? Text('${job.describeJob}') : null,
                                                                                    ),
                                                                                  ),
                                                                                if (listRegis[indexRegis].createdAt != null) FieldDetail(field: 'Vị trí ứng tuyển', content: '${currentUser.selectedJob.value.jobName}'),
                                                                                if (listRegis[indexRegis].createdAt != null) FieldDetail(field: 'Ngày ứng tuyển', content: GV.readTimestamp(listRegis[indexRegis].createdAt!)),
                                                                                if (listRegis[indexRegis].repliedAt != null) FieldDetail(field: 'Ngày duyệt', content: GV.readTimestamp(listRegis[indexRegis].repliedAt!)),
                                                                                if (trainee.traineeStart != null) FieldDetail(field: 'Thời gian thực tập', content: 'Từ ngày ${GV.readTimestamp(trainee.traineeStart!)} - Đến ngày: ${GV.readTimestamp(trainee.traineeEnd!)}'),
                                                                                if (listRegis[indexRegis].isConfirmed!)
                                                                                  const Padding(
                                                                                    padding: EdgeInsets.only(top: 15),
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Text(
                                                                                          'Công ty bạn đang thực tập.',
                                                                                          style: TextStyle(
                                                                                            fontSize: 12,
                                                                                            color: Colors.red,
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  )
                                                                              ] else if (isTrainee) ...[
                                                                                const Text(
                                                                                  'Vị trí tuyển dụng:',
                                                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                                                ),
                                                                                for (var job in firm.listJob!)
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(left: 25),
                                                                                    child: ListTile(
                                                                                      dense: true,
                                                                                      contentPadding: EdgeInsets.zero,
                                                                                      title: Text(
                                                                                        '${job.jobName}',
                                                                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                                                                      ),
                                                                                      subtitle: job.describeJob != '' ? Text('${job.describeJob}') : null,
                                                                                    ),
                                                                                  ),
                                                                                if (listRegis[indexRegis].createdAt != null) FieldDetail(field: 'Vị trí ứng tuyển', content: '${currentUser.selectedJob.value.jobName}'),
                                                                                if (listRegis[indexRegis].createdAt != null) FieldDetail(field: 'Ngày ứng tuyển', content: GV.readTimestamp(listRegis[indexRegis].createdAt!)),
                                                                                if (listRegis[indexRegis].repliedAt != null && listRegis[indexRegis].status == TrangThai.accept) FieldDetail(field: 'Ngày duyệt', content: GV.readTimestamp(listRegis[indexRegis].repliedAt!)) else if (listRegis[indexRegis].status != null) FieldDetail(field: 'Trạng thái', content: '${listRegis[indexRegis].status}'),
                                                                                const Padding(
                                                                                  padding: EdgeInsets.only(top: 15),
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: [
                                                                                      Text(
                                                                                        'Bạn đã có công ty thực tập.',
                                                                                        style: TextStyle(
                                                                                          fontSize: 12,
                                                                                          color: Colors.red,
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                )
                                                                              ] else if (listRegis[indexRegis].status == TrangThai.wait) ...[
                                                                                const Text(
                                                                                  'Vị trí tuyển dụng:',
                                                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                                                ),
                                                                                for (var data in firm.listJob!)
                                                                                  Obx(
                                                                                    () => CustomRadio(
                                                                                      title: '${data.jobName}',
                                                                                      onTap: () => currentUser.selectedJob.value = data,
                                                                                      subtitle: data.describeJob!.isNotEmpty ? data.describeJob : null,
                                                                                      selected: currentUser.selectedJob.value == data,
                                                                                    ),
                                                                                  ),
                                                                              ],
                                                                            ] else ...[
                                                                              if (isTrainee && listRegis[indexRegis].isConfirmed!) ...[
                                                                                FieldDetail(field: 'Vị trí ứng tuyển', content: '${currentUser.selectedJob.value.jobName}'),
                                                                                if (listRegis[indexRegis].createdAt != null) FieldDetail(field: 'Ngày ứng tuyển', content: GV.readTimestamp(listRegis[indexRegis].createdAt!)),
                                                                                if (listRegis[indexRegis].repliedAt != null) FieldDetail(field: 'Ngày duyệt', content: GV.readTimestamp(listRegis[indexRegis].repliedAt!)),
                                                                                if (trainee.traineeStart != null) FieldDetail(field: 'Thời gian thực tập', content: 'Từ ngày ${GV.readTimestamp(trainee.traineeStart!)} - Đến ngày: ${GV.readTimestamp(trainee.traineeEnd!)}'),
                                                                                const Padding(
                                                                                  padding: EdgeInsets.only(top: 15),
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: [
                                                                                      Text(
                                                                                        'Công ty bạn đang thực tập.',
                                                                                        style: TextStyle(
                                                                                          fontSize: 12,
                                                                                          color: Colors.red,
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                )
                                                                              ] else ...[
                                                                                FieldDetail(field: 'Vị trí ứng tuyển', content: '${currentUser.selectedJob.value.jobName}'),
                                                                                if (listRegis[indexRegis].createdAt != null) FieldDetail(field: 'Ngày ứng tuyển', content: GV.readTimestamp(listRegis[indexRegis].createdAt!)),
                                                                                if (listRegis[indexRegis].repliedAt != null) FieldDetail(field: 'Ngày duyệt', content: GV.readTimestamp(listRegis[indexRegis].repliedAt!)),
                                                                                const Padding(
                                                                                  padding: EdgeInsets.only(top: 15),
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: [
                                                                                      Text(
                                                                                        'Bạn đã có công ty thực tập không thể ứng tuyển hoặc thay đổi vị trí ứng tuyển.',
                                                                                        style: TextStyle(
                                                                                          fontSize: 12,
                                                                                          color: Colors.red,
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                )
                                                                              ]
                                                                            ]
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    actions: DateTime.now()
                                                                            .isBeforeTimestamp(setting.traineeStart!)
                                                                        ? isTrainee
                                                                            ? null
                                                                            : listRegis[indexRegis].status == TrangThai.wait && isTrainee == false && isRegistered
                                                                                ? [
                                                                                    ElevatedButton(
                                                                                      child: const Text(
                                                                                        "Ứng tuyển",
                                                                                        style: TextStyle(
                                                                                          fontWeight: FontWeight.bold,
                                                                                          fontSize: 16,
                                                                                        ),
                                                                                      ),
                                                                                      onPressed: () async {
                                                                                        if (firm.listRegis!.where((element) => element.userId == userId).isNotEmpty) {
                                                                                          for (var d in firm.listRegis!) {
                                                                                            if (d.userId == userId) {
                                                                                              if (d.jobId == currentUser.selectedJob.value.jobId) {
                                                                                                GV.warning(context: context, message: 'Không có gì thay đổi.');
                                                                                              } else {
                                                                                                var listRegis = firm.listRegis;
                                                                                                for (int i = 0; i < listRegis!.length; i++) {
                                                                                                  if (listRegis[i].userId == currentUser.userId.value) {
                                                                                                    if (listRegis[i].jobId != currentUser.selectedJob.value.jobId) {
                                                                                                      listRegis[i].jobId = currentUser.selectedJob.value.jobId;
                                                                                                      listRegis[i].jobName = currentUser.selectedJob.value.jobName;
                                                                                                      listRegis[i].createdAt = Timestamp.now();
                                                                                                    }
                                                                                                  }
                                                                                                }
                                                                                                firestore.collection('firms').doc(firm.firmId).update({
                                                                                                  'listRegis': listRegis.map((i) => i.toMap()).toList(),
                                                                                                });
                                                                                                var loadListRegis = await GV.traineesCol.doc(userId).get();
                                                                                                final listUserRegis = RegisterTraineeModel.fromMap(loadListRegis.data()!).listRegis;
                                                                                                for (int i = 0; i < listUserRegis!.length; i++) {
                                                                                                  if (listUserRegis[i].firmId == firm.firmId) {
                                                                                                    if (listUserRegis[i].jobId != currentUser.selectedJob.value.jobId) {
                                                                                                      listUserRegis[i].jobId = currentUser.selectedJob.value.jobId;
                                                                                                      listUserRegis[i].jobName = currentUser.selectedJob.value.jobName;
                                                                                                      listUserRegis[i].createdAt = Timestamp.now();
                                                                                                    }
                                                                                                  }
                                                                                                }
                                                                                                firestore.collection('trainees').doc(userId).update({
                                                                                                  'listRegis': listUserRegis.map((i) => i.toMap()).toList(),
                                                                                                });
                                                                                                Navigator.pop(context);
                                                                                                Navigator.pop(context);
                                                                                                GV.success(context: context, message: 'Đã cập nhật vị trí ứng tuyển.');
                                                                                              }
                                                                                            }
                                                                                          }
                                                                                        }
                                                                                      },
                                                                                    ),
                                                                                  ]
                                                                                : listRegis[indexRegis].status == TrangThai.accept && listRegis[indexRegis].isConfirmed == false
                                                                                    ? [
                                                                                        ElevatedButton(
                                                                                          onPressed: () async {
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
                                                                                                                  child: Text(
                                                                                                                    'Xác nhận thực tập',
                                                                                                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                                                                                                    textAlign: TextAlign.center,
                                                                                                                  ),
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
                                                                                                              constraints: BoxConstraints(
                                                                                                                minWidth: screenWidth * 0.35,
                                                                                                                maxWidth: screenWidth * 0.35,
                                                                                                              ),
                                                                                                              child: const Text('Bạn chỉ có thể xác nhận thực tập tại một công ty duy nhất và không thể thay đổi, bạn có chắc muốn thực tập tại công ty này?')),
                                                                                                          actions: [
                                                                                                            ElevatedButton(
                                                                                                              onPressed: () async {
                                                                                                                var loadCBHD = await firestore.collection('users').doc(firm.firmId).get();
                                                                                                                final cbhdName = UserModel.fromMap(loadCBHD.data()!).userName;
                                                                                                                final plan = PlanWorkModel(
                                                                                                                  cbhdId: firm.firmId,
                                                                                                                  cbhdName: cbhdName,
                                                                                                                  listWork: [],
                                                                                                                  userId: userId,
                                                                                                                );
                                                                                                                var listRegis = firm.listRegis;
                                                                                                                for (int i = 0; i < listRegis!.length; i++) {
                                                                                                                  if (listRegis[i].userId == currentUser.userId.value) {
                                                                                                                    if (listRegis[i].jobId == currentUser.selectedJob.value.jobId) {
                                                                                                                      listRegis[i].isConfirmed = true;
                                                                                                                      plan.traineeStart = trainee.traineeStart;
                                                                                                                      plan.traineeEnd = trainee.traineeEnd;
                                                                                                                    }
                                                                                                                  }
                                                                                                                }
                                                                                                                firestore.collection('plans').doc(userId).set(plan.toMap());
                                                                                                                firestore.collection('firms').doc(firm.firmId).update({
                                                                                                                  'listRegis': listRegis.map((i) => i.toMap()).toList()
                                                                                                                });
                                                                                                                var loadListRegis = await GV.traineesCol.doc(userId).get();
                                                                                                                final listUserRegis = RegisterTraineeModel.fromMap(loadListRegis.data()!).listRegis;
                                                                                                                for (int i = 0; i < listUserRegis!.length; i++) {
                                                                                                                  if (listUserRegis[i].firmId == firm.firmId) {
                                                                                                                    if (listUserRegis[i].jobId == currentUser.selectedJob.value.jobId) {
                                                                                                                      listUserRegis[i].isConfirmed = true;
                                                                                                                    }
                                                                                                                  }
                                                                                                                }
                                                                                                                firestore.collection('trainees').doc(userId).update({
                                                                                                                  'listRegis': listUserRegis.map((i) => i.toMap()).toList(),
                                                                                                                });
                                                                                                                Navigator.pop(context);
                                                                                                                Navigator.pop(context);
                                                                                                                GV.success(context: context, message: 'Đã xác nhận công ty thực tập');
                                                                                                              },
                                                                                                              child: const Text(
                                                                                                                'Chắc chắn',
                                                                                                                style: TextStyle(
                                                                                                                  fontWeight: FontWeight.bold,
                                                                                                                  fontSize: 16,
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                            ElevatedButton(
                                                                                                              onPressed: () {
                                                                                                                Navigator.pop(context);
                                                                                                              },
                                                                                                              child: const Text(
                                                                                                                'Để sau',
                                                                                                                style: TextStyle(
                                                                                                                  color: Colors.red,
                                                                                                                  fontSize: 16,
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
                                                                                          child: const Text(
                                                                                            'Xác nhận thực tập',
                                                                                            style: TextStyle(
                                                                                              fontWeight: FontWeight.bold,
                                                                                              fontSize: 16,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ]
                                                                                    : null
                                                                        : null,
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      },
                                                      icon: Icon(
                                                        CupertinoIcons
                                                            .pencil_outline,
                                                        size: 22,
                                                        color: Colors
                                                            .blue.shade700,
                                                      ))
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
                                      child: Text('Bạn chưa đăng ký công ty.')),
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
