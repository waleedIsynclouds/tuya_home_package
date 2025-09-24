import 'package:flutter/material.dart';
import 'package:tuya_example/screens/verfiy_screen.dart';
import 'package:tuya_home_sdk_flutter/tuya_home_sdk_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _username;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
        child: Column(
          children: [
            const SizedBox(height: 100),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    onSaved: (newValue) {
                      _username = newValue;
                    },
                    decoration: const InputDecoration(hintText: 'Email'),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        TuyaHomeSdkFlutter.instance
                            .sendVerifyCodeWithUserName(
                              username: _username!,
                              countryCode: '+2',
                              type: 1,
                            )
                            .then((v) {
                              if (v) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Code sent')),
                                );
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) =>
                                            VerfiyScreen(username: _username!),
                                  ),
                                );
                              }
                            });
                      }
                    },
                    child: const Text('Send code'),
                  ),

                  // Forget password
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
