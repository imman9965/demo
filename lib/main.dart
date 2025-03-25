import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:testgetx/screens/home.dart';
import 'package:testgetx/screens/login_screen.dart';
import 'package:testgetx/utils/binding.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Patient App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () =>  LoginScreen(), binding: AuthBinding()),
        GetPage(name: '/home', page: () =>  HomeScreen()),
      ],
    );
  }
}


