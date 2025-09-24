import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:tuya_example/screens/password_screen.dart';
import 'package:tuya_home_sdk_flutter/tuya_home_sdk_flutter.dart';

class VerfiyScreen extends StatefulWidget {
  final String username;

  const VerfiyScreen({super.key, required this.username});

  @override
  State<VerfiyScreen> createState() => _VerfiyScreenState();
}

class _VerfiyScreenState extends State<VerfiyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verfiy')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          const Text(
            'Write your code here',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 30),
          Pinput(
            closeKeyboardWhenCompleted: true,
            keyboardType: TextInputType.number,
            length: 6,
            defaultPinTheme: PinTheme(
              width: 56,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
            ),
            onCompleted: (value) {
              TuyaHomeSdkFlutter.instance
                  .checkCodeWithUserName(
                    username: widget.username,
                    countryCode: "+2",
                    type: 1,
                    code: value,
                  )
                  .then((v) {
                    if (v) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) => PasswordScreen(
                                username: widget.username,
                                code: value,
                                countryCode: '+2',
                              ),
                        ),
                      );
                    }
                  });
            },
          ),
        ],
      ),
    );
  }
}
