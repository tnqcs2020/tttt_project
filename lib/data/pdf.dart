import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:tttt_project/data/constant.dart';
import 'package:tttt_project/models/appreciate_cv_model.dart';
import 'package:universal_html/html.dart';

exportPDF(String classId, String term, NamHoc year,
    List<AppreciateCVModel> appreciates) async {
  final data = await rootBundle.load('assets/OpenSans-Regular.ttf');
  final fontImport =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

  final PdfDocument document = PdfDocument();

  final PdfPage page = document.pages.add();

  final PdfStringFormat format = PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle);
  final PdfStringFormat leftFormat = PdfStringFormat(
      alignment: PdfTextAlignment.left,
      lineAlignment: PdfVerticalAlignment.middle);

  final PdfPaddings padding = PdfPaddings(right: 3, top: 3, bottom: 3, left: 3);
  final PdfPen linePen = PdfPen(PdfColor(0, 0, 0), width: 0.5);
  final PdfBorders borders =
      PdfBorders(left: linePen, top: linePen, bottom: linePen, right: linePen);
  final PdfBorders noneBorder = PdfBorders(
      bottom: PdfPens.transparent,
      left: PdfPens.transparent,
      top: PdfPens.transparent,
      right: PdfPens.transparent);

  final PdfFont font = PdfTrueTypeFont(fontImport, 10);
  final PdfFont fontBold =
      PdfTrueTypeFont(fontImport, 10, style: PdfFontStyle.bold);
  final PdfFont fontLargeBold =
      PdfTrueTypeFont(fontImport, 13, style: PdfFontStyle.bold);

  final PdfGrid headerGrid = PdfGrid();
  headerGrid.style.font = font;
  headerGrid.columns.add(count: 3);

  final PdfGridRow headerRow0 = headerGrid.rows.add();
  headerRow0.cells[0].columnSpan = 3;
  headerRow0.cells[0].value = 'KẾT QUẢ THỰC TẬP';
  headerRow0.cells[0].style.stringFormat = format;
  headerRow0.cells[0].style.font = fontLargeBold;

  final PdfGridRow headerRow1 = headerGrid.rows.add();
  headerRow1.height = 15;

  final PdfGridRow headerRow2 = headerGrid.rows.add();
  headerRow2.height = 15;
  headerRow2.cells[0].value = 'Lớp: $classId';
  headerRow2.cells[0].style.stringFormat = leftFormat;
  headerRow2.cells[0].style.font = font;

  headerRow2.cells[1].value = 'Học kỳ: $term';
  headerRow2.cells[1].style.stringFormat = leftFormat;
  headerRow2.cells[1].style.font = font;

  headerRow2.cells[2].value = year == NamHoc.tatca
      ? 'Năm học: ${year.start}'
      : 'Năm học: ${year.start} - ${year.end}';
  headerRow2.cells[2].style.stringFormat = leftFormat;
  headerRow2.cells[2].style.font = font;

  final PdfGridRow headerRow3 = headerGrid.rows.add();
  headerRow3.height = 15;

  for (int i = 0; i < headerGrid.rows.count; i++) {
    final PdfGridRow headerRow = headerGrid.rows[i];
    for (int j = 0; j < headerRow.cells.count; j++) {
      headerRow.cells[j].style.borders = noneBorder;
    }
  }

  final PdfLayoutResult result =
      headerGrid.draw(page: page, bounds: const Rect.fromLTWH(1, 1, 0, 0))!;

  PdfGrid contentGrid = PdfGrid();
  contentGrid.style.font = font;
  contentGrid.columns.add(count: 5);

  contentGrid.headers.add(1);
  contentGrid.columns[0].width = 40;
  contentGrid.columns[1].width = 80;
  contentGrid.columns[3].width = 80;
  contentGrid.columns[4].width = 80;

  final PdfGridRow contentHeader = contentGrid.headers[0];
  contentHeader.cells[0].value = 'STT';
  contentHeader.cells[0].style.stringFormat = format;
  contentHeader.cells[0].style.borders = borders;
  contentHeader.cells[0].style.font = fontBold;
  contentHeader.cells[0].style.cellPadding = padding;

  contentHeader.cells[1].value = 'MSSV';
  contentHeader.cells[1].style.stringFormat = format;
  contentHeader.cells[1].style.borders = borders;
  contentHeader.cells[1].style.font = fontBold;
  contentHeader.cells[1].style.cellPadding = padding;

  contentHeader.cells[2].value = 'Họ Tên';
  contentHeader.cells[2].style.stringFormat = format;
  contentHeader.cells[2].style.borders = borders;
  contentHeader.cells[2].style.font = fontBold;
  contentHeader.cells[2].style.cellPadding = padding;

  contentHeader.cells[3].value = 'Điểm Số';
  contentHeader.cells[3].style.stringFormat = format;
  contentHeader.cells[3].style.borders = borders;
  contentHeader.cells[3].style.font = fontBold;
  contentHeader.cells[3].style.cellPadding = padding;

  contentHeader.cells[4].value = 'Điểm Chữ';
  contentHeader.cells[4].style.stringFormat = format;
  contentHeader.cells[4].style.borders = borders;
  contentHeader.cells[4].style.font = fontBold;
  contentHeader.cells[4].style.cellPadding = padding;

  for (int i = 0; i < appreciates.length; i++) {
    contentGrid = _addContentRow(
        '${i + 1}', contentGrid, format, leftFormat, appreciates[i], padding);
  }

  final PdfGridRow totalRow = contentGrid.rows.add();
  totalRow.cells[0].value = 'TỔNG SỐ SINH VIÊN';
  totalRow.cells[3].value = appreciates.length.toString();

  totalRow.cells[0].columnSpan = 3;
  totalRow.cells[0].style.stringFormat = format;
  totalRow.cells[0].style.font = fontBold;
  totalRow.cells[3].columnSpan = 2;
  totalRow.cells[3].style.stringFormat = format;
  totalRow.cells[3].style.font = fontBold;
  totalRow.height = 25;

  for (int i = 0; i < contentGrid.rows.count; i++) {
    final PdfGridRow contentRow = contentGrid.rows[i];
    for (int j = 0; j < contentRow.cells.count; j++) {
      contentRow.cells[j].style.borders = borders;
    }
  }

  contentGrid.draw(
      page: result.page,
      bounds: Rect.fromLTWH(1, result.bounds.top + result.bounds.height, 0, 0));

  List<int> bytes = await document.save();
  document.dispose();

  saveAndLaunchFile(bytes, 'Diem_TTTT_$classId.pdf');
}

PdfGrid _addContentRow(
    String srNo,
    PdfGrid grid,
    PdfStringFormat format,
    PdfStringFormat leftFormat,
    AppreciateCVModel appreciate,
    PdfPaddings padding) {
  final PdfGridRow contentRow = grid.rows.add();

  contentRow.cells[0].value = srNo;
  contentRow.cells[0].style.stringFormat = format;
  contentRow.cells[0].style.cellPadding = padding;

  contentRow.cells[1].value = appreciate.userId!.toUpperCase();
  contentRow.cells[1].style.stringFormat = leftFormat;
  contentRow.cells[1].style.cellPadding = padding;

  contentRow.cells[2].value = appreciate.userName;
  contentRow.cells[2].style.stringFormat = leftFormat;
  contentRow.cells[2].style.cellPadding = padding;

  contentRow.cells[3].value = appreciate.finalTotal.toString();
  contentRow.cells[3].style.stringFormat = format;
  contentRow.cells[3].style.cellPadding = padding;

  contentRow.cells[4].value = appreciate.pointChar;
  contentRow.cells[4].style.stringFormat = format;
  contentRow.cells[4].style.cellPadding = padding;

  return grid;
}

Future<void> saveAndLaunchFile(List<int> bytes, String fileName) async {
  AnchorElement(
    href:
        "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}",
  )
    ..setAttribute("download", fileName)
    ..click();
}
