import 'package:flutter/material.dart';

import 'package:flutternotificationserviceapp/constants/component.dart';
import 'package:flutternotificationserviceapp/constants/string_value.dart';

import 'package:flutternotificationserviceapp/screens/registration_screen.dart';
import 'package:flutternotificationserviceapp/firebase/firebase_services.dart';

import 'package:flutternotificationserviceapp/services/validator.dart';

import 'package:flutternotificationserviceapp/widgets/animated_button.dart';
import 'package:flutternotificationserviceapp/widgets/animated_transition.dart';

import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String kRoute = '/login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _firebaseService = FirebaseService();
  final _formKeyLogin = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _emailTextFormController;
  TextEditingController _passwordTextFormController;

  FocusNode _passwordFocusNode;
  FocusNode _emailFocusNode;

  int _attempts;
  AnimationController _animationController;
  bool _shouldStartTransition = false;

  @override
  void initState() {
    _attempts = 0;

    _emailTextFormController = TextEditingController();
    _passwordTextFormController = TextEditingController();

    _passwordFocusNode = FocusNode();
    _emailFocusNode = FocusNode();

    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 2));

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 28.0, vertical: 40),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Hero(
                    tag: Strings.tagLogo,
                    child: Container(
                      height: 70.0,
                      child: Image.asset(Strings.imageLogo),
                    ),
                  ),
                  kDefaultAnimatedTextTitle,
                  SizedBox(
                    height: 46.0,
                  ),
                  Form(
                    key: _formKeyLogin,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          maxLength: 256,
                          controller: _emailTextFormController,
                          focusNode: _emailFocusNode,
                          keyboardType: TextInputType.emailAddress,
                          textAlign: TextAlign.center,
                          validator: Validator.email,
                          onFieldSubmitted: (value) {
                            FocusScope.of(context)
                                .requestFocus(_passwordFocusNode);
                          },
                          decoration: kTextFormDecoration.copyWith(
                              labelText: Strings.emailLabelText,
                              hintText: Strings.emailHint,
                              labelStyle: TextStyle(color: Colors.black87)),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        TextFormField(
                            enableSuggestions: true,
                            focusNode: _passwordFocusNode,
                            controller: _passwordTextFormController,
                            obscureText: true,
                            maxLength: 30,
                            textAlign: TextAlign.center,
                            validator: Validator.password,
                            decoration: kTextFormDecoration.copyWith(
                              labelText: Strings.passwordLabelText,
                              hintText: Strings.passwordHint,
                            )),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 18.0,
                  ),
                  AnimatedSwitcher(
                    duration: Duration(seconds: 1),
                    child: _shouldStartTransition
                        ? AnimatedTransition()
                        : GestureDetector(
                            onTap: _onLoginSubmit,
                            child: AnimatedButton(
                                controller: _animationController.view,
                                color: Color(0xff487eb0),
                                buttonTitle: Strings.loginButton,
                                fontSize: 16.0,
                                startWidth: MediaQuery.of(context).size.width),
                          ),
                  ),
                  SizedBox(height: 18.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(Strings.notRegistered),
                      GestureDetector(
                        child: Text(
                          Strings.signUp,
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                              context, RegistrationScreen.kRoute);
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _onLoginSubmit() async {
    _passwordFocusNode.unfocus();

    if (!_formKeyLogin.currentState.validate() && _attempts > 0) {
      _showSnackBar(Strings.warning);

      return;
    }

    _animationController.forward();

    await Future.delayed(Duration(seconds: 1, milliseconds: 50));

    try {
      if (_formKeyLogin.currentState.validate()) {
        var authResult = await _firebaseService.signIn(
            email: _emailTextFormController.text.trim(),
            password: _passwordTextFormController.text.trim());

        _startTransitionAnimation(authResult.user);
      } else {
        _attempts++;
        _animationController.reverse();
      }
    } catch (e) {
      _animationController.reset();
      _showSnackBar(e.message);
    }
  }

  _showSnackBar(String message) {
    _scaffoldKey.currentState.removeCurrentSnackBar();

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.black45,
      duration: Duration(seconds: 2, milliseconds: 50),
      onVisible: () {
        _attempts = 0;
      },
      action: SnackBarAction(
        label: Strings.close,
        textColor: Colors.yellow,
        onPressed: () {
          _scaffoldKey.currentState.hideCurrentSnackBar();
        },
      ),
    ));
  }

  _startTransitionAnimation(firebaseUser) {
    setState(() {
      _shouldStartTransition = true;
      Future.delayed(Duration(seconds: 1, milliseconds: 50)).then((value) {
        Navigator.pushReplacementNamed(context, HomeScreen.kRoute);
      });
    });
  }
}
