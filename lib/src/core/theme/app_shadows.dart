import 'package:flutter/widgets.dart';

class AppShadow {
  const AppShadow._();

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.03),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> navTop = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.04),
      blurRadius: 10,
      offset: Offset(0, -4),
    ),
  ];

  static const List<BoxShadow> dialog = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.08),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
}
