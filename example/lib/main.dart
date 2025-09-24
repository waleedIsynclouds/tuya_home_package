import 'package:flutter/material.dart';
import 'package:tuya_example/screens/login_screen.dart';
import 'package:tuya_home_sdk_flutter/tuya_home_sdk_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    TuyaHomeSdkFlutter.instance.initSdk(
      '<AppKey>',
      '<AppSecret>',
      '<pluginKey>',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
