import 'package:flutter/material.dart';

final basketCounter = ValueNotifier<int>(0);
final scanCounter = ValueNotifier<int>(0);
final infoCounter = ValueNotifier<int>(0);
final checkoutRefresh = ValueNotifier<bool>(false);
final searchRefresh = ValueNotifier<bool>(false);
final favoriteRefresh = ValueNotifier<bool>(false);
const menuActiveColor = const Color(0xFFFFFFFF);
const menuInactiveColor = const Color(0xffD8E5F5);
const artnumintColor = const Color(0xff2A3B8E); //Color(0xFFF44336);
const badgeColor = const Color(0xff2A3B8E); //Color(0xFFF44336);
