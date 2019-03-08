import 'package:flutter/material.dart';

var TranscriptionTextStyle = new TextStyle(
  shadows: <Shadow>[
    Shadow(
      offset: Offset(0.6, 0.6),
      blurRadius: 3.0,
      color: Color.fromARGB(255, 0, 0, 0),
    ),
    Shadow(
      offset: Offset(-0.1, -0.1),
      blurRadius: 3.0,
      color: Color.fromARGB(255, 0, 0, 0),
    ),
  ],
  fontWeight: FontWeight.bold,
  fontSize: 20.0,
  color: Colors.white,
);
var WordTextStyle = new TextStyle(
  shadows: <Shadow>[
    Shadow(
      offset: Offset(1.0, 1.0),
      blurRadius: 3.0,
      color: Color.fromARGB(255, 0, 0, 0),
    ),
    Shadow(
      offset: Offset(-0.1, -0.1),
      blurRadius: 3.0,
      color: Color.fromARGB(255, 0, 0, 0),
    ),
  ],
  fontWeight: FontWeight.bold,
  fontSize: 40.0,
  color: Colors.white,
);
