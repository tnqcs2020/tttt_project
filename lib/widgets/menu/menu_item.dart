// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:tttt_project/data/constant.dart';
// import 'package:tttt_project/widgets/user_controller.dart';

// class MenuItem extends StatefulWidget {
//   final String title;
//   final VoidCallback onPressed;
//   const MenuItem({
//     Key? key,
//     required this.title,
//     required this.onPressed,
//   }) : super(key: key);

//   @override
//   State<MenuItem> createState() => _MenuItemState();
// }

// class _MenuItemState extends State<MenuItem> {
//   final currentUser = Get.put(UserController());
//   @override
//   Widget build(BuildContext context) {
//     return Obx(
//       () => Container(
//         height: 25,
//         padding: const EdgeInsets.only(left: 10),
//         decoration: const BoxDecoration(
//           color: Colors.transparent,
//         ),
//         child: ListTile(
//           onTap: widget.onPressed,
//           selected: pages[currentUser.group.value]
//                             ?[currentUser.menuSelected.value],
//           // child: Row(
//           //   children: [
//           //     InkWell(
//           //       onTap: widget.onPressed,
//           //       child: Text(
//           //         widget.title,
//           //         style: TextStyle(
//           //           color: menus[currentUser.group.value]
//           //                       ?[currentUser.menuSelected.value] ==
//           //                   widget.title
//           //               ? Colors.blue.shade900
//           //               : null,
//           //           fontWeight: menus[currentUser.group.value]
//           //                       ?[currentUser.menuSelected.value] ==
//           //                   widget.title
//           //               ? FontWeight.bold
//           //               : null,
//           //         ),
//           //       ),
//           //     )
//           //   ],
//           // ),
//         ),
//       ),
//     );
//   }
// }
