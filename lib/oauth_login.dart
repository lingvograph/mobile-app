import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:memoapp/api.dart';

oauthLogin(BuildContext ctx, String provider) async {
  var url = baseURL + '/oauth/login/' + provider;
  var plugin = new FlutterWebviewPlugin();
  plugin.launch(
    url,
    withJavascript: true,
    appCacheEnabled: true,
  );
  var onToken = new StreamController();

  var subscription = plugin.onUrlChanged.listen((url) async {
    try {
      var uri = Uri.parse(url);
      if (uri.queryParameters.containsKey('token')) {
        var token = uri.queryParameters['token'];
        onToken.add(token);
        await onToken.close();
      }
      if (uri.queryParameters.containsKey('error')) {
        var error = uri.queryParameters['error'];
        onToken.addError(error);
        await onToken.close();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  });

  var apiToken = await onToken.stream.first;
  setToken(apiToken);

  await subscription.cancel();
  await plugin.close();

  Navigator.of(ctx).pushReplacementNamed('/home');

  return apiToken;
}
