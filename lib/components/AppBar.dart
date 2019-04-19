import 'package:flutter/material.dart';
import 'package:memoapp/components/InputFieldDecoration.dart';

typedef SearchCallback = void Function(String searchString);

class SearchBtn extends StatefulWidget {
  SearchCallback onSearch;

  SearchBtn(this.onSearch);

  @override
  SearchBtnState createState() => SearchBtnState();
}

class SearchBtnState extends State<SearchBtn> {
  bool mode = true;
  double width = 0;
  Color c = Colors.black;
  String searchText = "";

  get onSearch {
    return widget.onSearch;
  }

  @override
  Widget build(BuildContext context) {
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
                  firstChild: Container(
                      alignment: Alignment(1, 0),
                      child: Icon(
                        Icons.search,
                        color: Colors.transparent,
                      )),
                  secondChild: Container(
                      alignment: Alignment(1, 0),
                      child: IconButton(
                        icon: Icon(
                          Icons.search,
                          color: Colors.grey[800],
                        ),
                        onPressed: () {
                          onSearch(searchText);
                          FocusScope.of(context).requestFocus(new FocusNode());
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
                  onSearch('');
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
                  onSearch('');
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

buildAppBar(BuildContext context, SearchCallback search) {
  return AppBar(
    title: Text('Learn'),
    actions: <Widget>[
      SearchBtn(search),
    ],
  );
}
