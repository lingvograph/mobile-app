import 'package:flutter/material.dart';

/*Widget used to decorate input fields with rounded and fill it with grey color*/
class InputFieldDecoration extends StatefulWidget {
  Widget child;
  InputFieldDecoration({@required this.child});

  @override
  _DecorationState createState() => _DecorationState();
}

class _DecorationState extends State<InputFieldDecoration> {
  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
      decoration: BoxDecoration(
          color: Colors.grey[100], borderRadius: BorderRadius.circular(20)),
      child:
        widget.child,
    );
  }
}
