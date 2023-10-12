import 'package:flutter/material.dart';

class LineDetail extends StatelessWidget {
  const LineDetail({
    super.key,
    required this.field,
    required this.value,
    this.width = 0.07,
  });
  final String field;
  final String value;
  final double width;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      height: 35,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            color: Colors.purpleAccent,
            child: SizedBox(
              width: screenWidth * width,
              height: 35,
              child: Text(
                field,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.left,
              ),
            ),
          ),
          Container(
            color: Colors.amberAccent,
            child: SizedBox(
              width: screenWidth * (width + 0.08),
              height: 35,
              child: Text(
                value,
              ),
            ),
          )
        ],
      ),
    );
  }
}
