import 'package:another_flushbar/flushbar_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_stock_tracker/authentication/auth_provider.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final formKey = new GlobalKey<FormState>();

  String? _email, _password, _confirmPassword;

  bool isEmailValid(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);
    double screenHeight = MediaQuery.of(context).size.height;

    final emailField = TextFormField(
      autofocus: false,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (isEmailValid(value!)) {
          return null;
        }

        return "Invalid email";
      },
      onChanged: (value) => _email = value.toLowerCase().trim(),
      decoration: const InputDecoration(
          icon: Icon(Icons.email),
          labelText: 'Email *',
          border: OutlineInputBorder()),
    );

    final passwordField = TextFormField(
      autofocus: false,
      obscureText: true,
      validator: (value) =>
          value!.length < 8 ? "Password must be >= 8 characters" : null,
      onChanged: (value) => _password = value,
      decoration: const InputDecoration(
          icon: Icon(Icons.password),
          labelText: 'Password *',
          border: OutlineInputBorder()),
    );

    final confirmPasswordField = TextFormField(
      autofocus: false,
      obscureText: true,
      validator: (value) => value! != _password ? "Passwords must match" : null,
      onChanged: (value) => _confirmPassword = value,
      decoration: const InputDecoration(
          icon: Icon(Icons.password),
          labelText: 'Confirm Password *',
          border: OutlineInputBorder()),
    );

    var loading = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[CircularProgressIndicator()],
    );

    var doRegister = () {
      final form = formKey.currentState;

      if (form!.validate()) {
        form.save();
        auth.register(_email!, _password!).then((response) {
          // Successful registration
          if (response == 200) {
            // go to login page
            auth.registeredInStatus = Status.Registered;
            Navigator.pushReplacementNamed(context, "/login");
            FlushbarHelper.createSuccess(
                    message: "Successfully registered!",
                    duration: const Duration(seconds: 3))
                .show(context);
          } else {
            setState(() {
              auth.registeredInStatus = Status.NotRegistered;
            });
            FlushbarHelper.createError(
                    title: "Error",
                    message: "Failed to register (Duplicate emails)",
                    duration: const Duration(seconds: 3))
                .show(context);
          }
        });
      }
    };

    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Form(
            key: formKey,
            child: ListView(
              children: <Widget>[
                SizedBox(height: screenHeight * 0.12),
                Text(
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
                  "Sign up to get started!",
                  style: TextStyle(
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 20),
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: screenHeight * .12),
                emailField,
                SizedBox(height: screenHeight * .025),
                passwordField,
                SizedBox(height: screenHeight * .025),
                confirmPasswordField,
                SizedBox(height: screenHeight * .075),
                auth.registeredInStatus == Status.Registering
                    ? loading
                    : ElevatedButton(
                        onPressed: doRegister,
                        child: Text(
                          "Sign Up",
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(0, 50),
                          // Width doesn't matter here
                          primary: Colors.blue[400],
                          elevation: 4,
                          padding: EdgeInsets.symmetric(vertical: 4.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(64),
                          ),
                        ),
                      ),
                SizedBox(height: screenHeight * .15),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, "/login");
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
                          text: "Sign in",
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
            )),
      ),
    );
  }
}
