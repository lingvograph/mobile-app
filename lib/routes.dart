import 'package:flutter/material.dart';
import 'package:memoapp/screen/home.dart';
import 'package:memoapp/screen/login.dart';
import 'package:memoapp/screen/root.dart';

final routes = {
  '/login': (BuildContext context) => new LoginScreen(),
  '/home': (BuildContext context) => new HomeScreen(),
  '/': (BuildContext context) => new RootScreen(),
};
