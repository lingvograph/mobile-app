import 'package:flutter/material.dart';
import 'package:memoapp/components/InputFieldDecoration.dart';

class SearchBtn extends StatefulWidget {
  //TermInfo term;

  SearchBtn();

  @override
  _searchBtnState createState() => _searchBtnState();
}

class _searchBtnState extends State<SearchBtn> {
  bool mode = true;
  double width = 30;
  Color c = Colors.black;
  String searchText;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Row(
      children: <Widget>[
        AnimatedContainer(
          child: new InputFieldDecoration(
              child: TextFormField(
                enabled: !mode,
                onSaved: (String value) {
                  setState(() {

                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search',
                ),
              )),
          duration: Duration(milliseconds: 300),
          width: width,
          height: 40,
        ),
        AnimatedCrossFade(
          firstChild: IconButton(
            icon: Icon(
              Icons.search,
              color: c,
            ),
            tooltip: 'Search',
            onPressed: () {
              setState(() {
                //c = Colors.red;
                if (mode) {
                  width = 200;
                  c = Colors.red;
                  mode = !mode;
                } else if (!mode) {
                  width = 0;
                  c = Colors.black;
                  mode = !mode;
                }
              });
            },
          ),
          secondChild: IconButton(
            icon: Icon(
              Icons.clear,
              color: c,
            ),
            tooltip: 'Search',
            onPressed: () {
              setState(() {
                //c = Colors.red;
                if (mode) {
                  width = 200;
                  c = Colors.red;
                  mode = !mode;
                } else if (!mode) {
                  width = 0;
                  c = Colors.black;
                  mode = !mode;
                }
              });
            },
          ),
          crossFadeState:
              mode ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          duration: Duration(milliseconds: 300),
          firstCurve: Curves.elasticInOut,
          secondCurve: Curves.elasticInOut,
        )
      ],
    );
  }
}

buildAppBar(BuildContext context) {
  return AppBar(
    title: Text('Learn'),
    actions: <Widget>[
      SearchBtn(),
    ],
  );
}
