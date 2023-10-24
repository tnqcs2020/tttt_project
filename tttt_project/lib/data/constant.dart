import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tttt_project/routes.dart';
import 'dart:math';

class GV {
  static final auth = FirebaseAuth.instance;
  static final usersCol = FirebaseFirestore.instance.collection('users');
  static final creditsCol = FirebaseFirestore.instance.collection('credits');
  static final traineesCol = FirebaseFirestore.instance.collection('trainees');
  static final cvsCol = FirebaseFirestore.instance.collection('cvs');
  static final firmsCol = FirebaseFirestore.instance.collection('firms');

  static String generateRandomString(int len) {
    var rd = Random();
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => chars[rd.nextInt(chars.length)])
        .join();
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
  RouteGenerator.firm,
];

List<String> menuQuanTri = [
  "Trang chủ",
  "Tạo tài khoản",
  "Danh sách thực tập",
  // "Công ty liên kết",
  "Quản lý học phần",
];

List<String> pageQuanTri = [
  RouteGenerator.home,
  RouteGenerator.addUser,
  RouteGenerator.dstttt,
  // RouteGenerator.firm,
  RouteGenerator.manageCredit,
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
  "Thêm thông báo",
  "Quản lý học phần",
];
List<String> pageGiaoVu = [
  RouteGenerator.home,
  RouteGenerator.info,
  RouteGenerator.firm,
];
List<String> menuCoVan = [
  'Trang chu',
  "Thông tin",
  "Công ty liên kết",
  "Đánh giá",
];
List<String> pageCoVan = [
  RouteGenerator.home,
  RouteGenerator.info,
  RouteGenerator.register,
  RouteGenerator.firm,
];

class NguoiDung {
  static const String quantri = "Quản trị viên";
  static const String giaovu = "Giáo vụ";
  static const String sinhvien = "Sinh viên";
  static const String covan = "Cố vấn học tập";
  static const String cbhd = "Cán bộ hướng dẫn";
  static const String congty = "Công ty";
}

class NamHoc {
  final String start;
  final String end;
  NamHoc({
    required this.start,
    required this.end,
  });
  static NamHoc n1920 = NamHoc(start: "2019", end: "2020");
  static NamHoc n2021 = NamHoc(start: "2020", end: "2021");
  static NamHoc n2122 = NamHoc(start: "2021", end: "2022");
  static NamHoc n2223 = NamHoc(start: "2022", end: "2023");
  static NamHoc n2324 = NamHoc(start: "2023", end: "2024");
}

class HocKy {
  static const String hk1 = "1";
  static const String hk2 = "2";
  static const String hk3 = "Hè";
}

class HocPhan {
  final String maHP;
  final String tenHP;
  HocPhan({
    required this.maHP,
    required this.tenHP,
  });
}

class DSHocPhan45 {
  static HocPhan ct215h =
      HocPhan(maHP: "CT215H", tenHP: "Thực tập thực tế (CLC)");
  static HocPhan ct471 =
      HocPhan(maHP: "CT471", tenHP: "Thực tập thực tế - CNTT");
  static HocPhan ct472 =
      HocPhan(maHP: "CT472", tenHP: "Thực tập thực tế - HTTT");
  static HocPhan ct473 =
      HocPhan(maHP: "CT473", tenHP: "Thực tập thực tế - KHMT");
  static HocPhan ct474 =
      HocPhan(maHP: "CT474", tenHP: "Thực tập thực tế - KTPM");
  static HocPhan ct475 =
      HocPhan(maHP: "CT475", tenHP: "Thực tập thực tế - THUD");
  static HocPhan ct476 =
      HocPhan(maHP: "CT476", tenHP: "Thực tập thực tế - TT&MMT");
}

class DSHocPhan49 {
  static HocPhan ct215h =
      HocPhan(maHP: "CT215H", tenHP: "Thực tập thực tế (CLC)");
  static HocPhan ct458e =
      HocPhan(maHP: "CT458E", tenHP: "Thực tập doanh nghiệp - KTPM");
  static HocPhan ct474h =
      HocPhan(maHP: "CT474H", tenHP: "Thực tập doanh nghiệp - KTPM (CLC)");
  static HocPhan ct493e = HocPhan(
      maHP: "CT493E", tenHP: "Thực tập doanh nghiệp - An toàn thông tin");
  static HocPhan ct508e =
      HocPhan(maHP: "CT508E", tenHP: "Thực tập doanh nghiệp - TTDPT");
  static HocPhan ct511e =
      HocPhan(maHP: "CT511E", tenHP: "Thực tập doanh nghiệp - HTTT");
  static HocPhan ct516e =
      HocPhan(maHP: "CT516E", tenHP: "Thực tập doanh nghiệp - KHMT");
  static HocPhan ct517e =
      HocPhan(maHP: "CT517E", tenHP: "Thực tập doanh nghiệp - MMT&TTDL");
  static HocPhan ct518e =
      HocPhan(maHP: "CT518E", tenHP: "Thực tập doanh nghiệp - CNTT");
}
