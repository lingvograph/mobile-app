import 'package:flutter/material.dart';
import 'package:memoapp/components/localization.dart';
import 'package:memoapp/data.dart';
import 'package:memoapp/localres.dart';
import 'package:memoapp/appstate.dart';

class UserProfile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<UserProfile> {
  Widget currentProfileWindow;

  initState() {
    super.initState();
    currentProfileWindow = new UserAchievments();
  }

  void openAchievements() {
    this.setState(() {
      currentProfileWindow = new UserAchievments();
      print(getString(key: PasswordLengthNotifications));
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

  @override
  Widget build(BuildContext context) {
    return new Column(children: <Widget>[
      Container(
          width: 100,
          height: 100,
          decoration: new BoxDecoration(
              shape: BoxShape.circle,
              image: new DecorationImage(
                  fit: BoxFit.fill,
                  image: Image.asset(
                    'assets/avatar_default.png',
                  ).image))),
      Container(
        padding: EdgeInsets.only(top: 10),
        child: new Text(
          'UserName',
          style: TextStyle(fontSize: 20),
        ),
      ),
      Padding(
        padding: EdgeInsets.all(10),
      ),
      new Row(
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
      ),
      currentProfileWindow,
    ]);
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
