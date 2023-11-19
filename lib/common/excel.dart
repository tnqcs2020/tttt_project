import 'dart:convert';

import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:tiengviet/tiengviet.dart';
import 'package:tttt_project/common/constant.dart';
import 'package:tttt_project/models/appreciate_cv_model.dart';
import 'package:tttt_project/models/register_trainee_model.dart';
import 'package:tttt_project/models/user_model.dart';
import 'package:universal_html/html.dart';

Future<void> xuatKQTT(
    {required String classId,
    required String term,
    required NamHoc year,
    required List<AppreciateCVModel> appreciates}) async {
  final Workbook workbook = Workbook();
  final Worksheet sheet = workbook.worksheets[0];
  Style styleLeft = workbook.styles.add('styleLeft');
  styleLeft.fontName = 'Times New Roman';
  styleLeft.hAlign = HAlignType.left;
  styleLeft.vAlign = VAlignType.center;
  styleLeft.borders.all.lineStyle = LineStyle.thin;

  Style styleCenter = workbook.styles.add('styleCenter');
  styleCenter.fontName = 'Times New Roman';
  styleCenter.hAlign = HAlignType.center;
  styleCenter.vAlign = VAlignType.center;
  styleCenter.borders.all.lineStyle = LineStyle.thin;

  Style styleRight = workbook.styles.add('styleRight');
  styleRight.fontName = 'Times New Roman';
  styleRight.hAlign = HAlignType.right;
  styleRight.vAlign = VAlignType.center;
  styleRight.borders.all.lineStyle = LineStyle.thin;

  sheet.getRangeByName('A1:E1').setText('KẾT QUẢ THỰC TẬP');
  sheet.getRangeByName('A1:E1').merge();
  sheet.getRangeByName('A1:E1').cellStyle = styleCenter;
  sheet.getRangeByName('A1:E1').cellStyle.borders.all.lineStyle =
      LineStyle.none;
  sheet.getRangeByName('A1:E1').cellStyle.bold = true;

  sheet.getRangeByName('A3').setText('Mã lớp: $classId');
  sheet.getRangeByName('A3').cellStyle = styleCenter;
  sheet.getRangeByName('A3').cellStyle.borders.all.lineStyle = LineStyle.none;
  sheet.getRangeByName('A3').cellStyle.bold = true;

  sheet.getRangeByName('C3').setText('Học kỳ: $term');
  sheet.getRangeByName('C3').cellStyle = styleCenter;
  sheet.getRangeByName('C3').cellStyle.borders.all.lineStyle = LineStyle.none;
  sheet.getRangeByName('C3').cellStyle.bold = true;

  sheet.getRangeByName('E3').setText('Năm học: ${year.start} - ${year.end}');
  sheet.getRangeByName('E3').cellStyle = styleCenter;
  sheet.getRangeByName('E3').cellStyle.borders.all.lineStyle = LineStyle.none;
  sheet.getRangeByName('E3').cellStyle.bold = true;

  sheet.getRangeByName('A5').setText('STT');
  sheet.getRangeByName('A5').cellStyle = styleCenter;
  sheet.getRangeByName('A5').cellStyle.bold = true;

  sheet.getRangeByName('B5').setText('Mã sinh viên');
  sheet.getRangeByName('B5').cellStyle = styleCenter;
  sheet.getRangeByName('B5').cellStyle.bold = true;

  sheet.getRangeByName('C5').setText('Họ tên sinh viên');
  sheet.getRangeByName('C5').cellStyle = styleCenter;
  sheet.getRangeByName('C5').cellStyle.bold = true;

  sheet.getRangeByName('D5').setText('Điểm số');
  sheet.getRangeByName('D5').cellStyle = styleCenter;
  sheet.getRangeByName('D5').cellStyle.bold = true;

  sheet.getRangeByName('E5').setText('Điểm chữ');
  sheet.getRangeByName('E5').cellStyle = styleCenter;
  sheet.getRangeByName('E5').cellStyle.bold = true;

  var rowIndex = 6;
  for (int i = 0; i < appreciates.length; i++) {
    sheet.getRangeByName('A$rowIndex').setText('${i + 1}');
    sheet.getRangeByName('A$rowIndex').cellStyle = styleCenter;
    sheet
        .getRangeByName('B$rowIndex')
        .setText(appreciates[i].userId!.toUpperCase());
    sheet.getRangeByName('B$rowIndex').cellStyle = styleLeft;
    sheet.getRangeByName('C$rowIndex').setText('${appreciates[i].userName}');
    sheet.getRangeByName('C$rowIndex').cellStyle = styleLeft;
    sheet.getRangeByName('D$rowIndex').setText('${appreciates[i].finalTotal}');
    sheet.getRangeByName('D$rowIndex').cellStyle = styleRight;
    sheet.getRangeByName('E$rowIndex').setText('${appreciates[i].pointChar}');
    sheet.getRangeByName('E$rowIndex').cellStyle = styleCenter;
    rowIndex++;
  }

  sheet.getRangeByName('A$rowIndex:C$rowIndex').setText('TỔNG SỐ SINH VIÊN');
  sheet.getRangeByName('A$rowIndex:C$rowIndex').merge();
  sheet.getRangeByName('A$rowIndex:C$rowIndex').cellStyle = styleCenter;
  sheet.getRangeByName('A$rowIndex:C$rowIndex').cellStyle.bold = true;

  sheet
      .getRangeByName('D$rowIndex:E$rowIndex')
      .setText(appreciates.length.toString());
  sheet.getRangeByName('D$rowIndex:E$rowIndex').merge();
  sheet.getRangeByName('D$rowIndex:E$rowIndex').cellStyle = styleCenter;
  sheet.getRangeByName('D$rowIndex:E$rowIndex').cellStyle.bold = true;

  sheet.autoFitColumn(1);
  sheet.autoFitColumn(2);
  sheet.autoFitColumn(3);
  sheet.autoFitColumn(4);
  sheet.autoFitColumn(5);

  List<int> bytes = workbook.saveAsStream();
  workbook.dispose();
  String nh = year.start == year.end
      ? TiengViet.parse(year.start).split(' ').join()
      : '${TiengViet.parse(year.start).split(' ').join()}_${TiengViet.parse(year.end).split(' ').join()}';
  saveExcel(bytes,
      'Diem_TTTT_${classId}_HK${TiengViet.parse(term).split(' ').join()}_NH$nh.xlsx');
}

Future<void> xuatDSSVTT(
    {required String classId,
    required String term,
    required NamHoc year,
    required List<RegisterTraineeModel> trainees}) async {
  final Workbook workbook = Workbook();
  final Worksheet sheet = workbook.worksheets[0];
  Style styleLeft = workbook.styles.add('styleLeft');
  styleLeft.fontName = 'Times New Roman';
  styleLeft.hAlign = HAlignType.left;
  styleLeft.vAlign = VAlignType.center;
  styleLeft.borders.all.lineStyle = LineStyle.thin;

  Style styleCenter = workbook.styles.add('styleCenter');
  styleCenter.fontName = 'Times New Roman';
  styleCenter.hAlign = HAlignType.center;
  styleCenter.vAlign = VAlignType.center;
  styleCenter.borders.all.lineStyle = LineStyle.thin;

  sheet.getRangeByName('A1:E1').setText('DANH SÁCH THỰC TẬP');
  sheet.getRangeByName('A1:E1').merge();
  sheet.getRangeByName('A1:E1').cellStyle = styleCenter;
  sheet.getRangeByName('A1:E1').cellStyle.borders.all.lineStyle =
      LineStyle.none;
  sheet.getRangeByName('A1:E1').cellStyle.bold = true;

  sheet.getRangeByName('A3').setText('Mã lớp: $classId');
  sheet.getRangeByName('A3').cellStyle = styleCenter;
  sheet.getRangeByName('A3').cellStyle.borders.all.lineStyle = LineStyle.none;
  sheet.getRangeByName('A3').cellStyle.bold = true;

  sheet.getRangeByName('C3').setText('Học kỳ: $term');
  sheet.getRangeByName('C3').cellStyle = styleCenter;
  sheet.getRangeByName('C3').cellStyle.borders.all.lineStyle = LineStyle.none;
  sheet.getRangeByName('C3').cellStyle.bold = true;

  sheet.getRangeByName('E3').setText('Năm học: ${year.start} - ${year.end}');
  sheet.getRangeByName('E3').cellStyle = styleCenter;
  sheet.getRangeByName('E3').cellStyle.borders.all.lineStyle = LineStyle.none;
  sheet.getRangeByName('E3').cellStyle.bold = true;

  sheet.getRangeByName('A5').setText('STT');
  sheet.getRangeByName('A5').cellStyle = styleCenter;
  sheet.getRangeByName('A5').cellStyle.bold = true;

  sheet.getRangeByName('B5').setText('Mã sinh viên');
  sheet.getRangeByName('B5').cellStyle = styleCenter;
  sheet.getRangeByName('B5').cellStyle.bold = true;

  sheet.getRangeByName('C5').setText('Họ tên sinh viên');
  sheet.getRangeByName('C5').cellStyle = styleCenter;
  sheet.getRangeByName('C5').cellStyle.bold = true;

  sheet.getRangeByName('D5').setText('Công ty thực tập');
  sheet.getRangeByName('D5').cellStyle = styleCenter;
  sheet.getRangeByName('D5').cellStyle.bold = true;

  sheet.getRangeByName('E5').setText('Vị trí thực tập');
  sheet.getRangeByName('E5').cellStyle = styleCenter;
  sheet.getRangeByName('E5').cellStyle.bold = true;

  var rowIndex = 6;
  for (int i = 0; i < trainees.length; i++) {
    sheet.getRangeByName('A$rowIndex').setText('${i + 1}');
    sheet.getRangeByName('A$rowIndex').cellStyle = styleCenter;
    sheet
        .getRangeByName('B$rowIndex')
        .setText(trainees[i].userId!.toUpperCase());
    sheet.getRangeByName('B$rowIndex').cellStyle = styleLeft;
    sheet.getRangeByName('C$rowIndex').setText('${trainees[i].studentName}');
    sheet.getRangeByName('C$rowIndex').cellStyle = styleLeft;

    final userRegis = trainees[i].listRegis!.firstWhere(
          (element) => element.isConfirmed == true,
          orElse: () => UserRegisterModel(),
        );
    sheet.getRangeByName('D$rowIndex').setText(userRegis.firmName ?? "");
    sheet.getRangeByName('D$rowIndex').cellStyle = styleLeft;
    sheet.getRangeByName('E$rowIndex').setText(userRegis.jobName ?? '');
    sheet.getRangeByName('E$rowIndex').cellStyle = styleLeft;
    rowIndex++;
  }

  sheet.getRangeByName('A$rowIndex:C$rowIndex').setText('TỔNG SỐ SINH VIÊN');
  sheet.getRangeByName('A$rowIndex:C$rowIndex').merge();
  sheet.getRangeByName('A$rowIndex:C$rowIndex').cellStyle = styleCenter;
  sheet.getRangeByName('A$rowIndex:C$rowIndex').cellStyle.bold = true;

  sheet
      .getRangeByName('D$rowIndex:E$rowIndex')
      .setText(trainees.length.toString());
  sheet.getRangeByName('D$rowIndex:E$rowIndex').merge();
  sheet.getRangeByName('D$rowIndex:E$rowIndex').cellStyle = styleCenter;
  sheet.getRangeByName('D$rowIndex:E$rowIndex').cellStyle.bold = true;

  sheet.autoFitColumn(1);
  sheet.autoFitColumn(2);
  sheet.autoFitColumn(3);
  sheet.autoFitColumn(4);
  sheet.autoFitColumn(5);

  List<int> bytes = workbook.saveAsStream();
  workbook.dispose();
  String nh = year.start == year.end
      ? TiengViet.parse(year.start).split(' ').join()
      : '${TiengViet.parse(year.start).split(' ').join()}_${TiengViet.parse(year.end).split(' ').join()}';
  saveExcel(bytes,
      'DS_TTTT_${classId}_HK${TiengViet.parse(term).split(' ').join()}_NH$nh.xlsx');
}

Future<void> xuatDSTTGV(
    {required String term,
    required NamHoc year,
    required List<RegisterTraineeModel> trainees}) async {
  final Workbook workbook = Workbook();
  final Worksheet sheet = workbook.worksheets[0];
  Style styleLeft = workbook.styles.add('styleLeft');
  styleLeft.fontName = 'Times New Roman';
  styleLeft.hAlign = HAlignType.left;
  styleLeft.vAlign = VAlignType.center;
  styleLeft.borders.all.lineStyle = LineStyle.thin;

  Style styleCenter = workbook.styles.add('styleCenter');
  styleCenter.fontName = 'Times New Roman';
  styleCenter.hAlign = HAlignType.center;
  styleCenter.vAlign = VAlignType.center;
  styleCenter.borders.all.lineStyle = LineStyle.thin;

  sheet.getRangeByName('A1:F1').setText('DANH SÁCH THỰC TẬP');
  sheet.getRangeByName('A1:F1').merge();
  sheet.getRangeByName('A1:F1').cellStyle = styleCenter;
  sheet.getRangeByName('A1:F1').cellStyle.borders.all.lineStyle =
      LineStyle.none;
  sheet.getRangeByName('A1:F1').cellStyle.bold = true;

  sheet.getRangeByName('C3').setText('Học kỳ: $term');
  sheet.getRangeByName('C3').cellStyle = styleCenter;
  sheet.getRangeByName('C3').cellStyle.borders.all.lineStyle = LineStyle.none;
  sheet.getRangeByName('C3').cellStyle.bold = true;

  sheet.getRangeByName('E3').setText('Năm học: ${year.start} - ${year.end}');
  sheet.getRangeByName('E3').cellStyle = styleCenter;
  sheet.getRangeByName('E3').cellStyle.borders.all.lineStyle = LineStyle.none;
  sheet.getRangeByName('E3').cellStyle.bold = true;

  sheet.getRangeByName('A5').setText('STT');
  sheet.getRangeByName('A5').cellStyle = styleCenter;
  sheet.getRangeByName('A5').cellStyle.bold = true;

  sheet.getRangeByName('B5').setText('Mã sinh viên');
  sheet.getRangeByName('B5').cellStyle = styleCenter;
  sheet.getRangeByName('B5').cellStyle.bold = true;

  sheet.getRangeByName('C5').setText('Họ tên sinh viên');
  sheet.getRangeByName('C5').cellStyle = styleCenter;
  sheet.getRangeByName('C5').cellStyle.bold = true;

  sheet.getRangeByName('D5').setText('Mã lớp');
  sheet.getRangeByName('D5').cellStyle = styleCenter;
  sheet.getRangeByName('D5').cellStyle.bold = true;

  sheet.getRangeByName('E5').setText('Khóa');
  sheet.getRangeByName('E5').cellStyle = styleCenter;
  sheet.getRangeByName('E5').cellStyle.bold = true;

  sheet.getRangeByName('F5').setText('Công ty thực tập');
  sheet.getRangeByName('F5').cellStyle = styleCenter;
  sheet.getRangeByName('F5').cellStyle.bold = true;

  var rowIndex = 6;
  for (int i = 0; i < trainees.length; i++) {
    sheet.getRangeByName('A$rowIndex').setText('${i + 1}');
    sheet.getRangeByName('A$rowIndex').cellStyle = styleCenter;
    sheet
        .getRangeByName('B$rowIndex')
        .setText(trainees[i].userId!.toUpperCase());
    sheet.getRangeByName('B$rowIndex').cellStyle = styleLeft;
    sheet.getRangeByName('C$rowIndex').setText('${trainees[i].studentName}');
    sheet.getRangeByName('C$rowIndex').cellStyle = styleLeft;
    sheet.getRangeByName('D$rowIndex').setText('${trainees[i].classId}');
    sheet.getRangeByName('D$rowIndex').cellStyle = styleLeft;
    sheet.getRangeByName('E$rowIndex').setText('${trainees[i].course}');
    sheet.getRangeByName('E$rowIndex').cellStyle = styleLeft;
    final userRegis = trainees[i].listRegis!.firstWhere(
          (element) => element.isConfirmed == true,
          orElse: () => UserRegisterModel(),
        );
    sheet.getRangeByName('F$rowIndex').setText(userRegis.firmName ?? "");
    sheet.getRangeByName('F$rowIndex').cellStyle = styleLeft;
    rowIndex++;
  }

  sheet.getRangeByName('A$rowIndex:D$rowIndex').setText('TỔNG SỐ SINH VIÊN');
  sheet.getRangeByName('A$rowIndex:D$rowIndex').merge();
  sheet.getRangeByName('A$rowIndex:D$rowIndex').cellStyle = styleCenter;
  sheet.getRangeByName('A$rowIndex:D$rowIndex').cellStyle.bold = true;

  sheet
      .getRangeByName('D$rowIndex:E$rowIndex')
      .setText(trainees.length.toString());
  sheet.getRangeByName('E$rowIndex:F$rowIndex').merge();
  sheet.getRangeByName('E$rowIndex:F$rowIndex').cellStyle = styleCenter;
  sheet.getRangeByName('E$rowIndex:F$rowIndex').cellStyle.bold = true;

  sheet.autoFitColumn(1);
  sheet.autoFitColumn(2);
  sheet.autoFitColumn(3);
  sheet.autoFitColumn(4);
  sheet.autoFitColumn(5);
  sheet.autoFitColumn(6);

  List<int> bytes = workbook.saveAsStream();
  workbook.dispose();

  String nh = year.start == year.end
      ? TiengViet.parse(year.start).split(' ').join()
      : '${TiengViet.parse(year.start).split(' ').join()}_${TiengViet.parse(year.end).split(' ').join()}';
  saveExcel(bytes,
      'DS_TTTT_HK_${TiengViet.parse(term).split(' ').join()}_NH_$nh.xlsx');
}

Future<void> xuatDSSVGV(
    {required String classId,
    required String className,
    required List<UserModel> users}) async {
  final Workbook workbook = Workbook();
  final Worksheet sheet = workbook.worksheets[0];
  Style styleLeft = workbook.styles.add('styleLeft');
  styleLeft.fontName = 'Times New Roman';
  styleLeft.hAlign = HAlignType.left;
  styleLeft.vAlign = VAlignType.center;
  styleLeft.borders.all.lineStyle = LineStyle.thin;

  Style styleCenter = workbook.styles.add('styleCenter');
  styleCenter.fontName = 'Times New Roman';
  styleCenter.hAlign = HAlignType.center;
  styleCenter.vAlign = VAlignType.center;
  styleCenter.borders.all.lineStyle = LineStyle.thin;

  Style styleRight = workbook.styles.add('styleRight');
  styleRight.fontName = 'Times New Roman';
  styleRight.hAlign = HAlignType.right;
  styleRight.vAlign = VAlignType.center;
  styleRight.borders.all.lineStyle = LineStyle.thin;

  sheet.getRangeByName('A1:E1').setText('DANH SÁCH SINH VIÊN');
  sheet.getRangeByName('A1:E1').merge();
  sheet.getRangeByName('A1:E1').cellStyle = styleCenter;
  sheet.getRangeByName('A1:E1').cellStyle.borders.all.lineStyle =
      LineStyle.none;
  sheet.getRangeByName('A1:F1').cellStyle.bold = true;

  sheet.getRangeByName('A3:C3').setText('Mã lớp: ${classId.toUpperCase()}');
  sheet.getRangeByName('A3:C3').merge();
  sheet.getRangeByName('A3:C3').cellStyle = styleLeft;
  sheet.getRangeByName('A3:C3').cellStyle.borders.all.lineStyle =
      LineStyle.none;
  sheet.getRangeByName('A3:C3').cellStyle.bold = true;

  sheet.getRangeByName('D3:E3').setText('Tên lớp: $className');
  sheet.getRangeByName('D3:E3').merge();
  sheet.getRangeByName('D3:E3').cellStyle = styleLeft;
  sheet.getRangeByName('D3:E3').cellStyle.borders.all.lineStyle =
      LineStyle.none;
  sheet.getRangeByName('D3:E3').cellStyle.bold = true;

  sheet.getRangeByName('A5').setText('STT');
  sheet.getRangeByName('A5').cellStyle = styleCenter;
  sheet.getRangeByName('A5').cellStyle.bold = true;

  sheet.getRangeByName('B5').setText('Mã sinh viên');
  sheet.getRangeByName('B5').cellStyle = styleCenter;
  sheet.getRangeByName('B5').cellStyle.bold = true;

  sheet.getRangeByName('C5').setText('Họ tên sinh viên');
  sheet.getRangeByName('C5').cellStyle = styleCenter;
  sheet.getRangeByName('C5').cellStyle.bold = true;

  sheet.getRangeByName('D5').setText('Email');
  sheet.getRangeByName('D5').cellStyle = styleCenter;
  sheet.getRangeByName('D5').cellStyle.bold = true;

  sheet.getRangeByName('E5').setText('Số điện thoại');
  sheet.getRangeByName('E5').cellStyle = styleCenter;
  sheet.getRangeByName('E5').cellStyle.bold = true;

  var rowIndex = 6;
  for (int i = 0; i < users.length; i++) {
    sheet.getRangeByName('A$rowIndex').setText('${i + 1}');
    sheet.getRangeByName('A$rowIndex').cellStyle = styleCenter;
    sheet.getRangeByName('B$rowIndex').setText(users[i].userId!.toUpperCase());
    sheet.getRangeByName('B$rowIndex').cellStyle = styleLeft;
    sheet.getRangeByName('C$rowIndex').setText('${users[i].userName}');
    sheet.getRangeByName('C$rowIndex').cellStyle = styleLeft;
    sheet.getRangeByName('D$rowIndex').setText('${users[i].email}');
    sheet.getRangeByName('D$rowIndex').cellStyle = styleLeft;

    sheet.getRangeByName('E$rowIndex').setText('${users[i].phone}');
    sheet.getRangeByName('E$rowIndex').cellStyle = styleLeft;
    rowIndex++;
  }

  sheet.getRangeByName('A$rowIndex:C$rowIndex').setText('TỔNG SỐ SINH VIÊN');
  sheet.getRangeByName('A$rowIndex:C$rowIndex').merge();
  sheet.getRangeByName('A$rowIndex:C$rowIndex').cellStyle = styleCenter;
  sheet.getRangeByName('A$rowIndex:C$rowIndex').cellStyle.bold = true;

  sheet
      .getRangeByName('D$rowIndex:E$rowIndex')
      .setText(users.length.toString());
  sheet.getRangeByName('D$rowIndex:E$rowIndex').merge();
  sheet.getRangeByName('D$rowIndex:E$rowIndex').cellStyle = styleCenter;
  sheet.getRangeByName('D$rowIndex:E$rowIndex').cellStyle.bold = true;

  sheet.autoFitColumn(1);
  sheet.autoFitColumn(2);
  sheet.autoFitColumn(3);
  sheet.autoFitColumn(4);
  sheet.autoFitColumn(5);

  List<int> bytes = workbook.saveAsStream();
  workbook.dispose();

  saveExcel(bytes, 'DSSV_$classId.xlsx');
}

Future<void> saveExcel(List<int> bytes, String fileName) async {
  AnchorElement(
    href:
        "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}",
  )
    ..setAttribute("download", fileName)
    ..click();
}
