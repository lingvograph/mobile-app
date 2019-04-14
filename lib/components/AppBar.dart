import 'package:flutter/material.dart';
import 'package:memoapp/api.dart';
import 'package:memoapp/components/InputFieldDecoration.dart';

class SearchBtn extends StatefulWidget {
  //TermInfo term;
  List<TermInfo> terms;

  SearchBtn({this.terms});

  @override
  _searchBtnState createState() => _searchBtnState();
}

class _searchBtnState extends State<SearchBtn> {
  bool mode = true;
  double width = 0;
  Color c = Colors.black;
  String searchText = "";

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Row(
      children: <Widget>[
        AnimatedContainer(
          child: new InputFieldDecoration(
            child: Stack(
              children: <Widget>[
                new TextField(
                  //decoration: const InputDecoration(labelText: 'Name'),
                  keyboardType: TextInputType.text,
                  onChanged: (text) {
                    //debugPrint(text);
                    searchText = text;
                  },
                ),
                AnimatedCrossFade(
                  firstChild: Icon(
                    Icons.search,
                    color: Colors.transparent,
                  ),
                  secondChild: Container(
                      alignment: Alignment(1, 0),
                      child: IconButton(
                        icon: Icon(
                          Icons.search,
                          color: Colors.grey[800],
                        ),
                        onPressed: ()async
                        {
                          var result = await SearchTerms(searchText);
                          //total = result.total;
                          widget.terms.clear();
                          widget.terms.addAll(result.items);
                        },
                        tooltip: 'Search',
                      )),
                  duration: Duration(microseconds: 1000),
                  secondCurve: Curves.elasticIn,
                  crossFadeState: mode
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                ),
              ],
            ),
          ),
          duration: Duration(milliseconds: 500),
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

buildAppBar(BuildContext context, List<TermInfo> terms) {
  return AppBar(
    title: Text('Learn'),
    actions: <Widget>[
      SearchBtn(terms: terms,),
    ],
  );
}
