import 'package:flutter/material.dart';

/*Widget used to decorate input fields with rounded and fill it with grey color*/
class IconWithShadow extends StatefulWidget {
  IconData child;
  double left= 1,top= 1;
  IconWithShadow({@required this.child, this.left, this.top});

  @override
  _DecorationState createState() => _DecorationState();
}

class _DecorationState extends State<IconWithShadow> {
  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: <Widget>[
        Positioned(
          top: widget.top,
          left: widget.left,
          child: Icon(
            widget.child,
            color: Colors.black,
          ),
        ),
        Positioned(
          child: Icon(
            widget.child,
            color: Colors.grey[200],
          ),
        ),

      ],
    );
  }
}