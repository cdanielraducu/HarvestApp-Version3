import 'package:flutter/foundation.dart';

class Punct with ChangeNotifier {
  final String numar;
  final String titluPunct;

  Punct({
    @required this.numar,
    @required this.titluPunct,
  });
}
