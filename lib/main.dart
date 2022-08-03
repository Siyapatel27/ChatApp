import 'package:chat_app/ChatList.dart';
import 'package:chat_app/SignUp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'DarkThemeProvider.dart';
import 'Preferences.dart';
import 'Profile.dart';
import 'SignIn.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = new DarkThemeProvider();

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => themeChangeProvider,
      child: Consumer<DarkThemeProvider>(
        builder: (context, value, child) {
          return MaterialApp(
            title: 'Flutter Demo',
            // theme: Styles.themeData(themeChangeProvider.darkTheme, context),
            theme: ThemeData(
              primaryColor: Colors.blue,
            ),
            debugShowCheckedModeBanner: false,
            home: Redirect(),
          );
        },
      ),
    );
  }
}

class Redirect extends StatefulWidget {
  const Redirect({Key? key}) : super(key: key);

  @override
  State<Redirect> createState() => _RedirectState();
}

class _RedirectState extends State<Redirect> {
  bool check = false;

  @override
  void initState() {
    super.initState();
    redirectToPage();
  }

  redirectToPage() async {
    check = await getBoolPrefs("LoginPref");
    if (check) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => ChatList()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SignUp()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

int themeColorIndex = 0;
List themeColors = [
  Colors.blue,
  Colors.pink,
  Colors.red,
  Colors.teal,
  Colors.purple,
  Colors.indigo,
  Colors.brown,
  Colors.cyan,
  Colors.green,
];