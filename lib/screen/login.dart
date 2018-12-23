import 'package:flutter/material.dart';
import 'package:validate/validate.dart';
import 'package:memoapp/model.dart';

// TODO loading state

class LoginData {
  String username = "";
  String password = "";
}

class LoginScreen extends StatefulWidget {
  final LoginData data;
  final ValueChanged<User> onLogin;

  LoginScreen({
    Key key,
    this.data,
    this.onLogin,
  }) : super(key: key);

  @override
  _LoginState createState() => _LoginState(data);
}

class _LoginState extends State<LoginScreen> {
  final LoginData data;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  _LoginState(this.data);

  void submit() {
    // TODO api call
    widget.onLogin(User(data.username, 'ru'));
  }

  String validateUsername(String value) {
    // TODO validate username or email
//    try {
//      Validate.isEmail(value);
//    } catch (e) {
//      return 'The E-mail Address must be a valid email address.';
//    }
    return null;
  }

  String validatePassword(String value) {
    if (value.length < 6) {
      return 'The Password must be at least 6 characters.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Container(
        padding: new EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // username field
              TextFormField(
                onSaved: (String value) {
                  data.username = value;
                },
                decoration: InputDecoration(
                  hintText: 'you@example.com',
                  labelText: 'Username or email address',
                ),
                validator: validateUsername,
              ),
              // password field
              TextFormField(
                onSaved: (String value) {
                  data.password = value;
                },
                obscureText: true, // password
                decoration: InputDecoration(
                  hintText: 'Password',
                  labelText: 'Enter your password',
                ),
                validator: validatePassword,
              ),
              // login button
              Container(
                  width: screenSize.width,
                  margin: new EdgeInsets.only(top: 20.0),
                  child: RaisedButton(
                    onPressed: submit,
                    child: Text(
                      'Login',
                      style: new TextStyle(color: Colors.white),
                    ),
                    color: Colors.blue,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
