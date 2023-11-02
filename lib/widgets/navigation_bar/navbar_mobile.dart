import 'package:flutter/material.dart';

class NavBarMobile extends StatelessWidget {
  const NavBarMobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: Colors.teal.shade200,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
          SizedBox(
            height: 80,
            width: 150,
            child: Image.asset("assets/logo.png"),
          ),
        ],
      ),
    );
  }
}
