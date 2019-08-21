import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:memoapp/AppData.dart';
import 'package:memoapp/api/api.dart';
import 'package:memoapp/api/model.dart';
import 'package:memoapp/components/nonCachedImage.dart';
import 'package:memoapp/locale.dart';

import '../AppState.dart';

class UserProfile extends StatefulWidget {
  UserInfo user;

  UserProfile(this.user) {}

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<UserProfile> {
  Widget currentProfileWindow;
  var targetLangVal;
  var firstLangVal;
  bool isCurrentUser;

  initState() {
    super.initState();
    isCurrentUser =
        widget.user != null && widget.user.uid == appData.appState.user.uid;
    firstLangVal =
        isCurrentUser ? appData.appState.user.firstLang : widget.user.firstLang;
    targetLangVal = isCurrentUser
        ? appData.appState.user.targetLang
        : widget.user.targetLang;

    if (appData.appState.user.email.contains("@gmail")) {
      appData.appState.user.firstName =
          appData.appState.user.email.replaceAll('@gmail.com', "");
    }
    if (!isCurrentUser && widget.user.email.contains("@gmail")) {
      widget.user.firstName = widget.user.email.replaceAll('@gmail.com', "");
    }
    currentProfileWindow = new UserAchievments();
  }

  void openAchievements() {
    this.setState(() {
      currentProfileWindow = new UserAchievments();
      print(SR.passwordValidation);
      print(appData.appState.apiToken);
    });
  }

  void openContent() {
    this.setState(() {
      currentProfileWindow = new UserContent();
    });
  }

  void openStatistics() {
    this.setState(() {
      currentProfileWindow = new UserStat();
    });
  }

  String verifyAvatarUrl(String url) {
    if (url != null && url.length > 0) {
      return url;
    } else
      return "https://api.adorable.io/avatars/random";
  }

  @override
  Widget build(BuildContext context) {
    var userAvatar = Container(
        width: 130,
        height: 130,
        decoration: new BoxDecoration(
            border: new Border.all(color: Colors.blueAccent, width: 2),
            shape: BoxShape.circle,
            image: new DecorationImage(
                fit: BoxFit.fill,
                image: NonCachedImage(
                  isCurrentUser
                      ? verifyAvatarUrl(appData.appState.user.avatar)
                      : verifyAvatarUrl(widget.user.avatar),
                  isCurrentUser
                      ? verifyAvatarUrl(appData.appState.user.uid)
                      : verifyAvatarUrl(widget.user.uid),
                  useDiskCache: false,
                  disableMemoryCache: true,
                  retryLimit: 1,
                ))));
    var userName = Container(
      padding: EdgeInsets.only(top: 10),
      child: new Text(
        isCurrentUser
            ? (appData.appState.user.firstName +
                " " +
                appData.appState.user.lastName)
            : (widget.user.firstName +
                " " +
                widget.user.lastName +
                widget.user.name),
        style: TextStyle(fontSize: 20, color: Colors.blueAccent),
      ),
    );
    var tabsSelector = new Row(
      children: <Widget>[
        ProfileTabSelector(
          picture: Icon(Icons.contacts),
          color: Colors.grey[200],
          onTap: openStatistics,
        ),
        ProfileTabSelector(
          picture: Icon(Icons.settings),
          color: Colors.grey[300],
          onTap: openAchievements,
        ),
        ProfileTabSelector(
          picture: Icon(Icons.clear),
          color: Colors.grey[400],
          onTap: openContent,
        ),
      ],
    );
    var firstLangShow = isCurrentUser
        ? DropdownButton<String>(
            value: firstLangVal,
            onChanged: (String newValue) {
              setState(() {
                firstLangVal = newValue;
              });
              postFirstLang(firstLangVal);
            },
            items: <String>['en', 'ru']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          )
        : Container(
            child: Text(
              firstLangVal,
              style: TextStyle(color: Colors.blueAccent),
            ),
            decoration: BoxDecoration(
                border: new Border.all(color: Colors.blueAccent, width: 2),
                borderRadius: BorderRadius.circular(5)));
    var targetLangShow = isCurrentUser
        ? DropdownButton<String>(
            value: targetLangVal,
            onChanged: (String newValue) {
              setState(() {
                targetLangVal = newValue;
              });
              postTargetLang(targetLangVal);
            },
            items: <String>['en', 'ru']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          )
        : Container(
            child: Text(
              targetLangVal,
              style: TextStyle(color: Colors.blueAccent),
            ),
            decoration: BoxDecoration(
                border: new Border.all(color: Colors.blueAccent, width: 2),
                borderRadius: BorderRadius.circular(5)));
    var body = new ListView(children: <Widget>[
      Padding(
        padding: EdgeInsets.all(7),
      ),
      Center(child: userAvatar),
      Center(child: userName),
      Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(2),
          ),
          Text(
            "First Lang.",
            style: TextStyle(color: Colors.blueAccent, fontSize: 18),
          ),
          Padding(
            padding: EdgeInsets.all(2),
          ),
          firstLangShow
        ],
      ),
      Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(2),
          ),
          Text(
            "Target Lang.",
            style: TextStyle(color: Colors.blueAccent, fontSize: 18),
          ),
          Padding(
            padding: EdgeInsets.all(2),
          ),
          targetLangShow
        ],
      ),
      Padding(
        padding: EdgeInsets.all(10),
      ),
      //tabsSelector,
      //currentProfileWindow,
    ]);
    return isCurrentUser
        ? body
        : Scaffold(
            appBar: AppBar(
              title: Text("Profile"),
            ),
            body: body,
          );
  }

  void postFirstLang(String firstLangVal) async {
    var uid = appData.appState.user.uid;
    //Да жри же ты этот лэнг..
    //Сожрал ))
    var resp = await postData(
        '/api/data/user/' + uid, {"first_lang": firstLangVal},
        verb: HttpVerb.put);
    appData.appState.user.firstLang = firstLangVal;
  }

  void postTargetLang(String targetLang) async {
    var uid = appData.appState.user.uid;
    var resp = await postData(
        '/api/data/user/' + uid, {"target_lang": targetLang},
        verb: HttpVerb.put);
    appData.appState.user.targetLang = targetLang;

    print(resp.toString());
  }
}

class ProfileTabSelector extends StatefulWidget {
  Icon picture;
  Color color;
  Function onTap;

  ProfileTabSelector(
      {@required this.picture, @required this.color, this.onTap});

  @override
  _ProfileTabSelectorState createState() => _ProfileTabSelectorState();
}

class _ProfileTabSelectorState extends State<ProfileTabSelector> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Expanded(
      child: new Material(
        child: InkWell(
          onTap: () {
            widget.onTap();
          },
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: widget.color, borderRadius: BorderRadius.circular(10)),
            child: widget.picture,
          ),
        ),
      ),
    );
  }
}

class UserAchievments extends StatefulWidget {
  @override
  _AchiementsState createState() => _AchiementsState();
}

class _AchiementsState extends State<UserAchievments> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Expanded(
        child: Container(
      constraints: BoxConstraints.expand(),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.blue[100], borderRadius: BorderRadius.circular(10)),
      child: Center(
        child: new Text(
          "ACHIEVEMENTS",
          style: TextStyle(fontSize: 20, decoration: TextDecoration.overline),
        ),
      ),
    ));
  }
}

class UserStat extends StatefulWidget {
  @override
  _StatisticsState createState() => _StatisticsState();
}

class _StatisticsState extends State<UserStat> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Expanded(
        child: Container(
      constraints: BoxConstraints.expand(),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.blue[50], borderRadius: BorderRadius.circular(10)),
      child: Center(
        child: new Text(
          "Statisticks",
          style: TextStyle(fontSize: 20, decoration: TextDecoration.overline),
        ),
      ),
    ));
  }
}

class UserContent extends StatefulWidget {
  @override
  _ContentState createState() => _ContentState();
}

class _ContentState extends State<UserContent> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Expanded(
        child: Container(
      constraints: BoxConstraints.expand(),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.blue[200], borderRadius: BorderRadius.circular(10)),
      child: Center(
        child: new Text(
          "User Content",
          style: TextStyle(fontSize: 20, decoration: TextDecoration.overline),
        ),
      ),
    ));
  }
}
