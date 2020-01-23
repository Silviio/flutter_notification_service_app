import 'package:flutter/material.dart';

class AnimatedButton extends StatelessWidget {
  final AnimationController controller;
  final double startWidth;
  final String buttonTitle;
  final Color color;
  final double fontSize;

  AnimatedButton(
      {this.controller,
      this.buttonTitle,
      this.startWidth,
      this.color,
      this.fontSize})
      : buttonSqueeze = Tween(begin: startWidth, end: 60.0).animate(
            CurvedAnimation(parent: controller, curve: Interval(0.0, 0.15)));

  final Animation<double> buttonSqueeze;

  Widget _buildAnimation(BuildContext context, Widget child) {
    return Material(
        elevation: 5.0,
        color: color,
        borderRadius: BorderRadius.circular(10.0),
        child: Container(
          width: this.buttonSqueeze.value,
          height: 48.0,
          child: Center(
            child: _buildInside(context),
          ),
        ));
  }

  Widget _buildInside(BuildContext context) {
    if (buttonSqueeze.value > 60) {
      return Text(
        this.buttonTitle,
        style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: fontSize),
      );
    } else {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        strokeWidth: 2,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: _buildAnimation,
      animation: controller,
    );
  }
}
