import 'package:flutter/material.dart';
import 'package:memoapp/screen/Discover.dart';
import 'package:memoapp/screen/Login.dart';
import 'package:memoapp/screen/Root.dart';

final routes = {
  '/login': (BuildContext context) => new LoginScreen(),
  '/home': (BuildContext context) => new DiscoverScreen(),
  '/': (BuildContext context) => new RootScreen(),
};
