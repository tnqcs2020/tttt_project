import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tttt_project/widgets/user_controller.dart';

class CustomRadio extends StatelessWidget {
  const CustomRadio(
      {Key? key,
      required this.title,
      this.subtitle,
      this.selected = false,
      required this.onTap})
      : super(key: key);
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: selected
                  ? Container(
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.lightBlue.shade900,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(50)),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.circle,
                          color: Colors.lightBlue.shade900,
                          size: 16,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.circle_outlined,
                      size: 20,
                    ),
            ),
            const SizedBox(width: 15),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                if (subtitle != null) Text(subtitle!),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
