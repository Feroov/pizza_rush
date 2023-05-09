import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pizza_rush/screens/SplashScreen.dart';

void main() {
  runApp(const MyApp());
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
}



class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pizza Rush',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const SplashScreen()
    );
  }
}

