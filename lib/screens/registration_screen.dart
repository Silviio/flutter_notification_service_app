import 'package:flutter/material.dart';
import 'package:flutternotificationserviceapp/constants/component.dart';
import 'package:flutternotificationserviceapp/constants/string_value.dart';
import 'package:flutternotificationserviceapp/firebase/firebase_services.dart';

import 'package:flutternotificationserviceapp/screens/home_screen.dart';
import 'package:flutternotificationserviceapp/services/validator.dart';
import 'package:flutternotificationserviceapp/widgets/animated_button.dart';

class RegistrationScreen extends StatefulWidget {
  static const String kRoute = '/registration';

  @override
  State<StatefulWidget> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with SingleTickerProviderStateMixin {
  final _firebaseService = FirebaseService();
  final _formKeyRegistration = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _emailTextFormController;
  TextEditingController _passwordTextFormController;

  FocusNode _passwordFocusNode;
  FocusNode _emailFocusNode;

  int _attempts;
  AnimationController _animationController;

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
    _passwordFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Flexible(
                  child: Hero(
                    tag: Strings.tagLogo,
                    child: Container(
                      height: 200.0,
                      child: Image.asset(Strings.imageLogo),
                    ),
                  ),
                ),
                SizedBox(
                  height: 48.0,
                ),
                Form(
                  key: _formKeyRegistration,
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
                  height: 24.0,
                ),
                GestureDetector(
                  onTap: _onRegistrationSubmit,
                  child: AnimatedButton(
                      controller: _animationController.view,
                      buttonTitle: Strings.register,
                      color: Color(0xff487eb0),
                      fontSize: 15.0,
                      startWidth: MediaQuery.of(context).size.width),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2, milliseconds: 50),
      action: SnackBarAction(
        label: Strings.close,
        textColor: Colors.yellow,
        onPressed: () {
          _scaffoldKey.currentState.hideCurrentSnackBar();
        },
      ),
    ));
  }

  void _onRegistrationSubmit() async {
    if (!_formKeyRegistration.currentState.validate() && _attempts > 0) {
      _showSnackBar(Strings.warning);
      return;
    }
    _animationController.animateTo(0.15);

    await Future.delayed(Duration(seconds: 1, milliseconds: 50));

    try {
      if (_formKeyRegistration.currentState.validate()) {
        final signResult = await _firebaseService.signUp(
            email: _emailTextFormController.text.trim(),
            password: _passwordTextFormController.text.trim());

        if (signResult != null) {
          await _firebaseService.signIn(
              email: _emailTextFormController.text.trim(),
              password: _passwordTextFormController.text.trim());
          _animationSubscriber();
        }
      } else {
        _attempts++;
        _animationController.reverse();
      }
    } catch (e) {
      _animationController.reset();
      _showSnackBar(e.message);
    }
  }

  void _animationSubscriber() {
    _animationController.forward();
    _animationController.addStatusListener((status) {
      if (AnimationStatus.completed == status) {
        Navigator.popAndPushNamed(context, HomeScreen.kRoute);
      }
    });
  }
}
