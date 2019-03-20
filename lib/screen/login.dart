import 'package:flutter/material.dart';
import 'package:memoapp/api.dart';
import 'package:memoapp/appstate.dart';
import 'package:memoapp/components/inputfielddecoration.dart';
import 'package:memoapp/data.dart';
import 'package:memoapp/oauth_login.dart';

// TODO loading indicator
// TODO display login error

class LoginState {
  String username = "";
  String password = "";
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  final AppState appState = appData.appState;
  final LoginState data = new LoginState();
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

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
    } catch (err) {
      // TODO display error
    }
  }

  loginVk() {
    oauthLogin(context, 'vk');
  }

  loginGoogle() {
    oauthLogin(context, 'google');
  }

  loginFacebook() {
    oauthLogin(context, 'facebook');
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

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    final username = new InputFieldDecoration(
        child: TextFormField(
      onSaved: (String value) {
        data.username = value;
      },
      decoration: InputDecoration(
        hintText: 'you@example.com',
        labelText: 'Username or email address',
      ),
      validator: validateUsername,
    ));

    final password = new InputFieldDecoration(
        child: TextFormField(
      onSaved: (String value) {
        data.password = value;
      },
      obscureText: true, // password
      decoration: InputDecoration(
        hintText: 'Password',
        labelText: 'Enter your password',
      ),
      validator: validatePassword,
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
              username,
              new Padding(padding: EdgeInsets.all(7)),
              password,
              loginBtn,
              new ImageButton("assets/logingoogle.png", loginGoogle),
              new ImageButton("assets/loginfacebook.png", loginFacebook),
              new ImageButton("assets/loginvk.png", loginVk),
            ],
          ),
        ),
      ),
    );
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
