import 'package:flutter/material.dart';
import 'package:memoapp/api/api.dart';
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
  List<String> tags;

  get onSearch {
    return widget.onSearch;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tags = new List();
    getTagList();
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
                    //onSearch(searchText);
                    if (searchText.contains('#')) {
                      print('dies');
                      List<String> val = getSelected(text);
                      if (val.length == 0) {
                        print('no hit');
                        setState(() {
                          selectedDropDownValues.clear();
                          //selectedDropDownValues.add('');
                        });
                      } else {
                        setState(() {
                          selectedDropDownValues = val;
                        });
                      }
                    }
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
                  duration: Duration(milliseconds: 400),
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
        ),
        selectedDropDownValues.length == 0 ? Container() : dropdownWidget()
      ],
    );
  }

  getTagList() async {
    var result = await getData("/api/data/tag/list");
    var terms = result['items'] as List<dynamic>;
    var items = terms.map((t) => tagTextFromJson(t)).toList();
    setState(() {
      tags = items;
    });
    //print(tags.toString());
  }

  String tagTextFromJson(t) {
    return t['text'];
  }

  List<String> getSelected(String text) {
    List<String> res = new List();
    print(tags.toString());
    for (int i = 0; i < tags.length; i++) {
      //print(text+" "+text.replaceAll('#', ''));
      if (text.length != 1 && tags[i].contains(text.replaceAll('#', ''))) {
        res.add(tags[i]);
      }
    }
    return res;
  }
}

buildAppBar(BuildContext context, SearchCallback search) {
  return AppBar(
    title: Text('Learn'),
    actions: <Widget>[SearchBtn(search)],

    //bottom: PreferredSize(child: Container(padding:EdgeInsets.all(20),width: 140,child: Column(children: <Widget>[Text("SDSD")],),)),
  );
}

List<String> selectedDropDownValues = [

]; //The list of values we want on the dropdown
String _currentlySelected = "";

Widget dropdownWidget() {
  return Container(
    width: 100,
    child: DropdownButton(
      //map each value from the lIst to our dropdownMenuItem widget
      items: selectedDropDownValues
          .map((value) => DropdownMenuItem(
        child: Text(value),
        value: value,
      ))
          .toList(),
      onChanged: (String value) {
        //once dropdown changes, update the state of out currentValue

      },
      //this wont make dropdown expanded and fill the horizontal space
      isExpanded: false,
      //make default value of dropdown the first value of our list
      value: selectedDropDownValues.first,
    ),
  );
  return Container(
    width: 100,
    child: Stack(children: <Widget>[Column(
      children: selectedDropDownValues
          .map((value) => Container(
        height: 20,
        child: Text(value),
      ))
          .toList(),
    ),  ],

    ),
  );
}
