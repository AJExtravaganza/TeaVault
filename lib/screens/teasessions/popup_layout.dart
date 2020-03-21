import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PopupLayout extends ModalRoute {
  @override
  Color get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return GestureDetector(
      onTap: () {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      },
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          bottom: true,
          child: _buildOverlayContent(context),
        ),
      ),
    );
  }

  _buildOverlayContent(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: this.bottom, left: this.left, right: this.right, top: this.top),
      child: this.child,
    );
  }

  @override
  Widget buildTransitions(
      BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }

  @override
  bool get maintainState => false;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);
  double top;
  double bottom;
  double left;
  double right;
  Color bgColor;

  final Widget child;

  PopupLayout(
      {Key key, this.bgColor, @required this.child, this.top = 10, this.bottom = 20, this.left = 20, this.right = 20});
}
