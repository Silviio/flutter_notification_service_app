import 'package:flutter/material.dart';
import 'package:flutternotificationserviceapp/constants/string_value.dart';
import 'package:flutternotificationserviceapp/firebase/firebase_services.dart';
import 'package:flutternotificationserviceapp/screens/home_screen.dart';
import 'package:flutternotificationserviceapp/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String kRoute = '/splash';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _firebaseService = FirebaseService();

  bool _visible = false;

  @override
  void initState() {
    _initAnimationTransition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: AnimatedOpacity(
            duration: Duration(seconds: 1),
            opacity: _visible ? 1.0 : 0.0,
            child: Hero(
              tag: Strings.tagLogo,
              child: Container(
                height: 60.0,
                child: Image.asset(Strings.imageLogo),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _initAnimationTransition() async {
    await Future.delayed(Duration(seconds: 2)).then((_) {
      setState(() {
        _visible = true;
      });
    }).then((_) async {
      await Future.delayed(Duration(seconds: 2));

      var user = await _firebaseService.getCurrentUser();

      if (user != null)
        Navigator.pushNamed(context, HomeScreen.kRoute);
      else
        Navigator.pushNamed(context, LoginScreen.kRoute);
    });
  }
}
