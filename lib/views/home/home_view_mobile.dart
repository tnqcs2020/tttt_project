import 'package:flutter/material.dart';
import 'package:tttt_project/widgets/navigation_bar/navbar_mobile.dart';

class HomeViewMobile extends StatefulWidget {
  const HomeViewMobile({Key? key}) : super(key: key);

  @override
  State<HomeViewMobile> createState() => _HomeViewMobileState();
}

class _HomeViewMobileState extends State<HomeViewMobile> with SingleTickerProviderStateMixin{
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          NavBarMobile(),
        ],
      ),
    );
  }
}
