import 'package:flutter/material.dart';
import 'package:tttt_project/widgets/navigation_bar/navbar_tablet.dart';

class HomeViewTablet extends StatefulWidget {
  const HomeViewTablet({Key? key}) : super(key: key);

  @override
  State<HomeViewTablet> createState() => _HomeViewTabletState();
}

class _HomeViewTabletState extends State<HomeViewTablet> with SingleTickerProviderStateMixin{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: const Column(
        children: [
          NavBarTablet(),
        ],
      ),
      floatingActionButton: CircleAvatar(
        radius: 35,
        child: IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.message_outlined,
              size: 45,
            )),
      ),
    );
  }
}
