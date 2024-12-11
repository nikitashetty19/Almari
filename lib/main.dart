import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'views/swiping_screen.dart';
import 'package:almari/controllers/swiping_controller.dart';

void main() {
  runApp(const MyApp());
  Get.put(SwipingController());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Swipe Images',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 224, 196, 185),
        appBarTheme: AppBarTheme(
          backgroundColor: Color.fromARGB(255, 224, 196,
              185), // Optional: You can also set appBar background color
        ),
        // primarySwatch: Colors.blue,
      ),
      home: const SwipingScreen(),
    );
  }
}
