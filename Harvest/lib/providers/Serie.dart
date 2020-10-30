import 'package:Harvest/providers/Mesaj.dart';
import 'package:flutter/foundation.dart';

class Serie with ChangeNotifier {
  final int index;
  final String titlu;
  final String data;
  final String pasaj;
  final String rezumat;
  final String imageUrl;
  final String imageUrlForMp;
  final List<Mesaj> mesaje;
  final String videoLink;

  Serie({
    @required this.index,
    @required this.titlu,
    @required this.data,
    @required this.pasaj,
    @required this.rezumat,
    @required this.imageUrl,
    @required this.imageUrlForMp,
    @required this.mesaje,
    @required this.videoLink,
  });
}
