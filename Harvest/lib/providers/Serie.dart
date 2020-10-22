import 'package:Harvest/providers/Mesaj.dart';
import 'package:flutter/foundation.dart';

class Serie with ChangeNotifier {
  final int index;
  final String titlu;
  final String data;
  final String pasaj;
  final String rezumat;
  final String imageUrl;
  final List<Mesaj> mesaje;

  Serie({
    @required this.index,
    @required this.titlu,
    @required this.data,
    @required this.pasaj,
    @required this.rezumat,
    @required this.imageUrl,
    @required this.mesaje,
  });
}
