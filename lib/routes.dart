import 'package:flutter/material.dart';
import 'package:tttt_project/views/desktop/admin/add_user_screen.dart';
import 'package:tttt_project/views/desktop/admin/list_trainee_screen.dart';
import 'package:tttt_project/views/desktop/admin/list_user.dart';
import 'package:tttt_project/views/desktop/canbo/manage_info_canbo.dart';
import 'package:tttt_project/views/desktop/canbo/manage_trainee.dart';
import 'package:tttt_project/views/desktop/covan/info_covan.dart';
import 'package:tttt_project/views/desktop/covan/manage_list_student.dart';
import 'package:tttt_project/views/desktop/giaovu/manage_announcement.dart';
import 'package:tttt_project/views/desktop/giaovu/manage_credit_screen.dart';
import 'package:tttt_project/views/desktop/giaovu/manage_time.dart';
import 'package:tttt_project/views/desktop/home_view_desktop.dart';
import 'package:tttt_project/views/desktop/student/cv_screen.dart';
import 'package:tttt_project/views/desktop/student/regisFirm/firm_link.dart';
import 'package:tttt_project/views/desktop/student/information.dart';
import 'package:tttt_project/views/desktop/student/register_trainee.dart';
import 'package:tttt_project/views/login/login_screen.dart';

class RouteGenerator {
  static const String login = '/dang-nhap';
  static const String info = '/thong-tin';
  static const String register = '/dky-tttt';
  static const String firm = '/cong-ty';
  static const String home = '/trang-chu';
  static const String cv = '/ho-so';
  static const String addUser = '/tao-tk';
  static const String dstttt = '/ds-tttt';
  static const String manageCredit = '/ql-hoc-phan';
  static const String manageInfoCB = '/ql-thong-tin';
  static const String manageTraineeCB = '/ql-thuc-tap';
  static const String dsNguoiDung = '/ds-nguoi-dung';
  static const String manageAnnouncement = '/ql-thong-bao';
  static const String manageTime = '/ql-thoi-gian';
  static const String infoCV = '/thong-tin-cv';
  static const String dssv = '/ds-sinh-vien';

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
      case dsNguoiDung:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const ListUserScreen(),
        );
      case manageAnnouncement:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const ManageAnnouncementScreen(),
        );
      case manageTime:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const ManageTimeScreen(),
        );
      case infoCV:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const InfoCV(),
        );
      case dssv:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const ManageListStudent(),
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
