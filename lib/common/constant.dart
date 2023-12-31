import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'package:tttt_project/routes.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class GV {
  static final auth = FirebaseAuth.instance;
  static final usersCol = FirebaseFirestore.instance.collection('users');
  static final creditsCol = FirebaseFirestore.instance.collection('credits');
  static final traineesCol = FirebaseFirestore.instance.collection('trainees');
  static final cvsCol = FirebaseFirestore.instance.collection('cvs');
  static final firmsCol = FirebaseFirestore.instance.collection('firms');
  static final Color primaryColor = Colors.blue.shade600;
  static final Color fieldColor = Colors.blue.shade300;

  static String generateRandomString(int len) {
    var rd = Random();
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => chars[rd.nextInt(chars.length)])
        .join();
  }

  static String readTimestamp(Timestamp timestamp) {
    var date = DateFormat('dd/MM/yyyy').format(
        DateTime.fromMicrosecondsSinceEpoch(timestamp.microsecondsSinceEpoch));
    return date.toString();
  }

  static String readTimestampBefore(Timestamp timestamp) {
    var date = DateFormat('dd/MM/yyyy').format(
        DateTime.fromMicrosecondsSinceEpoch(timestamp.microsecondsSinceEpoch)
            .subtract(const Duration(days: 1)));
    return date.toString();
  }

  static String readTimestampAfter(Timestamp timestamp) {
    var date = DateFormat('dd/MM/yyyy').format(
        DateTime.fromMicrosecondsSinceEpoch(timestamp.microsecondsSinceEpoch)
            .add(const Duration(days: 1)));
    return date.toString();
  }

  //toast
  static warning(
      {required BuildContext context, String? title, required String message}) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return MotionToast.warning(
      title: Text(
        title ?? 'Chú ý',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      description: Text(
        message,
        style: const TextStyle(fontSize: 12),
      ),
      toastDuration: const Duration(milliseconds: 1500),
      animationType: AnimationType.fromLeft,
      padding: EdgeInsets.only(
        left: screenWidth * 0.6,
        bottom: 20,
      ),
      width: screenWidth * 0.24,
      height: screenHeight * 0.1,
    ).show(context);
  }

  static success(
      {required BuildContext context, String? title, required String message}) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return MotionToast.success(
      title: Text(
        title ?? 'Thành công',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      description: Text(
        message,
        style: const TextStyle(fontSize: 12),
      ),
      toastDuration: const Duration(milliseconds: 1500),
      animationType: AnimationType.fromLeft,
      padding: EdgeInsets.only(
        left: screenWidth * 0.6,
        bottom: 20,
      ),
      width: screenWidth * 0.24,
      height: screenHeight * 0.1,
    ).show(context);
  }

  static error(
      {required BuildContext context, String? title, required String message}) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return MotionToast(
      icon: Icons.close,
      title: Text(
        title ?? "Từ chối",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      description: Text(
        message,
        style: const TextStyle(fontSize: 12),
      ),
      toastDuration: const Duration(milliseconds: 2000),
      animationType: AnimationType.fromLeft,
      padding: EdgeInsets.only(
        left: screenWidth * 0.6,
        bottom: 20,
      ),
      width: screenWidth * 0.24,
      height: screenHeight * 0.1,
      primaryColor: Colors.red,
    ).show(context);
  }
}

List<String> menuSinhVien = [
  "Trang chủ",
  "Thông tin sinh viên",
  "Thực tập thực tế",
  "Công ty liên kết",
];
List<String> pageSinhVien = [
  RouteGenerator.home,
  RouteGenerator.info,
  RouteGenerator.register,
  RouteGenerator.firmSV,
];

List<String> menuQuanTri = [
  "Trang chủ",
  "Tạo tài khoản",
  "Danh sách người dùng",
  "Danh sách thực tập",
  // "Quản lý học phần",
];
List<String> pageQuanTri = [
  RouteGenerator.home,
  RouteGenerator.addUser,
  RouteGenerator.dsNguoiDung,
  RouteGenerator.dstttt,
  // RouteGenerator.manageCredit,
];

List<String> menuCanBo = [
  "Trang chủ",
  "Quản lý thông tin",
  "Quản lý thực tập",
];
List<String> pageCanBo = [
  RouteGenerator.home,
  RouteGenerator.manageInfoCB,
  RouteGenerator.manageTraineeCB,
];

List<String> menuGiaoVu = [
  "Trang chủ",
  "Quản lý thông báo",
  "Quản lý học phần",
  "Quản lý kế hoạch thực tập",
  "Quản lý các mốc thời gian",
  "Danh sách thực tập",
  "Danh sách công ty",
];
List<String> pageGiaoVu = [
  RouteGenerator.home,
  RouteGenerator.manageAnnouncement,
  RouteGenerator.manageCredit,
  RouteGenerator.managePlan,
  RouteGenerator.settingTrainee,
  RouteGenerator.dstttt,
  RouteGenerator.firmCommon,
];

List<String> menuCoVan = [
  'Trang chủ',
  "Thông tin cá nhân",
  "Quản lý sinh viên",
  "Danh sách công ty",
];
List<String> pageCoVan = [
  RouteGenerator.home,
  RouteGenerator.infoCV,
  RouteGenerator.dssv,
  RouteGenerator.firmCommon,
];

class NguoiDung {
  static const String quantri = "Quản trị viên";
  static const String giaovu = "Giáo vụ";
  static const String sinhvien = "Sinh viên";
  static const String covan = "Cố vấn học tập";
  static const String cbhd = "Cán bộ hướng dẫn";
  static const String tatca = "Tất cả";
  static const String empty = "";
  // static const String congty = "Công ty";
}

List<String> dsnd = [
  NguoiDung.giaovu,
  NguoiDung.covan,
  NguoiDung.cbhd,
  NguoiDung.sinhvien,
];
List<String> dsndAll = [
  NguoiDung.tatca,
  NguoiDung.giaovu,
  NguoiDung.covan,
  NguoiDung.cbhd,
  NguoiDung.sinhvien,
];

class TrangThai {
  static const String empty = "";
  static const String wait = "Chờ duyệt";
  static const String accept = "Đã duyệt";
  static const String reject = "Từ chối";
  static const String tatca = 'Tất cả';
}

List<String> dsttAll = [
  TrangThai.tatca,
  TrangThai.wait,
  TrangThai.accept,
  TrangThai.reject,
];

class NamHoc {
  String start;
  String end;
  NamHoc({
    required this.start,
    required this.end,
  });
  static NamHoc tatca = NamHoc(start: "Tất cả", end: "Tất cả");
  static NamHoc n2122 = NamHoc(start: "2021", end: "2022");
  static NamHoc n2223 = NamHoc(start: "2022", end: "2023");
  static NamHoc n2324 = NamHoc(start: "2023", end: "2024");
  static NamHoc n2425 = NamHoc(start: "2024", end: "2025");
  static NamHoc empty = NamHoc(start: "", end: "");

  factory NamHoc.fromMap(Map<String, dynamic> map) {
    return NamHoc(
      start: map['yearStart'] ?? '',
      end: map['yearEnd'] ?? '',
    );
  }
}

List<NamHoc> dsnhAll = [
  NamHoc.tatca,
  NamHoc.n2122,
  NamHoc.n2223,
  NamHoc.n2324,
  NamHoc.n2425,
];
List<NamHoc> dsnh = [
  NamHoc.n2122,
  NamHoc.n2223,
  NamHoc.n2324,
  NamHoc.n2425,
];

class HocKy {
  static const String tatca = "Tất cả";
  static const String hk1 = "1";
  static const String hk2 = "2";
  static const String hk3 = "Hè";
  static const String empty = "";
}

List<String> dshkAll = [
  HocKy.tatca,
  HocKy.hk1,
  HocKy.hk2,
  HocKy.hk3,
];
List<String> dshk = [
  HocKy.hk1,
  HocKy.hk2,
  HocKy.hk3,
];

List<String> contentAppreciate = [
  'I.1. Thực hiện nội quy của cơ quan (nếu thực tập online thì không chẩm điểm)',
  'I.2. Chấp hành giờ giấc làm việc (nếu thực tập online thì không chẩm điểm)',
  'I.3. Thái độ giao tiếp với cán bộ trong đơn vị (nếu thực lập online thì không chấm điểm)',
  'I.4. Tích cực trong công việc',
  'II.1. Đáp ứng yêu cầu công việc',
  'II.2. Tinh thần học hỏi, nâng cao trình độ chuyên môn, nghiệp vụ',
  'II.3. Có đề xuất, sáng kiến, năng động trong công việc',
  'III.1. Báo cáo tiến độ công việc cho cán bộ hướng dẫn mỗi tuần 1 lần',
  'III.2. Hoàn thành công việc được giao',
  'III.3. Kết quả công việc có đóng góp cho cơ quan nơi thực tập',
  'I. Tinh thần kỷ luật',
  'II. Khả năng chuyên môn, nghiệp vụ',
  'III. Kết quả công tác',
];

List<String> appreciatesCTDT = [
  'Phù hợp với thực tế',
  'Tăng cường ngoại ngữ',
  'Không phù hợp với thực tế',
  'Tăng cường kỹ năng làm việc nhóm',
  'Tăng cường kỹ năng mềm',
];

List<String> contentsPlan = [
  'Trong các buôi sinh hoạt CVHT, giáo viên cô vân hướng dân sinh viên về mục đích, yêu cầu của thực tập thực tế, hướng dẫn sinh viên tìm các cơ quan có thể tiếp nhận SV TTTT.',
  """Dự kiến mở các lớp HP TTTT:
- Đối với các lớp đúng tiến độ (K45): Mở các lớp HP theo lớp do GVCV phụ trách.
- Đôi với SV chậm tiên độ: mở chung 1 lớp HP do GVCV phụ trách.
- Đối với SV vượt tiên độ (K46): mỗi ngành mở 1 lớp, các Khoa phân công GV phụ trách.""",
  "In giấy giới thiệu cho SV theo DS SV đã lập KHHT",
  """- Sinh viên nhận giấy giới thiệu để liên hệ địa điểm thực tập:
+ K45: Lớp trưởng nhận tại VP và phát cho các bạn (có thê phát trong buôi sinh hoạt lân 1).
+ Đôi với SV các khóa khác thì nhận trực tiêp tại VP.
Lưu ý: Môi SV chí có 1 giây giới thiệu, vì vậy đê nghị SV sử dụng cẩn thận.""",
  """GV phụ trách họp với SV đê hướng dân quy trình TTTT (hướng dân SV liên hệ công ty đê nộp giây giới thiệu và phiếu tiếp nhận SV, kế hoạc TTTT, đề cương HP TTTT, mẫu đánh giá, mẫu BC).
GV lưu ý nhắc SV khi đăng ký HP cần đăng ký đúng nhóm do GV phụ trách. Khuyến khích họp trong giờ SH CVHT.
(Lớp trưởng có thể phát giấy giới thiệu cho các bạn trong buổi họp này nếu thuận tiện).""",
  """SV nộp "Phiếu tiếp nhận" của đơn vị tại VP, đồng thời điền dầy đủ các thông tin vào Form. Những SV không nộp phiếu và không diền thông tin vào Form sẽ không có tên trong danh sách xét duyệt TTTT
(Lưu ý: S1 phải dang ky HP TTTT thì mới được TTTT).""",
  "Các Khoa duyệt các phiêu tiêp nhận SV của các công ty",
  "Chuẩn bị hồ sơ cho SV đi TTTT tại công ty",
  "Công bố danh sách SV đi thực tập theo mẫu (chỉ những SV có đăng ký môn học mới có tên trong DS, không giải quyết ngoại lệ)",
  "Các Khoa họp với SV để sinh hoạt nội quy khi đi TTTT.",
  """SV nhận các giấy tờ có liên quan để đi thực tập (nhận tại sảnh VP). 
Lớp trưởng có thể nhận và phát cho các bạn trong giờ sinh hoạt với GVHD nếu thuận tiện.""",
  "Sinh viên bắt đầu thực tập (8 tuần)",
  "Sinh viên nộp báo cáo thực tập cho giáo viên.",
  "Giáo viên chấm và nhập điểm TTTT.",
];

List<String> appreciateCV = [
  'I. Hình thức trình bày',
  '''I.1 Đúng format của khoa (Trang bìa, trang lời cảm ơn, trang đánh giá thực tập của khoa, trang mục lục và các nội dung báo cáo). Sử dụng đúng mã và font tiếng Việt (Unicode Times New Roman, Size 13) ''',
  'I.2 Trình bày mạch lạc, súc tích, không có lỗi chính tả',
  'II. Phiếu theo dõi',
  'II.1 Có lịch làm việc đầy đủ cho 8 tuần',
  '''II.2 Hoàn thành tốt kế hoạch công tác ghi trong lịch làm việc. Cách tính điểm = (Điểm cộng của cán bộ hướng dẫn/100) x 5''',
  'III. Nội dung thực tập (quyển báo cáo)',
  'III.1 Có được sự hiểu biết tốt về cơ quan nơi thực tập',
  'III.2 Phương pháp thực hiện phù hợp với nội dung công việc được giao',
  'III.3 Kết quả cùng cố lý thuyết',
  'III.4 Kết quả rèn luyện kỹ năng thực hành',
  'III.5 Kinh nghiêm thực tiễn thu nhận được',
  'III.6 Kết quả công việc có đóng góp cho cơ quan nơi thực tập',
  'TỔNG CỘNG',
  'Điểm trừ',
  'Điểm còn lại',
];

List<double> pointAppreciateCV = [
  1.0,
  0.5,
  0.5,
  6.0,
  1.0,
  5.0,
  3.0,
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
  10,
  0,
  0,
];
List<double> initPoint = [
  0.5,
  0.5,
  1.0,
  5.0,
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
  0.5,
  0.0,
];

class HocPhan {
  final String maHP;
  final String tenHP;
  HocPhan({
    required this.maHP,
    required this.tenHP,
  });
}

List<String> majors = [
  'An toàn thông tin',
  'Công nghệ thông tin',
  'Công nghệ thông tin (chất lượng cao)',
  'Hệ thống thông tin',
  'Mạng máy tính và truyền thông dữ liệu',
  'Kỹ thuật phần mềm',
  'Kỹ thuật phần mềm (chất lượng cao)',
  'Khoa học máy tính',
  'Tin học ứng dụng',
  'Truyền thông đa phương tiện',
];

List<String> majorsAll = [
  'Tất cả',
  'An toàn thông tin',
  'Công nghệ thông tin',
  'Công nghệ thông tin (chất lượng cao)',
  'Hệ thống thông tin',
  'Mạng máy tính và truyền thông dữ liệu',
  'Kỹ thuật phần mềm',
  'Kỹ thuật phần mềm (chất lượng cao)',
  'Khoa học máy tính',
  'Tin học ứng dụng',
  'Truyền thông đa phương tiện',
];

List<String> courses = [
  '45',
  '46',
  '47',
  '48',
  '49',
  '50',
];
List<String> coursesAll = [
  'Tất cả',
  '45',
  '46',
  '47',
  '48',
  '49',
  '50',
];
// class DSHocPhan45 {
//   static HocPhan ct215h =
//       HocPhan(maHP: "CT215H", tenHP: "Thực tập thực tế (CLC)");
//   static HocPhan ct471 =
//       HocPhan(maHP: "CT471", tenHP: "Thực tập thực tế - CNTT");
//   static HocPhan ct472 =
//       HocPhan(maHP: "CT472", tenHP: "Thực tập thực tế - HTTT");
//   static HocPhan ct473 =
//       HocPhan(maHP: "CT473", tenHP: "Thực tập thực tế - KHMT");
//   static HocPhan ct474 =
//       HocPhan(maHP: "CT474", tenHP: "Thực tập thực tế - KTPM");
//   static HocPhan ct475 =
//       HocPhan(maHP: "CT475", tenHP: "Thực tập thực tế - THUD");
//   static HocPhan ct476 =
//       HocPhan(maHP: "CT476", tenHP: "Thực tập thực tế - TT&MMT");
// }

// class DSHocPhan49 {
//   static HocPhan ct215h =
//       HocPhan(maHP: "CT215H", tenHP: "Thực tập thực tế (CLC)");
//   static HocPhan ct458e =
//       HocPhan(maHP: "CT458E", tenHP: "Thực tập doanh nghiệp - KTPM");
//   static HocPhan ct474h =
//       HocPhan(maHP: "CT474H", tenHP: "Thực tập doanh nghiệp - KTPM (CLC)");
//   static HocPhan ct493e = HocPhan(
//       maHP: "CT493E", tenHP: "Thực tập doanh nghiệp - An toàn thông tin");
//   static HocPhan ct508e =
//       HocPhan(maHP: "CT508E", tenHP: "Thực tập doanh nghiệp - TTDPT");
//   static HocPhan ct511e =
//       HocPhan(maHP: "CT511E", tenHP: "Thực tập doanh nghiệp - HTTT");
//   static HocPhan ct516e =
//       HocPhan(maHP: "CT516E", tenHP: "Thực tập doanh nghiệp - KHMT");
//   static HocPhan ct517e =
//       HocPhan(maHP: "CT517E", tenHP: "Thực tập doanh nghiệp - MMT&TTDL");
//   static HocPhan ct518e =
//       HocPhan(maHP: "CT518E", tenHP: "Thực tập doanh nghiệp - CNTT");
// }
