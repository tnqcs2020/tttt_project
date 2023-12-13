import 'package:flutter/material.dart';

class FieldDetail extends StatelessWidget {
  const FieldDetail({
    super.key,
    required this.field,
    required this.content,
  });

  final String field;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: '$field: ',
        style: const TextStyle(fontWeight: FontWeight.bold),
        children: [
          TextSpan(
            text: content,
            style: const TextStyle(fontWeight: FontWeight.normal),
          )
        ],
      ),
      overflow: TextOverflow.clip,
      textAlign: TextAlign.justify,
    );
  }
}