import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.15,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Trường Công nghệ Thông tin và Truyền thông - Trường Đại học Cần Thơ",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Text(
                "Địa chỉ: Khu II, Đường 3/2, Phường Xuân Khánh, Quận Ninh Kiêu, Cần Thơ",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Text(
                "k",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
