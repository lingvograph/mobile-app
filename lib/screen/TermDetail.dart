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
  String dropdownValue = 'ru';

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

  get appState {
    return appData.appState;
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    tabInflateMethods = new List();
    tabInflateMethods.add(makeDetailedAudios);
    tabInflateMethods.add(makeDetailedPictures);
    tabInflateMethods.add(makeDetailedTranslations);
    tabInflateMethods.add(makeDetailedInOther);
    tabInflateMethods.add(makeDetailedRelated);
    tabInflateMethods.add(makeDetailedDefinition);
    tabInflateMethods.add(makeDetailedDefinitionOf);
  }

  void initPages(TermInfo visualTerm) {
    pages = new List(title.length);
    //visualTerm.audio = term.audio;
    //term = visualTerm;
    //начальная инициализация сообщением, информирующем об отсутствии данных
    for (int i = 0; i < title.length; i++) {
      pages[i] = Align(
        child: Container(
          width: 200,
          child: Column(
            children: <Widget>[
              Text(
                " No Content for ",
                style: TextStyle(fontSize: 20, color: Colors.blue[800]),
              ),
              Text(
                title[i].edgeName + "",
                style: TextStyle(fontSize: 20, color: Colors.blue[600]),
              ),
            ],
          ),
          alignment: Alignment(0, 0),
          padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
          decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(14),
              boxShadow: <BoxShadow>[BoxShadow(blurRadius: 5)]),
        ),
      );
    }
    //кнопки для контроля масштаба термов

    makeDetailedAudios(visualTerm);
    makeDetailedPictures(visualTerm);

    makeDetailedTranslations(visualTerm);
    makeDetailedInOther(visualTerm);
    makeDetailedRelated(visualTerm);
    makeDetailedDefinition(visualTerm);
    makeDetailedDefinitionOf(visualTerm);
  }

  void makeDetailedDefinitionOf(TermInfo visualTerm) {
    List<Widget> definitionOf = new List();
    for (int i = 0; i < visualTerm.definitionOf.length; i++) {
      if (visualTerm.definitionOf[i].lang == dropdownValue)
      {
        definitionOf.add(TermView(term: visualTerm.definitionOf[i]));
      }
    }

    makeTermListView(definitionOf, 6);
  }

  void makeDetailedDefinition(TermInfo visualTerm) {
    List<Widget> definition = new List();
    for (int i = 0; i < visualTerm.definition.length; i++) {
      if (visualTerm.definition[i].lang == dropdownValue) {
        definition.add(TermView(term: visualTerm.definition[i]));
      }
    }

    makeTermListView(definition, 5);
  }

  void makeDetailedRelated(TermInfo visualTerm) {
    List<Widget> relatedTo = new List();
    for (int i = 0; i < visualTerm.relatedTo.length; i++) {
      if (visualTerm.relatedTo[i].lang == dropdownValue) {
        relatedTo.add(TermView(term: visualTerm.relatedTo[i]));
      }
    }

    makeTermListView(relatedTo, 4);
  }

  void makeDetailedInOther(TermInfo visualTerm) {
    List<Widget> inOther = new List();
    for (int i = 0; i < visualTerm.isInOtherTerms.length; i++) {
      if (visualTerm.isInOtherTerms[i].lang == dropdownValue) {
        inOther.add(TermView(
          term: visualTerm.isInOtherTerms[i],
          viewMode: viewMode,
        ));
      }
    }

    makeTermListView(inOther, 3);
  }

  void makeDetailedTranslations(TermInfo visualTerm) {
    List<Widget> translationView = new List();
    for (int i = 0; i < visualTerm.translations.length; i++) {
      //print(visualTerm.translations[i].lang);
      if (visualTerm.translations[i].lang == dropdownValue) {
        translationView.add(TermView(
          term: visualTerm.translations[i],
          viewMode: viewMode,
        ));
      }
    }

    makeTermListView(translationView, 2);
  }

  void makeTermListView(List<Widget> children, int pageIndex) {
    if (children.length > 0) {
      if (viewMode == 2) {
        pages[pageIndex] = new Column(
          children: <Widget>[
            getControll(),
            GridView.count(
              primary: false,
              shrinkWrap: true,
              // Create a grid with 2 columns. If you change the scrollDirection to
              // horizontal, this would produce 2 rows.
              crossAxisCount: 2,
              // Generate 100 Widgets that display their index in the List
              children: children,
            ),
          ],
        );
      } else {
        pages[pageIndex] = Column(
          children: <Widget>[
            getControll(),
            Column(
              children: children,
            )
          ],
        );
      }
    } else {
      pages[pageIndex] = Column(
        children: <Widget>[
          getControll(),
        ],
      );
    }
  }

  void makeDetailedAudios(TermInfo ti) {
    pages[0] = getAudiosPage();
  }

  void makeDetailedPictures(TermInfo visualTerm) {
    List<Widget> pictures = new List();

    for (int i = 0; i < visualTerm.visual.total; i++) {
      try {
        visualTerm.visual.items[i].url.contains('youtube')
            ? pictures.add(Container())
            : pictures.add(InkWell(
                onTap: () {
                  print("TAPPPPPPP");
                },
                child: Column(
                  children: <Widget>[
                    Padding(
                      child: Container(
                        height: 200,
                        padding: new EdgeInsets.only(left: 16.0, right: 16.0),
                        decoration: new BoxDecoration(
                          boxShadow: <BoxShadow>[BoxShadow(blurRadius: 10)],
                          borderRadius: BorderRadius.circular(5),
                          border:
                              new Border.all(color: Colors.grey[400], width: 2),
                          image: new DecorationImage(
                            image: loadImg(visualTerm.visual.items[i].url),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      padding: EdgeInsets.all(7),
                    ),
                    Padding(
                      padding: EdgeInsets.all(1),
                    )
                  ],
                ),
              ));
      } catch (e) {
        pictures.add(Container());
      }
    }

    if (pictures.length > 0) {
      pages[1] = new Column(
        children: pictures,
      );
    }
  }

  loadImg(String url) {
    var img;
    img = new CachedNetworkImageProvider(url, errorListener: () {
      print("failed");
      img = CachedNetworkImageProvider(
          "https://i1.wp.com/thefrontline.org.uk/wp-content/uploads/2018/10/placeholder.jpg");
    });
    return img;
  }

  fetchData() async {
    var result = await fetchAudioList(id, totalLoadedAudios, loadOffset);
    totalLoadedAudios = result.audio.items.length;
    TermInfo visualTerm = await fetchVisualList(id, 0, 10);
    visualTerm.audio = result.audio;
    term = visualTerm;
    totalLoadedVisuals = term.visual.items.length;
    setState(() {
      initPages(visualTerm);
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

  Widget getControll() {
    return Container(
      padding: EdgeInsets.only(right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          DropdownButton<String>(
            value: dropdownValue,
            onChanged: (String newValue) {
              setState(() {
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
              RadialAddButton,
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
