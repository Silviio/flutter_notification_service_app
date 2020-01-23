import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import 'string_value.dart';

const kSendButtonTextStyle = TextStyle(
  color: Colors.lightBlueAccent,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: '',
  errorStyle: TextStyle(color: Colors.red),
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
  ),
);

const kTextFormDecoration = InputDecoration(
  labelText: '',
  labelStyle: TextStyle(color: Colors.black87),
  hintText: '',
  counterText: '',
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black45, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black45, width: 3.0),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
);

const kTextFieldDecorationForm = InputDecoration(
    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black45, width: 2.0),
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.black45, width: 3.0),
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
    ));

const kDefaultAnimatedTextTitle = TyperAnimatedTextKit(
  text: [Strings.title],
  isRepeatingAnimation: false,
  textStyle: TextStyle(
    fontSize: 38.0,
    fontWeight: FontWeight.w900,
  ),
);

const kTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
  hintText: '',
  errorStyle: TextStyle(color: Colors.red),
  border: InputBorder.none,
);
