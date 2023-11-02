import 'package:flutter/material.dart';
import 'package:tttt_project/widgets/custom_devider.dart';

class Footer extends StatelessWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.14,
      padding: const EdgeInsets.only(top: 20),
      child: const Column(
        children: [
          CustomDivider(
            color: Colors.grey,
            dashHeight: 0.5,
            dashWidth: 2,
          ),
          Row(
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
          CustomDivider(
            color: Colors.grey,
            dashHeight: 0.5,
            dashWidth: 2,
          ),
        ],
      ),
    );
  }
}
