// @dart=2.9
import 'package:flutter/material.dart';


  class SizeConfig {
    static MediaQueryData _mediaQueryData;
    static double screenWidth;
    static double screenHeight;
    static double blockSizeHorizontal;
    static double blockSizeVertical;

    void init(BuildContext context) {
      _mediaQueryData = MediaQuery.of(context);
      screenWidth = _mediaQueryData.size.width;
      screenHeight = _mediaQueryData.size.height;
      blockSizeHorizontal = screenWidth / 100;
      blockSizeVertical = screenHeight / 100;
    }
  }

  final ThemeData myTheme = ThemeData(
    primarySwatch: MaterialColor(4289400352,{50: Color( 0xfffde7ea )
		, 100: Color( 0xfffbd0d5 )
		, 200: Color( 0xfff7a1ab )
		, 300: Color( 0xfff37280 )
		, 400: Color( 0xfff04256 )
		, 500: Color( 0xffec132c )
		, 600: Color( 0xffbd0f23 )
		, 700: Color( 0xff8d0c1a )
		, 800: Color( 0xff5e0812 )
		, 900: Color( 0xff2f0409 )
		}),
    brightness: Brightness.light,
    primaryColor: Color( 0xffab0e20 ),
    primaryColorLight: Color( 0xfffbd0d5 ),
    primaryColorDark: Color( 0xff8d0c1a ),
    canvasColor: Color( 0xfffafafa ),
    scaffoldBackgroundColor: Color( 0xfffafafa ),
    bottomAppBarTheme: BottomAppBarTheme (color: Color(0xffab0e20)),
    cardColor: Color( 0xffffffff ),
    dividerColor: Color( 0x1f000000 ),
    highlightColor: Color( 0x66bcbcbc ),
    splashColor: Color( 0x66c8c8c8 ),
    unselectedWidgetColor: Color( 0x8a000000 ),
    disabledColor: Color( 0x61000000 ),
    secondaryHeaderColor: Color( 0xfffde7ea ),
    dialogBackgroundColor: Color( 0xffffffff ),
    indicatorColor: Color( 0xffec132c ),
    hintColor: Color( 0x8a000000 ),
    buttonTheme: ButtonThemeData(
      textTheme: ButtonTextTheme.normal,
      minWidth: 88,
      height: 36,
      padding: EdgeInsets.only(top:0,bottom:0,left:16, right:16),
      shape:     RoundedRectangleBorder(
      side: BorderSide(color: Color( 0xff000000 ), width: 0, style: BorderStyle.none, ),
      borderRadius: BorderRadius.all(Radius.circular(2.0)),
    )
 ,
      alignedDropdown: false ,
      buttonColor: Color( 0xffe0e0e0 ),
      disabledColor: Color( 0x61000000 ),
      highlightColor: Color( 0x29000000 ),
      splashColor: Color( 0x1f000000 ),
      focusColor: Color( 0x1f000000 ),
      hoverColor: Color( 0x0a000000 ),
      colorScheme: ColorScheme(
        primary: Color( 0xffab0e20 ),
        secondary: Color( 0xffec132c ),
        surface: Color( 0xffffffff ),
        background: Color( 0xfff7a1ab ),
        error: Color( 0xffd32f2f ),
        onPrimary: Color( 0xffffffff ),
        onSecondary: Color( 0xffffffff ),
        onSurface: Color( 0xff000000 ),
        onBackground: Color( 0xffffffff ),
        onError: Color( 0xffffffff ),
        brightness: Brightness.light,
      ),
    ),
    textTheme: TextTheme(
      bodySmall: TextStyle(
      color: Color( 0x8a000000 ),
      fontSize: null,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    ),
      labelLarge: TextStyle(
      color: Color( 0xdd000000 ),
      fontSize: null,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    ),
      labelSmall: TextStyle(
      color: Color( 0xff000000 ),
      fontSize: null,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    ),
    ),
    primaryTextTheme: TextTheme(
      bodySmall: TextStyle(
      color: Color( 0xb3ffffff ),
      fontSize: null,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    ),
      labelLarge: TextStyle(
      color: Color( 0xffffffff ),
      fontSize: null,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    ),
      labelSmall: TextStyle(
      color: Color( 0xffffffff ),
      fontSize: null,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    ),
    ),

    inputDecorationTheme:   InputDecorationTheme(
    labelStyle: TextStyle(
      color: Color( 0xdd000000 ),
      fontSize: null,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    ),
    helperStyle: TextStyle(
      color: Color( 0xdd000000 ),
      fontSize: null,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    ),
    hintStyle: TextStyle(
      color: Color( 0xdd000000 ),
      fontSize: null,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    ),
    errorStyle: TextStyle(
      color: Color( 0xdd000000 ),
      fontSize: null,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    ),
    errorMaxLines: null,
    isDense: false,
    contentPadding: EdgeInsets.only(top:12,bottom:12,left:0, right:0),
    isCollapsed : false,
    prefixStyle: TextStyle(
      color: Color( 0xdd000000 ),
      fontSize: null,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    ),
    suffixStyle: TextStyle(
      color: Color( 0xdd000000 ),
      fontSize: null,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    ),
    counterStyle: TextStyle(
      color: Color( 0xdd000000 ),
      fontSize: null,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    ),
    filled: false,
    fillColor: Color( 0x00000000 ),
    errorBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Color( 0xff000000 ), width: 1, style: BorderStyle.solid, ),
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Color( 0xff000000 ), width: 1, style: BorderStyle.solid, ),
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    ),
    focusedErrorBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Color( 0xff000000 ), width: 1, style: BorderStyle.solid, ),
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    ),
    disabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Color( 0xff000000 ), width: 1, style: BorderStyle.solid, ),
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Color( 0xff000000 ), width: 1, style: BorderStyle.solid, ),
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    ),
    border: UnderlineInputBorder(
      borderSide: BorderSide(color: Color( 0xff000000 ), width: 1, style: BorderStyle.solid, ),
      borderRadius: BorderRadius.all(Radius.circular(4.0)),
    ),
  ),
    iconTheme: IconThemeData(
      color: Color( 0xdd000000 ),
      opacity: 1,
      size: 24,
    ),
    primaryIconTheme: IconThemeData(
      color: Color( 0xffffffff ),
      opacity: 1,
      size: 24,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: null,
      inactiveTrackColor: null,
      disabledActiveTrackColor: null,
      disabledInactiveTrackColor: null,
      activeTickMarkColor: null,
      inactiveTickMarkColor: null,
      disabledActiveTickMarkColor: null,
      disabledInactiveTickMarkColor: null,
      thumbColor: null,
      disabledThumbColor: null,
      thumbShape: null,
      overlayColor: null,
      valueIndicatorColor: null,
      valueIndicatorShape: null,
      showValueIndicator: null,
      valueIndicatorTextStyle: TextStyle(
      color: Color( 0xffffffff ),
      fontSize: null,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    ),
    ),
    tabBarTheme: TabBarTheme(
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: Color( 0xffffffff ),
      unselectedLabelColor: Color( 0xb2ffffff ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Color( 0x1f000000 ),
      brightness: Brightness.light,
      deleteIconColor: Color( 0xde000000 ),
      disabledColor: Color( 0x0c000000 ),
      labelPadding: EdgeInsets.only(top:0,bottom:0,left:8, right:8),
      labelStyle: TextStyle(
      color: Color( 0xde000000 ),
      fontSize: null,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    ),
      padding: EdgeInsets.only(top:4,bottom:4,left:4, right:4),
      secondaryLabelStyle: TextStyle(
      color: Color( 0x3d000000 ),
      fontSize: null,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
    ),
      secondarySelectedColor: Color( 0x3dab0e20 ),
      selectedColor: Color( 0x3d000000 ),
      shape: StadiumBorder( side: BorderSide(color: Color( 0xff000000 ), width: 0, style: BorderStyle.none, ) ),
    ),
    dialogTheme: DialogTheme(
      shape:     RoundedRectangleBorder(
      side: BorderSide(color: Color( 0xff000000 ), width: 0, style: BorderStyle.none, ),
      borderRadius: BorderRadius.all(Radius.circular(0.0)),
    )

    ),
  );
