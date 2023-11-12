import 'dart:convert';

import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:tttt_project/common/constant.dart';
import 'package:tttt_project/models/appreciate_cv_model.dart';
import 'package:universal_html/html.dart';

Future<void> exportExcel(
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

  Style styleCenter = workbook.styles.add('styleCenter');
  styleCenter.fontName = 'Times New Roman';
  styleCenter.hAlign = HAlignType.center;
  styleCenter.vAlign = VAlignType.center;

  sheet.getRangeByName('C1').setText('KẾT QUẢ THỰC TẬP');
  sheet.getRangeByName('C1').cellStyle = styleCenter;

  sheet.getRangeByName('A3').setText('Mã lớp: $classId');
  sheet.getRangeByName('A3').cellStyle = styleCenter;
  sheet.getRangeByName('C3').setText('Học kỳ: $term');
  sheet.getRangeByName('C3').cellStyle = styleCenter;
  sheet.getRangeByName('E3').setText('Năm học: ${year.start} - ${year.end}');
  sheet.getRangeByName('E3').cellStyle = styleCenter;

  sheet.getRangeByName('A5').setText('STT');
  sheet.getRangeByName('A5').cellStyle = styleCenter;
  sheet.getRangeByName('B5').setText('Mã sinh viên');
  sheet.getRangeByName('B5').cellStyle = styleCenter;
  sheet.getRangeByName('C5').setText('Họ tên sinh viên');
  sheet.getRangeByName('C5').cellStyle = styleCenter;
  sheet.getRangeByName('D5').setText('Điểm số');
  sheet.getRangeByName('D5').cellStyle = styleCenter;
  sheet.getRangeByName('E5').setText('Điểm chữ');
  sheet.getRangeByName('E5').cellStyle = styleCenter;

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
    sheet.getRangeByName('D$rowIndex').cellStyle = styleCenter;
    sheet.getRangeByName('E$rowIndex').setText('${appreciates[i].pointChar}');
    sheet.getRangeByName('E$rowIndex').cellStyle = styleCenter;
    rowIndex++;
  }

  sheet.autoFitColumn(1);
  sheet.autoFitColumn(2);
  sheet.autoFitColumn(3);
  sheet.autoFitColumn(4);
  sheet.autoFitColumn(5);

  List<int> bytes = workbook.saveAsStream();
  workbook.dispose();

  saveExcel(bytes, 'Diem_TTTT_$classId.xlsx');
}

Future<void> saveExcel(List<int> bytes, String fileName) async {
  AnchorElement(
    href:
        "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}",
  )
    ..setAttribute("download", fileName)
    ..click();
}
