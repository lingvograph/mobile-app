import 'package:flutter/material.dart';
import 'package:memoapp/api.dart';
import 'package:memoapp/data.dart';
import 'package:memoapp/appstate.dart';
import 'package:memoapp/model.dart';
import 'package:memoapp/components/inputfielddecoration.dart';
import 'package:memoapp/oauth_login.dart';
// TODO loading state
// TODO login error

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
    // setState(() => _isLoading = true);
    form.save();

    // TODO handle login error
    var token = await login(data.username, data.password);
    // TODO request user data/preferences
    var user = User(data.username, 'ru');

    appState.user = user;
    appState.apiToken = token;
    Navigator.of(context).pushReplacementNamed('/home');
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
    }
    else if( value.contains(" ")) {
        return 'The Password must not contain spaces.';
      }
    else if( value.contains(".") || value.contains("|") || value.contains("|")|| value.contains(";")|| value.contains(",")
        || value.contains("!")|| value.contains("?")) {
      return 'The Password must not contain \". , ; ! ?\" and so';
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

              new InputFieldDecoration(child:
              TextFormField(
                onSaved: (String value) {
                  data.username = value;
                },
                decoration: InputDecoration(
                  hintText: 'you@example.com',
                  labelText: 'Username or email address',
                ),
                validator: validateUsername,
              )),
              // password field
              new Padding(padding: EdgeInsets.all(7)),///Border-divider between two fields
              new InputFieldDecoration(child:
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
              )),
              // login button
              //width field is now properly working so it is sized by padding
              Container(
                  width: 200,
                  height: 40,
                  margin: new EdgeInsets.all(30.0),
                  child: RaisedButton(
                    shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(10.0)),
                    onPressed: submit,
                    child: Text(
                      'Login',
                      style: new TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    color: Colors.blue,
                  )),

              new LoginImageBtn(src: "assets/logingoogle.png", onTap: loginGoogle ,),

              new LoginImageBtn(src: "assets/loginfacebook.png", onTap: loginFacebook ),

              new LoginImageBtn(src: "assets/loginvk.png", onTap: loginVk ),

            ],
          ),
        ),
      ),
    );
  }
}
class LoginImageBtn extends StatefulWidget
{
  String src;
  Function onTap;
  LoginImageBtn({@required this.src, this.onTap});

  @override
  _LoginImageBtnState createState() => _LoginImageBtnState();
}

class _LoginImageBtnState extends State<LoginImageBtn>
{
  @override
  Widget build(BuildContext context) {
    //debugPrint(widget.onTap.toString());
    return new Container(padding: EdgeInsets.only(top: 10),
      alignment: Alignment(-0.1, 0),child:
        InkWell(child:
          Image.asset(widget.src ,height: 40,), onTap: widget.onTap),);
  }

}
