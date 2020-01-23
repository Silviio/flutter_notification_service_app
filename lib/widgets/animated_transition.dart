import 'package:flutter/material.dart';

class AnimatedTransition extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.green,
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        width: 60.0,
        height: 48.0,
        child: Center(child: Icon(Icons.check, color: Colors.white)),
      ),
    );
  }
}
