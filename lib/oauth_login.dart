import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:memoapp/api.dart';
import 'package:memoapp/data.dart';

oauthLogin(BuildContext ctx, String provider) async {
  var url = BASE_URL + '/api/oauth/login/' + provider;
  var plugin = new FlutterWebviewPlugin();
  plugin.launch(
    url,
    withJavascript: true,
    appCacheEnabled: true,
    userAgent: 'Mozilla/5.0 (Linux; Android 8.0.0; TA-1053 Build/OPR1.170623.026) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3368.0 Mobile Safari/537.36',
  );
  var onToken = new StreamController();

  var subscription = plugin.onUrlChanged.listen((url) async {
    try {
      var uri = Uri.parse(url);
      if (uri.queryParameters.containsKey('token')) {
        var value = uri.queryParameters['token'];
        onToken.add(value);
        await onToken.close();
      }
      if (uri.queryParameters.containsKey('error')) {
        var value = uri.queryParameters['error'];
        onToken.addError(value);
        await onToken.close();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  });

  var token = await onToken.stream.first;

  await subscription.cancel();
  await plugin.close();

  appData.appState.onLogin(ctx, token);

  return token;
}
