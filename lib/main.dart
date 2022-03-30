import 'package:flutter/material.dart';
import 'package:in_stock_tracker/account/profile_provider.dart';
import 'package:in_stock_tracker/authentication/login.dart';
import 'package:in_stock_tracker/authentication/user.dart';
import 'package:in_stock_tracker/theme/app_theme.dart';
import 'package:in_stock_tracker/utils/local_persistence.dart';
import 'package:in_stock_tracker/watchlist/watchlist_provider.dart';
import 'package:provider/provider.dart';

import 'authentication/auth_provider.dart';
import 'authentication/register.dart';
import 'authentication/user_provider.dart';
import 'main_screen.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    Future<User> getUserData() => UserPreferences().getUser();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => WatchlistProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: MaterialApp(
          theme: ThemeData(brightness: Brightness.light),
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          debugShowCheckedModeBanner: false,
          home: FutureBuilder<User>(
              future: getUserData(),
              builder: (context, AsyncSnapshot<User> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return CircularProgressIndicator();
                  default:
                    if (snapshot.hasError) {
                      UserPreferences().removeUser();
                      return Login();
                    } else if (snapshot.data == null) {
                      return Login();
                    }
                    Provider.of<UserProvider>(context, listen: false)
                        .setUser(snapshot.data!);
                    return MainView();
                }
              }),
          routes: {
            '/login': (context) => Login(),
            '/register': (context) => Register(),
            '/watchlist': (context) => MainView()
          }),
    );
  }
}
