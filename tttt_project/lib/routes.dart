import 'package:flutter/material.dart';
import 'package:tttt_project/views/home/desktop/admin/add_user_screen.dart';
import 'package:tttt_project/views/home/desktop/admin/list_trainee_screen.dart';
import 'package:tttt_project/views/home/desktop/admin/manage_credit_screen.dart';
import 'package:tttt_project/views/home/desktop/canbo/manage_info_canbo.dart';
import 'package:tttt_project/views/home/desktop/canbo/manage_trainee.dart';
import 'package:tttt_project/views/home/desktop/home_view_desktop.dart';
import 'package:tttt_project/views/home/desktop/student/cv_screen.dart';
import 'package:tttt_project/views/home/desktop/student/regisFirm/firm_link.dart';
import 'package:tttt_project/views/home/desktop/student/information.dart';
import 'package:tttt_project/views/home/desktop/student/register_trainee.dart';
import 'package:tttt_project/views/login/login_screen.dart';

class RouteGenerator {
  static const String login = '/dangnhap';
  static const String info = '/thongtin';
  static const String register = '/dkytttt';
  static const String firm = '/congty';
  static const String home = '/trangchu';
  static const String cv = '/hoso';
  static const String addUser = '/taotk';
  static const String dstttt = '/dstttt';
  static const String manageCredit = '/qlhocphan';
  static const String manageInfoCB = '/qlthongtin';
  static const String manageTraineeCB = '/qlthuctap';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case '/':
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const HomeViewDesktop(),
        );
      case login:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => LogInScreen(),
        );
      case home:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const HomeViewDesktop(),
        );
      case register:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const RegisterTrainee(),
        );
      case firm:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const FirmLink(),
        );
      case info:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const InfoScreen(),
        );
      case cv:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const CVScreen(),
        );
      case addUser:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const AddUserScreen(),
        );
      case dstttt:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const ListTraineeScreen(),
        );
      case manageCredit:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const ManageCreditScreen(),
        );
      case manageInfoCB:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const ManageInfoCB(),
        );
      case manageTraineeCB:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const ManageTrainee(),
        );
      default:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Screen does not exist'),
            ),
          ),
        );
    }
  }
}
