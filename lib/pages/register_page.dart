import 'package:another_flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:in_stock_tracker_new/providers/profile_provider.dart';
import 'package:provider/provider.dart';

import '../providers/authentication_service.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isEmailValid(String email) {
    return RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    ProfileProvider profileProvider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: screenHeight * 0.12),
              const Text(
                "Create Account,",
                style: TextStyle(
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 32),
                textAlign: TextAlign.start,
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                "Sign up to get started",
                style: TextStyle(
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 20),
                textAlign: TextAlign.start,
              ),
              SizedBox(height: screenHeight * 0.12),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (isEmailValid(value!)) {
                    return null;
                  }
                  return "Invalid email";
                },
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    labelText: "Email"
                ),
              ),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                validator: (value) {
                  if (value!.length > 8) {
                    return null;
                  }
                  return "Password must be >= 8 characters";
                },
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.password),
                    labelText: "Password"
                ),
              ),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                validator: (value) {
                  if (value == passwordController.text) {
                    return null;
                  }
                  return "Passwords don't match";
                },
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.password),
                    labelText: "Confirm Password"
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      bool success = await context.read<AuthenticationService>().signUp(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim());
                      if (success) {
                        String uuid = context.read<AuthenticationService>().getUuid().toString();
                        String? registrationToken = await context.read<AuthenticationService>().getRegistrationToken();
                        await profileProvider.createNewUser(uuid, registrationToken!);
                        Navigator.pop(context);
                      } else {
                        FlushbarHelper.createError(
                            message: "The account may already exist already",
                            duration: const Duration(seconds: 2))
                            .show(context);
                      }
                    }
                  },
                  child: const Text("Sign up")
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                    overlayColor:
                    MaterialStateProperty.all(Colors.transparent)),
                child: RichText(
                  text: const TextSpan(
                    text: "I'm already a member, ",
                    style: TextStyle(color: Colors.white70),
                    children: [
                      TextSpan(
                        text: "Sign In",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
