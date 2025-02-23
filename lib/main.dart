import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'views/swiping_screen.dart';
import 'package:almari/views/signup_page.dart';
// import 'package:almari/views/login.dart';
import 'package:almari/controllers/auth_controller.dart';
import 'package:almari/controllers/swiping_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Get.put(AuthController());
  Get.put(SwipingController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Swipe Images',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 239, 254),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 255, 239,
              254), // Optional: You can also set appBar background color
        ),
        // primarySwatch: Colors.blue,
      ),
      // home: const SwipingScreen(),
      // home: LoginPage(),
      home: SignupPage(),
    );
  }
}
