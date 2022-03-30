import 'package:another_flushbar/flushbar_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_stock_tracker/authentication/auth_provider.dart';
import 'package:in_stock_tracker/authentication/user.dart';
import 'package:in_stock_tracker/authentication/user_provider.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = new GlobalKey<FormState>();

  late String _email, _password;

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
      onSaved: (value) => _email = value!,
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
      onSaved: (value) => _password = value!,
      decoration: const InputDecoration(
          icon: Icon(Icons.password),
          labelText: 'Password *',
          border: OutlineInputBorder()),
    );

    var loading = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[CircularProgressIndicator()],
    );

    var doLogin = () {
      final form = formKey.currentState;

      if (form!.validate()) {
        form.save();

        final Future<Map<String, dynamic>> successfulMessage =
            auth.login(_email, _password);

        successfulMessage.then((response) {
          if (response['status']) {
            User user = response['user'];
            Provider.of<UserProvider>(context, listen: false).setUser(user);

            FlushbarHelper.createSuccess(
                    message: "Successful login",
                    duration: const Duration(seconds: 3))
                .show(context);
            Navigator.pushReplacementNamed(context, "/watchlist");
          } else {
            FlushbarHelper.createError(
                    message: 'Invalid email and/or password',
                    title: 'Error',
                    duration: const Duration(seconds: 3))
                .show(context);
          }
        });
      }
    };

    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(25.0),
        child: Form(
            key: formKey,
            child: ListView(
              children: <Widget>[
                SizedBox(height: 36.0),
                Text(
                  "Welcome,",
                  style: TextStyle(
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 48),
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 8.0),
                Text(
                  "Sign in to continue",
                  style: TextStyle(
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 24),
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 128.0),
                emailField,
                SizedBox(height: 16.0),
                passwordField,
                SizedBox(height: 16.0),
                auth.loggedInStatus == Status.Authenticating
                    ? loading
                    : ElevatedButton(
                        onPressed: doLogin,
                        child: Text(
                          "Log In",
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(0,50), // Width doesn't matter here
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
                    Navigator.pushReplacementNamed(context, "/register");
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
            )),
      ),
    );
  }
}
