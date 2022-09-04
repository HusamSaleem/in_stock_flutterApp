import 'package:another_flushbar/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:in_stock_tracker_new/providers/authentication_service.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatelessWidget {
  SignInPage({Key? key}) : super(key: key);
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isEmailValid(String email) {
    return RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              SizedBox(height: screenHeight * 0.12),
              const Text(
                "Welcome,",
                style: TextStyle(
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 32),
                textAlign: TextAlign.start,
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                "Sign in to continue",
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
              SizedBox(height: screenHeight * 0.05),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      FlushbarHelper.createInformation(
                          message: "Attempting to sign in...",
                          duration: const Duration(seconds: 2))
                          .show(context);
                      bool success = await context.read<AuthenticationService>().signIn(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim());
                      if (!success) {
                        FlushbarHelper.createError(
                            message: "Wrong email/password combination",
                            duration: const Duration(seconds: 2))
                            .show(context);
                      } else {
                        FlushbarHelper.createSuccess(
                            message: "Successfully signed in!",
                            duration: const Duration(seconds: 2))
                            .show(context);
                      }
                    }
                  },
                  child: const Text("Sign in")
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                style: ButtonStyle(
                    overlayColor:
                    MaterialStateProperty.all(Colors.transparent)),
                child: RichText(
                  text: const TextSpan(
                    text: "I'm a new user, ",
                    style: TextStyle(color: Colors.white70),
                    children: [
                      TextSpan(
                        text: "Sign Up",
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
