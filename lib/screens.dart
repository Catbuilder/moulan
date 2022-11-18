import 'package:moulan/theme.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';
//import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:badges/badges.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:virtual_keyboard/virtual_keyboard.dart';
import 'package:provider/provider.dart';
import 'package:scan/scan.dart';
import 'globals.dart' as globals;
import 'wsam.dart';
import 'searchbar.dart';
import 'restart.dart';
import 'theme_changer.dart';
import 'dynaform.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:native_pdf_view/native_pdf_view.dart';
import 'package:printing/printing.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

GlobalKey<_TreeScreen> approTreeScreen = GlobalKey<_TreeScreen>();

class MainTabState extends StatefulWidget {
  final BuildContext menuScreenContext;
  MainTabState({Key key, this.menuScreenContext}) : super(key: key);

  @override
  _MainTabState createState() => _MainTabState();
}

class _MainTabState extends State<MainTabState> with WidgetsBindingObserver {
  PersistentTabController _controller;
  bool _hideNavBar;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: approInitialIndex);
    mainTab = _controller;
    _hideNavBar = false;
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void didChangeMetrics() {
    /*
    print('changeOrientation: ' + SizeConfig.blockSizeHorizontal.toString());

    setState(() {
      _themeProvider.setTheme(myTheme.copyWith(
          textTheme: myTheme.textTheme.copyWith(
              subtitle1: myTheme.textTheme.subtitle1.copyWith(
        fontSize: ((SizeConfig.blockSizeHorizontal <=
            SizeConfig.blockSizeVertical
            ? SizeConfig.blockSizeHorizontal
            : SizeConfig.blockSizeVertical) / 3.2) * approDataTextSize,
      ))));

    });

    */
  }

  Widget _shoppingCartBadge() {
    return Badge(
      badgeColor: globals.badgeColor,
      position: BadgePosition.topEnd(top: -7, end: -12),
      animationDuration: Duration(milliseconds: 300),
      animationType: BadgeAnimationType.slide,
      showBadge: true,
      badgeContent: ValueListenableBuilder(
        valueListenable: globals.basketCounter,
        builder: (BuildContext context, int value, Widget child) {
          return Text('$value', style: TextStyle(color: Colors.white));
        },
      ),
      child: Icon(Icons.shopping_cart),
    );
  }

  Widget _catalogBadge() {
    return Badge(
      badgeColor: globals.badgeColor,
      position: BadgePosition.topEnd(top: -7, end: -12),
      animationDuration: Duration(milliseconds: 300),
      animationType: BadgeAnimationType.slide,
      showBadge: true,
      badgeContent: ValueListenableBuilder(
        valueListenable: globals.infoCounter,
        builder: (BuildContext context, int value, Widget child) {
          return Text('$value', style: TextStyle(color: Colors.white));
        },
      ),
      child: Icon(Icons.folder_open_outlined),
    );
  }

  List<Widget> _buildScreens() {
    return [
      FavoriteScreen(
        menuScreenContext: widget.menuScreenContext,
        hideStatus: _hideNavBar,
        onScreenHideButtonPressed: () {
          setState(() {
            _hideNavBar = !_hideNavBar;
          });
        },
      ),
      TreeScreen(
        menuScreenContext: widget.menuScreenContext,
        hideStatus: _hideNavBar,
        onScreenHideButtonPressed: () {
          setState(() {
            _hideNavBar = !_hideNavBar;
          });
        },
      ),
      ScanScreen(
        menuScreenContext: widget.menuScreenContext,
        hideStatus: _hideNavBar,
        onScreenHideButtonPressed: () {
          setState(() {
            _hideNavBar = !_hideNavBar;
          });
        },
      ),
      BasketScreen(
        menuScreenContext: widget.menuScreenContext,
        hideStatus: _hideNavBar,
        onScreenHideButtonPressed: () {
          setState(() {
            _hideNavBar = !_hideNavBar;
          });
        },
      ),
      SearchScreen(
        menuScreenContext: widget.menuScreenContext,
        hideStatus: _hideNavBar,
        onScreenHideButtonPressed: () {
          setState(() {
            _hideNavBar = !_hideNavBar;
          });
        },
      ),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.favorite_outline_sharp),
        title: AppLocalizations.of(context).favorite,
        activeColorPrimary: globals.menuActiveColor,
        inactiveColorPrimary: globals.menuInactiveColor,
      ),
      PersistentBottomNavBarItem(
        icon: ValueListenableBuilder(
            valueListenable: globals.infoCounter,
            builder: (BuildContext context, int value, Widget child) {
              return value > 0
                  ? _catalogBadge()
                  : Icon(Icons.folder_open_outlined);
            }),
        title: AppLocalizations.of(context).catalog,
        activeColorPrimary: globals.menuActiveColor,
        inactiveColorPrimary: globals.menuInactiveColor,
        routeAndNavigatorSettings: RouteAndNavigatorSettings(
          initialRoute: '/tree',
        ),
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.add),
        title: AppLocalizations.of(context).add,
        activeColorPrimary: globals.menuActiveColor,
        inactiveColorPrimary: globals.menuInactiveColor,
        //activeContentColor: globals.menuActiveColor,
      ),
      PersistentBottomNavBarItem(
        icon: ValueListenableBuilder(
            valueListenable: globals.basketCounter,
            builder: (BuildContext context, int value, Widget child) {
              return value > 0
                  ? _shoppingCartBadge()
                  : Icon(Icons.shopping_cart);
            }),
        title: AppLocalizations.of(context).cart,
        activeColorPrimary: globals.menuActiveColor,
        inactiveColorPrimary: globals.menuInactiveColor,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.search_sharp),
        title: AppLocalizations.of(context).search,
        activeColorPrimary: globals.menuActiveColor,
        inactiveColorPrimary: globals.menuInactiveColor,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar:      AppBar(title: const Text('Catbuilder Appro 7/24',style: TextStyle(fontSize: 18.0))),
      key: approScaffoldKey,
      drawer: GeneralDrawer(),
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _buildScreens(),
        items: _navBarsItems(),
        confineInSafeArea: true,
        backgroundColor: myTheme.primaryColor,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: true,
        hideNavigationBarWhenKeyboardShows: true,
        hideNavigationBar: _hideNavBar,
        margin: EdgeInsets.all(0.0),
        popActionScreens: PopActionScreensType.all,
        bottomScreenMargin: 0.0,
        // onWillPop: () async {
        //   await showDialog(
        //     context: context,
        //     useSafeArea: true,
        //     builder: (context) => Container(
        //       height: 50.0,
        //       width: 50.0,
        //       color: Colors.white,
        //       child: RaisedButton(
        //         child: Text("Close"),
        //         onPressed: () {
        //           Navigator.pop(context);
        //         },
        //       ),
        //     ),
        //   );
        //   return false;
        // },
        decoration: NavBarDecoration(
            colorBehindNavBar: Colors.white,
            borderRadius: BorderRadius.circular(0.0)),
        popAllScreensOnTapOfSelectedTab: true,
        itemAnimationProperties: ItemAnimationProperties(
          duration: Duration(milliseconds: 400),
          curve: Curves.ease,
        ),
        screenTransitionAnimation: ScreenTransitionAnimation(
          animateTabTransition: true,
          curve: Curves.ease,
          duration: Duration(milliseconds: 200),
        ),
        navBarStyle:
            NavBarStyle.style6, // Choose the nav bar style with this property
      ),
    );
  }
}

class CustomNavBarWidget extends StatelessWidget {
  final int selectedIndex;
  final List<PersistentBottomNavBarItem> items;
  final ValueChanged<int> onItemSelected;

  CustomNavBarWidget({
    Key key,
    this.selectedIndex,
    @required this.items,
    this.onItemSelected,
  });

  Widget _buildItem(PersistentBottomNavBarItem item, bool isSelected) {
    return Container(
      alignment: Alignment.center,
      height: kBottomNavigationBarHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            child: IconTheme(
              data: IconThemeData(
                  size: 26.0,
                  color: isSelected
                      ? (item.activeColorSecondary == null
                          ? item.activeColorPrimary
                          : item.activeColorSecondary)
                      : item.inactiveColorSecondary == null
                          ? item.activeColorPrimary
                          : item.inactiveColorSecondary),
              child: item.icon,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Material(
              type: MaterialType.transparency,
              child: FittedBox(
                  child: Text(
                item.title,
                style: TextStyle(
                    color: isSelected
                        ? (item.activeColorSecondary == null
                            ? item.activeColorPrimary
                            : item.activeColorSecondary)
                        : item.inactiveColorPrimary,
                    fontWeight: FontWeight.w400,
                    fontSize: item.textStyle.fontSize),
              )),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Container(
        width: double.infinity,
        height: kBottomNavigationBarHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.map((item) {
            var index = items.indexOf(item);
            return Flexible(
              child: GestureDetector(
                onTap: () {
                  this.onItemSelected(index);
                },
                child: _buildItem(item, selectedIndex == index),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/*
class ChangeQtyScreen extends StatefulWidget {
  ChangeQtyScreen(this.quantityValue, this.onScreenHideButtonPressed);
  final int quantityValue;
  final Function onScreenHideButtonPressed;
  @override
  _ChangeQtyScreen createState() =>
      _ChangeQtyScreen(quantityValue, onScreenHideButtonPressed);
}

class _ChangeQtyScreen extends State<ChangeQtyScreen> {
  _ChangeQtyScreen(this.quantityValue, this.onScreenHideButtonPressed);
  final int quantityValue;
  final Function onScreenHideButtonPressed;
  final FocusNode _nodeNum = FocusNode();
  final qtyController = TextEditingController();

  void initState() {
    super.initState();
    qtyController.text = quantityValue.toString();
    qtyController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: quantityValue.toString().length,
    );
    Future.delayed(Duration(seconds: 0), () => onScreenHideButtonPressed());
  }

  void dispose() {
    super.dispose();
    Future.delayed(Duration(seconds: 0), () => onScreenHideButtonPressed());
  }

  void _onEditComplete() {
//    globals.scanCounter.value = globals.scanCounter.value + 1;
//    globals.scanCounter.value = globals.scanCounter.value - 1;
    //onScreenHideButtonPressed();
    Navigator.pop(context, int.parse(qtyController.text));
  }

  /// Creates the [KeyboardActionsConfig] to hook up the fields
  /// and their focus nodes to our [FormKeyboardActions].
  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: myTheme.bottomAppBarColor,
      nextFocus: false,
      actions: [
        KeyboardActionsItem(focusNode: _nodeNum, toolbarButtons: [
          (node) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              child: ElevatedButton(
                child: Icon(
                  Icons.done,
                  color: Colors.white,
                ),
                onPressed: () => _onEditComplete(),
              ),
            );
          },
        ])
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('', style: TextStyle(fontSize: 18.0))),
      body: KeyboardActions(
        enable: true,
        config: _buildConfig(context),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 15.0),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: CupertinoTextField(
//                  textInputAction: TextInputAction.done,
                  prefix: Text(AppLocalizations.of(context).quantity),
                  controller: qtyController,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  clearButtonMode: OverlayVisibilityMode.editing,
                  keyboardType: TextInputType.numberWithOptions(
                      signed: false, decimal: false),
                  focusNode: _nodeNum,
                  autocorrect: false,
                  autofocus: true,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 0,
                        color: CupertinoColors.inactiveGray,
                      ),
                    ),
                  ),
                  placeholder: AppLocalizations.of(context).reqval,
                  onEditingComplete: () {
                    _onEditComplete();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/

class NewsScreen extends StatefulWidget {
  const NewsScreen();
  @override
  _NewsScreen createState() => _NewsScreen();
}

class _NewsScreen extends State<NewsScreen> {
  _NewsScreen();

  var storage = new InfoNewsStorage();

  _refreshInfoNews() {
    globals.infoCounter.value =
        infoNews.where((r) => r.infsta == 0).toList().length;
    storage.writeInfoNews(infoNews);
  }

  @override
  Widget build(BuildContext context) {
    var futureBuilder = FutureBuilder(
      future: getNews(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          default:
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return ListView.builder(
                  itemCount: infoNews.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: <Widget>[
                        ValueListenableBuilder(
                            valueListenable: globals.infoCounter,
                            builder: (BuildContext context, int value,
                                Widget child) {
                              return ListTile(
                                title: Column(children: <Widget>[
                                  Container(
                                    padding:
                                        EdgeInsets.only(top: 2.0, bottom: 0.0),
                                    child: Image.network(
                                      'https://' +
                                          approShop +
                                          '.catbuilder.info/catalogs/' +
                                          getText(infoNews[index].infimg),
                                      fit: BoxFit.cover,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent loadingProgress) {
                                        if (loadingProgress == null) {
                                          return Center(child: child);
                                        } else {
                                          return Container();
                                        }
                                      },
                                    ),
                                  ),
                                  Container(
                                      height: infoNews[index].infdet == ''
                                          ? 0.0
                                          : 5.0),
                                  //Text(getText(infoNews[index].infdet)),
                                  ListTile(
                                    //minLeadingWidth: 20.0,
                                    dense: true,
                                    horizontalTitleGap: 0.0,
                                    contentPadding: EdgeInsets.all(0.0),
                                    leading: infoNews[index].infsta == 1
                                        ? IconButton(
                                            padding: EdgeInsets.only(
                                                top: 0.0,
                                                left: 0.0,
                                                right: 4.0),
                                            icon:
                                                Icon(Icons.check_box_outlined),
                                            onPressed: () {
                                              infoNews[index].infsta = 0;
                                              _refreshInfoNews();
                                            },
                                          )
                                        : IconButton(
                                            padding: EdgeInsets.only(
                                                top: 0.0,
                                                left: 0.0,
                                                right: 4.0),
                                            icon: Icon(Icons
                                                .check_box_outline_blank_outlined),
                                            onPressed: () {
                                              infoNews[index].infsta = 1;
                                              _refreshInfoNews();
                                            },
                                          ),
                                    title:
                                        Text(getText(infoNews[index].inftit)),

                                    onTap: () async {
                                      switch (infoNews[index].infact) {
                                        case 'search':
                                          infoNews[index].infsta = 1;
                                          _refreshInfoNews();
                                          List<CatLevel> _result = [];
                                          _result = await searchItem(
                                              getItemToken(
                                                  infoNews[index].inflin,
                                                  '|',
                                                  1),
                                              getItemToken(
                                                  infoNews[index].inflin,
                                                  '|',
                                                  2),
                                              context);
                                          var route = MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                ChapterScreen(
                                                    _result,
                                                    infoNews[index].inftit,
                                                    null),
                                          );
                                          Navigator.of(context).push(route);
                                          break;

                                        case 'goto':
                                          infoNews[index].infsta = 1;
                                          globals.infoCounter.value = infoNews
                                              .where((r) => r.infsta == 0)
                                              .toList()
                                              .length;
                                          var route = MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                FavoriteDetailScreen(
                                              basdes: getText(
                                                  infoNews[index].inftit),
                                              basval: getItemToken(
                                                  getItemToken(
                                                      infoNews[index].inflin,
                                                      '/',
                                                      2),
                                                  '.',
                                                  1),
                                              basurl: infoNews[index].inflin,
                                              synctoc: true,
                                            ),
                                          );
                                          Navigator.of(context).push(route);
                                          break;
                                      }
                                    },
                                    trailing: infoNews[index].infact == ''
                                        ? Container()
                                        : Icon(Icons.arrow_forward_ios_rounded,
                                            size: 16),
                                  )
                                ]),
                                onTap: () async {
                                  switch (infoNews[index].infact) {
                                    case 'search':
                                      infoNews[index].infsta = 1;
                                      _refreshInfoNews();
                                      List<CatLevel> _result = [];
                                      _result = await searchItem(
                                          getItemToken(
                                              infoNews[index].inflin, '|', 1),
                                          getItemToken(
                                              infoNews[index].inflin, '|', 2),
                                          context);
                                      var route = MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            ChapterScreen(_result,
                                                infoNews[index].inftit, null),
                                      );
                                      Navigator.of(context).push(route);
                                      break;
                                    case 'goto':
                                      infoNews[index].infsta = 1;
                                      _refreshInfoNews();
                                      var route = MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            FavoriteDetailScreen(
                                          basdes:
                                              getText(infoNews[index].inftit),
                                          basval: getItemToken(
                                              getItemToken(
                                                  infoNews[index].inflin,
                                                  '/',
                                                  2),
                                              '.',
                                              1),
                                          basurl: infoNews[index].inflin,
                                          synctoc: true,
                                        ),
                                      );
                                      Navigator.of(context).push(route);
                                      break;
                                  }
                                },
                              );
                            }),
                        //Divider(height: 1.0,),
                      ],
                    );
                  });
            }
        }
      },
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Row(children: <Widget>[
        Expanded(
            child: Text(getText(approNewsTitle),
                style: TextStyle(fontSize: 14.0))),
        Container(width: 8.0),
        IconButton(
          padding: EdgeInsets.only(top: 0.0, left: 16.0, right: 16.0),
          icon: Icon(Icons.check_box_outlined),
          onPressed: () {
            setState(() {
              for (var e in infoNews) {
                e.infsta = 1;
              }
            });
            _refreshInfoNews();
          },
        ),
      ])),
      body: Container(
          padding: EdgeInsets.only(top: 0.0, bottom: 60), child: futureBuilder),
    );
  }
}

class PdfScreen extends StatefulWidget {
  PdfScreen(this.pdfUrl, this.noddes);
  final List<String> pdfUrl;
  final String noddes;

  @override
  _PdfScreen createState() => _PdfScreen(pdfUrl, noddes);
}

class _PdfScreen extends State<PdfScreen> {
  _PdfScreen(this.pdfUrl, this.noddes);
  final String noddes;
  final List<String> pdfUrl;
  bool pdfReady = false;
  PdfController _pdfController;
  String _pdfFile;
  List<File> _pdfTabFile = [];
  int _actualPageNumber = 1, _allPagesCount = 0;

  void _printPDF() async {
    final file = File(_pdfFile);
    final bytes = await file.readAsBytes(); // Uint8List
    final byteData = bytes.buffer.asByteData();
    await Printing.layoutPdf(onLayout: (_) => byteData.buffer.asUint8List());
  }

  void _sharePDF() async {
    final file = File(_pdfFile);
    final bytes = await file.readAsBytes(); // Uint8List
    final byteData = bytes.buffer.asByteData();

    await Printing.sharePdf(
        bytes: byteData.buffer.asUint8List(), filename: this.noddes + '.pdf');
  }

  @override
  void initState() {
    if (pdfUrl.length == 1) {
      getFileFromUrl(pdfUrl[0], 0, false).then((f) {
        _pdfController = PdfController(document: PdfDocument.openFile(f.path));
        _pdfFile = f.path;
        setState(() {
          pdfReady = true;
        });
      });
    } else {
      imageCache.clear();
      var iMax = pdfUrl.length;
      for (var i = 0; i < pdfUrl.length; i++) {
        _pdfTabFile.add(null);
      }
      for (var i = 0; i < pdfUrl.length; i++) {
        getFileFromUrl(pdfUrl[i], i, true).then((f) {
          _pdfTabFile[i] = File(f.path.replaceAll('.pdf', '.jpg'));
          iMax--;
          if (iMax == 0) {
            setState(() {
              pdfReady = true;
            });
          }
        });
      }
    }
    super.initState();
  }

  void dispose() {
    if (_pdfController != null) _pdfController.dispose();
    super.dispose();
  }

  Widget pdfView() => PdfView(
        controller: _pdfController,
        renderer: (PdfPage page) => page.render(
          width: page.width * 2,
          height: page.height * 2,
          format: PdfPageImageFormat.jpeg,
          backgroundColor: '#FFFFFF',
        ),
        onDocumentLoaded: (document) {
          setState(() {
            _allPagesCount = document.pagesCount;
          });
        },
        onPageChanged: (page) {
          setState(() {
            _actualPageNumber = page;
          });
        },
      );
  Widget build(BuildContext context) {
    if (pdfUrl.length > 1) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
//            crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
              Expanded(
                  child: Text(
                noddes,
                style: TextStyle(fontSize: 14.0),
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              )),
            ])),
        body: pdfReady
            ? Container(
                padding: EdgeInsets.only(top: 0.0, bottom: 60),
                child: GridView.builder(
                  itemCount: _pdfTabFile.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0),
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: new InkResponse(
                        child: Image.file(_pdfTabFile[index]),
                        onTap: () {
                          List<String> myUrl = [];
                          myUrl.add(pdfUrl[index]);
                          var route = MaterialPageRoute(
                              builder: (BuildContext context) => PdfScreen(
                                    myUrl,
                                    noddes,
                                  ));
                          Navigator.of(context).push(route);
                        },
                      ),
                    );
                  },
                ),
/*                          onTap: () {
                            List<String> myUrl = [];
                            myUrl.add(pdfUrl[index]);
                            var route = MaterialPageRoute(
                                builder: (BuildContext context) => PdfScreen(
                                      myUrl,
                                      noddes,
                                    ));
                            Navigator.of(context).push(route);
                          },
                        )
                      ]);
                    }),

 */
              )
            : Center(child: CircularProgressIndicator()),
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.white,
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterTop,
        floatingActionButton: Container(
          height: 40.0,
          width: 40.0,
          child: FittedBox(
            child: FloatingActionButton(
                elevation: 5.0,
                mini: false,
                onPressed: () {
                  _actualPageNumber = _actualPageNumber < _allPagesCount
                      ? _actualPageNumber + 1
                      : 1;
                  _pdfController.jumpToPage(_actualPageNumber);
                },
                child: Text(
                    _actualPageNumber.toString() +
                        '/' +
                        _allPagesCount.toString(),
                    style: TextStyle(fontSize: 14.0))),
          ),
        ),
        appBar: AppBar(
            title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
//            crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
              Expanded(
                  child: Text(
                noddes,
                style: TextStyle(fontSize: 14.0),
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              )),
              IconButton(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerRight,
                icon: Icon(
                  Icons.share_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  _sharePDF();
                },
              ),
              IconButton(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerRight,
                icon: Icon(
                  Icons.print,
                  color: Colors.white,
                ),
                onPressed: () {
                  _printPDF();
                },
              ),
            ])),
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            pdfReady ? pdfView() : Center(child: CircularProgressIndicator())
          ],
        ),
      );
    }
  }
}

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen(
      {Key key,
      this.menuScreenContext,
      this.onScreenHideButtonPressed,
      this.hideStatus = false})
      : super(key: key);
  final BuildContext menuScreenContext;
  final Function onScreenHideButtonPressed;
  final bool hideStatus;
  @override
  _FavoriteScreen createState() =>
      _FavoriteScreen(menuScreenContext, onScreenHideButtonPressed, hideStatus);
}

class _FavoriteScreen extends State<FavoriteScreen> {
  _FavoriteScreen(
      this.menuScreenContext, this.onScreenHideButtonPressed, this.hideStatus);

  final BuildContext menuScreenContext;
  final Function onScreenHideButtonPressed;
  final bool hideStatus;
  int segmentedControlValue = 0;

  final Map<int, Widget> mapMenuSegment = {};

  Widget segmentedControl() {
    return Container(
//      width: 300,
      child: CupertinoSlidingSegmentedControl(
          groupValue: segmentedControlValue,
          backgroundColor: Colors.transparent,
          thumbColor: myTheme.toggleableActiveColor,
          children: mapMenuSegment,
          onValueChanged: (value) {
            setState(() {
              segmentedControlValue = value;
            });
          }),
    );
  }

  void _refresh() async {
    await getFavorite(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    mapMenuSegment.putIfAbsent(
      0,
      () => Text(AppLocalizations.of(context).favorite,
          style: TextStyle(fontSize: 14.0)),
    );
    mapMenuSegment.putIfAbsent(
      1,
      () => Text(AppLocalizations.of(context).history,
          style: TextStyle(fontSize: 14.0)),
    );
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
//            crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
//              Text(FavoriteCode == 'archive' ? 'History' : 'Favorite'),
              segmentedControl(),
              IconButton(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerRight,
                icon: Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
                onPressed: () {
                  _refresh();
                },
              ),
            ])),
        drawer: GeneralDrawer(),
        body: Container(
          padding: EdgeInsets.only(top: 0.0, bottom: 60),
          child: ListView.builder(
            itemCount: segmentedControlValue == 1
                ? basketArchive.length
                : basketFavorite.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: <Widget>[
                  ListTile(
                    title: Text(segmentedControlValue == 1
                        ? basketArchive[index].basdes +
                            '\n' +
                            basketArchive[index].basdat
                        : basketFavorite[index].basdes),
                    onTap: () {
                      var route = MaterialPageRoute(
                        builder: (BuildContext context) => FavoriteDetailScreen(
                          basdes: (segmentedControlValue == 1
                                  ? basketArchive
                                  : basketFavorite)[index]
                              .basdes,
                          basval: (segmentedControlValue == 1
                                  ? basketArchive
                                  : basketFavorite)[index]
                              .basval,
                          basurl: '',
                          synctoc: true,
                          onScreenHideButtonPressed: onScreenHideButtonPressed,
                        ),
                      );
                      Navigator.of(context).push(route);
                    },
                    trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  ),
                  Divider(
                    height: 1.0,
                  ),
                ],
              );
            },
          ),
        ));
  }
}

class FavoriteDetailScreen extends StatefulWidget {
  const FavoriteDetailScreen(
      {Key key,
      this.menuScreenContext,
      this.onScreenHideButtonPressed,
      this.hideStatus = false,
      this.basdes = '',
      this.basval = '',
      this.basurl = '',
      this.synctoc = false,
      this.syncnum = ''})
      : super(key: key);
  final BuildContext menuScreenContext;
  final Function onScreenHideButtonPressed;
  final bool hideStatus;
  final String basdes;
  final String basval;
  final String basurl;
  final bool synctoc;
  final String syncnum;
  @override
  _FavoriteDetailScreen createState() => _FavoriteDetailScreen(
      menuScreenContext,
      onScreenHideButtonPressed,
      hideStatus,
      basdes,
      basval,
      basurl,
      synctoc,
      syncnum);
}

class _FavoriteDetailScreen extends State<FavoriteDetailScreen> {
  _FavoriteDetailScreen(
      this.menuScreenContext,
      this.onScreenHideButtonPressed,
      this.hideStatus,
      this.basdes,
      this.basval,
      this.basurl,
      this.synctoc,
      this.syncnum);
  final BuildContext menuScreenContext;
  final Function onScreenHideButtonPressed;
  final bool hideStatus;
  final String basdes;
  final String basval;
  final String basurl;
  final bool synctoc;
  final String syncnum;

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  var _position;
  var _pdfIndex = 0;

  void _showPDF(context, replace) async {
    List<String> myUrl = [''];
    if (approPDFSuffix == '') {
      myUrl[0] = basurl.replaceAll('.asp', '.pdf');
    } else {
      myUrl[0] =
          basurl.replaceAll('.asp', approPDFSuffix + approLanguage + '.pdf');
    }
    if (myUrl[0].indexOf('/catalogs/') == -1)
      myUrl[0] = '/catalogs/' + myUrl[0];
    myUrl[0] = 'https://' + approShop + '.catbuilder.info' + myUrl[0];

    var route = MaterialPageRoute(
      builder: (BuildContext context) => PdfScreen(myUrl, basdes),
    );
    if (replace) {
      Navigator.pushReplacement(context, route);
    } else {
      Navigator.of(context).push(route);
    }
  }

  void _showItemPDF(context, url, des) async {
    for (var i = 0; i < url.length; i++) {
      url[i] = url[i].indexOf('http') == -1
          ? 'https://' + approShop + '.catbuilder.info' + url[i]
          : url[i];
    }
    var route = MaterialPageRoute(
      builder: (BuildContext context) => PdfScreen(url, des),
    );
    Navigator.of(context).push(route);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var _product = Product('');
    var futureBuilder = FutureBuilder(
      future: basurl == ''
          ? getBasketDetail(basval)
          : getProductItem(basval, basurl, _product),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Scaffold(
                appBar: AppBar(),
                backgroundColor: Colors.white,
                body: Center(child: CircularProgressIndicator()));
          default:
            if (snapshot.hasError) {
              Future.delayed(Duration(milliseconds: 200)).then((v) {
                restoreShopConnexion(context, '2:Security');
              });
              return Scaffold(
                  appBar: AppBar(),
                  backgroundColor: Colors.white,
                  body: Center(child: Container()));
            } else if (basurl != '' && snapshot.data.length == 0) {
              Future.delayed(Duration(milliseconds: 200)).then((v) {
                _showPDF(context, true);
              });
              return Scaffold(
                  appBar: AppBar(),
                  backgroundColor: Colors.white,
                  body: Center(child: CircularProgressIndicator()));
            } else {
              //print(_product.toString());

              return createListViewDetail(context, snapshot, _product);
            }
        }
      },
    );

    return futureBuilder;
  }

  Widget createListViewDetail(
      BuildContext context, AsyncSnapshot snapshot, Product product) {
    List<BasketDetail> values = snapshot.data;
    _position = 0;
    if (syncnum != '') {
      _position = values.indexWhere((e) => e.artnumint == syncnum);
      if (_position == -1) _position = 0;
    }
    _pdfIndex = values.indexWhere((element) => element.artpdf.length > 0);
    //print('Position: $_position');

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
              Expanded(
                  child: Text(
                basdes,
                style: TextStyle(fontSize: 14.0),
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              )),
              _pdfIndex == -1
                  ? Container()
                  : IconButton(
                      icon: Image.asset(
                        'images/ft.png',
                        width: 24.0,
                        height: 24.0,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        _showItemPDF(context, values[_pdfIndex].artpdf,
                            values[_pdfIndex].artdes);
                      },
                    ),
              basurl == '' || approPDFSuffix == 'x' || product.sheet == ''
                  ? Container()
                  : IconButton(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerRight,
                      icon: Icon(
                        Icons.info_outline,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        _showPDF(context, false);
                      },
                    ),
            ])),
        body: Container(
          padding: EdgeInsets.only(top: 5.0, bottom: 60),
          child: ScrollablePositionedList.builder(
            itemCount: values.length,
            initialScrollIndex: _position,
            scrollDirection: Axis.vertical,
            itemPositionsListener: itemPositionsListener,
            itemScrollController: itemScrollController,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: <Widget>[
                  ListTile(
                    title: Row(children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          if (basurl == '') return;
                          if (values[index].repcod == '') {
                            if (basurl.indexOf('/catalogs/') == -1) {
                              values[index].repcod =
                                  getItemToken(basurl, '/', 1);
                            } else {
                              values[index].repcod = getItemToken(
                                  getItemToken(basurl, '/catalogs/', 2),
                                  '/',
                                  1);
                            }
                          }
                          var route = MaterialPageRoute(
                            builder: (BuildContext context) => ItemDetailScreen(
                                itemSelected: values[index],
                                productSelected: product),
                          );
                          Navigator.of(context).push(route);
                        },
                        child: FadeInImage(
                          imageErrorBuilder: (BuildContext context,
                              Object exception, StackTrace stackTrace) {
                            //print('Error Handler');
                            return Container(
                              width: 64.0 * approThumbSizeRatio,
                              height: 64.0 * approThumbSizeRatio,
                              child: Image.asset('images/pixel.gif'),
                            );
                          },
                          placeholder: AssetImage('images/pixel.gif'),
                          image: values[index].nodnum == ''
                              ? AssetImage('images/pixel.gif')
                              : NetworkImage('https://' +
                                  approShop +
                                  '.catbuilder.info/catalogs/thumbs/' +
                                  (values[index].artimg == ''
                                      ? values[index].nodnum
                                      : values[index].artimg) +
                                  '.jpg'),
                          fit: BoxFit.contain,
                          height: 64.0 * approThumbSizeRatio,
                          width: 64.0 * approThumbSizeRatio,
                        ),
                        //Image.network('https://'+approShop+'.catbuilder.info/catalogs/thumbs/'+ values[index].nodnum +'.jpg'),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                            Text(values[index].artdes),
                            Wrap(direction: Axis.horizontal, children: <Widget>[
                              if (synctoc)
                                ElevatedButton(
                                  onPressed: () async {
                                    await getNodePath(values[index].nodnum,
                                        values[index].repcod, context);
                                    if (currentNodePath != '') {
                                      mainTab.jumpToTab(1);
                                      if (approTreeScreen.currentContext ==
                                          null) {
                                        await Future.delayed(
                                            const Duration(milliseconds: 100),
                                            () {});
                                      }

                                      final _context =
                                          approTreeScreen.currentContext;

                                      final _name = '/tree';
                                      if (_context != null) {
                                        Navigator.of(_context).popUntil(
                                            ModalRoute.withName("/tree"));
                                      }
                                      await syncNode(
                                          treeRoot,
                                          _name,
                                          _context,
                                          onScreenHideButtonPressed,
                                          1,
                                          values[index].artnumint);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                      primary: myTheme.toggleButtonsTheme.color,
                                      visualDensity: VisualDensity.compact,
                                      textStyle: TextStyle(fontSize: 12.0)),
                                  child: Text(
                                    values[index].artnumint,
                                  ),
                                )
                              else
                                Text(values[index].artnumint,
                                    style: TextStyle(
                                      color: globals.artnumintColor,
                                      backgroundColor:
                                          syncnum == values[index].artnumint
                                              ? Colors.amberAccent
                                              : myTheme.canvasColor,
                                    )),
                              /*
                                values[index].artpdf.length > 0
                                    ? IconButton(
                                        icon: Icon(SimpleLineIcons.book_open,
                                            size: 20.0, color: Colors.grey),
                                        onPressed: () {
                                          _showItemPDF(
                                              context,
                                              values[index].artpdf,
                                              values[index].artdes);
                                        },
                                      )
                                    : Container(),
                                */
                            ]),
                          ])),
                      SizedBox(
                        width: 10,
                      ),
                      CheckedWidget(values[index]),
                    ]),
                    //onTa]),p: () {},
                    //         trailing: CheckedWidget(values[index]),
                  ),
                  ListTile(
                    title: Row(
                      children: <Widget>[
                        TouchInfo(
                          //onScreenHideButtonPressed: onScreenHideButtonPressed,
                          //                         displayFormat: ,
                          iconSize: 24.0,
                          iconActiveColor: Colors.red,
                          iconDisabledColor: Colors.grey,
                          iconPadding: EdgeInsets.all(2),
                          artnumint: values[index].artnumint,
                          artpri: values[index].artpri,
                          artpac: values[index].artpac,
                          enabled: true,
                          leftPadding: 64.0 * approThumbSizeRatio,
                        ),
                      ],
                    ),
                  ),
                  ValueListenableBuilder(
                      valueListenable: globals.favoriteRefresh,
                      builder:
                          (BuildContext context, bool value, Widget child) {
                        var _bindex = basketChecked.indexWhere(
                            (e) => e.artnumint == values[index].artnumint);

                        return _bindex >
                                -1 //&& basketChecked[_bindex].newchecked
                            ? ListTile(
                                /*  leading: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: 64,
                                maxWidth: 64,
                              ),
                              child: Icon(
                                Feather.package,
                                size: 23.0,
                                color: Colors.grey,
                              ),
                            ),

                           */
                                title: SizedBox(
                                  width: 100,
                                  child: TouchSpin2(
                                    scrollVisible: true,
                                    //onScreenHideButtonPressed: onScreenHideButtonPressed,
                                    value: basketChecked[_bindex].artqty,
                                    min: 1,
                                    max: 10000,
                                    step: 1,
                                    //                         displayFormat: ,
                                    textStyle: TextStyle(fontSize: 16),
                                    iconSize: 24.0,
                                    addIcon: Icon(Icons.add_circle_outline),
                                    subtractIcon:
                                        Icon(Icons.remove_circle_outline),
                                    iconActiveColor: Colors.red,
                                    iconDisabledColor: Colors.grey,
                                    iconPadding: EdgeInsets.all(2),
                                    showStockIcon: false,
                                    artnumint: basketChecked[_bindex].artnumint,
                                    onChanged: (val) {
                                      basketChecked[_bindex].artqty = val;
                                      globals.basketCounter.value =
                                          globals.basketCounter.value + 1;
                                      globals.basketCounter.value =
                                          globals.basketCounter.value - 1;
                                    },
                                    enabled: true,
                                    leftPadding: 64.0 * approThumbSizeRatio,
                                  ),
                                ),
                              )
                            : Container();
                      }),
                  Divider(height: 5.0),
                ],
              );
            },
          ),
        ));
  }
}

class ItemDetailScreen extends StatelessWidget {
  const ItemDetailScreen(
      {Key key,
      this.menuScreenContext,
      this.onScreenHideButtonPressed,
      this.hideStatus = false,
      this.itemSelected,
      this.productSelected})
      : super(key: key);
  final BuildContext menuScreenContext;
  final Function onScreenHideButtonPressed;
  final bool hideStatus;
  final BasketDetail itemSelected;
  final Product productSelected;

  void _showPDF(context) async {
    List<String> myUrl = [''];
    if (approPDFSuffix == '') {
      myUrl[0] = itemSelected.nodnum + '.pdf';
    } else {
      myUrl[0] = itemSelected.nodnum + approPDFSuffix + approLanguage + '.pdf';
    }
    myUrl[0] = 'https://' +
        approShop +
        '.catbuilder.info/catalogs/' +
        itemSelected.repcod +
        '/' +
        myUrl[0];
    //print(myUrl);
    var route = MaterialPageRoute(
      builder: (BuildContext context) => PdfScreen(myUrl, itemSelected.artdes),
    );
    Navigator.of(context).push(route);
  }

  @override
  Widget build(BuildContext context) {
    var futureBuilder = FutureBuilder(
      future: getItemPicture(itemSelected),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          default:
            if (snapshot.hasError) {
              Future.delayed(Duration(milliseconds: 200)).then((v) {
                restoreShopConnexion(context, '2:Security');
              });
              return Scaffold(
                  appBar: AppBar(),
                  backgroundColor: Colors.white,
                  body: Center(child: Container()));
            } else
              return createListViewDetail(context, snapshot);
        }
      },
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
//            crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
            Expanded(
                child: Text(
              itemSelected.artdes,
              style: TextStyle(fontSize: 14.0),
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            )),
            approPDFSuffix == 'x' || productSelected.sheet == ''
                ? Container()
                : IconButton(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerRight,
                    icon: Icon(
                      Icons.info_outline,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _showPDF(context);
                    },
                  ),
          ])),
      body: futureBuilder,
    );
  }

  Widget createListViewDetail(BuildContext context, AsyncSnapshot snapshot) {
    BasketDetail value = snapshot.data;
    //print(value.artimg);
    //print(value.nodimg);
    return Container(
      padding: EdgeInsets.only(top: 5.0, bottom: 60, left: 5, right: 5),
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: value.nodimg.length,
          itemBuilder: (BuildContext context, int index) {
            return Center(
                child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 128,
                minHeight: 128,
                maxWidth: MediaQuery.of(context).size.width,
                maxHeight: 3000,
              ),
              child: FadeInImage(
                imageErrorBuilder: (BuildContext context, Object exception,
                    StackTrace stackTrace) {
                  //print('Error Handler');
                  return Container(
                    width: 100.0,
                    height: 100.0,
                    child: Image.asset('images/nopicture.jpg'),
                  );
                },
                placeholder: AssetImage('images/pixel.gif'),
                image: NetworkImage(value.nodimg[index], scale: 1),
                fit: BoxFit.contain,
                //height: 250.0,
                //width: MediaQuery.of(context).size.width,
              ),
            ));
          }),
    );
  }
}

class TreeScreen extends StatefulWidget {
  const TreeScreen(
      {Key key,
      this.menuScreenContext,
      this.onScreenHideButtonPressed,
      this.hideStatus = false,
      this.treeChildren})
      : super(key: key);
  final BuildContext menuScreenContext;
  final Function onScreenHideButtonPressed;
  final bool hideStatus;
  final List<CatLevel> treeChildren;

  @override
  _TreeScreen createState() =>
      _TreeScreen(menuScreenContext, onScreenHideButtonPressed, hideStatus);
}

class _TreeScreen extends State<TreeScreen> {
  _TreeScreen(
      this.menuScreenContext, this.onScreenHideButtonPressed, this.hideStatus);
  final BuildContext menuScreenContext;
  final Function onScreenHideButtonPressed;
  final bool hideStatus;

  void _refresh() async {
    treeRoot = await getTree(context, approStartCatalog);
    infoNews = await getApproNews(null);
    if (infoNews != null) {
      approShowNews = (infoNews.length > 0);
    }
    setState(() {});
    //globals.infoCounter.value = infoNews.where((r) => r.infsta == 0).toList().length;
  }

  _launchURL(url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        webViewConfiguration: WebViewConfiguration(
          enableJavaScript: true,
        ),
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: approTreeScreen,
      backgroundColor: Colors.white,
      drawer: GeneralDrawer(),
      appBar: AppBar(
          title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
//            crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
            Text(AppLocalizations.of(context).catalog,
                style: TextStyle(fontSize: 14.0)),
            Row(mainAxisAlignment: MainAxisAlignment.end,
//            crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  !approShowNews
                      ? Container()
                      : ValueListenableBuilder(
                          valueListenable: globals.infoCounter,
                          builder:
                              (BuildContext context, int value, Widget child) {
                            // This builder will only get called when the _counter
                            // is updated.
                            return globals.infoCounter.value == 0
                                ? IconButton(
                                    padding: EdgeInsets.zero,
                                    alignment: Alignment.center,
                                    icon: Icon(
                                      FontAwesome.bullhorn,
                                      size: 20.0,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      var route = MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            NewsScreen(),
                                      );
                                      Navigator.of(context).push(route);
                                    },
                                  )
                                : Badge(
                                    badgeColor: globals.badgeColor,
                                    position:
                                        BadgePosition.topEnd(top: -2, end: -3),
                                    animationDuration:
                                        Duration(milliseconds: 300),
                                    animationType: BadgeAnimationType.slide,
                                    badgeContent: ValueListenableBuilder(
                                      valueListenable: globals.infoCounter,
                                      builder: (BuildContext context, int value,
                                          Widget child) {
                                        // This builder will only get called when the _counter
                                        // is updated.
                                        return Text('$value',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ));
                                      },
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      alignment: Alignment.center,
                                      icon: Icon(
                                        FontAwesome.bullhorn,
                                        size: 20.0,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        var route = MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              NewsScreen(),
                                        );
                                        Navigator.of(context).push(route);
                                        //globals.infoCounter.value = 0;
                                      },
                                    ),
                                  );
                          }),
                  IconButton(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerRight,
                    icon: Icon(
                      Icons.refresh,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _refresh();
                    },
                  ),
                ]),
          ])),
      body: Container(
        padding: EdgeInsets.only(top: 0.0, bottom: 60),
        child: ListView.builder(
          itemCount: treeRoot.length == null ? 0 : treeRoot.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: <Widget>[
                ListTile(
                    title: Row(children: <Widget>[
                      FadeInImage(
                        imageErrorBuilder: (BuildContext context,
                            Object exception, StackTrace stackTrace) {
                          //print('Error Handler');
                          return Container(
                            width: 64.0 * approThumbSizeRatio,
                            height: 64.0 * approThumbSizeRatio,
                            child: Image.asset('images/pixel.gif'),
                          );
                        },
                        placeholder: AssetImage('images/pixel.gif'),
                        image: treeRoot[index].nodimg == ''
                            ? AssetImage('images/pixel.gif')
                            : NetworkImage(
                                'https://' +
                                    approShop +
                                    '.catbuilder.info/catalogs/' +
                                    treeRoot[index].nodimg,
                                scale: 1.0),
                        fit: BoxFit.contain,
                        height: 64.0 * approThumbSizeRatio,
                        width: 64.0 * approThumbSizeRatio,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(child: Text(treeRoot[index].noddes)),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, size: 16)
                    ]),
                    onTap: () async {
                      if (treeRoot[index].nodnum.indexOf('goto_external(') >
                          -1) {
                        var myUrl = getText(getItemToken(
                            getItemToken(
                                treeRoot[index].nodnum, 'goto_external(\'', 2),
                            '\')',
                            1));
                        _launchURL(myUrl);
                      } else {
                        if (treeRoot[index].nodnum.indexOf('@') > -1) {
                          var e = await getTree(
                              context, treeRoot[index].nodnum.split('@')[1]);
                          var route = MaterialPageRoute(
                            builder: (BuildContext context) => ChapterScreen(
                                e,
                                treeRoot[index].noddes,
                                onScreenHideButtonPressed),
                          );
                          Navigator.of(context).push(route);
                        } else {
                          var e = await getTreeLevel(treeRoot[index].xmlnod);
                          var route = MaterialPageRoute(
                            builder: (BuildContext context) => ChapterScreen(
                                e,
                                treeRoot[index].noddes,
                                onScreenHideButtonPressed),
                          );
                          Navigator.of(context).push(route);
                        }
                      }
                    }),
                Divider(
                  height: 1.0,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ChapterScreen extends StatefulWidget {
  const ChapterScreen(
      this.nodes, this.ancnoddes, this.onScreenHideButtonPressed);
  final List<CatLevel> nodes;
  final String ancnoddes;
  final Function onScreenHideButtonPressed;
  @override
  _ChapterScreen createState() =>
      _ChapterScreen(nodes, ancnoddes, onScreenHideButtonPressed);
}

class _ChapterScreen extends State<ChapterScreen> {
  _ChapterScreen(
      this.nodeChildren, this.ancnoddes, this.onScreenHideButtonPressed);
  final List<CatLevel> nodeChildren;
  final String ancnoddes;
  final Function onScreenHideButtonPressed;
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(ancnoddes, style: TextStyle(fontSize: 14.0))),
      body: Container(
        padding: EdgeInsets.only(top: 0.0, bottom: 60),
        child: ListView.builder(
          itemCount: nodeChildren.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: <Widget>[
                ListTile(
/*                    leading: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 64,
                        minHeight: 64,
                        maxWidth: 64,
                        maxHeight: 64,
                      ),
                      child: FadeInImage(
                        imageErrorBuilder: (BuildContext context,
                            Object exception, StackTrace stackTrace) {
                          //print('Error Handler');
                          return Container(
                            width: 64.0,
                            height: 64.0,
                            child: Image.asset('images/pixel.gif'),
                          );
                        },
                        placeholder: AssetImage('images/pixel.gif'),
                        image: nodeChildren[index].nodimg == ''
                            ? AssetImage('images/pixel.gif')
                            : NetworkImage('https://' +
                                approShop +
                                '.catbuilder.info/catalogs/' +
                                nodeChildren[index].nodimg),
                        fit: BoxFit.contain,
                        height: 64.0,
                        width: 64.0,
                      ),
                    ),
                    title: Text(nodeChildren[index].noddes),
                    trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
*/
                    title: Row(children: <Widget>[
                      FadeInImage(
                        imageErrorBuilder: (BuildContext context,
                            Object exception, StackTrace stackTrace) {
                          //print('Error Handler');
                          return Container(
                            width: 64.0 * approThumbSizeRatio,
                            height: 64.0 * approThumbSizeRatio,
                            child: Image.asset('images/pixel.gif'),
                          );
                        },
                        placeholder: AssetImage('images/pixel.gif'),
                        image: nodeChildren[index].nodimg == ''
                            ? AssetImage('images/pixel.gif')
                            : NetworkImage(
                                'https://' +
                                    approShop +
                                    '.catbuilder.info/catalogs/' +
                                    nodeChildren[index].nodimg,
                                scale: 1.0),
                        fit: BoxFit.contain,
                        height: 64.0 * approThumbSizeRatio,
                        width: 64.0 * approThumbSizeRatio,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(child: Text(nodeChildren[index].noddes)),
                      SizedBox(
                        width: 10,
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, size: 16)
                    ]),
                    onTap: () async {
                      var route;
                      if (nodeChildren[index].nodtyp == 2) {
                        route = MaterialPageRoute(
                          builder: (BuildContext context) =>
                              FavoriteDetailScreen(
                            basdes: nodeChildren[index].noddes,
                            basval: nodeChildren[index].nodnum,
                            basurl: nodeChildren[index].nodurl,
                            onScreenHideButtonPressed:
                                onScreenHideButtonPressed,
                          ),
                        );
                      } else {
                        var e = await getTreeLevel(nodeChildren[index].xmlnod);
                        route = MaterialPageRoute(
                          builder: (BuildContext context) => ChapterScreen(
                              e,
                              nodeChildren[index].noddes,
                              onScreenHideButtonPressed),
                        );
                      }
                      Navigator.of(context).push(route);
                    }),
                Divider(
                  height: 1.0,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ScanScreen extends StatefulWidget {
  final BuildContext menuScreenContext;
  final Function onScreenHideButtonPressed;
  final bool hideStatus;
  const ScanScreen(
      {Key key,
      this.menuScreenContext,
      this.onScreenHideButtonPressed,
      this.hideStatus = false})
      : super(key: key);
  @override
  _ScanScreenState createState() => _ScanScreenState(
      this.menuScreenContext, this.onScreenHideButtonPressed, this.hideStatus);
}

class _ScanScreenState extends State<ScanScreen> {
  _ScanScreenState(
      this.menuScreenContext, this.onScreenHideButtonPressed, this.hideStatus);

  final BuildContext menuScreenContext;
  final Function onScreenHideButtonPressed;
  final bool hideStatus;
  final artnumintController = TextEditingController();

  void _goScan(context, context2) async {
    var route =
        MaterialPageRoute(builder: (BuildContext context2) => ScanScanScreen());
    final _scanBarcode = await Navigator.of(context2).push(route);
    if (_scanBarcode.toString() != 'null')
      checkItem(context2, _scanBarcode.toString());
  }

  void _addItem() async {
    var route = MaterialPageRoute(
      builder: (BuildContext context) => ScanAddScreen(),
    );
    final result = await Navigator.of(context).push(route);
    if (result != null) checkItem(context, result);
  }

  void _toCart() {
    var c = 0;
    for (var b in basketScanned) {
      if (b.status > -1) {
        b.status = 0;
        c = basketChecked.indexWhere((e) => e.artnumint == b.artnumint);
        if (c == -1) {
          basketChecked.add(b);
          globals.basketCounter.value++;
        } else {
          basketChecked[c].artqty += b.artqty;
          globals.basketCounter.value++;
          globals.basketCounter.value--;
        }
      }
    }
    basketScanned = [];
    globals.scanCounter.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          titleSpacing: 0,
          title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ElevatedButton.icon(
                  icon: Icon(Icons.photo_camera),
                  label: Text(AppLocalizations.of(context).scan),
                  onPressed: () {
                    _goScan(menuScreenContext, context);
                  },
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.keyboard),
                  label: Text(AppLocalizations.of(context).input),
                  onPressed: () {
                    _addItem();
                  },
                ),
/*                ElevatedButton.icon(
                  icon: Icon(Icons.add_shopping_cart_outlined),
                  label: Text(AppLocalizations.of(context).tocart),
                  onPressed: () {
                    _toCart();
                  },
                ),
                */
              ]),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        floatingActionButton: FloatingActionButton(
          tooltip: AppLocalizations.of(context).tocart,
          mini: true,
          onPressed: () {
            _toCart();
          },
          child: Icon(Icons.add_shopping_cart_outlined),
          backgroundColor: Colors.red,
        ),
        body: Builder(builder: (BuildContext context) {
          return ValueListenableBuilder(
            valueListenable: globals.scanCounter,
            builder: (BuildContext context, int value, Widget child) {
              return Container(
                padding: EdgeInsets.only(top: 10.0, bottom: 60),
                child: ListView.builder(
                  itemCount: basketScanned.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Dismissible(
                      onDismissed: (DismissDirection direction) {
                        setState(() {
                          basketScanned.removeAt(index);
                        });
                      },
                      secondaryBackground: Container(
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context).delete,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        color: Colors.red,
                      ),
                      key: UniqueKey(),
                      direction: DismissDirection.endToStart,
                      background: Container(),
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            title: Row(children: <Widget>[
                              Stack(clipBehavior: Clip.hardEdge, children: <
                                  Widget>[
                                FadeInImage(
                                  imageErrorBuilder: (BuildContext context,
                                      Object exception, StackTrace stackTrace) {
                                    //print('Error Handler');
                                    return Container(
                                      width: 64.0,
                                      height: 64.0,
                                      child:
                                          Image.asset('images/nopicture.jpg'),
                                    );
                                  },
                                  placeholder: AssetImage('images/pixel.gif'),
                                  image: NetworkImage(basketScanned[index]
                                              .artimg ==
                                          ''
                                      ? 'https://' +
                                          approShop +
                                          '.catbuilder.info/showcase/img/nopicture.jpg'
                                      : basketScanned[index].artimg),
                                  fit: BoxFit.contain,
                                  height: 64.0 * approThumbSizeRatio,
                                  width: 64.0 * approThumbSizeRatio,
                                ),
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  child: ValueListenableBuilder(
                                      valueListenable: globals.checkoutRefresh,
                                      builder: (BuildContext context,
                                          bool value, Widget child) {
                                        return basketScanned[index].status == 0
                                            ? Text('')
                                            : basketScanned[index].status == 1
                                                ? Icon(
                                                    Icons.check_box,
                                                    color: Colors.green,
                                                    size: 22.0,
                                                  )
                                                : Icon(
                                                    Icons.cancel,
                                                    color: Colors.red,
                                                    size: 22.0,
                                                  );
                                      }),
                                ),
                              ]),
                              SizedBox(width: 10.0),
                              Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(basketScanned[index].artdes),
                                      ElevatedButton(
                                        onPressed: () async {
                                          await getNodePath(
                                              basketScanned[index].nodnum,
                                              basketScanned[index].repcod,
                                              context);
                                          if (currentNodePath != '') {
                                            mainTab.jumpToTab(1);
                                            if (approTreeScreen
                                                    .currentContext ==
                                                null) {
                                              await Future.delayed(
                                                  const Duration(
                                                      milliseconds: 100),
                                                  () {});
                                            }
                                            final _context =
                                                approTreeScreen.currentContext;
                                            final _name = '/tree';
                                            if (_context != null) {
                                              Navigator.of(_context).popUntil(
                                                  ModalRoute.withName("/tree"));
                                            }
                                            await syncNode(
                                                treeRoot,
                                                _name,
                                                _context,
                                                onScreenHideButtonPressed,
                                                1,
                                                basketScanned[index].artnumint);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                            primary: myTheme
                                                .toggleButtonsTheme.color,
                                            visualDensity:
                                                VisualDensity.compact,
                                            textStyle: TextStyle(
                                                fontSize:
                                                    approDataTextSize * 1.0)),
                                        child: Text(
                                          basketScanned[index].artnumint,
                                        ),
                                      ),
                                      /*Text(basketScanned[index].artnumint,
                                      style: TextStyle(
                                        color: globals.artnumintColor,
                                      ))*/
                                    ]),
                              ),
                            ]),
                            // onTap: () {},
                          ),
                          ListTile(
                            title: basketScanned[index].status == -1
                                ? SizedBox(
                                    height: 42.0,
                                    child: Text(
                                        AppLocalizations.of(context).notfound))
                                : Row(children: <Widget>[
                                    SizedBox(
                                      width: 250,
                                      child: TouchSpin2(
                                        value: basketScanned[index].artqty,
                                        min: 1,
                                        max: 10000,
                                        step: 1,
                                        //                         displayFormat: ,
                                        textStyle: TextStyle(fontSize: 16),
                                        iconSize: 24.0,
                                        showStockIcon: approShowStockIcon,
                                        artnumint:
                                            basketScanned[index].artnumint,
                                        addIcon: Icon(Icons.add_circle_outline),
                                        subtractIcon:
                                            Icon(Icons.remove_circle_outline),
                                        iconActiveColor: Colors.red,
                                        iconDisabledColor: Colors.grey,
                                        iconPadding: EdgeInsets.all(2),
                                        onChanged: (val) {
                                          basketScanned[index].artqty = val;
                                        },
                                        enabled: true,
                                      ),
                                    ),
                                  ]),
                          ),
                          Divider(
                            height: 1.0,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        }));
  }
}

class ScanScanScreen extends StatefulWidget {
  ScanScanScreen();
  @override
  _ScanScanScreen createState() => _ScanScanScreen();
}

class _ScanScanScreen extends State<ScanScanScreen> {
  _ScanScanScreen();

  ScanController controller = ScanController();
  bool _torch = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
        tooltip: AppLocalizations.of(context).tocart,
        mini: true,
        onPressed: () {
          controller.toggleTorchMode();
          setState(() {
            _torch = !_torch;
          });
        },
        child: _torch
            ? Icon(Icons.flash_on_outlined)
            : Icon(Icons.flash_off_outlined),
        backgroundColor: Colors.red,
      ),
      appBar: AppBar(
          title: Text(AppLocalizations.of(context).scan,
              style: TextStyle(fontSize: 14.0))),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: ScanView(
          controller: controller,
          scanAreaScale: .7,
          scanLineColor: Colors.green.shade400,
          onCapture: (data) {
            Navigator.pop(context, data);
          },
        ),
      ),
    );
  }
}

class ScanAddScreen extends StatefulWidget {
  ScanAddScreen();
  @override
  _ScanAddScreen createState() => _ScanAddScreen();
}

class _ScanAddScreen extends State<ScanAddScreen> {
  _ScanAddScreen();

  final artnumintController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Text(AppLocalizations.of(context).input,
              style: TextStyle(fontSize: 14.0))),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 15.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: CupertinoTextField(
              prefix: Text(AppLocalizations.of(context).itemno),
              controller: artnumintController,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              clearButtonMode: OverlayVisibilityMode.editing,
              keyboardType: TextInputType.text,
              autocorrect: false,
              autofocus: true,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 0,
                    color: CupertinoColors.inactiveGray,
                  ),
                ),
              ),
              placeholder: AppLocalizations.of(context).reqval,
              onEditingComplete: () {
                Navigator.pop(context, artnumintController.text);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BasketScreen extends StatefulWidget {
  const BasketScreen(
      {Key key,
      this.menuScreenContext,
      this.onScreenHideButtonPressed,
      this.hideStatus = false})
      : super(key: key);
  final BuildContext menuScreenContext;
  final Function onScreenHideButtonPressed;
  final bool hideStatus;
  @override
  _BasketScreen createState() =>
      _BasketScreen(menuScreenContext, onScreenHideButtonPressed, hideStatus);
}

class _BasketScreen extends State<BasketScreen> {
  _BasketScreen(
      this.menuScreenContext, this.onScreenHideButtonPressed, this.hideStatus);
  final BuildContext menuScreenContext;
  final Function onScreenHideButtonPressed;
  final bool hideStatus;

  var _storage = new BasketStorage();

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
        floatingActionButton: FloatingActionButton(
          tooltip: AppLocalizations.of(context).send,
          mini: true,
          onPressed: () {
            if (basketChecked.indexWhere((b) => b.status == 0) > -1) {
              final snackBar = SnackBar(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                behavior: SnackBarBehavior.fixed,
                content: Text(AppLocalizations.of(context).mustcheckbasket),
                action: SnackBarAction(
                  label: AppLocalizations.of(context).hide,
                  onPressed: () {},
                ),
              );
              scaffoldMessengerKey.currentState.showSnackBar(snackBar);
              return;
            }
            var route = MaterialPageRoute(
              settings: RouteSettings(name: '/send'),
              builder: (BuildContext context) => BasketSendScreen(),
            );
            Navigator.of(context).push(route);
          },
          child: Icon(Icons.send),
          backgroundColor: Colors.red,
        ),
        appBar: AppBar(
          //leading: ,
          titleSpacing: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ElevatedButton.icon(
                icon: Icon(Icons.check),
                label: Text(AppLocalizations.of(context).checkout),
                onPressed: () {
                  checkBasket(context, -1);
                },
              ),
              /*ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text(AppLocalizations.of(context)
                    .save), //Text(AppLocalizations.of(context).save),
                onPressed: () {
                  _storage.writeBasket(basketChecked);
                },
              ),*/
              ElevatedButton.icon(
                icon: Icon(AntDesign.pdffile1, size: 20.0),
                label: Text(''), //Text(AppLocalizations.of(context).save),
                onPressed: () async {
                  if (basketChecked.indexWhere((b) => b.status == 0) > -1) {
                    final snackBar = SnackBar(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      behavior: SnackBarBehavior.fixed,
                      content:
                          Text(AppLocalizations.of(context).mustcheckbasket),
                      action: SnackBarAction(
                        label: AppLocalizations.of(context).hide,
                        onPressed: () {},
                      ),
                    );
                    scaffoldMessengerKey.currentState.showSnackBar(snackBar);
                    return;
                  }
                  await sendBasket(context, 'print', 'basket', '', '', false);

                  List<String> myUrl = [''];
                  myUrl[0] = 'https://' +
                      approShop +
                      '.catbuilder.info/catalogs/pdf/' +
                      approUser +
                      '-basket.pdf';
                  final route = MaterialPageRoute(
                    builder: (BuildContext context) =>
                        PdfScreen(myUrl, AppLocalizations.of(context).cart),
                  );
                  Navigator.of(context).push(route);
                },
              ),
            ],
          ),
        ),
        body: Builder(builder: (BuildContext context) {
          return ValueListenableBuilder(
              valueListenable: globals.basketCounter,
              builder: (BuildContext context, int value, Widget child) {
                return Container(
                  padding: EdgeInsets.only(top: 10.0, bottom: 60),
                  child: ListView.builder(
                    itemCount: basketChecked.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Dismissible(
                        onDismissed: (DismissDirection direction) {
                          setState(() {
                            basketChecked.removeAt(index);
                            _storage.writeBasket(basketChecked);
                            globals.basketCounter.value = basketChecked.length;
                          });
                        },
                        secondaryBackground: Container(
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context).delete,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          color: Colors.red,
                        ),
                        key: UniqueKey(),
                        direction: DismissDirection.endToStart,
                        background: Container(),
                        child: Column(children: <Widget>[
                          ListTile(
                              title: Row(
                            children: <Widget>[
                              GestureDetector(
                                  onTap: () async {
                                    var _product = Product('');
                                    await getProductItem(
                                        '',
                                        basketChecked[index].repcod +
                                            '/' +
                                            basketChecked[index].nodnum +
                                            '.asp',
                                        _product);

                                    var route = MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          ItemDetailScreen(
                                        itemSelected: basketChecked[index],
                                        productSelected: _product,
                                      ),
                                    );
                                    Navigator.of(context).push(route);
                                  },
                                  child: Stack(
                                      //overflow: Overflow.visible,
                                      clipBehavior: Clip.hardEdge,
                                      children: <Widget>[
                                        FadeInImage(
                                          imageErrorBuilder:
                                              (BuildContext context,
                                                  Object exception,
                                                  StackTrace stackTrace) {
                                            //print('Error Handler');
                                            return Container(
                                              width: 64.0 * approThumbSizeRatio,
                                              height:
                                                  64.0 * approThumbSizeRatio,
                                              child: Image.asset(
                                                  'images/nopicture.jpg'),
                                            );
                                          },
                                          placeholder:
                                              AssetImage('images/pixel.gif'),
                                          image: NetworkImage(basketChecked[
                                                          index]
                                                      .artimg
                                                      .indexOf('http') >
                                                  -1
                                              ? basketChecked[index].artimg
                                              : 'https://' +
                                                  approShop +
                                                  '.catbuilder.info/catalogs/thumbs/' +
                                                  (basketChecked[index]
                                                              .artimg ==
                                                          ''
                                                      ? basketChecked[index]
                                                          .nodnum
                                                      : basketChecked[index]
                                                          .artimg) +
                                                  '.jpg'),
                                          fit: BoxFit.contain,
                                          height: 64.0 * approThumbSizeRatio,
                                          width: 64.0 * approThumbSizeRatio,
                                        ),
                                        Positioned(
                                          left: 0,
                                          top: 0,
                                          child: ValueListenableBuilder(
                                              valueListenable:
                                                  globals.checkoutRefresh,
                                              builder: (BuildContext context,
                                                  bool value, Widget child) {
                                                return (basketChecked[index]
                                                            .status ==
                                                        0
                                                    ? Text('')
                                                    : basketChecked[index]
                                                                .status ==
                                                            1
                                                        ? Icon(
                                                            Icons.check_box,
                                                            color: Colors.green,
                                                            size: 20.0,
                                                          )
                                                        : Icon(
                                                            Icons.cancel,
                                                            color: Colors.red,
                                                            size: 20.0,
                                                          ));
                                              }),
                                        ),
/*                                        PositionedDirectional(
                                            start: 50,
                                            bottom: -5,
                                            child: Icon(
                                              Icons.zoom_in_outlined,
                                              size: 24,
                                              color: Colors.grey,
                                            )),

 */
                                      ])),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                    Wrap(
                                        spacing: 2,
                                        runSpacing: 2,
                                        children: <Widget>[
                                          Text(basketChecked[index].artdes),
                                          Text('')
                                        ]),
                                    ElevatedButton(
                                      onPressed: () async {
                                        await getNodePath(
                                            basketChecked[index].nodnum,
                                            basketChecked[index].repcod,
                                            context);
                                        if (currentNodePath != '') {
                                          mainTab.jumpToTab(1);
                                          if (approTreeScreen.currentContext ==
                                              null) {
                                            await Future.delayed(
                                                const Duration(
                                                    milliseconds: 100),
                                                () {});
                                          }
                                          final _context =
                                              approTreeScreen.currentContext;
                                          final _name = '/tree';
                                          if (_context != null) {
                                            Navigator.of(_context).popUntil(
                                                ModalRoute.withName("/tree"));
                                          }
                                          await syncNode(
                                              treeRoot,
                                              _name,
                                              _context,
                                              onScreenHideButtonPressed,
                                              1,
                                              basketChecked[index].artnumint);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                          primary:
                                              myTheme.toggleButtonsTheme.color,
                                          visualDensity: VisualDensity.compact,
                                          textStyle: TextStyle(
                                              fontSize:
                                                  approDataTextSize * 1.0)),
                                      child: Text(
                                        basketChecked[index].artnumint,
                                      ),
                                    )
                                  ])),
                            ],
                          )),
                          ListTile(
                            title: SizedBox(
                              width: 180,
                              child: TouchSpin2(
                                value: basketChecked[index].artqty,
                                scrollVisible: false,
                                min: 1,
                                max: 10000,
                                step: 1,
                                //                         displayFormat: ,
                                textStyle: TextStyle(fontSize: 16),
                                iconSize: 24.0,
                                leftPadding: MediaQuery.of(context).size.width -
                                            (64.0 * approThumbSizeRatio) <
                                        220
                                    ? MediaQuery.of(context).size.width - 220
                                    : 64.0 * approThumbSizeRatio,
                                addIcon: Icon(Icons.add_circle_outline),
                                subtractIcon: Icon(Icons.remove_circle_outline),
                                iconActiveColor: Colors.red,
                                iconDisabledColor: Colors.grey,
                                iconPadding: EdgeInsets.all(2),
                                onChanged: (val) {
                                  basketChecked[index].artqty = val;
                                },
                                enabled: true,
                              ),
                            ),
                          ),
                          ValueListenableBuilder(
                              valueListenable: globals.checkoutRefresh,
                              builder: (BuildContext context, bool value,
                                  Widget child) {
                                return basketChecked[index].status == 1
                                    ? ListTile(
                                        leading: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            minWidth: MediaQuery.of(context)
                                                            .size
                                                            .width -
                                                        (59.0 *
                                                            approThumbSizeRatio) <
                                                    220
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    220
                                                : 59.0 * approThumbSizeRatio,
                                            maxWidth: MediaQuery.of(context)
                                                            .size
                                                            .width -
                                                        (59.0 *
                                                            approThumbSizeRatio) <
                                                    220
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    220
                                                : 59.0 * approThumbSizeRatio,
                                          ),
                                        ),
                                        title: Wrap(runSpacing: 0, children: <
                                            Widget>[
                                          SizedBox(
                                              height: 32,
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    basketChecked[index]
                                                                .artoul
                                                                .indexOf('|') ==
                                                            -1
                                                        ? Text(AppLocalizations
                                                                    .of(context)
                                                                .orderunit +
                                                            ': ' +
                                                            basketChecked[index]
                                                                .artorduni)
                                                        : OrderUnitWidget(
                                                            basketChecked[
                                                                index],
                                                            true,
                                                            basketChecked[index]
                                                                .artnumint),

/*                                                    IconButton(
                                                      padding: EdgeInsets.zero,
                                                      icon: (basketChecked[
                                                                      index]
                                                                  .status ==
                                                              1
                                                          ? Icon(
                                                              Icons
                                                                  .zoom_in_outlined,
                                                              color:
                                                                  Colors.grey,
                                                              size: 24)
                                                          : Text('')),
                                                      onPressed: () {
                                                        if (basketChecked[index]
                                                                .status ==
                                                            1) {
                                                          var route =
                                                              MaterialPageRoute(
                                                            builder: (BuildContext
                                                                    context) =>
                                                                BasketDetailScreen(
                                                                    artidx:
                                                                        index),
                                                          );
                                                          Navigator.of(context)
                                                              .push(route);
                                                        }
                                                      },
                                                    )

 */
                                                  ])),
                                          basketChecked[index].artstofla == 'x'
                                              ? Container()
                                              : SizedBox(
                                                  height: 20,
                                                  child: Row(children: <Widget>[
                                                    basketChecked[index]
                                                                .artstofla ==
                                                            ''
                                                        ? basketChecked[index]
                                                                    .artsto ==
                                                                ''
                                                            ? Text('')
                                                            : Text(AppLocalizations.of(
                                                                        context)
                                                                    .stock +
                                                                ': ' +
                                                                basketChecked[
                                                                        index]
                                                                    .artsto)
                                                        : basketChecked[index]
                                                                    .artstofla ==
                                                                'green'
                                                            ? Wrap(
                                                                children: <
                                                                    Widget>[
                                                                    Text(AppLocalizations.of(context)
                                                                            .stock +
                                                                        ': '),
                                                                    Icon(
                                                                        Icons
                                                                            .circle,
                                                                        color: Colors
                                                                            .green,
                                                                        size: (2 +
                                                                                approDataTextSize) *
                                                                            1.0)
                                                                  ])
                                                            : basketChecked[index]
                                                                        .artstofla ==
                                                                    'yellow'
                                                                ? Wrap(
                                                                    children: <
                                                                        Widget>[
                                                                        Text(AppLocalizations.of(context).stock +
                                                                            ': '),
                                                                        Icon(
                                                                            Icons
                                                                                .circle,
                                                                            color:
                                                                                Colors.orange,
                                                                            size: (2 + approDataTextSize) * 1.0)
                                                                      ])
                                                                : Wrap(
                                                                    children: <
                                                                        Widget>[
                                                                        Text(AppLocalizations.of(context).stock +
                                                                            ': '),
                                                                        Icon(
                                                                            Icons
                                                                                .circle,
                                                                            color:
                                                                                Colors.red,
                                                                            size: (2 + approDataTextSize) * 1.0)
                                                                      ])
                                                  ])),
                                          approShowPrice == false ||
                                                  basketChecked[index].artpri ==
                                                      'x'
                                              ? Container()
                                              : SizedBox(
                                                  height: 20,
                                                  child: Row(children: <Widget>[
                                                    Text(AppLocalizations.of(
                                                                context)
                                                            .price +
                                                        ': '),
                                                    Text(basketChecked[index]
                                                                .artpri ==
                                                            basketChecked[index]
                                                                .artbes
                                                        ? basketChecked[index]
                                                                .artbes +
                                                            ' ' +
                                                            basketChecked[index]
                                                                .artuni
                                                        : basketChecked[index]
                                                                .artpri +
                                                            ' / ' +
                                                            basketChecked[index]
                                                                .artbes +
                                                            ' ' +
                                                            basketChecked[index]
                                                                .artuni)
                                                  ]))
                                        ]),
                                      )
                                    : Container();
                              }),
                          Divider(
                            height: 6.0,
                          ),
                        ]),
                        // onTap: () {},
                      );
                    },
                  ),
                );
              });
        }));
  }
}

class BasketDetailScreen extends StatelessWidget {
  const BasketDetailScreen(
      {Key key,
      this.menuScreenContext,
      this.onScreenHideButtonPressed,
      this.hideStatus = false,
      this.artidx = 0})
      : super(key: key);
  final BuildContext menuScreenContext;
  final Function onScreenHideButtonPressed;
  final bool hideStatus;
  final int artidx;

  void _showPDF(context) async {
    List<String> myUrl = [''];
    if (approPDFSuffix == '') {
      myUrl[0] = basketChecked[artidx].nodnum + '.pdf';
    } else {
      myUrl[0] = basketChecked[artidx].nodnum +
          approPDFSuffix +
          approLanguage +
          '.pdf';
    }
    myUrl[0] = 'https://' +
        approShop +
        '.catbuilder.info/catalogs/' +
        basketChecked[artidx].repcod +
        '/' +
        myUrl[0];
    //print(myUrl);
    var route = MaterialPageRoute(
      builder: (BuildContext context) =>
          PdfScreen(myUrl, basketChecked[artidx].artdes),
    );
    Navigator.of(context).push(route);
  }

  @override
  Widget build(BuildContext context) {
    var futureBuilder = FutureBuilder(
      future: getItemDetail(artidx, 'basket'),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          default:
            if (snapshot.hasError) {
              Future.delayed(Duration(milliseconds: 200)).then((v) {
                restoreShopConnexion(context, '2:Security');
              });
              return Scaffold(
                  appBar: AppBar(),
                  backgroundColor: Colors.white,
                  body: Center(child: Container()));
            } else
              return createListViewDetail(context, snapshot);
        }
      },
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
//            crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
            Expanded(
                child: Text(
              basketChecked[artidx].artdes,
              style: TextStyle(fontSize: 14.0),
              overflow: TextOverflow.ellipsis,
              softWrap: true,
            )),
            approPDFSuffix == 'x'
                ? Container()
                : IconButton(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerRight,
                    icon: Icon(
                      Icons.info_outline,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _showPDF(context);
                    },
                  ),
          ])),
      body: futureBuilder,
    );
  }

  Widget createListViewDetail(BuildContext context, AsyncSnapshot snapshot) {
    BasketDetail value = snapshot.data;
    //print(value.artimg);
    //print(value.nodimg);
    return Container(
      padding: EdgeInsets.only(top: 5.0, bottom: 60, left: 5, right: 5),
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: value.nodimg.length,
          itemBuilder: (BuildContext context, int index) {
            return Center(
                child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 128,
                minHeight: 128,
                maxWidth: MediaQuery.of(context).size.width,
                maxHeight: 3000,
              ),
              child: FadeInImage(
                imageErrorBuilder: (BuildContext context, Object exception,
                    StackTrace stackTrace) {
                  //print('Error Handler');
                  return Container(
                    width: 100.0,
                    height: 100.0,
                    child: Image.asset('images/nopicture.jpg'),
                  );
                },
                placeholder: AssetImage('images/pixel.gif'),
                image: NetworkImage(value.nodimg[index], scale: 1),
                fit: BoxFit.contain,
                //height: 250.0,
                //width: MediaQuery.of(context).size.width,
              ),
            ));
          }),
    );
  }
}

class BasketSendScreen extends StatelessWidget {
  const BasketSendScreen({Key key}) : super(key: key);

  sendBasketBasket(context) async {
    if (await sendBasket(context, 'basket', 'basket', '', '', false)) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    }
  }

  sendOrder(context) async {
    var myXML = await getOrderInfo(context);
    if (myXML != '') {
      var route = MaterialPageRoute(
        settings: RouteSettings(name: '/send/order'),
        builder: (BuildContext context) => OrderFormXml(myXML),
      );
      Navigator.of(context).push(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
//            crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
            Text(AppLocalizations.of(context).send,
                style: TextStyle(fontSize: 14.0)),
          ])),
      body: Container(
        padding: EdgeInsets.only(top: 5.0, bottom: 60),
        child: Center(
          child: ListView(children: <Widget>[
            ListTile(
              title: Text(AppLocalizations.of(context).sendfav),
              trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                var route = MaterialPageRoute(
                  settings: RouteSettings(name: '/send/favorite'),
                  builder: (BuildContext context) => SendFavoriteScreen(),
                );
                Navigator.of(context).push(route);
              },
            ),
            ListTile(
              title: Text(AppLocalizations.of(context).sendbas),
              onTap: () {
                sendBasketBasket(context);
              },
            ),
            ListTile(
              title: Text(AppLocalizations.of(context).sendorder),
              trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16),
              enabled: approCanOrder,
              onTap: () {
                sendOrder(context);
              },
            ),
          ]),
        ),
      ),
    );
  }
}

class SendFavoriteScreen extends StatefulWidget {
  SendFavoriteScreen();
  @override
  _SendFavoriteScreen createState() => _SendFavoriteScreen();
}

class _SendFavoriteScreen extends State<SendFavoriteScreen> {
  _SendFavoriteScreen();
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final mailController = TextEditingController();
  final comController = TextEditingController();

  List<CompanyUser> companyUser = [];
  int _index;
  String _recipient = '';
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool _copyForMe = false;
  bool _notForMe = false;

  sendNamedFavorite(context, b) async {
    if (await sendBasket(context, 'favorite', nameController.text,
        mailController.text, comController.text, b)) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    }
  }

  _setPref() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setString(approShop + '-recipient', mailController.text);
  }

  _getPref() async {
    final SharedPreferences prefs = await _prefs;
    _recipient = prefs.get(approShop + '-recipient');
    if (_recipient.toString() == 'null' || _recipient == '') {
      _recipient = approUser;
    }
    mailController.text = _recipient;
    setState(() {
      _notForMe = (_recipient != approUser);
    });
  }

  _initPicker() async {
    companyUser = await getCompanyUser();
    _index = companyUser.indexWhere((e) => e.usemai == _recipient);
    if (_index == -1) _index = 0;
  }

  Future<void> _selectedUser(BuildContext context) async {
    await showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
          padding: EdgeInsets.only(top: 0.0, bottom: 0),
          height: 200,
          child: CupertinoPicker(
            backgroundColor: Colors.white,
            itemExtent: 34,
            scrollController: FixedExtentScrollController(initialItem: _index),
            onSelectedItemChanged: (int value) {
              mailController.text = companyUser[value].usemai;
              _index = value;
              _setPref();
              setState(() {
                _notForMe = (companyUser[value].usemai != approUser);
              });
            },
            children: companyUser
                .map(
                  (e) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 8),
                      child: Text(
                        e.usemai,
                        style: TextStyle(fontSize: 14),
                      )),
                )
                .toList(),
          )),
    );
  }

  @override
  void initState() {
    _getPref();
    super.initState();
    _initPicker();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).sendfavtit,
            style: TextStyle(fontSize: 14.0)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 0, bottom: 300),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              //SizedBox(height: 5.0),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: AppLocalizations.of(context).namefavh,
                    )),
              ),
              /*Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: CupertinoTextField(
                  prefix: Text(AppLocalizations.of(context).namefav),
                  controller: nameController,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  clearButtonMode: OverlayVisibilityMode.editing,
                  keyboardType: TextInputType.text,
                  autocorrect: false,
                  autofocus: true,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 0,
                        color: CupertinoColors.inactiveGray,
                      ),
                    ),
                  ),
                  placeholder: AppLocalizations.of(context).namefavh,
                ),
              ),*/
              //             SizedBox(height: 5.0),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: GestureDetector(
                  onTap: () => _selectedUser(context),
                  child: AbsorbPointer(
                    child: TextField(
                        controller: mailController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: AppLocalizations.of(context).email,
                        )),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                child: _notForMe
                    ? ListTile(
                        title: Text(AppLocalizations.of(context).keepcopy),
                        trailing: Switch(
                            value: _copyForMe,
                            onChanged: (bool value) {
                              setState(() {
                                _copyForMe = value;
                              });
                            }),
                      )
                    : Container(),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: TextField(
                    keyboardType: TextInputType.multiline,
                    controller: comController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: AppLocalizations.of(context).addmessage,
                    )),
              ),
              SizedBox(height: 15.0),
              Center(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.send),
                  label: Text(AppLocalizations.of(context).send),
                  onPressed: () {
                    sendNamedFavorite(context, _copyForMe);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SendOrderScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
//            crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
            Text('Send order'),
          ])),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 5.0, bottom: 60),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 25.0),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: CupertinoTextField(
                  prefix: Text('Name'),
                  controller: nameController,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  clearButtonMode: OverlayVisibilityMode.editing,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 0,
                        color: CupertinoColors.inactiveGray,
                      ),
                    ),
                  ),
                  placeholder: 'Name',
                ),
              ),
              SizedBox(height: 20.0),
              Center(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.send),
                  label: Text("Order now"),
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/', (Route<dynamic> route) => false);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CheckedWidget extends StatefulWidget {
  CheckedWidget(this.basrow);
  final BasketDetail basrow;
  @override
  _CheckedWidgetState createState() => _CheckedWidgetState(basrow);
}

class _CheckedWidgetState extends State<CheckedWidget> {
  _CheckedWidgetState(this.basrow);
  final BasketDetail basrow;
  bool _isChecked = false;
  var _storage = new BasketStorage();
  @override
  void initState() {
    super.initState();

    for (var b in basketChecked) {
      if (b.artnumint == basrow.artnumint) {
        _isChecked = true;
        //b.newchecked = false;
        break;
      }
    }
    //basketChecked
    //  .forEach((e) => { if(e.artnum == basrow.artnum) {_isChecked = true }});
  }

  void _toggleFavorite() {
    if (_isChecked) {
      for (var i = 0; i < basketChecked.length; i++) {
        if (basketChecked[i].artnumint == basrow.artnumint) {
          basketChecked.removeAt(i);
          break;
        }
      }
    } else {
      basketChecked.add(basrow);
      basketChecked[basketChecked.length - 1].newchecked = true;
    }
    _storage.writeBasket(basketChecked);
    globals.basketCounter.value = basketChecked.length;
    globals.favoriteRefresh.value = !globals.favoriteRefresh.value;
    setState(() {
      _isChecked = !_isChecked;
    });
  }

  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(0),
          child: IconButton(
            padding: EdgeInsets.all(0),
            alignment: Alignment.centerRight,
            icon: (_isChecked
                ? Icon(
                    Icons.shopping_cart_rounded,
                    color: Colors.red,
                  )
                : Icon(Icons.shopping_cart_outlined, color: Colors.grey[350])),
            onPressed: _toggleFavorite,
          ),
        ),
      ],
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen(
      {Key key,
      this.menuScreenContext,
      this.onScreenHideButtonPressed,
      this.hideStatus = false})
      : super(key: key);
  final BuildContext menuScreenContext;
  final Function onScreenHideButtonPressed;
  final bool hideStatus;

  createState() =>
      _SearchScreen(menuScreenContext, onScreenHideButtonPressed, hideStatus);
}

class _SearchScreen extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  _SearchScreen(
      this.menuScreenContext, this.onScreenHideButtonPressed, this.hideStatus);
  final BuildContext menuScreenContext;
  final Function onScreenHideButtonPressed;
  final bool hideStatus;

  TextEditingController _searchTextController = new TextEditingController();
  FocusNode _searchFocusNode = FocusNode();
  AnimationController _animationController;
  Animation _animation;
  // String _scanBarcode = 'Unknown';

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
      reverseCurve: Curves.easeInOut,
    );
    _searchFocusNode.addListener(() {
      if (!_animationController.isAnimating) {
        _animationController.forward();
      }
    });
  }

  void _cancelSearch() {
    _searchTextController.clear();
    _searchFocusNode.unfocus();
    _animationController.reverse();
    searchNode('', context);
  }

  void _goScan() {
    _cancelSearch();
    Future.delayed(Duration(milliseconds: 200)).then((v) {
      _goScan2();
    });
  }

  void _goScan2() async {
    var route = MaterialPageRoute(
      settings: RouteSettings(name: 'scan'),
      builder: (BuildContext context) => ScanScanScreen(),
    );
    final _scanBarcode = await Navigator.of(context).push(route);
    //print('codebare:'+_scanBarcode.toString());
    if (_scanBarcode.toString() != 'null')
      _searchTextController.text = _scanBarcode.toString();
    searchNode(_searchTextController.text, context);
  }

  void _clearSearch() async {
    _goScan();
    //_searchTextController.clear();
  }

  void _goSearch(s) {
    searchNode(_searchTextController.text, context);
  }

  Widget build(BuildContext context) {
    //_scanBarcode = AppLocalizations.of(context).unknown;

    return Scaffold(
      backgroundColor: Colors.white,
      body: ValueListenableBuilder(
        valueListenable: globals.searchRefresh,
        builder: (BuildContext context, bool value, Widget child) {
          return Container(
            padding: EdgeInsets.only(top: 0.0, bottom: 60),
            child: ListView.builder(
              itemCount: resultNode.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: <Widget>[
                    ListTile(
                      title: Row(children: <Widget>[
                        FadeInImage(
                          imageErrorBuilder: (BuildContext context,
                              Object exception, StackTrace stackTrace) {
                            //print('Error Handler');
                            return Container(
                              width: 64.0,
                              height: 64.0,
                              child: Image.asset('images/nopicture.jpg'),
                            );
                          },
                          placeholder: AssetImage('images/pixel.gif'),
                          image: NetworkImage('https://' +
                              approShop +
                              '.catbuilder.info' +
                              resultNode[index].nodimg),
                          fit: BoxFit.contain,
                          height: 64.0 * approThumbSizeRatio,
                          width: 64.0 * approThumbSizeRatio,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(child: Text(resultNode[index].noddes)),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ]),
                      onTap: () {
                        var route = MaterialPageRoute(
                          builder: (BuildContext context) =>
                              FavoriteDetailScreen(
                            basdes: resultNode[index].noddes,
                            basval: resultNode[index].nodnum,
                            basurl: resultNode[index].nodurl,
                            onScreenHideButtonPressed:
                                onScreenHideButtonPressed,
                            synctoc: true,
                          ),
                        );
                        Navigator.of(context).push(route);
                      },
                    ),
                    Divider(
                      height: 1.0,
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
      appBar: AppBar(
        titleSpacing: 0,
        flexibleSpace: CupertinoNavigationBar(
          backgroundColor: myTheme.bottomAppBarColor,
          middle: IOSSearchBar(
            controller: _searchTextController,
            focusNode: _searchFocusNode,
            animation: _animation,
            onCancel: _cancelSearch,
            onClear: _clearSearch,
            onSubmit: _goSearch,
          ),
        ),
      ),
    );
  }
}

class ParameterScreen extends StatefulWidget {
  const ParameterScreen({Key key}) : super(key: key);

  @override
  _ParameterScreen createState() => _ParameterScreen();
}

class _ParameterScreen extends State<ParameterScreen> {
  _ParameterScreen();

  int segmentedLanguageValue = approLanguages.indexOf(approLanguage);
  int segmentedDataTextValue = approDataTextSize;
  var mapLanguageSegment = new Map<int, Widget>();
  var mapDataTextSegment = new Map<int, Widget>();
  var _themeProvider;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  void dispose() async {
    super.dispose();
    // _savePref();
  }

  void _savePref() async {
    final SharedPreferences prefs = await _prefs;
    prefs.setInt('datatextsize', approDataTextSize);
    prefs.setDouble('thumbsizeratio', approThumbSizeRatio);
    prefs.setBool(approShop + '-showprice', approShowPrice);
    prefs.setString(approShop + '-language', approLanguage);
  }

  /*((SizeConfig.blockSizeHorizontal <=
  SizeConfig.blockSizeVertical
  ? SizeConfig.blockSizeHorizontal
      : SizeConfig.blockSizeVertical) /
  3.2) *
  */
  void _loadValue() {
    for (var i = 0; i < approLanguages.length; i++) {
      mapLanguageSegment.putIfAbsent(
        i,
        () => Text(approLanguages[i].toUpperCase()),
      );
    }
    mapDataTextSegment.putIfAbsent(
        8,
        () => Icon(
              Icons.text_fields,
              size: 8.0,
            ));
    mapDataTextSegment.putIfAbsent(
        10,
        () => Icon(
              Icons.text_fields,
              size: 10.0,
            ));
    mapDataTextSegment.putIfAbsent(
        12,
        () => Icon(
              Icons.text_fields,
              size: 12.0,
            ));
    mapDataTextSegment.putIfAbsent(
        14,
        () => Icon(
              Icons.text_fields,
              size: 14.0,
            ));
    mapDataTextSegment.putIfAbsent(
        16,
        () => Icon(
              Icons.text_fields,
              size: 16.0,
            ));
    if (![8, 10, 12, 14, 16].contains(segmentedDataTextValue))
      segmentedDataTextValue = 14;

    setState(() {});
  }

  Widget languageControl() {
    return Container(
      width: 300,
      child: CupertinoSlidingSegmentedControl(
          groupValue: segmentedLanguageValue,
//          backgroundColor: myTheme.buttonColor,
          thumbColor: myTheme.toggleableActiveColor,
          children: mapLanguageSegment,
          onValueChanged: (value) {
            setState(() {
              segmentedLanguageValue = value;
              approLanguage = approLanguages[value];
            });
          }),
    );
  }

  Widget dataTextControl() {
    return Container(
      width: 300,
      child: CupertinoSlidingSegmentedControl(
          groupValue: segmentedDataTextValue,
//          backgroundColor: myTheme.buttonColor,
          thumbColor: myTheme.toggleableActiveColor,
          children: mapDataTextSegment,
          onValueChanged: (value) {
            setState(() {
              segmentedDataTextValue = value;
              approDataTextSize = value;

              _themeProvider.setTheme(myTheme.copyWith(
                  textTheme: myTheme.textTheme.copyWith(
                      subtitle1: myTheme.textTheme.subtitle1.copyWith(
                fontSize: value * 1.0,
              ))));
            });
          }),
    );
  }

  Widget thumbRatioControl() {
    return Container(
      width: 300,
      child: CupertinoSlider(
          value: approThumbSizeRatio,
          min: 0.8,
          max: 2.0,
          divisions: 12,
          onChanged: (selectedValue) {
            setState(() {
              approThumbSizeRatio = selectedValue;
              _themeProvider.setTheme(myTheme.copyWith(
                  textTheme: myTheme.textTheme.copyWith(
                      subtitle1: myTheme.textTheme.subtitle1.copyWith(
                fontSize: approDataTextSize * 1.0,
              ))));
            });
          }),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadValue();
  }

  Widget build(BuildContext context) {
    _themeProvider = Provider.of<ThemeChanger>(context);
    return Scaffold(
      appBar: AppBar(
          title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
//            crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
            Text(AppLocalizations.of(context).parameter,
                style: TextStyle(fontSize: 14.0)),
            IconButton(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerRight,
              icon: Icon(
                Icons.save,
                color: Colors.white,
              ),
              onPressed: () {
                _savePref();
              },
            ),
          ])),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 20.0, left: 10, right: 10),
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: <
              Widget>[
            Center(
              child: approLanguages.length > 1
                  ? Text(AppLocalizations.of(context).datalanguage)
                  : null,
            ),
            SizedBox(height: 10.0),
            Center(child: approLanguages.length > 1 ? languageControl() : null),
            SizedBox(height: 10.0),
            Center(
              child: Text(AppLocalizations.of(context).datatextsize),
            ),
            SizedBox(height: 5.0),
            dataTextControl(),
            SizedBox(height: 20.0),
            Center(
              child: Text(AppLocalizations.of(context).thumbsize),
            ),
            SizedBox(height: 5.0),
            thumbRatioControl(),
            SizedBox(height: 10.0),
            Center(
              child: Text(AppLocalizations.of(context).showprice),
            ),
            Switch(
                value: approShowPrice,
                onChanged: (b) {
                  setState(() {
                    approShowPrice = b;
                  });
                  globals.checkoutRefresh.value =
                      !globals.checkoutRefresh.value;
                })
          ]),
        ),
      ),
    );
  }
}

class GeneralDrawer extends StatelessWidget {
  _launchURL() async {
    var url = 'https://' +
        approShop +
        '.catbuilder.info/catalogs/verify.asp?userlang=' +
        approLanguage +
        '&username=' +
        approUser +
        '&credential=' +
        approCredential +
        '&divmode=basket';
    // +approLanguage;
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(
        Uri.parse(url),
        webViewConfiguration: WebViewConfiguration(
          enableJavaScript: true,
        ),
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(children: <Widget>[
      Container(
          height: MediaQuery.of(context).padding.top +
              AppBar().preferredSize.height,
          child: DrawerHeader(
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  IconButton(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    icon: Icon(
                      Icons.menu,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ]),
            margin: EdgeInsets.only(top: 0.0, bottom: 0.0),
            decoration: BoxDecoration(
              color: myTheme.bottomAppBarColor,
            ),
          )),
      Expanded(
        child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.only(top: 0.0),
            children: <Widget>[
              ListTile(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                leading: Icon(Icons.settings),
                title: Text(AppLocalizations.of(context).parameter),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) {
                      return ParameterScreen();
                    },
                    settings: RouteSettings(
                      name: '/',
                    ),
                  ));

                  //pushNewScreen(context, screen: ParameterScreen());
                },
              ),
              ListTile(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                leading: Icon(Icons.open_in_browser_outlined),
                title: Text(AppLocalizations.of(context).openinbrowser),
                onTap: () {
                  _launchURL();
                },
              ),
              ListTile(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                leading: Icon(Icons.logout),
                title: Text(AppLocalizations.of(context).logout),
                onTap: () async {
                  //_restart();
                  final sstorage = new FlutterSecureStorage();
                  await sstorage.delete(key: approShop);
                  //await sstorage.deleteAll();

                  Navigator.of(context).popAndPushNamed('/');
                  RestartWidget.restartApp(context);
                  //Navigator.pushReplacement( context, MaterialPageRoute(builder: (BuildContext context) => MyApp()) );
                },
              ),
            ]),
      ),
      Container(
          padding: EdgeInsets.all(10),
          height: 85,
          child: Text(
            'Version ' + approVersion,
            style: TextStyle(fontSize: 10.0),
          )),
    ]));
  }
}

class TouchSpin2 extends StatefulWidget {
  final num value;
  final num min;
  final num max;
  final num step;
  final double iconSize;
  final ValueChanged<num> onChanged;
  final NumberFormat displayFormat;
  final Icon subtractIcon;
  final Icon addIcon;
  final EdgeInsetsGeometry iconPadding;
  final TextStyle textStyle;
  final Color iconActiveColor;
  final Color iconDisabledColor;
  final bool enabled;
  final bool scrollVisible;
  final bool showStockIcon;
  final String artnumint;
  final double leftPadding;

  const TouchSpin2(
      {Key key,
      this.value = 1.0,
      this.onChanged,
      this.min = 1.0,
      this.max = 9999999.0,
      this.step = 1.0,
      this.iconSize = 24.0,
      this.displayFormat,
      this.subtractIcon = const Icon(Icons.remove),
      this.addIcon = const Icon(Icons.add),
      this.iconPadding = const EdgeInsets.all(4.0),
      this.textStyle = const TextStyle(fontSize: 24),
      this.iconActiveColor,
      this.iconDisabledColor,
      this.enabled = true,
      this.scrollVisible = true,
      this.showStockIcon = false,
      this.artnumint = '',
      this.leftPadding = 64})
      : super(key: key);

  @override
  _TouchSpinState2 createState() => _TouchSpinState2();
}

class _TouchSpinState2 extends State<TouchSpin2> {
  final GlobalKey expansionKey = GlobalKey();

  var _storage = new BasketStorage();

  num _value;
  String _text;
  BasketDetail _basketDetail =
      BasketDetail('', '', '', false, 1, '', '', '', []);
  bool _edit = false;
  bool _stock = false;
  bool get minusBtnDisabled =>
      _value <= widget.min ||
      _value - widget.step < widget.min ||
      !widget.enabled;

  bool get addBtnDisabled =>
      _value >= widget.max ||
      _value + widget.step > widget.max ||
      !widget.enabled;

  bool get _scrollVisible => widget.scrollVisible;
  bool get _showStockIcon => widget.showStockIcon;
  String get _artnumint => widget.artnumint;

  Future _checkStock(context) async {
    _basketDetail = await checkBasketItem(context, _artnumint, _value);
    //print(_value);
    //print(_basketDetail.artsto);
  }

  @override
  void initState() {
    super.initState();
    _value = widget.value;

    if (_scrollVisible) {
      Future.delayed(Duration(milliseconds: 200)).then((v) {
        if (this.mounted) {
          Scrollable.ensureVisible(context,
              alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
              duration: Duration(milliseconds: 200));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        key: expansionKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _showStockIcon
                    ? ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: widget.leftPadding,
                          maxWidth: widget.leftPadding,
                        ),
                        child: IconButton(
                            icon: _stock
                                ? Icon(Icons.expand_less_outlined,
                                    color: Colors.grey)
                                : Icon(Feather.package),
                            iconSize: 23.0,
                            color: Colors.grey,
                            onPressed: () async {
                              if (!_stock) {
                                await _checkStock(context);
                                Future.delayed(Duration(milliseconds: 200))
                                    .then((v) {
                                  Scrollable.ensureVisible(
                                      expansionKey.currentContext,
                                      alignmentPolicy:
                                          ScrollPositionAlignmentPolicy
                                              .keepVisibleAtEnd,
                                      duration: Duration(milliseconds: 200));
                                });
                              }
                              if (_stock) {}
                              setState(() {
                                if (_edit) _edit = false;
                                _stock = !_stock;
                              });
                            }))
                    : ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: widget.leftPadding,
                          maxWidth: widget.leftPadding,
                        ),
                      ),
                IconButton(
                  padding: widget.iconPadding,
                  iconSize: widget.iconSize,
                  color: minusBtnDisabled
                      ? widget.iconDisabledColor ??
                          Theme.of(context).disabledColor
                      : widget.iconActiveColor ??
                          Theme.of(context).textTheme.button.color,
                  icon: widget.subtractIcon,
                  onPressed: minusBtnDisabled
                      ? null
                      : () async {
                          if (_edit) {
                            setState(() {
                              _edit = !_edit;
                            });
                          }

                          num newVal = _value - widget.step;
                          setState(() {
                            _value = newVal;
                          });
                          if (_stock) {
                            await _checkStock(context);
                            setState(() {
                              _stock = !_stock;
                              _stock = !_stock;
                            });
                          }
                          if (widget.onChanged != null)
                            widget.onChanged(newVal);
                          _storage.writeBasket(basketChecked);
                        },
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: 40,
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      _edit
                          ? _text
                          : '${widget.displayFormat == null ? _value.toString() : widget.displayFormat.format(_value)}',
                      style: widget.textStyle,
                    ),
                  ),
                ),
                IconButton(
                  padding: widget.iconPadding,
                  iconSize: widget.iconSize,
                  color: addBtnDisabled
                      ? widget.iconDisabledColor ??
                          Theme.of(context).disabledColor
                      : widget.iconActiveColor ??
                          Theme.of(context).textTheme.button.color,
                  icon: widget.addIcon,
                  onPressed: addBtnDisabled
                      ? null
                      : () async {
                          if (_edit) {
                            setState(() {
                              _edit = !_edit;
                            });
                          }
                          num newVal = _value + widget.step;
                          setState(() {
                            _value = newVal;
                          });
                          if (_stock) {
                            await _checkStock(context);
                            setState(() {
                              _stock = !_stock;
                              _stock = !_stock;
                            });
                          }

                          if (widget.onChanged != null)
                            widget.onChanged(newVal);
                          _storage.writeBasket(basketChecked);
                        },
                ),
                IconButton(
                    icon: _edit
                        ? Icon(Icons.expand_less_outlined, color: Colors.grey)
                        : Icon(Icons.keyboard, color: Colors.grey),
                    onPressed: () {
                      if (!_edit) {
                        _text = '';

                        Future.delayed(Duration(milliseconds: 200)).then((v) {
                          Scrollable.ensureVisible(expansionKey.currentContext,
                              alignmentPolicy: ScrollPositionAlignmentPolicy
                                  .keepVisibleAtEnd,
                              duration: Duration(milliseconds: 200));
                        });
                      }
                      if (_edit) {
                        //_value = num.parse(_text);
                        //if (widget.onChanged != null) widget.onChanged(_value);
                      }
                      setState(() {
                        if (_stock) _stock = false;
                        _edit = !_edit;
                      });
                    })
              ]),
          _stock
              ? Row(children: <Widget>[
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: widget.leftPadding + 16,
                      maxWidth: widget.leftPadding + 16,
                    ),
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(children: <Widget>[
                          _basketDetail.artoul.indexOf('|') == -1
                              ? Text(AppLocalizations.of(context).orderunit +
                                  ': ' +
                                  _basketDetail.artorduni)
                              : OrderUnitWidget(
                                  _basketDetail, true, _artnumint),
                        ]),
                        SizedBox(height: 4.0, width: 0.0),
                        _basketDetail.artstofla == 'x'
                            ? Container()
                            : Row(children: <Widget>[
                                _basketDetail.artstofla == ''
                                    ? _basketDetail.artsto == ''
                                        ? Text('')
                                        : Text(
                                            AppLocalizations.of(context).stock +
                                                ': ' +
                                                _basketDetail.artsto)
                                    : _basketDetail.artstofla == 'green'
                                        ? Wrap(children: <Widget>[
                                            Text(AppLocalizations.of(context)
                                                    .stock +
                                                ': '),
                                            Icon(Icons.circle,
                                                color: Colors.green,
                                                size: (2 + approDataTextSize) *
                                                    1.0)
                                          ])
                                        : _basketDetail.artstofla == 'yellow'
                                            ? Wrap(children: <Widget>[
                                                Text(
                                                    AppLocalizations.of(context)
                                                            .stock +
                                                        ': '),
                                                Icon(Icons.circle,
                                                    color: Colors.orange,
                                                    size: (2 +
                                                            approDataTextSize) *
                                                        1.0)
                                              ])
                                            : Wrap(children: <Widget>[
                                                Text(
                                                    AppLocalizations.of(context)
                                                            .stock +
                                                        ': '),
                                                Icon(Icons.circle,
                                                    color: Colors.red,
                                                    size: (2 +
                                                            approDataTextSize) *
                                                        1.0)
                                              ])
                              ]),
                      ]),
                ])
              : Container(),
          _edit
              ? Row(children: <Widget>[
                  _showStockIcon
                      ? ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: widget.leftPadding + 16,
                            maxWidth: widget.leftPadding + 16,
                          ),
                        )
                      : ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: widget.leftPadding + 16,
                            maxWidth: widget.leftPadding + 16,
                          ),
                        ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: 140,
                      maxWidth: 140,
                    ),
                    child: Container(
                      color: Theme.of(context).primaryColorDark,
                      child: VirtualKeyboard(
                        height: 150,
                        textColor: globals.menuActiveColor,
                        type: VirtualKeyboardType.Numeric,
                        onKeyPress: (key) {
                          switch (key.action) {
                            case VirtualKeyboardKeyAction.Backspace:
                              if (_text.length == 0) return;
                              _text = _text.substring(0, _text.length - 1);
                              break;
                            default:
                              _text = _text + key.text;
                          }
                          setState(() {
                            _text.length == 0
                                ? _value = 1
                                : _value = num.parse(_text);
                          });
                          if (widget.onChanged != null)
                            widget.onChanged(_value);
                          _storage.writeBasket(basketChecked);
                        },
                      ),
                    ),
                  ),
                ])
              : Container(),
        ]);
  }
}

class TouchInfo extends StatefulWidget {
  final double iconSize;
  final NumberFormat displayFormat;
  final EdgeInsetsGeometry iconPadding;
  final Color iconActiveColor;
  final Color iconDisabledColor;
  final bool enabled;
  final String artnumint;
  final double leftPadding;
  final String artpri;
  final String artpac;

  const TouchInfo(
      {Key key,
      this.iconSize = 24.0,
      this.displayFormat,
      this.iconPadding = const EdgeInsets.all(4.0),
      this.iconActiveColor,
      this.iconDisabledColor,
      this.enabled = true,
      this.artnumint = '',
      this.leftPadding = 64,
      this.artpri = '', this.artpac = ''})
      : super(key: key);

  @override
  _TouchInfoState createState() => _TouchInfoState();
}

class _TouchInfoState extends State<TouchInfo> {
  final GlobalKey expansionKey = GlobalKey();

  num _value;
  BasketDetail _basketDetail =
      BasketDetail('', '', '', false, 1, '', '', '', []);
  bool _stock = false;

  String get _artnumint => widget.artnumint;
  String get _text => widget.artpri;
  String get _artpac => widget.artpac;

  Future _checkStock(context) async {
    _basketDetail = await checkBasketItem(context, _artnumint, _value);
    //print(_value);
    //print(_basketDetail.artsto);
  }

  @override
  void initState() {
    super.initState();

    /*
   if (_scrollVisible) {
      Future.delayed(Duration(milliseconds: 200)).then((v) {
        if (this.mounted) {
          Scrollable.ensureVisible(context,
              alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
              duration: Duration(milliseconds: 200));
        }
      });
    }
   */
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        key: expansionKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(width: widget.leftPadding),
                IconButton(
                    icon: _stock
                        ? Icon(Icons.expand_less_outlined, color: Colors.grey)
                        : (approShowPrice
                            ? Image.asset(
                                'images/pricetag.png',
                                width: 18.0,
                              )
                            : Icon(Feather.package,
                                color: Colors.grey, size:18.0)),
                    /*Icons.expand_more_outlined*/
                    iconSize: 23.0,
                    color: Colors.grey,
                    onPressed: () async {
                      if (!_stock) {
                        await _checkStock(context);
                        Future.delayed(Duration(milliseconds: 200)).then((v) {
                          Scrollable.ensureVisible(expansionKey.currentContext,
                              alignmentPolicy: ScrollPositionAlignmentPolicy
                                  .keepVisibleAtEnd,
                              duration: Duration(milliseconds: 200));
                        });
                      }
                      if (_stock) {}
                      setState(() {
                        _stock = !_stock;
                      });
                    }),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    _text == null ? '' : _text,
                  ),
                ),
              ]),
          _stock
              ? Row(children: <Widget>[
                  SizedBox(width: widget.leftPadding + 12),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(children: <Widget>[
                          _basketDetail.artoul.indexOf('|') == -1
                              ? Text(AppLocalizations.of(context).orderunit +
                                  ': ' +
                                  _basketDetail.artorduni)
                              : OrderUnitWidget(
                                  _basketDetail, true, _artnumint),
                        ]),
                        SizedBox(height: 4.0, width: 0.0),
                        _basketDetail.artstofla == 'x'
                            ? Container()
                            : Row(children: <Widget>[
                                _basketDetail.artstofla == ''
                                    ? _basketDetail.artsto == ''
                                        ? Text('')
                                        : Text(
                                            AppLocalizations.of(context).stock +
                                                ': ' +
                                                _basketDetail.artsto)
                                    : _basketDetail.artstofla == 'green'
                                        ? Wrap(children: <Widget>[
                                            Text(AppLocalizations.of(context)
                                                    .stock +
                                                ': '),
                                            Icon(Icons.circle,
                                                color: Colors.green,
                                                size: (2 + approDataTextSize) *
                                                    1.0)
                                          ])
                                        : _basketDetail.artstofla == 'yellow'
                                            ? Wrap(children: <Widget>[
                                                Text(
                                                    AppLocalizations.of(context)
                                                            .stock +
                                                        ': '),
                                                Icon(Icons.circle,
                                                    color: Colors.orange,
                                                    size: (2 +
                                                            approDataTextSize) *
                                                        1.0)
                                              ])
                                            : Wrap(children: <Widget>[
                                                Text(
                                                    AppLocalizations.of(context)
                                                            .stock +
                                                        ': '),
                                                Icon(Icons.circle,
                                                    color: Colors.red,
                                                    size: (2 +
                                                            approDataTextSize) *
                                                        1.0)
                                              ])
                              ]),
                        SizedBox(height: 4.0, width: 0.0),
                        Row(children: <Widget>[
                          Wrap(children: <Widget>[
                            Text(AppLocalizations.of(context).packing +
                                ': '),
                            Text(_artpac)
                          ])
                        ]),
                        SizedBox(height: 4.0, width: 0.0),
                        approShowPrice
                            ? Row(children: <Widget>[
                                Wrap(children: <Widget>[
                                  Text(AppLocalizations.of(context).price +
                                      ': '),
                                  Text(_basketDetail.artpri ==
                                          _basketDetail.artbes
                                      ? _basketDetail.artbes +
                                          ' ' +
                                          _basketDetail.artuni
                                      : _basketDetail.artpri +
                                          ' / ' +
                                          _basketDetail.artbes +
                                          ' ' +
                                          _basketDetail.artuni)
                                ])
                              ])
                            : Container(),
                      ]),
                ])
              : Container(),
        ]);
  }
}

class OrderUnitWidget extends StatefulWidget {
  OrderUnitWidget(this.basrow, this.refresh, this.artnumint);
  final BasketDetail basrow;
  final bool refresh;
  final String artnumint;
  @override
  _OrderUnitWidgetState createState() =>
      _OrderUnitWidgetState(basrow, refresh, artnumint);
}

class _OrderUnitWidgetState extends State<OrderUnitWidget> {
  _OrderUnitWidgetState(this.basrow, this.refresh, this.artnumint);
  final BasketDetail basrow;
  final bool refresh;
  var _selected = 0;
  String artnumint;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 0)).then((v) {
      itemScrollController.scrollTo(
          index: _selected,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOutCubic);
    });
  }

  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(AppLocalizations.of(context).orderunit + ': '),
        SizedBox(
          height: 40,
          width: MediaQuery.of(context).size.width -
              80 -
              (66.0 * max(approThumbSizeRatio, 1)),
          child: _buildChips(),
        ),
      ],
    );
  }

  Widget _buildChips() {
    List<Widget> chips = [];
    var myTab = basrow.artoul.split('|');
    int _idx = basketChecked.indexWhere((e) => e.artnumint == artnumint);
    if (_idx > -1) basrow.artorduni = basketChecked[_idx].artorduni;
    if (basrow.artorduni == '' && myTab.length > 0) basrow.artorduni = myTab[0];
    for (var i = 0; i < myTab.length; i++) {
      ChoiceChip choiceChip = ChoiceChip(
        visualDensity: VisualDensity.compact,
        selected: myTab[i] == basrow.artorduni,
        label: Text(myTab[i]),
        labelStyle: TextStyle(
            fontSize: approDataTextSize * 1.0,
            color: myTab[i] == basrow.artorduni ? Colors.white : Colors.black),
        avatar: null,
        elevation: 1,
        pressElevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        selectedColor: myTheme.toggleableActiveColor,
        onSelected: (bool selected) {
          setState(() {
            int _idx =
                basketChecked.indexWhere((e) => e.artnumint == artnumint);
            if (_idx > -1) basketChecked[_idx].artorduni = myTab[i];
            if (refresh) checkBasket(context, _idx);
            if (selected) {
              basrow.artorduni = myTab[i];
              _selected = i;
            }
          });
        },
      );
      if (choiceChip.selected) _selected = i;
      chips.add(Padding(
          padding: EdgeInsets.symmetric(horizontal: 1), child: choiceChip));
    }
    return ScrollablePositionedList.builder(
      itemCount: chips.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) => chips[index],
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
    );
    /*
    SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: chips),
    );
*/
  }
}

Future<void> syncNode(e, n, c, f, l, a) async {
  List<CatLevel> e2 = [];
  var _node = '', _noddes = '';
  var i = 0;
  _node = getItemToken(currentNodePath, '|', l);
  if (_node != '') {
    if (l == 1) {
      i = e.indexWhere((el) => el.nodnum == '@' + _node);
      if (i > -1) {
        e2 = await getTree(c, _node);
        if (i > -1) {
          _noddes = e[i].noddes;
          n += '/' + _node;
          var route = MaterialPageRoute(
            settings: RouteSettings(name: n),
            builder: (BuildContext context) => ChapterScreen(e2, _noddes, f),
          );
          Navigator.of(c).push(route);
          syncNode(e2, n, c, f, l + 1, a);
          return;
        }
      } else {
        syncNode(e, n, c, f, l + 1, a);
        return;
      }
    }
    i = e.indexWhere((el) => el.nodnum == _node);

    if (i > -1) {
      n += '/' + _node;
      _noddes = e[i].noddes;
      if (e[i].nodtyp == 2) {
        var route = MaterialPageRoute(
          settings: RouteSettings(name: n),
          builder: (BuildContext context) => FavoriteDetailScreen(
            basdes: e[i].noddes,
            basval: e[i].nodnum,
            basurl: e[i].nodurl,
            onScreenHideButtonPressed: f,
            syncnum: a,
          ),
        );
        Navigator.of(c).push(route);
      } else {
        e2 = await getTreeLevel(e[i].xmlnod);
        var route = MaterialPageRoute(
          settings: RouteSettings(name: n),
          builder: (BuildContext context) => ChapterScreen(e2, _noddes, f),
        );
        Navigator.of(c).push(route);
        syncNode(e2, n, c, f, l + 1, a);
      }
    }
  }
}
