import 'package:flutter/widgets.dart';

@immutable
class AppRadii {
  const AppRadii._();

  static const Radius r4 = Radius.circular(4);
  static const Radius r16 = Radius.circular(16);
  static const Radius r24 = Radius.circular(24);
  static const Radius r28 = Radius.circular(28);
  static const Radius r30 = Radius.circular(30);

  static const BorderRadius card = BorderRadius.all(r24);
  static const BorderRadius pill = BorderRadius.all(r30);
  static const BorderRadius image = BorderRadius.all(r28);
}










