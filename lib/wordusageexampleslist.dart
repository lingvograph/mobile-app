import 'package:flutter/material.dart';
import 'package:memoapp/model.dart';

class WordUsagesList extends StatefulWidget {
  Word word;

  //предполагаю из него будем вытаскивать озвучки по ID
  WordUsagesList({@required this.word});

  @override
  _ListState createState() => _ListState();
}

class _ListState extends State<WordUsagesList> {
  List<Widget> usageExamples;
  double width;
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width / 4;
    usageExamples = new List();
    usageExamples.add(new UsageExample());
    usageExamples.add(new UsageExample());
    usageExamples.add(new UsageExample());
    usageExamples.add(new UsageExample());

    return new Center(
      child: Padding(
        padding: EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 10),
        child: Container(
          padding: EdgeInsets.only(top: 10),
          constraints: BoxConstraints.expand(
              height: ((usageExamples.length.toDouble() + 1) * 60)),
          decoration: BoxDecoration(
              color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
          child: new Column(
            children: <Widget>[
              new Column(
                children: usageExamples,
              ),
              Padding(
                  padding: EdgeInsets.only(top: 4, left: width, right: width),
                  child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new IconButton(
                                  icon: Icon(
                                    Icons.navigate_before,
                                    size: 25,
                                  ),
                                  onPressed: null),
                              new IconButton(
                                  icon: Icon(
                                    Icons.navigate_next,
                                    size: 25,
                                  ),
                                  onPressed: null),
                            ],
                          )))),
            ],
          ),
        ),
      ),
    );
  }
}

class UsageExample extends StatefulWidget {
  @override
  _UsageState createState() => _UsageState();
}

class _UsageState extends State<UsageExample> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: EdgeInsets.only(top: 4, left: 20, right: 20),
      child: Container(
          decoration: BoxDecoration(
              color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Row(
              children: <Widget>[
                Text("Usage example #1"),
                Padding(
                  padding: EdgeInsets.only(
                    left: 15,
                  ),
                  child: new IconButton(
                      icon: Icon(
                        Icons.arrow_forward,
                        size: 25,
                      ),
                      onPressed: null),
                ),
              ],
            ),
          )),
    );
  }
}
