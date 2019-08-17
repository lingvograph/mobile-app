import 'dart:io';
import 'dart:math';
import 'package:flutter/rendering.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:memoapp/AppData.dart';
import 'package:memoapp/api/api.dart';
import 'package:memoapp/api/model.dart';
import 'package:memoapp/components/Loading.dart';
import 'package:memoapp/components/TermView.dart';
import 'package:memoapp/components/AudioList.dart';
import 'package:memoapp/components/addContentButton.dart';
import 'package:memoapp/components/detailedViewMethods.dart';
import 'package:memoapp/screen/recordaudioscreen.dart';

//import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:youtube_player/youtube_player.dart';

typedef SearchCallback = void Function(String searchString);

class TermDetail extends StatefulWidget {
  String id;

  TermDetail(this.id);

  @override
  State<StatefulWidget> createState() {
    return new TermDetailState(id);
  }
}

class TermDetailState extends State<TermDetail> {
  GlobalKey<State> key = new GlobalKey();

  //total loaded audios/visuals
  int totalLoadedAudios = 0;
  int totalLoadedVisuals = 0;
  String dropdownValue = 'en';

  final int loadOffset = 5;

  //current page
  Widget cp = Container();

  //horizontal switch menu
  Widget switcher = Container();
  String id;
  TermInfo term;
  int _addStatus = 1;
  bool loading = false;

  TermDetailState(this.id);

  List<Widget> pages;
  int viewMode = 3;

  //Список функций в порядке меню, используется для вызова обновления при смене режима просмотра(компакт, средний, полный)
  List<Function(TermInfo)> tabInflateMethods;

  TernDetailedViewInflateMethods stateSaver;
  get appState {
    return appData.appState;
  }

  @override
  void initState() {
    super.initState();
    tabInflateMethods = new List();
    pages = new List(title.length);

    stateSaver = new TernDetailedViewInflateMethods(pages: pages, getControll: getPageControlWidget, getAudiosPage: getAudiosPage);
    fetchData();

    stateSaver.fillInflateMethos(tabInflateMethods);
  }



  fetchData() async {
    var result = await fetchAudioList(id, totalLoadedAudios, loadOffset);
    totalLoadedAudios = result.audio.items.length;
    TermInfo visualTerm = await fetchVisualList(id, 0, 10);
    visualTerm.audio = result.audio;
    term = visualTerm;
    totalLoadedVisuals = term.visual.items.length;
    setState(() {
      stateSaver.initEmptyPages(visualTerm);
    });
  }

  void addContent() {
    if (_addStatus == 0) {
      setState(() {
        _addStatus = 1;
      });
    } else if (_addStatus == 1) {
      setState(() {
        _addStatus = 0;
      });
    }
  }

  void openAddAudio() {
    print("audio open!");
    var route = MaterialPageRoute(
        builder: (_) => new RecordAudioScreen(
              term: term,
            ));
    Navigator.pushReplacement(context, route);
  }

  Widget getAudiosPage() {
    return term.audio.items.length > 0
        ? new AudioList(term)
        : Align(
            child: Container(
              width: 200,
              child: Text(
                "No audios yet ;)",
                style: TextStyle(fontSize: 20, color: Colors.blue[800]),
              ),
              alignment: Alignment(0, 0),
              padding: EdgeInsets.only(top: 10, bottom: 10),
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: <BoxShadow>[BoxShadow(blurRadius: 5)]),
            ),
          );
  }

  var currentPage = 0.0;

  //
  Widget getPageControlWidget() {
    return Container(
      padding: EdgeInsets.only(right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          DropdownButton<String>(
            value: dropdownValue,
            onChanged: (String newValue) {

              setState(() {
                stateSaver.dropdownValue = newValue;
                stateSaver.viewMode = viewMode;
                dropdownValue = newValue;
                tabInflateMethods[currentPage.round()](term);
              });
            },
            items: <String>['en', 'ru', 'fr']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          Padding(
            padding: EdgeInsets.all(5),
          ),
          IconButton(
            icon: Icon(
              Icons.featured_play_list,
              color: viewMode == 1 ? Colors.blue[500] : Colors.blue[200],
            ),
            onPressed: () {
              setState(() {
                viewMode = 1;
                stateSaver.viewMode = viewMode;
              });
              tabInflateMethods[currentPage.round()](term);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.grid_on,
              color: viewMode == 2 ? Colors.blue[500] : Colors.blue[200],
            ),
            onPressed: () {
              setState(() {
                viewMode = 2;
                stateSaver.viewMode = viewMode;

              });
              tabInflateMethods[currentPage.round()](term);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.line_style,
              color: viewMode == 3 ? Colors.blue[500] : Colors.blue[200],
            ),
            onPressed: () {
              setState(() {
                viewMode = 3;
                stateSaver.viewMode = viewMode;

              });
              tabInflateMethods[currentPage.round()](term);
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (term == null) {
      return Loading();
    }

    PageController controller = PageController(initialPage: 0);

    controller.addListener(() {
      setState(() {
        currentPage = controller.page;
      });
    });

    var RadialAddButton = Container(
        child: RadialMenu(
      icons: <RadialBtn>[
        RadialBtn(
            angle: 160,
            color: Colors.grey[600],
            icon: FontAwesomeIcons.cameraRetro,
            onTap: () {
              openCamera(term);
            }),
        RadialBtn(
            angle: 110,
            color: Colors.green,
            icon: FontAwesomeIcons.images,
            onTap: () {
              openGalery(term);
            }),
        RadialBtn(
            angle: 40,
            color: Colors.orange,
            icon: FontAwesomeIcons.microphoneAlt,
            onTap: () {
              openAddAudio();
            }),
      ],
    ));

    return new Scaffold(
      appBar: AppBar(
        title: Text("Detail"),
      ),
      body: NotificationListener<ScrollNotification>(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: TermView(term: term, tappable: false),
              ),
              //switcher,
              Container(
                //padding: EdgeInsets.all(10),

                child: Stack(
                  children: <Widget>[
                    Positioned(child: HorizontalEdgeMenu(currentPage)),
                    Positioned.fill(
                      child: PageView.builder(
                        itemCount: title.length,
                        controller: controller,
                        reverse: false,
                        itemBuilder: (context, index) {
                          return Container(
                              //child: Text(index.toString()),
                              );
                        },
                      ),
                    )
                  ],
                ),
              ),
              pages[currentPage.round()],
              //cp,
              new MyObservableWidget(key: key),
              //RadialAddButton,
            ],
          ),
          onNotification: (ScrollNotification scroll) {
            var currentContext = key.currentContext;
            if (currentContext == null) return false;

            var renderObject = currentContext.findRenderObject();
            RenderAbstractViewport viewport =
                RenderAbstractViewport.of(renderObject);
            var offsetToRevealBottom =
                viewport.getOffsetToReveal(renderObject, 1.0);
            var offsetToRevealTop =
                viewport.getOffsetToReveal(renderObject, 0.0);

            //Если маркер находится в поле видимости, попытаться подтянуть данные
            if (offsetToRevealBottom.offset > scroll.metrics.pixels ||
                scroll.metrics.pixels > offsetToRevealTop.offset) {
              //end of list is out of view
            } else {
              //end of the list is visible - time to load new content
              //print("end for sure");

              //Пытаться загрузить, только если сейчас не грузит
              //Я уже 1 раз так сервер уронил
              if (!loading) {
                loading = true;
                fetchContent();
              }
            }

            return false;
          }),
    );
  }

  void fetchContent() async {
    //Тут смотрит по текуйщей странице что грузить
    //Возможно это можно сделать оптимальней и более гибко...
    //Например список методов или сущность страницы с методами и данными, но в этом (наверно) пока нет смысла
    if (currentPage.round() == 0) {
      await paginateAudios();
    }
    if (currentPage.round() == 1) {
      await paginateVisual();
    }
    //print("finish");
    loading = false;
  }

  paginateAudios() async {
    print('audio fet');
    if (term.audio.total > totalLoadedAudios) {
      var result = await fetchAudioList(id, totalLoadedAudios, 5);
      totalLoadedAudios += result.audio.items.length;

      setState(() {
        term.audio.items.addAll(result.audio.items);
      });
      tabInflateMethods[currentPage.round()](term);
    }
  }

  paginateVisual() async {
    print('visual fet');
    if (term.visual.total > totalLoadedVisuals) {
      var result = await fetchAudioList(id, totalLoadedVisuals, 5);
      totalLoadedVisuals += result.visual.items.length;

      setState(() {
        term.visual.items.addAll(result.visual.items);
      });
      tabInflateMethods[currentPage.round()](term);
    }
  }
}
