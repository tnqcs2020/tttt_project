import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tttt_project/firebase_options.dart';
import 'package:tttt_project/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tttt_project/views/login/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? isLoggedIn = prefs.getBool("isLoggedIn");
  if (isLoggedIn == true) {
    prefs.getString('email').toString();
    prefs.getString('password').toString();
    prefs.getString('userId').toString();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'HTQL Thực tập',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade600),
        useMaterial3: true,
      ),
      home: LogInScreen(),
      initialRoute: RouteGenerator.login,
      onGenerateRoute: RouteGenerator.generateRoute,
      builder: EasyLoading.init(),
    );
  }
}
