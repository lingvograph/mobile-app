import 'package:flutter/material.dart';
import 'dart:math';
import 'package:vector_math/vector_math.dart' show radians, Vector3;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RadialMenu extends StatefulWidget {
  List<RadialBtn> icons;

  RadialMenu({this.icons});

  createState() => _RadialMenuState();
}

class _RadialMenuState extends State<RadialMenu>
    with SingleTickerProviderStateMixin {
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(milliseconds: 900), vsync: this);
    // ..addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return RadialAnimation(
      controller: controller,
      icons: widget.icons,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class RadialAnimation extends StatelessWidget {
  List<RadialBtn> icons;

  RadialAnimation({Key key, this.controller, this.icons})
      : translation = Tween<double>(
          begin: 0.0,
          end: 90.0,
        ).animate(
          CurvedAnimation(parent: controller, curve: Curves.elasticOut),
        ),
        scale = Tween<double>(
          begin: 1.5,
          end: 0.0,
        ).animate(
          CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn),
        ),
        rotation = Tween<double>(
          begin: 0.0,
          end: 360.0,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.0,
              0.7,
              curve: Curves.decelerate,
            ),
          ),
        ),
        super(key: key);

  final AnimationController controller;
  final Animation<double> rotation;
  final Animation<double> translation;
  final Animation<double> scale;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: controller,
        builder: (context, widget) {
          return Container(
            padding: EdgeInsets.only(bottom: 90),
            width: 300,
            height: 250,
            child: Transform.rotate(
              angle: radians(rotation.value),
              child: Stack(
                alignment: Alignment.center,
                children: icons
                    .map((t) => _buildButton(t.angle,
                    color: t.color, icon: t.icon, onTap: t.onTap))
                    .toList()
                  ..add(Transform.scale(
                    scale: scale.value - 1,
                    child: FloatingActionButton(
                        child: Icon(FontAwesomeIcons.minus),
                        onPressed: _close,
                        backgroundColor: Colors.red),
                  ))
                  ..add(Transform.scale(
                    scale: scale.value / 1.5,
                    child: FloatingActionButton(
                        child: Icon(FontAwesomeIcons.plus),
                        onPressed: _open),
                  )),

              )),);
        });
  }

  _open() {
    controller.forward();
  }

  _close() {
    controller.reverse();
  }

  Widget _buildButton(double angle,
      {Color color, IconData icon, Function onTap}) {
    final double rad = radians(angle);
    return new Transform(
      //transformHitTests: false,
        transform: Matrix4.identity()
          ..translate(
              (translation.value) * cos(rad), (translation.value) * sin(rad)),
        child: FloatingActionButton(
            child: Icon(icon),
            backgroundColor: color,
            onPressed: (){onTap();},
            elevation: 0));
  }
}

class RadialBtn {
  double angle;
  Color color;
  IconData icon;
  Function onTap;

  RadialBtn({this.angle, this.icon, this.color, this.onTap});
}
