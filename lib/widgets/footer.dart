import 'package:flutter/material.dart';
import 'package:tttt_project/widgets/custom_devider.dart';

class Footer extends StatelessWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.17,
      padding: const EdgeInsets.only(top: 20, bottom: 20),
      child: const Column(
        children: [
          CustomDivider(
            color: Colors.grey,
            dashHeight: 0.5,
            dashWidth: 2,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Trường Công nghệ Thông tin và Truyền thông - Trường Đại học Cần Thơ",
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "Địa chỉ: Khu II, Đường 3/2, Phường Xuân Khánh, Quận Ninh Kiêu, Cần Thơ",
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    Text(
                        "Điện thoại: 84 0292 3 734713 - 0292 3 831301; Fax: 84 0292 3830841; Email: tcntt@ctu.edu.vn")
                  ],
                ),
              ],
            ),
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
