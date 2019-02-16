import 'package:flutter/material.dart';

buildAppBar(BuildContext context) {
  return AppBar(
    title: Text('Learn'),
    actions: <Widget>[
     
      IconButton(
        icon: Icon(Icons.search),
        tooltip: 'Search',
        onPressed: () {

        },
      ),
    ],

  );
}
