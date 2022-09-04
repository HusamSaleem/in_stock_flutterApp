
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:in_stock_tracker_new/providers/authentication_service.dart';
import 'package:in_stock_tracker_new/pages/register_page.dart';
import 'package:in_stock_tracker_new/pages/home_page.dart';
import 'package:in_stock_tracker_new/pages/sign_in_page.dart';
import 'package:in_stock_tracker_new/providers/profile_provider.dart';
import 'package:in_stock_tracker_new/providers/watchlist_service.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(FirebaseAuth.instance),
        ),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => WatchlistProvider()),
        StreamProvider(
            create: (context) => context.read<AuthenticationService>().authStateChanges, initialData: null)
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
          brightness: Brightness.dark,
          visualDensity: VisualDensity.adaptivePlatformDensity
        ),
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        home: const AuthenticationWrapper(),
        routes: {
          '/login': (context) => SignInPage(),
          '/register': (context) => RegisterPage(),
          '/home': (context) => const HomePage(),
        },
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();
    if (firebaseUser != null) {
      return const HomePage();
    }
    return SignInPage();
  }
}

