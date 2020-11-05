import 'package:Harvest/providers/Mesaj.dart';
import 'package:Harvest/providers/Punct.dart';
import 'package:Harvest/providers/Serie.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';

class Serii with ChangeNotifier {
  List<Serie> _serii = [];

  List<Serie> get serii {
    return [..._serii];
  }

  Serie findByTitle(String titlu) {
    return _serii.firstWhere((element) => element.titlu == titlu);
  }

  Future<void> fetchAndSetSerii() async {
    print("a");
    // incarca seriile din baza de date de pe firebase
    const url = 'https://harvestmesaje2.firebaseio.com/Serii.json';
    // print(f.originalUrl);
    try {
      final response = await http.get(url);
      List<dynamic> extractedData = json.decode(response.body) as List<dynamic>;
      List<dynamic> extractedDataReversed = extractedData.reversed.toList();

      final List<Serie> loadedProducts = [];
      if (extractedDataReversed == null) {
        return;
      }

      extractedDataReversed.forEach((serieData) {
        List<Mesaj> mesaje = [];

        serieData['mesaje'].forEach((mesaj) {
          List<Punct> puncte = [];

          if (mesaj['Puncte'] != null) {
            mesaj['Puncte'].forEach((punct) {
              puncte.add(Punct(
                numar: punct['Numar'],
                titluPunct: punct['Titlu'],
              ));
            });
          }

          MediaItem mediaItem = MediaItem(
            id: mesaj['Audiolink'],
            album: serieData['titlu'],
            title: mesaj['Titlu'],
            artist: mesaj['Fratele'],
            duration: Duration(
              minutes: 20,
              seconds: 20,
            ),
            artUri: serieData['imageUrl'],
          );

          Mesaj mesajReceived = Mesaj(
            data: mesaj['Data'],
            ideeaCentrala: mesaj['IdeeaCentrala'],
            pasaj: mesaj['Pasaj'],
            titlu: mesaj['Titlu'],
            puncte: puncte,
            mediaItem: mediaItem,
            pdfUrl: mesaj['PdfUrl'],
            durataMin: mesaj['DurataMin'],
            durataSec: mesaj['DurataSec'],
          );

          mesaje.add(mesajReceived);
        });

        loadedProducts.add(Serie(
          index: serieData['index'],
          titlu: serieData['titlu'],
          data: serieData['data'],
          pasaj: serieData['pasaj'],
          rezumat: serieData['rezumat'],
          imageUrl: serieData['imageUrl'],
          imageUrlForMp: serieData['imageUrlForMp'],
          mesaje: mesaje,
          videoLink: serieData['videoLink'],
        ));

        _serii = loadedProducts;
      });
    } catch (error) {
      print(error);
      throw (error);
    }
  }

  getPosts(int offset, int limit) {
    return _serii.getRange(offset, limit);
  }
}
