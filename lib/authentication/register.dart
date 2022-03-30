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

    final emailField = TextFormField(
      autofocus: false,
      validator: (value) {
        if (isEmailValid(value!)) {
          return null;
        }

        return "Invalid email";
      },
      onChanged: (value) => _email = value,
      decoration: const InputDecoration(
          icon: Icon(Icons.email),
          labelText: 'Email *',
          border: OutlineInputBorder()),
    );

    final passwordField = TextFormField(
      autofocus: false,
      obscureText: true,
      maxLength: 32,
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
      maxLength: 32,
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

    return SafeArea(
        child: Scaffold(
      body: Container(
        padding: EdgeInsets.all(25.0),
        child: Form(
            key: formKey,
            child: ListView(
              children: <Widget>[
                SizedBox(height: 36.0),
                Text(
                  "Create Account,",
                  style: TextStyle(
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 48),
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 8.0),
                Text(
                  "Sign up to get started!",
                  style: TextStyle(
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 24),
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 128.0),
                emailField,
                SizedBox(height: 32.0),
                passwordField,
                SizedBox(height: 16.0),
                confirmPasswordField,
                SizedBox(height: 16.0),
                auth.registeredInStatus == Status.Registering
                    ? loading
                    : ElevatedButton(
                        onPressed: doRegister,
                        child: Text(
                          "Sign Up",
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(0, 50), // Width doesn't matter here
                          primary: Colors.blue[400],
                          elevation: 4,
                          padding: EdgeInsets.symmetric(vertical: 4.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(64),
                          ),
                        ),
                      ),
                SizedBox(height: 255),
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
    ));
  }
}
