import 'package:flutter/material.dart';
import 'package:memoapp/api/api.dart';
import 'package:memoapp/AppState.dart';
import 'package:memoapp/components/InputFieldDecoration.dart';
import 'package:memoapp/AppData.dart';
import 'package:memoapp/components/Loading.dart';
import 'package:memoapp/oauth_login.dart';

// TODO loading indicator

class LoginState {
  String username = "";
  String password = "";
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Container(
        padding: new EdgeInsets.all(20.0),
        child: LoginForm(),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginForm> {
  final AppState appState = appData.appState;
  final LoginState data = new LoginState();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  bool isLoggingIn = false;

  void submit() async {
    final form = _formKey.currentState;
    if (!form.validate()) {
      return;
    }

    form.save();

    if (!form.validate()) {
      return;
    }

    try {
      // setState(() => _isLoading = true);

      var token = await login(data.username, data.password);
      await appState.onLogin(context, token);
    } on StateError catch (err) {
      final snackBar = SnackBar(
        content: Text(err.message),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  loginVk() {
    setState(() {
      isLoggingIn = true;
    });
    oauthLogin(context, 'vk');
  }

  loginGoogle() {
    setState(() {
      isLoggingIn = true;
    });
    oauthLogin(context, 'google');
  }

  loginFacebook() {
    setState(() {
      isLoggingIn = true;
    });

    oauthLogin(context, 'facebook');
  }

  @override
  Widget build(BuildContext context) {
    print(appState.apiToken);
    if (isLoggingIn) {
      return Loading();
    }
    final Size screenSize = MediaQuery.of(context).size;

    final username = new Container(
      child: TextFormField(
        onSaved: (String value) {
          setState(() {
            data.username = value;
          });
        },
        decoration: InputDecoration(
            hintText: 'you@example.com',
            labelText: 'Username or email address',
            border: new OutlineInputBorder(
              borderRadius: new BorderRadius.circular(25.0),
              borderSide: new BorderSide(),
            )),
        validator: Validators.username,
      ),
    );

    final password = new Container(
        child: TextFormField(
      onSaved: (String value) {
        setState(() {
          data.password = value;
        });
      },
      obscureText: true, // password
      decoration: InputDecoration(
          hintText: 'Password',
          labelText: 'Enter your password',
          border: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(25.0),
            borderSide: new BorderSide(color: Colors.blueAccent),
          )),
      validator: Validators.password,
    ));

    var loginBtn = Container(
        width: 200,
        height: 40,
        margin: new EdgeInsets.all(30.0),
        child: RaisedButton(
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(10.0)),
          onPressed: submit,
          child: Text(
            'Login',
            style: new TextStyle(color: Colors.white, fontSize: 18),
          ),
          color: Colors.blue,
        ));

    return Form(
      key: _formKey,
      child: ListView(
        children: <Widget>[
          new Padding(padding: EdgeInsets.all(7)),
          username,
          new Padding(padding: EdgeInsets.all(7)),
          password,
          loginBtn,
          new ImageButton("assets/logingoogle.png", loginGoogle),
          new ImageButton("assets/loginfacebook.png", loginFacebook),
          new ImageButton("assets/loginvk.png", loginVk),
        ],
      ),
    );
  }
}

class Validators {
  static String username(String value) {
    // TODO validate username or email
//    try {
//      Validate.isEmail(value);
//    } catch (e) {
//      return 'The E-mail Address must be a valid email address.';
//    }
    return null;
  }

  static String password(String value) {
    if (value.length < 6) {
      return 'The Password must be at least 6 characters.';
    } else if (value.contains(" ")) {
      return 'The Password must not contain spaces.';
    } else if (value.contains(".") ||
        value.contains("|") ||
        value.contains("|") ||
        value.contains(";") ||
        value.contains(",") ||
        value.contains("!") ||
        value.contains("?")) {
      return 'The Password must not contain \". , ; ! ?\" and so';
    }
    return null;
  }
}

class ImageButton extends StatelessWidget {
  String src;
  Function onTap;

  ImageButton(this.src, this.onTap);

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: EdgeInsets.only(top: 10),
      alignment: Alignment(-0.1, 0),
      child: InkWell(
          child: Image.asset(
            src,
            height: 40,
          ),
          onTap: onTap),
    );
  }
}
