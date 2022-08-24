import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'theme.dart';
import 'restart.dart';
import 'screens.dart';
import 'wsam.dart';
import 'theme_changer.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info/package_info.dart';

//generate splashscreen >>>  flutter pub pub run flutter_native_splash:create
//generate icon >>> flutter pub run flutter_launcher_icons:main
// flutter run --debug
// flutter config --no-enable-web
// open /Applications/Android\ Studio.app sur macincloud

void main() {
  runApp(RestartWidget(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeChanger(myTheme)),
      ],
      child: MaterialAppWithTheme(),
    );
  }
}

class MaterialAppWithTheme extends StatelessWidget {
  @override

  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    return MaterialApp(
      theme: theme.getTheme,
      home: MainMenu(),
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: [
        const Locale('en', ''), // English, no country code
        const Locale('fr', ''), // French, no country code
        const Locale('nl', ''), // Dutch, no country code
        const Locale('de', ''), // German, no country code
      ],
    );
  }
}

class MainMenu extends StatefulWidget {
  MainMenu({Key key}) : super(key: key);

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  final pswController = ObscuringTextEditingController();
  final msgController = TextEditingController();
  var _themeProvider;
  String _token;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  @override
  void initState() {
    super.initState();
    getPref();
  }

  void _setTheme() {
    _themeProvider.setTheme(myTheme.copyWith(
        textTheme: myTheme.textTheme.copyWith(
            subtitle1: myTheme.textTheme.subtitle1.copyWith(
      fontSize: approDataTextSize * 1.0,
    ))));
  }

  void dispose() async {
    var storage = new BasketStorage();
    storage.writeBasket(basketChecked);
    // Clean up the controller when the widget is disposed.
    emailController.dispose();
    codeController.dispose();
    pswController.dispose();

    super.dispose();
  }

  void getPref() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    approVersion = packageInfo.version;

    final SharedPreferences prefs = await _prefs;
    emailController.text = prefs.get('user');
    codeController.text = prefs.get('shop');
    setState(() {
      approLogo = prefs.get(codeController.text + '-logo');
      if (approLogo == null) approLogo = '';
      //print(codeController.text + '-shop' + ':' + approLogo);
    });
    pswController.text = '';
    var _shortestSide = MediaQuery.of(context).size.shortestSide;

    setState(() {
      approDataTextSize = prefs.getInt('datatextsize');
      approThumbSizeRatio = prefs.getDouble('thumbsizeratio');
      if(_shortestSide < 600) {
        approDataTextSize = approDataTextSize == null ? 12 : approDataTextSize;
        approThumbSizeRatio =
        approThumbSizeRatio == null ? 1 : approThumbSizeRatio;
      } else {
        approDataTextSize = approDataTextSize == null ? 14 : approDataTextSize;
        approThumbSizeRatio =
        approThumbSizeRatio == null ? 1.5 : approThumbSizeRatio;
      }
    });
    final sstorage = new FlutterSecureStorage();
    //print(await sstorage.readAll());

    _token = await sstorage.read(key: codeController.text);
    if (_token != null) {
      //Vérifier faceid ou finger print
      var localAuth = LocalAuthentication();
      bool canCheckBiometrics = await localAuth.canCheckBiometrics;
      if (canCheckBiometrics) {
        bool didAuthenticate = false;
        try {
          didAuthenticate = await localAuth.authenticate(
              options: AuthenticationOptions(biometricOnly: true,),
              localizedReason: AppLocalizations.of(context).faceid);
        } on PlatformException catch (e) {
          if (e.code == auth_error.notAvailable) {
            //print('authenticate notAvailable');
          } else {
            //print(e.code);
          }
        }
        if (didAuthenticate) {
          login(true);
          _setTheme();
        }
      }
    }
  }

  void login(bool bfaceid) async {
    msgController.text = '';
    if (bfaceid) {
      if (codeController.text == '' || emailController.text == '') {
        msgController.text = AppLocalizations.of(context).fieldsmandatory;
        return;
      }
    } else {
      if (codeController.text == '' ||
          emailController.text == '' ||
          pswController.text == '') {
        msgController.text = AppLocalizations.of(context).fieldsmandatory;
        return;
      }
    }
    showCupertinoModalPopup(
        context: context,
        useRootNavigator: false,
        builder: (context) => Container(
            color: Colors.white.withOpacity(0.5),
            child: Center(child: CircularProgressIndicator())));

    final result = await getCredential(emailController.text, pswController.text,
        codeController.text, context, _token);
    Navigator.pop(context);
    if (result.ok) {
      final SharedPreferences prefs = await _prefs;
      prefs.setString('user', emailController.text);
      prefs.setString('shop', codeController.text);
      var route = MaterialPageRoute(
        settings: RouteSettings(name: '/'),
        builder: (BuildContext context) =>
            MainTabState(menuScreenContext: context),
      );
      Navigator.of(context).push(route);
    } else {
      FocusScope.of(context).requestFocus(FocusNode());
      msgController.text = result.msg;
    }
  }

  Widget build(BuildContext context) {
    SizeConfig().init(context);
    _themeProvider = Provider.of<ThemeChanger>(context);
    return Scaffold(
      appBar: AppBar(
          title:
              Text("Catbuilder Appro 7/24", style: TextStyle(fontSize: 18.0)),
          centerTitle: true),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 20.0),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: CupertinoTextField(
                  prefix: Icon(
                    CupertinoIcons.mail_solid,
                    color: CupertinoColors.secondaryLabel,
                    size: 24,
                  ),
                  controller: emailController,
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
                  placeholder: AppLocalizations.of(context).email,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: CupertinoTextField(
                  prefix: Icon(
                    CupertinoIcons.padlock,
                    color: CupertinoColors.secondaryLabel,
                    size: 24,
                  ),
                  controller: pswController,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  obscureText: false,
                  clearButtonMode: OverlayVisibilityMode.editing,
                  keyboardType: TextInputType.visiblePassword,
                  autocorrect: false,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 0,
                        color: CupertinoColors.inactiveGray,
                      ),
                    ),
                  ),
                  placeholder: AppLocalizations.of(context).password,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: CupertinoTextField(
                  prefix: Icon(
                    CupertinoIcons.house,
                    color: CupertinoColors.secondaryLabel,
                    size: 24,
                  ),
                  controller: codeController,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  clearButtonMode: OverlayVisibilityMode.editing,
                  keyboardType: TextInputType.text,
                  autocorrect: false,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 0,
                        color: CupertinoColors.inactiveGray,
                      ),
                    ),
                  ),
                  placeholder: AppLocalizations.of(context).shopcode,
                ),
              ),
              SizedBox(height: 20.0),
              Center(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.login_sharp),
                  label: Text(AppLocalizations.of(context).login),
                  onPressed: () {
                    _setTheme();
                    login(false);
                  },
                ),
              ),
              SizedBox(height: 10.0),
              Center(
                child: TextField(
                  maxLines: 2,
                  controller: msgController,
                  readOnly: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red,
                  ),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none),
                ),
              ),
              SizedBox(height: 10.0),
              Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: 128,
                      minHeight: 128,
                      maxWidth: 200,
                      maxHeight: 128,
                    ),
                    child: FadeInImage(
                      imageErrorBuilder: (BuildContext context,
                          Object exception, StackTrace stackTrace) {
                        //print('Error Handler');
                        return Container(
                          width: 100.0,
                          height: 100.0,
                          child: Image.asset('images/nopicture.jpg'),
                        );
                      },
                      placeholder: AssetImage('images/pixel.gif'),
                      image: approLogo == ''
                          ? AssetImage('images/cat192.png')
                          : NetworkImage(approLogo),
                      fit: BoxFit.contain,
                      height: 200.0,
                      width: 200.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ObscuringTextEditingController extends TextEditingController {
  @override
  TextSpan buildTextSpan(
      {BuildContext context, TextStyle style, bool withComposing}) {
    var displayValue = '•' * value.text.length;
    if (!value.composing.isValid || !withComposing) {
      return TextSpan(style: style, text: displayValue);
    }
    final TextStyle composingStyle = style.merge(
      const TextStyle(decoration: TextDecoration.underline),
    );
    return TextSpan(
      style: style,
      children: <TextSpan>[
        TextSpan(text: value.composing.textBefore(displayValue)),
        TextSpan(
          style: composingStyle,
          text: value.composing.textInside(displayValue),
        ),
        TextSpan(text: value.composing.textAfter(displayValue)),
      ],
    );
  }
}
