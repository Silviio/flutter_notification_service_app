import 'package:flutter/material.dart';
import 'package:flutternotificationserviceapp/screens/home_screen.dart';
import 'package:flutternotificationserviceapp/screens/registration_screen.dart';
import 'package:flutternotificationserviceapp/screens/splash_screen.dart';
import 'screens/login_screen.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(primaryColor: Color(0xff40739e)),
      debugShowCheckedModeBanner: false,
      initialRoute: SplashScreen.kRoute,
      routes: {
        SplashScreen.kRoute: (context) => SplashScreen(),
        LoginScreen.kRoute: (context) => LoginScreen(),
        RegistrationScreen.kRoute: (context) => RegistrationScreen(),
        HomeScreen.kRoute: (context) => HomeScreen()
      },
    );
  }
}
