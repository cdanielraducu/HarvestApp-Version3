import 'package:Harvest/providers/Punct.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';

class Mesaj with ChangeNotifier {
  final String titlu;
  final String data;
  final String pasaj;

  final String ideeaCentrala;
  final List<Punct> puncte;
  final MediaItem mediaItem;
  final String pdfUrl;
  final int durataMin;
  final int durataSec;

  Mesaj({
    @required this.titlu,
    @required this.data,
    @required this.pasaj,
    @required this.ideeaCentrala,
    @required this.puncte,
    @required this.mediaItem,
    this.pdfUrl = '',
    @required this.durataMin,
    @required this.durataSec,
  });
}
