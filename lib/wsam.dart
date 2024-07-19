// @dart=2.9
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:path_provider/path_provider.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'dart:io';
import 'dart:convert';
import 'globals.dart' as globals;
import 'package:intl/intl.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pdfx/pdfx.dart';
import 'restart.dart';

var approCredential = '';
var approShop = 'moulan';
var approUser = '';
var approLanguage = 'fr';
var approStartCatalog = 'cat01';
var approDataTextSize = 14;
var approThumbSizeRatio = 1.0;
var approPDFSuffix = '_';
var approShowPrice = true;
var approDisableShowPrice = false;
var approCanOrder = false;
var approVersion = '';
var approLogo = '';
var approInitialIndex = 0;
var approShowStockIcon = true;
var approShowNews = false;
var approShowComment = false;
var approNewsTitle = '';
var approDoc1 = '';
PersistentTabController mainTab;
List<String> approLanguages = ['fr'];
List<BasketDetail> basketChecked = [];
List<CatNode> resultNode = [];
var _lastSearch = '';
List<Basket> basketFavorite = [];
List<Basket> basketArchive = [];
List<CatLevel> treeRoot = [];
List<BasketDetail> basketScanned = [];
List<InfoNews> infoNews = [];
GlobalKey<ScaffoldState> approScaffoldKey =  GlobalKey<ScaffoldState>();
GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey=GlobalKey<ScaffoldMessengerState>();
var currentNodePath = '';

Future<ReturnFunctionCode> getCredential(us, ps, sh, context, to) async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.none) {
    ReturnFunctionCode(false, AppLocalizations.of(context).nointernet);
  }
  approCredential = '';

  var myUrl = 'https://' + sh + '.catbuilder.info/catalogs/wsam.asp';
  var cXML = '<?xml version="1.0" encoding="UTF-8" ?>';
  cXML += '<dbsync>';
  cXML += '<header>';
  cXML += '<sender><credential><client>appro724</client><identity>' +
      us +
      '</identity></credential></sender>';
  cXML += '</header>';
  cXML += '<request>';
  cXML += '<type>getcredential</type>';
  cXML += '<par1>' + ps + '</par1>';
  if (to != null) {
    cXML += '<par2>' + to + '</par2>';
  }
  cXML += '</request>';
  cXML += '</dbsync>';
  http.Response response;
  try {
    response = await http
        .post(Uri.parse(myUrl), body: cXML)
        .timeout(Duration(seconds: 10), onTimeout: () {
      return null;
    });
  } catch (e) {
    //print(e);
    return ReturnFunctionCode(false, AppLocalizations.of(context).shoperror);
  }

  if (response == null)
    return ReturnFunctionCode(
        false, AppLocalizations.of(context).requesttimeout);
  //print(response.body);

  var document = XmlDocument.parse(response.body);
  if (document.findAllElements('result').first.text == '2:Security') {
    return ReturnFunctionCode(false, AppLocalizations.of(context).invalidcred);
  }
  approCredential = document.findAllElements('sharedsecret').first.text;
  approStartCatalog = document.findAllElements('startcatalog').first.text;
  approPDFSuffix = document.findAllElements('pdfsuffix').first.text;
  approInitialIndex = document.findAllElements('initialtab').length == 0
      ? 0
      : int.parse(document.findAllElements('initialtab').first.text);
  approShowStockIcon = document.findAllElements('stockicon').length == 0
      ? false
      : (document.findAllElements('stockicon').first.text == 'true');
  approDisableShowPrice = document.findAllElements('disableprice').length == 0
      ? false
      : (document.findAllElements('disableprice').first.text == '1');
  approShowComment = document.findAllElements('showcomment').length == 0
      ? false
      : (document.findAllElements('showcomment').first.text == '1');
  approLogo = '';
  var tag = document.findAllElements('logo');
  if (tag.length > 0) approLogo = tag.first.text;
  tag = document.findAllElements('doc1');
  if (tag.length > 0) approDoc1 = tag.first.text;

  approCanOrder = (document.findAllElements('canorder').first.text == 'true');
  final languages = document.findAllElements('languages');
  approLanguages = [];
  approLanguage = 'fr';
  for (var l in languages ?? []) {
    approLanguages = l.text.split('|');
  }
  globals.infoCounter.value = 0;

  if (approCredential != '') {
    final storage = new BasketStorage();
    await storage.readBasket();
    final sstorage = new FlutterSecureStorage();
    await sstorage.write(key: sh, value: approCredential);

    approShop = sh;
    approUser = us;

    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    prefs.setString(approShop + '-logo', approLogo);

    approShowPrice = prefs.get(approShop + '-showprice');
    approShowPrice = approShowPrice == null ? true : approShowPrice;
    if(approDisableShowPrice) approShowPrice = false;

    approLanguage = prefs.get(sh + '-language');
    approLanguage = approLanguage == null ? approLanguages[0] : approLanguage;

    await getFavorite(null);
    treeRoot = await getTree(null, approStartCatalog);

    approShowNews = false;
    if (document.findAllElements('shownews').length > 0) {
      final storage2 = new InfoNewsStorage();
      await storage2.readInfoNews();

      approNewsTitle = document.findAllElements('shownews').first.text;
      approShowNews = true;
      infoNews = await getApproNews(null);
      if (infoNews != null) {
        approShowNews = (infoNews.length > 0);
      }
    }

    return ReturnFunctionCode(true, '');
  }
  return ReturnFunctionCode(false, '');
}

Future<List<CatLevel>> getTree(context, cat) async {
  var myUrl = 'https://' + approShop + '.catbuilder.info/catalogs/wsam.asp';
  var cXML = '<?xml version="1.0" encoding="UTF-8" ?>';
  cXML += '<dbsync>';
  cXML += '<header>';
  cXML += '<sender><credential><client>appro724</client><identity>' +
      approUser +
      '</identity><sharedsecret>' +
      approCredential +
      '</sharedsecret></credential></sender>';

  cXML += '</header>';
  cXML += '<request>';
  cXML += '<type>getcatalogtree2</type>';
  cXML += '<par1>' + cat + '</par1>';
  cXML += '</request>';
  cXML += '</dbsync>';
  if (context != null) {
    showCupertinoModalPopup(
        context: context,
        useRootNavigator: false,
        builder: (context) => Container(
            color: Colors.white.withOpacity(0.5),
            child: Center(child: CircularProgressIndicator())));
  }
  http.Response response = await http.post(Uri.parse(myUrl), body: cXML);
 // print(response.body);
  if (context != null) Navigator.pop(context);
  List<CatLevel> tab = [];
  //var unescape = HtmlUnescape();
  var document = XmlDocument.parse(response.body);
  var r = document.findAllElements('LEVEL').first;

  for (var e in r.children) {
    if (e.nodeType == XmlNodeType.ELEMENT) {
      if (e.getAttribute('name') != null) {
        tab.add(CatLevel(e.getAttribute('id'), getText(e.getAttribute('name')),
            e.getAttribute('img'), e, 1, ''));
       // print(e.getAttribute('name'));
      }
    }
  }
  return tab;
}

Future<List<InfoNews>> getApproNews(context) async {
  var myUrl = 'https://' + approShop + '.catbuilder.info/catalogs/wsam.asp';
  var cXML = '<?xml version="1.0" encoding="UTF-8" ?>';
  var isTo = false;
  var resultData = [];
  var j = 0;

  cXML += '<dbsync>';
  cXML += '<header>';
  cXML += '<sender><credential><client>appro724</client><identity>' +
      approUser +
      '</identity><sharedsecret>' +
      approCredential +
      '</sharedsecret></credential></sender>';

  cXML += '</header>';
  cXML += '<request>';
  cXML += '<type>getnews</type>';
  cXML += '<language>' + approLanguage + '</language>';
  cXML += '</request>';
  cXML += '</dbsync>';

  if (context != null) {
    showCupertinoModalPopup(
        context: context,
        useRootNavigator: false,
        builder: (context) => Container(
            color: Colors.white.withOpacity(0.5),
            child: Center(child: CircularProgressIndicator())));
  }
  http.Response response = await http
      .post(Uri.parse(myUrl), body: cXML)
      .timeout(Duration(seconds: 10), onTimeout: () {
    isTo = true;
    return;
  });
  if (context != null) Navigator.pop(context);
  if (isTo) return null;
  //print(response.body);
  var document = XmlDocument.parse(response.body);
  if (document.findAllElements('result').first.text == '0:OK') {
    document =
        XmlDocument.parse(document.findAllElements('data').first.innerText);
    resultData = document
        .findAllElements('Item')
        .map<InfoNews>((e) => InfoNews(
            e.findElements('inftit').first.text,
            e.findElements('infdet').first.text,
            e.findElements('infimg').first.text,
            e.findElements('inflin').first.text,
            e.findElements('infact').first.text,
            DateTime.parse(e.findElements('infbeg').first.text),
            DateTime.parse(e.findElements('infend').first.text)))
        .toList();
    for (var i = infoNews.length - 1; i >= 0; i--) {
      j = resultData.indexWhere((e) => e.inflin == infoNews[i].inflin);
      if (j > -1) {
        resultData[j].infsta = infoNews[i].infsta;
      }
    }
    globals.infoCounter.value =
        resultData.where((r) => r.infsta == 0).toList().length;
    //print(resultData[1].infsta);
    return resultData;
  } else {
    return null;
  }
}

Future<String> getOrderInfo(context) async {
  var myUrl = 'https://' + approShop + '.catbuilder.info/catalogs/wsam.asp';
  var cXML = '<?xml version="1.0" encoding="UTF-8" ?>';
  var isTo = false;
  var myLang = approLanguage;
  switch (Localizations.localeOf(context).toString()) {
    case 'fr':
    case 'de':
    case 'nl':
    case 'en':
      myLang = Localizations.localeOf(context).toString();
      break;
  }

  cXML += '<dbsync>';
  cXML += '<header>';
  cXML += '<sender><credential><client>appro724</client><identity>' +
      approUser +
      '</identity><sharedsecret>' +
      approCredential +
      '</sharedsecret></credential></sender>';

  cXML += '</header>';
  cXML += '<request>';
  cXML += '<type>getorderinfo</type>';
  cXML += '<language>' + myLang + '</language>';
  var myData = '';
  for (var b in basketChecked ?? []) {
    if (myData != '') myData += '||';
    myData += b.artnumint + '##' + b.artqty.toString();
  }
  cXML += '<data>' + myData + '</data>';

  cXML += '</request>';
  cXML += '</dbsync>';

  if (context != null) {
    showCupertinoModalPopup(
        context: context,
        useRootNavigator: false,
        builder: (context) => Container(
            color: Colors.white.withOpacity(0.5),
            child: Center(child: CircularProgressIndicator())));
  }
  http.Response response = await http
      .post(Uri.parse(myUrl), body: cXML)
      .timeout(Duration(seconds: 10), onTimeout: () {
    isTo = true;
    return;
  });
  if (context != null) Navigator.pop(context);
  if (isTo) return '';
  var document = XmlDocument.parse(response.body);
  if (document.findAllElements('result').first.text == '0:OK') {
    //print(document.findAllElements('data').first.innerText);
    return document
        .findAllElements('data')
        .first
        .innerText
        .replaceAll('[[', ']]');
  } else {
    return '';
  }
}

Future<List<CatLevel>> getTreeLevel(l) async {
  List<CatLevel> tab = [];

  for (var e in l.children) {
    if (e.nodeType == XmlNodeType.ELEMENT) {
      tab.add(CatLevel(
          e.getAttribute('id'),
          getText(
              e.name.toString() == 'LEVEL' ? e.getAttribute('name') : e.text),
          e.getAttribute(e.name.toString() == 'LEVEL' ? 'img' : 'thumb'),
          e,
          e.name.toString() == 'LEVEL' ? 1 : 2,
          e.name.toString() == 'LEVEL' ? '' : e.getAttribute('url')));
    }
  }
  return tab;
}

Future<List<CompanyUser>> getCompanyUser() async {
  List<CompanyUser> tab = [];

  var myUrl = 'https://' + approShop + '.catbuilder.info/catalogs/wsam.asp';
  var cXML = '<?xml version="1.0" encoding="UTF-8" ?>';
  cXML += '<dbsync>';
  cXML += '<header>';
  cXML += '<sender><credential><client>appro724</client><identity>' +
      approUser +
      '</identity><sharedsecret>' +
      approCredential +
      '</sharedsecret></credential></sender>';

  cXML += '</header>';
  cXML += '<request>';
  cXML += '<type>getcompanyuser</type>';
  cXML += '</request>';
  cXML += '</dbsync>';

  http.Response response = await http.post(Uri.parse(myUrl), body: cXML);
  var document = XmlDocument.parse(response.body);
  tab = document
      .findAllElements('user')
      .map<CompanyUser>((e) => CompanyUser(e.findElements('usemai').first.text))
      .toList();
  if (tab.length == 0) {
    tab.add(CompanyUser(approUser));
  }
  //tab.forEach((CompanyUser) => print(CompanyUser.usemai));
  return tab;
}

Future<bool> getFavorite(context) async {
  var myUrl = 'https://' + approShop + '.catbuilder.info/catalogs/wsam.asp';
  var cXML = '<?xml version="1.0" encoding="UTF-8" ?>';
  cXML += '<dbsync>';
  cXML += '<header>';
  cXML += '<sender><credential><client>appro724</client><identity>' +
      approUser +
      '</identity><sharedsecret>' +
      approCredential +
      '</sharedsecret></credential></sender>';

  cXML += '</header>';
  cXML += '<request>';
  cXML += '<type>getfavorit</type>';
  cXML += '</request>';
  cXML += '</dbsync>';
  if (context != null) {
    showCupertinoModalPopup(
        context: context,
        useRootNavigator: false,
        builder: (context) => Container(
            color: Colors.white.withOpacity(0.5),
            child: Center(child: CircularProgressIndicator())));
  }
  http.Response response = await http.post(Uri.parse(myUrl), body: cXML);
  if (context != null) Navigator.pop(context);

  var document = XmlDocument.parse(response.body);
  //print('getFavorite');
  //print(response.body);
  List data = document
      .findAllElements('item')
      .map<Basket>((e) => Basket(
          e.findElements('basnum').first.text,
          e.findElements('basdes').first.text,
          e.findElements('basval').first.text,
          e.findElements('bastyp').first.text,
          e.findElements('basdat').first.text))
      .toList();
  //print(data);

  basketArchive = data.where((f) => f.bastyp.startsWith('archive')).toList();

  basketArchive.sort((a, b) => (a.basdat.substring(6, 10) +
          a.basdat.substring(3, 5) +
          a.basdat.substring(0, 2) +
          a.basdat.substring(11, 19))
      .compareTo(b.basdat.substring(6, 10) +
          b.basdat.substring(3, 5) +
          b.basdat.substring(0, 2) +
          b.basdat.substring(11, 19)));
  basketArchive = basketArchive.reversed.toList();
  basketArchive = basketArchive.take(10).toList();

  basketFavorite = data.where((f) => f.bastyp.startsWith('basket')).toList();
  basketFavorite
      .sort((a, b) => a.basdes.toLowerCase().compareTo(b.basdes.toLowerCase()));
  return true;
}

Future<bool> delFavorite(context,basnum) async {
  var myUrl = 'https://' + approShop + '.catbuilder.info/catalogs/wsam.asp';
  var cXML = '<?xml version="1.0" encoding="UTF-8" ?>';
  cXML += '<dbsync>';
  cXML += '<header>';
  cXML += '<sender><credential><client>appro724</client><identity>' +
      approUser +
      '</identity><sharedsecret>' +
      approCredential +
      '</sharedsecret></credential></sender>';

  cXML += '</header>';
  cXML += '<request>';
  cXML += '<type>delfavorit</type>';
  cXML += '<par1>'+basnum+'</par1>';
  cXML += '</request>';
  cXML += '</dbsync>';
  if (context != null) {
    showCupertinoModalPopup(
        context: context,
        useRootNavigator: false,
        builder: (context) => Container(
            color: Colors.white.withOpacity(0.5),
            child: Center(child: CircularProgressIndicator())));
  }
  http.Response response = await http.post(Uri.parse(myUrl), body: cXML);
  var document = XmlDocument.parse(response.body);
  if (document.findAllElements('result').first.text == '0:OK') {
    await getFavorite(null);
    if (context != null) Navigator.pop(context);

    final snackBar = SnackBar(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      behavior: SnackBarBehavior.fixed,
      content: Text(AppLocalizations.of(context).deleteok),
      action: SnackBarAction(
        label: AppLocalizations.of(context).hide,
        onPressed: () {},
      ),
    );
    scaffoldMessengerKey.currentState.showSnackBar(snackBar);
  } else {
    if (context != null) Navigator.pop(context);
    final snackBar = SnackBar(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      behavior: SnackBarBehavior.fixed,
      content: Text(AppLocalizations.of(context).deletenok),
      action: SnackBarAction(
        label: AppLocalizations.of(context).hide,
        onPressed: () {},
      ),
    );
    scaffoldMessengerKey.currentState.showSnackBar(snackBar);
  }

  //
  //print(cXML);
  //print(response.body);
  return true;
}

Future<bool> sendBasket(context, t, n, u, com, sendcopy) async {
  var myUrl = 'https://' + approShop + '.catbuilder.info/catalogs/wsam.asp';
  var cXML = '<?xml version="1.0" encoding="UTF-8" ?>';
  cXML += '<dbsync>';
  cXML += '<header>';
  cXML += '<sender><credential><client>appro724</client><identity>' +
      approUser +
      '</identity><sharedsecret>' +
      approCredential +
      '</sharedsecret></credential></sender>';
  cXML += '</header>';
  cXML += '<request>';
  cXML += '<type>send' + t + '</type>';
  cXML += '<par1>' + n + '</par1>';
  cXML += '<par2>join</par2>';
  if ((t == 'favorite' || t == 'order') && (u != approUser || com != '')) {
    cXML += '<par3>' + u + '</par3>';
    cXML += '<par4>' +
        XmlToken.openCDATA +
        XmlText(com).toString() +
        XmlToken.closeCDATA +
        '</par4>';
    if (sendcopy) {
      cXML += '<par5>' + approUser + '</par5>';
    }
  }
  cXML += '<language>' + approLanguage + '</language>';
  var myData = '';
  for (var b in basketChecked ?? []) {
    if (myData != '') myData += '||';
    myData += b.artnumint + '##' + b.artqty.toString();
    if( b.artoul != '' ) myData += '##' + b.artorduni;
    if( b.artnumint == 'comment' ) myData += '##' + b.artdes;
  }

  cXML += '<data>' + myData + '</data>';
  cXML += '</request>';
  cXML += '</dbsync>';
  showCupertinoModalPopup(
      context: context,
      useRootNavigator: false,
      builder: (context) => Container(
          color: Colors.white.withOpacity(0.5),
          child: Center(child: CircularProgressIndicator())));
  http.Response response = await http.post(Uri.parse(myUrl), body: cXML);
  Navigator.pop(context);

  if (t == 'print') return true;
  //print('sendFavorite');
  //print(response.body);
  var document = XmlDocument.parse(response.body);
  if (document.findAllElements('result').first.innerText == '0:OK') {
    var data = document.findAllElements('data').first.innerText;
    for (var i = basketChecked.length - 1; i >= 0; i--) {
      if (data.indexOf(basketChecked[i].artnumint + ':ok') > -1) {
        basketChecked.removeAt(i);
      }
      globals.basketCounter.value = getCheckedCount();
      var _storage = new BasketStorage();
      _storage.writeBasket(basketChecked);
    }
    if (globals.basketCounter.value == 0) {
      final snackBar = SnackBar(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        behavior: SnackBarBehavior.fixed,
        content: Text(t == 'favorite'
            ? AppLocalizations.of(context).sendfavok
            : t == 'basket'
                ? AppLocalizations.of(context).sendbasok
                : AppLocalizations.of(context).sendorderok),
        action: SnackBarAction(
          label: AppLocalizations.of(context).hide,
          onPressed: () {},
        ),
      );
      scaffoldMessengerKey.currentState.showSnackBar(snackBar);
      return true;
    } else {
      final snackBar = SnackBar(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        behavior: SnackBarBehavior.fixed,
        content: Text(t == 'basket'
            ? AppLocalizations.of(context).sendbasokx
            : AppLocalizations.of(context).sendfavokx),
        action: SnackBarAction(
          label: AppLocalizations.of(context).hide,
          onPressed: () {},
        ),
      );
      scaffoldMessengerKey.currentState.showSnackBar(snackBar);
      var storage = new BasketStorage();
      storage.writeBasket(basketChecked);
      return true;
    }
  }
  if (document.findAllElements('result').first.innerText == '3:MSG') {
    final snackBar = SnackBar(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      behavior: SnackBarBehavior.fixed,
      content: Text(document.findAllElements('message').first.innerText),
      action: SnackBarAction(
        label: AppLocalizations.of(context).hide,
        onPressed: () {},
      ),
    );
    scaffoldMessengerKey.currentState.showSnackBar(snackBar);
  }
  return false;
}

Future<List<BasketDetail>> getBasketDetail(v) async {
  var unescape = HtmlUnescape();
  List rows = v.split('@@');
  //print(rows[0]);
  var map = rows.map<BasketDetail>((e) => BasketDetail(
      e.split('&&')[0],
      getText(unescape
          .convert(e.split('&&')[4])
          .replaceAll('<br>', '\n')
          .replaceAll('<BR>', '\n')),
      e.split('&&')[6],
      false,
      1,
      e.split('&&')[1],
      getToken(e.split('&&')[5], 'ap'),
      getItemToken(getItemToken(e.split('&&')[7], '/catalogs/', 2), '/', 1),
      []));

  return map
      .where((f) =>
          f.artnumint != f.artnum &&
          f.artnum.indexOf('+') == -1 &&
          f.artnumint != '')
      .toList();
}

Future<List<BasketDetail>> getBasket() async {
  return basketChecked;
}

Future<BasketDetail> getItemDetail(i, bastyp) async {
  if (bastyp == 'basket') {
//    print(basketChecked[i].nodimg);
    if (basketChecked[i].nodimg.length == 0) {
      var ap = getToken(basketChecked[i].artinf, 'ap');
      if (ap != '') {
        basketChecked[i].nodimg.add('https://' +
            approShop +
            '.catbuilder.info/catalogs/' +
            basketChecked[i].repcod +
            '/z_' +
            ap +
            '.jpg');
      } else {
        var u = '/catalogs/' +
            basketChecked[i].repcod +
            '/' +
            basketChecked[i].nodnum +
            '.asp';
        var myUrl =
            'https://' + approShop + '.catbuilder.info/catalogs/wsam.asp';
        var cXML = '<?xml version="1.0" encoding="UTF-8" ?>';
        cXML += '<dbsync>';
        cXML += '<header>';
        cXML += '<sender><credential><client>appro724</client><identity>' +
            approUser +
            '</identity><sharedsecret>' +
            approCredential +
            '</sharedsecret></credential></sender>';

        cXML += '</header>';
        cXML += '<request>';
        cXML += '<type>productinfo</type>';
        cXML += '<language>' + approLanguage + '</language>';
        cXML += '<data><url>' + u + '</url></data>';
        cXML += '</request>';
        cXML += '</dbsync>';
        //print('productitem: ' + u);
        http.Response response = await http.post(Uri.parse(myUrl), body: cXML);
        //print('productinfo: ' + response.body);
        var document = XmlDocument.parse(response.body);
        if (document.findAllElements('result').first.text == '0:OK') {
          var _it = document.findAllElements('image');
          basketChecked[i].nodimg = _it
              .map<String>((e) =>
                  'https://' +
                  approShop +
                  '.catbuilder.info/catalogs/' +
                  basketChecked[i].repcod +
                  '/' +
                  e.text)
              .toList();
        }
      }
    }
    return basketChecked[i];
  }
  return basketScanned[i];
}

Future<BasketDetail> getItemPicture(BasketDetail b) async {
  var u = '/catalogs/' + b.repcod + '/' + b.nodnum + '.asp';
  var myUrl = 'https://' + approShop + '.catbuilder.info/catalogs/wsam.asp';
  var cXML = '<?xml version="1.0" encoding="UTF-8" ?>';
  cXML += '<dbsync>';
  cXML += '<header>';
  cXML += '<sender><credential><client>appro724</client><identity>' +
      approUser +
      '</identity><sharedsecret>' +
      approCredential +
      '</sharedsecret></credential></sender>';

  cXML += '</header>';
  cXML += '<request>';
  cXML += '<type>productinfo</type>';
  cXML += '<language>' + approLanguage + '</language>';
  cXML += '<data><url>' + u + '</url></data>';
  cXML += '</request>';
  cXML += '</dbsync>';
  //print('productitem: ' + u);
  http.Response response = await http.post(Uri.parse(myUrl), body: cXML);
  //print('productinfo: ' + response.body);
  var document = XmlDocument.parse(response.body);
  if (document.findAllElements('result').first.text == '0:OK') {
    var _it = document.findAllElements('image');
    b.nodimg = _it
        .map<String>((e) =>
            'https://' +
            approShop +
            '.catbuilder.info/catalogs/' +
            b.repcod +
            '/' +
            e.text)
        .toList();
  }
  return b;
}

Future<List<CatNode>> getSearch() async {
  return resultNode;
}

Future<List<InfoNews>> getNews() async {
  return infoNews;
}

Future<List<CatLevel>> searchItem(val, repcod, context) async {
  if (val == '') {
    return [];
  }
  var mytab = val.split("  ");
  val = mytab.join(" ");
  mytab = val.split("  ");
  val = mytab.join(" ");
  mytab = val.split("  ");
  val = mytab.join(" ");
  mytab = val.split(" +");
  val = mytab.join("+");
  mytab = val.split("+ ");
  val = mytab.join("+");
  mytab = val.split("+");
  val = mytab.join("%@%and%@%");
  mytab = val.split(" ");
  val = mytab.join("%@%and%@%");
  val = '%' + val + '%';
  //print(val);
  var unescape = HtmlUnescape();
  var myUrl = 'https://' + approShop + '.catbuilder.info/catalogs/wsam.asp';
  var cXML = '<?xml version="1.0" encoding="UTF-8" ?>';
  cXML += '<dbsync>';
  cXML += '<header>';
  cXML += '<sender><credential><client>appro724</client><identity>' +
      approUser +
      '</identity><sharedsecret>' +
      approCredential +
      '</sharedsecret></credential></sender>';

  cXML += '</header>';
  cXML += '<request>';
  cXML += '<type>search</type>';
  cXML += '<par1><![CDATA[' + val + ']]></par1>';
  cXML += '<par2>' + approLanguage + '</par2>';
  cXML += '<par5>' + repcod + '</par5>';

  cXML += '</request>';
  cXML += '</dbsync>';

  //print(cXML);
  showCupertinoModalPopup(
      context: context,
      useRootNavigator: false,
      builder: (context) => Container(
          color: Colors.white.withOpacity(0.5),
          child: Center(child: CircularProgressIndicator())));
  http.Response response = await http.post(Uri.parse(myUrl), body: cXML);
  Navigator.pop(context);
  //print(cXML);
  //print(response.body);
  var document = XmlDocument.parse(response.body);
  document =
      XmlDocument.parse(document.findAllElements('data').first.innerText);
  var _resultNode = document
      .findAllElements('Item')
      .map<CatLevel>((e) => CatLevel(
      e.getAttribute('id'),
      getText(unescape
          .convert(e.text)
          .replaceAll('<br>', ' ')
          .replaceAll('<BR>', ' ')),
      e.getAttribute('thumb').replaceAll('/catalogs/', ''),
      null, 2,
      e.getAttribute('url')))
      .toList();
  //  data .forEach((CatNode) =>  print(CatNode.noddes));
  _resultNode
      .sort((a, b) => a.noddes.toLowerCase().compareTo(b.noddes.toLowerCase()));
  return _resultNode;
}

Future<List<BasketDetail>> getProductItem(n, String u, Product p) async {
  var unescape = HtmlUnescape();
  var myUrl = 'https://' + approShop + '.catbuilder.info/catalogs/wsam.asp';
  var cXML = '<?xml version="1.0" encoding="UTF-8" ?>';
  cXML += '<dbsync>';
  cXML += '<header>';
  cXML += '<sender><credential><client>appro724</client><identity>' +
      approUser +
      '</identity><sharedsecret>' +
      approCredential +
      '</sharedsecret></credential></sender>';

  if (u.indexOf('/catalogs/') == -1) u = '/catalogs/' + u;
  var repcod = getItemToken(getItemToken(u, '/catalogs/', 2), '/', 1);
  cXML += '</header>';
  cXML += '<request>';
  cXML += '<type>productitem</type>';
  cXML += '<language>' + approLanguage + '</language>';
  cXML += '<data><url>' + u + '</url></data>';
  cXML += '</request>';
  cXML += '</dbsync>';
  //print('productitem: ' + u);
  http.Response response = await http.post(Uri.parse(myUrl), body: cXML);
  //print('productitem: ' + response.body);
  var document = XmlDocument.parse(response.body);
  p.sheet = document.findAllElements('sheet').first.text;
  List data = document
      .findAllElements('item')

      /*
  BasketDetail(this.artnum, this.artdes, this.nodnum, this.checked, this.artqty,
      this.artnumint, this.artimg, this.repcod);
  */
      .map<BasketDetail>((e) => BasketDetail(
          e.findElements('artnum').first.text,
          (e.findElements('artdes').first.text != ''
              ? getText(unescape
                  .convert(
                    e.findElements('artdes').first.text,
                  )
                  .replaceAll('<br>', '\n')
                  .replaceAll('<BR>', '\n'))
              : e.findElements('artnumint').first.text),
          n,
          false,
          1,
          e.findElements('artnumint').first.text,
          getToken(e.findElements('artinf').first.text, 'ap'),
          repcod,
          e.findElements('artpdf').length == 0
              ? []
              : e.findElements('artpdf').map<String>((el) => el.text).toList()))
      .toList();
  var myVal = '';
  final items = document.findAllElements('item').toList();
  for (var i = 0; i < data.length; i++) {
    myVal = items[i].findElements('artpri').single.text;
    data[i].artpri = myVal == ''
        ? '0.0'
        : NumberFormat("##0.00#").format(double.parse(myVal));

    data[i].artpac = items[i].findElements('artpac').single.text;
  }
  return data;
}

Future<bool> searchNode(val, context) async {
  if (val == '') {
    _lastSearch = '';
    resultNode = [];
    globals.searchRefresh.value = !globals.searchRefresh.value;
    return true;
  }
  var mytab = val.split("  ");
  val = mytab.join(" ");
  mytab = val.split("  ");
  val = mytab.join(" ");
  mytab = val.split("  ");
  val = mytab.join(" ");
  mytab = val.split(" +");
  val = mytab.join("+");
  mytab = val.split("+ ");
  val = mytab.join("+");
  mytab = val.split("+");
  val = mytab.join("%@%and%@%");
  mytab = val.split(" ");
  val = mytab.join("%@%and%@%");
  val = '%' + val + '%';
  if (_lastSearch == val) return true;
  _lastSearch = val;
  //print(val);
  var unescape = HtmlUnescape();
  var myUrl = 'https://' + approShop + '.catbuilder.info/catalogs/wsam.asp';
  var cXML = '<?xml version="1.0" encoding="UTF-8" ?>';
  cXML += '<dbsync>';
  cXML += '<header>';
  cXML += '<sender><credential><client>appro724</client><identity>' +
      approUser +
      '</identity><sharedsecret>' +
      approCredential +
      '</sharedsecret></credential></sender>';

  cXML += '</header>';
  cXML += '<request>';
  cXML += '<type>search</type>';
  cXML += '<par1><![CDATA[' + val + ']]></par1>';
  cXML += '<par2>' + approLanguage + '</par2>';

  cXML += '</request>';
  cXML += '</dbsync>';

  //print(cXML);
  showCupertinoModalPopup(
      context: context,
      useRootNavigator: false,
      builder: (context) => Container(
          color: Colors.white.withOpacity(0.5),
          child: Center(child: CircularProgressIndicator())));
  http.Response response = await http.post(Uri.parse(myUrl), body: cXML);
  Navigator.pop(context);
  //print(cXML);
  //print(response.body);
  var document = XmlDocument.parse(response.body);
  document =
      XmlDocument.parse(document.findAllElements('data').first.innerText);
  resultNode = document
      .findAllElements('Item')
      .map<CatNode>((e) => CatNode(
          e.getAttribute('id'),
          getText(unescape
              .convert(e.text)
              .replaceAll('<br>', ' ')
              .replaceAll('<BR>', ' ')),
          e.getAttribute('thumb'),
          '',
          e.getAttribute('url')))
      .toList();
  //  data .forEach((CatNode) =>  print(CatNode.noddes));
  resultNode
      .sort((a, b) => a.noddes.toLowerCase().compareTo(b.noddes.toLowerCase()));

  globals.searchRefresh.value = !globals.searchRefresh.value;
  return true;
}

Future<void> restoreShopConnexion(context, r) {
  if (r == '2:Security') {
    final snackBar = SnackBar(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      behavior: SnackBarBehavior.fixed,
      content: Text(AppLocalizations.of(context).shopbreak),
      action: SnackBarAction(
        label: AppLocalizations.of(context).login,
        onPressed: () async {
          final sstorage = new FlutterSecureStorage();
          await sstorage.delete(key: approShop);
          //await sstorage.deleteAll();

          Navigator.of(context).popAndPushNamed('/');
          RestartWidget.restartApp(context);
        },
      ),
    );
    scaffoldMessengerKey.currentState.showSnackBar(snackBar);
  }
  return null;
}

Future<File> getFileFromUrl(String url, idx, thu) async {
  try {
    var data = await http.get(Uri.parse(url));
    var bytes = data.bodyBytes;
    var dir = await getApplicationDocumentsDirectory();
    File file = File("${dir.path}/mypdfonline" + idx.toString() + ".pdf");
    File urlFile = await file.writeAsBytes(bytes);
    if (thu) {
      final document = await PdfDocument.openFile(urlFile.path);
      final page = await document.getPage(1);
      final pageImage = await page.render(
          width: page.width * 2,
          height: page.height * 2,
          format: PdfPageImageFormat.jpeg);
      await page.close();
      file = File("${dir.path}/mypdfonline" + idx.toString() + ".jpg");
      await file.writeAsBytes(pageImage.bytes);
    }
    return urlFile;
  } catch (e) {
    throw Exception("Error opening url file");
  }
}

void checkBasket(context, idx) async {
  var data = '';
  var myVal = '';
  if (idx >= 0) {
    data += '<item><id>' +
        basketChecked[idx].artnumint +
        '</id><qty>' +
        basketChecked[idx].artqty.toString() +
        '</qty>';
    if( basketChecked[idx].artoul != ''  )
      data += '<ou>'+ basketChecked[idx].artorduni + '</ou>';
    data += '</item>';
  } else {
    for (var i = 0; i < basketChecked.length; i++) {
      data += '<item><id>' +
          basketChecked[i].artnumint +
          '</id><qty>' +
          basketChecked[i].artqty.toString() +
          '</qty>';

      if( basketChecked[i].artoul != ''  )
        data += '<ou>'+ basketChecked[i].artorduni + '</ou>';
      data += '</item>';
    }
  }
  if (data == '') return;
  var myUrl = 'https://' + approShop + '.catbuilder.info/catalogs/wsam.asp';
  var cXML = '<?xml version="1.0" encoding="UTF-8" ?>';
  cXML += '<dbsync>';
  cXML += '<header>';
  cXML += '<sender><credential><client>appro724</client><identity>' +
      approUser +
      '</identity><sharedsecret>' +
      approCredential +
      '</sharedsecret></credential></sender>';
  cXML += '</header>';
  cXML += '<request>';
  cXML += '<type>pvcheck</type>';
  cXML += '<language>' + approLanguage + '</language>';
  cXML += '<data>';
  cXML += data;
  cXML += '</data>';
  cXML += '</request>';
  cXML += '</dbsync>';
  //print(cXML);
  showCupertinoModalPopup(
      context: context,
      useRootNavigator: false,
      builder: (context) => Container(
          color: Colors.white.withOpacity(0.5),
          child: Center(child: CircularProgressIndicator())));
  http.Response response = await http.post(Uri.parse(myUrl), body: cXML);
  //print('pvcheck: ' + response.body);
  var document = XmlDocument.parse(response.body);
  final items = document.findAllElements('item').toList();
  if (items.length == 0) {
    Navigator.pop(context);
    await restoreShopConnexion(
        context, document.findAllElements('result').first.text);
    return;
  }

  for (var i = 0; i < items.length; i++) {
    var id = items[i].findElements('id').single.text;
    idx = basketChecked.indexWhere((e) => e.artnumint == id);
    if (idx > -1) {
      basketChecked[idx].status =
          int.parse(items[i].findElements('status').single.text);
      if (basketChecked[idx].status == 1) {
        myVal = items[i].findElements('price').single.text;
        basketChecked[idx].artpri = myVal == ''
            ? '0.0'
            : NumberFormat("##0.00#").format(double.parse(myVal));

        myVal = items[i].findElements('bestprice').single.text;
        basketChecked[idx].artbes = myVal == ''
            ? '0.0'
            : NumberFormat("##0.00#").format(double.parse(myVal));

        basketChecked[idx].artuni = items[i].findElements('unit').single.text;
        basketChecked[idx].artinf = items[i].findElements('info').single.text;
        basketChecked[idx].artoul = getToken(basketChecked[idx].artinf , 'oul');
        if(basketChecked[idx].artoul.indexOf(basketChecked[idx].artorduni) == -1 || basketChecked[idx].artorduni == '') {
          basketChecked[idx].artorduni =
              items[i]
                  .findElements('orderunit')
                  .single
                  .text;
        }
        if(basketChecked[idx].repcod == '') basketChecked[idx].repcod = items[i].findElements('catalog').single.text;
        basketChecked[idx].artsto = items[i].findElements('stock').single.text;
        basketChecked[idx].artstofla =
            items[i].findElements('stockflag').single.text;
        //print(basketChecked[idx].artinf);
      } else {
        basketChecked[idx].status = -1;
      }
//        print(basketChecked[idx].artnum + ': ' + basketChecked[idx].status.toString());
    }
  }
  Navigator.pop(context);
  globals.checkoutRefresh.value = !globals.checkoutRefresh.value;
}

Future<BasketDetail> checkBasketItem(context, artnumint, artqty) async {
  var data = '';
  var myVal = '';
  BasketDetail b;
  b = BasketDetail('', '', '', false, 1, '', '', '', []);
  data += '<item><id>' +
      artnumint +
      '</id><qty>' +
      artqty.toString() +
      '</qty></item>';
  var myUrl = 'https://' + approShop + '.catbuilder.info/catalogs/wsam.asp';
  var cXML = '<?xml version="1.0" encoding="UTF-8" ?>';
  cXML += '<dbsync>';
  cXML += '<header>';
  cXML += '<sender><credential><client>appro724</client><identity>' +
      approUser +
      '</identity><sharedsecret>' +
      approCredential +
      '</sharedsecret></credential></sender>';
  cXML += '</header>';
  cXML += '<request>';
  cXML += '<type>pvcheck</type>';
  cXML += '<language>' + approLanguage + '</language>';
  cXML += '<data>';
  cXML += data;
  cXML += '</data>';
  cXML += '</request>';
  cXML += '</dbsync>';
  //print(cXML);
  showCupertinoModalPopup(
      context: context,
      useRootNavigator: false,
      builder: (context) => Container(
          color: Colors.white.withOpacity(0.5),
          child: Center(child: CircularProgressIndicator())));
  http.Response response = await http.post(Uri.parse(myUrl), body: cXML);
  //print('pvcheck: ' + response.body);
  var document = XmlDocument.parse(response.body);
  final items = document.findAllElements('item').toList();
  if (items.length == 0) {
    Navigator.pop(context);
    await restoreShopConnexion(
        context, document.findAllElements('result').first.text);
    return b;
  }

  for (var i = 0; i < items.length; i++) {
    var id = items[i].findElements('id').single.text;
    if (id == artnumint) {
      b.status = int.parse(items[i].findElements('status').single.text);
      if (b.status == 1) {
        myVal = items[i].findElements('price').single.text;
        b.artpri = myVal == ''
            ? '0.0'
            : NumberFormat("##0.00#").format(double.parse(myVal));

        myVal = items[i].findElements('bestprice').single.text;
        b.artbes = myVal == ''
            ? '0.0'
            : NumberFormat("##0.00#").format(double.parse(myVal));

        b.artuni = items[i].findElements('unit').single.text;
        b.artorduni = items[i].findElements('orderunit').single.text;
        if(b.repcod == '') b.repcod = items[i].findElements('catalog').single.text;
        b.artsto = items[i].findElements('stock').single.text;
        b.artstofla = items[i].findElements('stockflag').single.text;
        b.artinf = items[i].findElements('info').single.text;
        b.artoul = getToken(b.artinf , 'oul');
        //print(b.artinf);
      } else {
        b.status = -1;
      }
//        print(b.artnum + ': ' + b.status.toString());
    }
  }
  Navigator.pop(context);
  return b;
}

void checkItem(context, a) async {
  BasketDetail d;
  var data = '<item><id>' + a + '</id></item>';
  var myUrl = 'https://' + approShop + '.catbuilder.info/catalogs/wsam.asp';
  var cXML = '<?xml version="1.0" encoding="UTF-8" ?>';
  cXML += '<dbsync>';
  cXML += '<header>';
  cXML += '<sender><credential><client>appro724</client><identity>' +
      approUser +
      '</identity><sharedsecret>' +
      approCredential +
      '</sharedsecret></credential></sender>';
  cXML += '</header>';
  cXML += '<request>';
  cXML += '<type>check</type>';
  cXML += '<language>' + approLanguage + '</language>';
  cXML += '<data>';
  cXML += data;
  cXML += '</data>';
  cXML += '</request>';
  cXML += '</dbsync>';
  // print (cXML);
  showCupertinoModalPopup(
      context: context,
      useRootNavigator: false,
      builder: (context) => Container(
          color: Colors.white.withOpacity(0.5),
          child: Center(child: CircularProgressIndicator())));
  http.Response response = await http.post(Uri.parse(myUrl), body: cXML);

  //print('check: ' + response.body);
  var document = XmlDocument.parse(response.body);
  final items = document.findAllElements('item').toList();
  if (items.length == 0) {
    Navigator.pop(context);
    await restoreShopConnexion(
        context, document.findAllElements('result').first.text);
    return;
  }
  for (var i = 0; i < items.length; i++) {
    var id = items[i].findElements('id').single.text;
    //if (id == a) {
    if (int.parse(items[i].findElements('status').single.text) == 1) {
      d = BasketDetail(
          items[i].findElements('artnum').first.text,
          items[i]
              .findElements('name-' + approLanguage)
              .first
              .text
              .replaceAll('<br>', '\n')
              .replaceAll('<BR>', '\n'),
          items[i].findElements('nodnum').first.text,
          false,
          1,
          id,
          items[i].findElements('image').first.text,
          items[i].findElements('repcod').first.text,
          []);
      d.status = 1;
      d.artinf = items[i].findElements('artinf').first.text;
      d.artoul = getToken(d.artinf , 'oul');
      basketScanned.add(d);
      globals.scanCounter.value++;
    } else {
      d = BasketDetail('', '', '', false, 1, a, '', '', []);
      d.status = -1;
      basketScanned.add(d);
      globals.scanCounter.value++;
    }
    //}
  }
  Navigator.pop(context);
  return;
}

Future<void> getNodePath(nodnum, repcod, context) async {
  var myUrl = 'https://' + approShop + '.catbuilder.info/catalogs/wsam.asp';
  var cXML = '<?xml version="1.0" encoding="UTF-8" ?>';
  cXML += '<dbsync>';
  cXML += '<header>';
  cXML += '<sender><credential><client>appro724</client><identity>' +
      approUser +
      '</identity><sharedsecret>' +
      approCredential +
      '</sharedsecret></credential></sender>';

  cXML += '</header>';
  cXML += '<request>';
  cXML += '<type>getnodepath</type>';
  cXML += '<language>' + approLanguage + '</language>';
  cXML += '<data><nodnum>' + nodnum + '</nodnum><repcod>'+repcod+'</repcod></data>';
  cXML += '</request>';
  cXML += '</dbsync>';
  http.Response response = await http.post(Uri.parse(myUrl), body: cXML);
  //print(repcod);
  //print('getnodepath: ' + response.body);
  var document = XmlDocument.parse(response.body);
  currentNodePath = document.findAllElements('data').first.text;
  if(currentNodePath.indexOf('|') < 0 ) currentNodePath = '';
  if (currentNodePath == '') {
    final snackBar = SnackBar(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      behavior: SnackBarBehavior.fixed,
      content: Text(AppLocalizations.of(context).notfound),
      action: SnackBarAction(
        label: AppLocalizations.of(context).hide,
        onPressed: () {},
      ),
    );
    scaffoldMessengerKey.currentState.showSnackBar(snackBar);
  }
}

Future<String> getRegisterInfo(context) async {
  var myUrl = 'https://' + approShop + '.catbuilder.info/catalogs/wsam.asp';
  var cXML = '<?xml version="1.0" encoding="UTF-8" ?>';
  var isTo = false;
  cXML += '<dbsync>';
  cXML += '<header>';
  cXML += '<sender><credential><client>appro724</client><identity>' +
      approUser +
      '</identity><sharedsecret>' +
      approCredential +
      '</sharedsecret></credential></sender>';

  cXML += '</header>';
  cXML += '<request>';
  cXML += '<type>sendregister</type>';
  cXML += '<language>' + Localizations.localeOf(context).toString() + '</language>';
  cXML += '</request>';
  cXML += '</dbsync>';

  print(Localizations.localeOf(context).toString());

  if (context != null) {
    showCupertinoModalPopup(
        context: context,
        useRootNavigator: false,
        builder: (context) => Container(
            color: Colors.white.withOpacity(0.5),
            child: Center(child: CircularProgressIndicator())));
  }
  http.Response response = await http
      .post(Uri.parse(myUrl), body: cXML)
      .timeout(Duration(seconds: 10), onTimeout: () {
    isTo = true;
    return http.Response('Timeout',408);
  });
  if (context != null) Navigator.pop(context);
  if (isTo) return '';
  //print(response.body);
  var document = XmlDocument.parse(response.body);
  if (document.findAllElements('result').first.text == '0:OK') {
    //print(document.findAllElements('data').first.innerText);
    return document
        .findAllElements('data')
        .first
        .innerText
        .replaceAll('[[', ']]');
  } else {
    return '';
  }
}

Future<bool> sendRegister(context, x) async {
  var myUrl = 'https://' + approShop + '.catbuilder.info/catalogs/wsam.asp';
  var cXML = '<?xml version="1.0" encoding="UTF-8" ?>';
  cXML += '<dbsync>';
  cXML += '<header>';
  cXML += '<sender><credential><client>appro724</client><identity>' +
      approUser +
      '</identity><sharedsecret>' +
      approCredential +
      '</sharedsecret></credential></sender>';
  cXML += '</header>';
  cXML += '<request>';
  cXML += '<type>sendregister</type>';
  cXML += '<language>' + approLanguage + '</language>';
  cXML += '<par1>' +
      XmlToken.openCDATA +
      XmlText(x).toString() +
      XmlToken.closeCDATA +
      '</par1>';

  cXML += '</request>';
  cXML += '</dbsync>';
  showCupertinoModalPopup(
      context: context,
      useRootNavigator: false,
      builder: (context) => Container(
          color: Colors.white.withOpacity(0.5),
          child: Center(child: CircularProgressIndicator())));
  http.Response response = await http.post(Uri.parse(myUrl), body: cXML);
  Navigator.pop(context);
  //print(response.body);
  var document = XmlDocument.parse(response.body);
  if (document.findAllElements('result').first.innerText == '0:OK') {
    if (document.findAllElements('message').length > 0) {
      final snackBar = SnackBar(
        duration: Duration(seconds: 10),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        behavior: SnackBarBehavior.fixed,
        content: Text(document.findAllElements('message').first.innerText),
        action: SnackBarAction(
          label: AppLocalizations.of(context).hide,
          onPressed: () {},
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    return true;
  }
  if (document.findAllElements('result').first.innerText == '3:MSG') {
    final snackBar = SnackBar(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      behavior: SnackBarBehavior.fixed,
      content: Text(document.findAllElements('message').first.innerText),
      action: SnackBarAction(
        label: AppLocalizations.of(context).hide,
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  return false;
}

Future<bool> sendUnregister(context,x) async {
  var myUrl = 'https://' + approShop + '.catbuilder.info/catalogs/wsam.asp';
  var cXML = '<?xml version="1.0" encoding="UTF-8" ?>';
  cXML += '<dbsync>';
  cXML += '<header>';
  cXML += '<sender><credential><client>appro724</client><identity>' +
      approUser +
      '</identity><sharedsecret>' +
      approCredential +
      '</sharedsecret></credential></sender>';
  cXML += '</header>';
  cXML += '<request>';
  cXML += '<type>dropregistration</type>';
  cXML += '<language>' +  Localizations.localeOf(context).toString() + '</language>';
  cXML += '<par1>' +
      XmlToken.openCDATA +
      XmlText(x).toString() +
      XmlToken.closeCDATA +
      '</par1>';

  cXML += '</request>';
  cXML += '</dbsync>';
  showCupertinoModalPopup(
      context: context,
      useRootNavigator: false,
      builder: (context) => Container(
          color: Colors.white.withOpacity(0.5),
          child: Center(child: CircularProgressIndicator())));
  http.Response response = await http.post(Uri.parse(myUrl), body: cXML);
  Navigator.pop(context);
  //print(response.body);
  var document = XmlDocument.parse(response.body);
  if (document.findAllElements('result').first.innerText == '0:OK') {
    if (document.findAllElements('message').length > 0) {
      final snackBar = SnackBar(
        duration: Duration(seconds: 5),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        behavior: SnackBarBehavior.fixed,
        content: Text(document.findAllElements('message').first.innerText),
        action: SnackBarAction(
          label: AppLocalizations.of(context).hide,
          onPressed: () {
          },
        ),
      );
      final sstorage = new FlutterSecureStorage();
      approCredential = '';
      await sstorage.write(key: approShop, value: approCredential);
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    return true;
  }
  if (document.findAllElements('result').first.innerText == '3:MSG') {
    final snackBar = SnackBar(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      behavior: SnackBarBehavior.fixed,
      content: Text(document.findAllElements('message').first.innerText),
      action: SnackBarAction(
        label: AppLocalizations.of(context).hide,
        onPressed: () {},
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  return false;
}

int getCheckedCount() {
  int c = 0;
  basketChecked.forEach((b) {
    if(b.artnumint != 'comment') c++;
  });
  return c;
}


String getToken(s, t) {
  var tab = s.split('<' + t + '>');
  return tab.length > 1 ? tab[1].split('</' + t + '>')[0] : '';
}

String getItemToken(s, t, i) {
  var tab = s.split(t);
  return tab.length >= i ? tab[i - 1] : '';
}

String getText(s) {
  if (s == '' || s == null) return '';

  var i = approLanguages.indexOf(approLanguage);
  var tok = s.indexOf('<l>') == -1 ? '|' : '<l>';
  var tab = s.split(tok);
  if (i > -1 && i < tab.length) return tab[i];
  return tab[0];
}

String formatXml(xml) {
  xml = xml.replaceAll('&#', '()#()');
  xml = xml.replaceAll('&', '&amp; ');
  xml = xml.replaceAll('()#()', '&#');
  xml = xml.replaceAll('<', '&lt;');
  xml = xml.replaceAll('>', '&gt;');
  xml = xml.replaceAll('"', '&quot;');
  xml = xml.replaceAll("´", '&apos;');
  xml = xml.replaceAll("'", '&apos;');
  return xml;
}

class BasketStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    //print('$path/appro724basket.json');
    return File('$path/appro724basket.json');
  }

  readBasket() async {
    try {
      final file = await _localFile;
      // Read the file
      String contents = await file.readAsString();
      final jsonContents = json.decode(contents);
      var rows = jsonContents["rows"] as List;
      //print(rows);
      var map = rows.map<BasketDetail>((e) => BasketDetail.fromJson(e));
      basketChecked = map.toList();
      globals.basketCounter.value = basketChecked.length;
    } catch (e) {}
  }

  Future<File> writeBasket(List<BasketDetail> b) async {
    final file = await _localFile;
    Map<String, dynamic> _json = {};
    String contents = '';
    b.forEach((e) {
      _json.addAll(e.toJson());
      if (contents != '') contents += ',';
      contents += jsonEncode(_json);
    });
    //print('['+contents+']');
    return file.writeAsString('{"rows":[$contents]}');
  }
}

class Basket {
  final String basnum;
  final String basdes;
  final String basval;
  final String bastyp;
  final String basdat;

  Basket(this.basnum, this.basdes, this.basval, this.bastyp, this.basdat);

  Basket.fromJson(Map<String, dynamic> json)
      : basnum = json['basnum'],
        basdes = json['basdes'],
        basval = json['basval'],
        bastyp = json['bastyp'],
        basdat = json['basdat'];

  Map<String, dynamic> toJson() => {
        'basnum': basnum,
        'basdes': basdes,
        'basval': basval,
        'bastyp': bastyp,
        'basdat': basdat
      };
}

class BasketDetail {
  final String artnumint;
  final String artnum;
  String artdes;
  final String nodnum;
  final String artimg;
  String repcod;
  int artqty;
  bool checked;
  bool newchecked = false;
  int status = 0;
  String artpri;
  String artbes;
  String artuni = '';
  String artorduni = '';
  String artoul = '';
  String artsto = '';
  String artstofla = '';
  List<String> nodimg = [];
  String artinf = '';
  List<String> artpdf = [];
  String artpac = '';


  BasketDetail(this.artnum, this.artdes, this.nodnum, this.checked, this.artqty,
      this.artnumint, this.artimg, this.repcod, this.artpdf);

  BasketDetail.fromJson(Map<String, dynamic> json)
      : artnum = json['artnum'],
        artdes = json['artdes'],
        nodnum = json['nodnum'],
        checked = json['checked'],
        artqty = json['artqty'],
        artnumint = json['artnumint'],
        artimg = json['artimg'],
        repcod = json['repcod'],
        artorduni = json['artorduni'],
        artoul = json['artoul'],
        artpac = json['artpac'];

  Map<String, dynamic> toJson() => {
        'artnum': artnum,
        'artdes': artdes,
        'nodnum': nodnum,
        'checked': checked,
        'artqty': artqty,
        'artnumint': artnumint,
        'artimg': artimg,
        'repcod': repcod,
        'artorduni': artorduni,
        'artoul': artoul,
        'artpac': artpac
  };

  String toText() =>
      artnum +
      '\t' +
      artdes +
      '\t' +
      nodnum +
      '\t' +
      checked.toString() +
      '\t' +
      artqty.toString() +
      '\t' +
      artnumint +
      '\t' +
      artimg +
      '\t' +
      repcod;

  BasketDetail.fromText(String t)
      : artnum = t.split('~t')[1],
        artdes = t.split('~t')[2],
        nodnum = t.split('~t')[3],
        checked = (t.split('~t')[4] == 'true'),
        artqty = int.parse(t.split('~t')[5]),
        artnumint = t.split('~t')[6],
        artimg = t.split('~t')[7];
}

class CatLevel {
  final String nodnum;
  final String noddes;
  final String nodimg;
  final XmlNode xmlnod;
  final int nodtyp;
  final String nodurl;

  CatLevel(this.nodnum, this.noddes, this.nodimg, this.xmlnod, this.nodtyp,
      this.nodurl);
}

class CatNode {
  final String nodnum;
  final String noddes;
  final String nodimg;
  final String nodcat;
  final String nodurl;
  CatNode(this.nodnum, this.noddes, this.nodimg, this.nodcat, this.nodurl);
}

class Product {
  String sheet;
  Product(this.sheet);
}

class CompanyUser {
  final String usemai;
  CompanyUser(this.usemai);
}

class InfoNews {
  final String inftit;
  final String infdet;
  final String infimg;
  final String inflin;
  final String infact;
  final DateTime infbeg;
  final DateTime infend;
  int infsta = 0;

  InfoNews(this.inftit, this.infdet, this.infimg, this.inflin, this.infact,
      this.infbeg, this.infend);

  InfoNews.fromJson(Map<String, dynamic> json)
      : inftit = json['inftit'],
        infdet = json['infdet'],
        infimg = json['infimg'],
        inflin = json['inflin'],
        infact = json['infact'],
        infbeg = DateTime.parse(json['infbeg']),
        infend = DateTime.parse(json['infend']),
        infsta = json['infsta'];

  Map<String, dynamic> toJson() => {
        'inftit': inftit,
        'infdet': infdet,
        'infimg': infimg,
        'inflin': inflin,
        'infact': infact,
        'infbeg': infbeg.toString(),
        'infend': infend.toString(),
        'infsta': infsta
      };
}

class InfoNewsStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    //print(path);
    return File('$path/appro724infonews.json');
  }

  readInfoNews() async {
    try {
      final file = await _localFile;
      // Read the file
      String contents = await file.readAsString();
      final jsonContents = json.decode(contents);
      var rows = jsonContents["rows"] as List;
      //print(rows);
      var map = rows.map<InfoNews>((e) => InfoNews.fromJson(e));
      infoNews = map.toList();
      globals.infoCounter.value =
          infoNews.where((r) => r.infsta == 0).toList().length;
    } catch (e) {}
  }

  Future<File> writeInfoNews(List<InfoNews> b) async {
    final file = await _localFile;
    Map<String, dynamic> _json = {};
    String contents = '';
    b.forEach((e) {
      _json.addAll(e.toJson());
      if (contents != '') contents += ',';
      contents += jsonEncode(_json);
    });
    //print('['+contents+']');
    return file.writeAsString('{"rows":[$contents]}');
  }
}

class ReturnFunctionCode {
  final bool ok;
  final String msg;
  ReturnFunctionCode(this.ok, this.msg);
}
