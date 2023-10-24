import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LineDetail extends StatelessWidget {
  const LineDetail({
    super.key,
    required this.field,
    this.display,
    this.widthField = 0.07,
    this.widthForm = 0.17,
    this.ctrl,
    this.minLines = 1,
    this.textFormat,
  });
  final String field;
  final String? display;
  final double widthField;
  final double widthForm;
  final TextEditingController? ctrl;
  final int minLines;
  final List<TextInputFormatter>? textFormat;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: screenWidth * widthField,
            child: Text(
              field,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
              ),
              overflow: TextOverflow.visible,
            ),
          ),
          SizedBox(
            width: screenWidth * widthForm,
            child: TextFormField(
              controller: ctrl,
              readOnly: display != null ? true : false,
              minLines: minLines,
              maxLines: 100,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: display != null && ctrl == null ? display : null,
                hintStyle: const TextStyle(color: Colors.black87),
                contentPadding: const EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderSide:
                      display != null ? BorderSide.none : const BorderSide(),
                ),
              ),
              inputFormatters: textFormat,
            ),
          )
        ],
      ),
    );
  }
}
