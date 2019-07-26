import 'package:flutter/material.dart';

/*Widget used to decorate input fields with rounded and fill it with grey color*/
class IconWithShadow extends StatefulWidget {
  IconData child;
  double left= 1,top= 1;
  double size = 50;
  Color color = Colors.grey[200];
  IconWithShadow({@required this.child, this.left, this.top, this.size, this.color});

  @override
  _DecorationState createState() => _DecorationState();
}

class _DecorationState extends State<IconWithShadow> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: new Stack(
        children: <Widget>[
          Positioned(
            top: widget.top,
            left: widget.left,
            child: Icon(
              widget.child,
              color: Colors.black,
              size: widget.size,
            ),
          ),
          Positioned(
            child: Icon(
              widget.child,
              color: widget.color,
              size: widget.size,
            ),
          ),

        ],
      ),
    );
  }
}