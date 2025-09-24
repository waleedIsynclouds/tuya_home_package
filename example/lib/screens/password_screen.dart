import 'package:flutter/material.dart';
import 'package:tuya_example/screens/home_screen.dart';
import 'package:tuya_home_sdk_flutter/tuya_home_sdk_flutter.dart';

class PasswordScreen extends StatefulWidget {
  final String username;
  final String countryCode;
  final String code;
  const PasswordScreen({
    super.key,
    required this.username,
    required this.countryCode,
    required this.code,
  });

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _password;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Password')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 30),
              TextFormField(
                decoration: const InputDecoration(hintText: 'Password'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                child: const Text('Submit'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    var res = await TuyaHomeSdkFlutter.instance
                        .registerByUserName(
                          username: widget.username,
                          countryCode: widget.countryCode,
                          code: widget.code,
                          password: _password!,
                        );
                    if (res) {
                      TuyaHomeSdkFlutter.instance
                          .addHomeWithName(
                            name: "My Home",
                            geoName: "My Geo",
                            rooms: ["Living Room", "Bedroom"],
                          )
                          .then((value) {
                            if (value != null) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Registration failed'),
                                ),
                              );
                            }
                          });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Registration failed')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
