import 'package:flutter/material.dart';
import 'package:memoapp/screen/Discover.dart';
import 'package:memoapp/screen/Login.dart';
import 'package:memoapp/screen/Root.dart';

final routes = {
  '/': (BuildContext context) => new RootScreen(),
  '/login': (BuildContext context) => new LoginScreen(),
  '/home': (BuildContext context) => new DiscoverScreen(),
  '/discover': (BuildContext context) => new DiscoverScreen(),
};
