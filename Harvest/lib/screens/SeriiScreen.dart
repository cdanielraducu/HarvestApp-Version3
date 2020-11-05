import 'dart:io';

import 'package:Harvest/MpArguments.dart';
import 'package:Harvest/providers/Serie.dart';
import 'package:Harvest/providers/Serii.dart';
import 'package:Harvest/screens/MesajeScreen.dart';
import 'package:Harvest/screens/MpScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:parallax_image/parallax_image.dart';
import 'package:provider/provider.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

class SeriiScreen extends StatefulWidget {
  @override
  _SeriiScreenState createState() => _SeriiScreenState();
}

class _SeriiScreenState extends State<SeriiScreen> {
  Serii _seriiDataFromFirebase;
  var _loading = true;
  var imagesInit = false;
  List<File> fileStream = [];

  _updateSeriiData() {
    _update().then((_) {
      getSeriiDataFromFirebase(context).then((val) {
        setState(() {
          _seriiDataFromFirebase = val;
        });
        _getImages();
      });
    });
  }

  Future<void> _update() async {
    await Provider.of<Serii>(context).fetchAndSetSerii();
  }

  Future<Serii> getSeriiDataFromFirebase(BuildContext context) async {
    return Provider.of<Serii>(context);
  }

  _getImages() async {
    List<File> fileStreamInput = [];
    for (int i = 0; i < _seriiDataFromFirebase.serii.length; i++) {
      File readImage = await DefaultCacheManager()
          .getSingleFile(_seriiDataFromFirebase.serii[i].imageUrl);
      fileStreamInput.add(readImage);
    }
    setState(() {
      fileStream = fileStreamInput;
      _loading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(Duration.zero, () {
      _updateSeriiData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Harvest',
          style: TextStyle(
            fontFamily: 'PTSans',
            fontSize: 22,
          ),
        ),
        actions: <Widget>[
          Row(
            children: [
              Container(
                child: InkWell(
                  // onTap: () {
                  //   // print(_seriiDataFromFirebase.serii.first.mesaje.last.titlu);
                  //   Navigator.of(context).pushNamed(MpScreen.routeName,
                  //       arguments: MpArguments(
                  //         _seriiDataFromFirebase.serii.first.mesaje.last,
                  //         _seriiDataFromFirebase.serii.first.titlu,
                  //         _seriiDataFromFirebase.serii.first.imageUrlForMp,
                  //       ));
                  // },
                  child: Text(
                    'Ultima predica',
                    style: TextStyle(
                      fontFamily: 'PTSans',
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () {
                    // print(_seriiDataFromFirebase.serii.first.mesaje.last.titlu);
                    Navigator.of(context).pushNamed(MpScreen.routeName,
                        arguments: MpArguments(
                          _seriiDataFromFirebase.serii.first.mesaje.last,
                          _seriiDataFromFirebase.serii.first.titlu,
                          _seriiDataFromFirebase.serii.first.imageUrlForMp,
                        ));
                  },
                  child: Icon(
                    Icons.navigate_next,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _loading
          ? Stack(
              children: [
                Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Container(
                    //   child: Image.asset('lib/assets/harvest.png'),
                    //   width: 200,
                    //   height: 200,
                    // ),
                    Text(
                      'Se incarca seriile...',
                      style: TextStyle(
                          fontFamily: 'PTSans',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic),
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 4.0, top: 5.0),
                      child: LinearProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        backgroundColor: Colors.black26,
                      ),
                      width: 100,
                    )
                  ],
                ))
              ],
            )
          : _listaSerii(context),
    );
  }

  Widget _listaSerii(context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListView.builder(
        itemCount: _seriiDataFromFirebase.serii.length,
        itemBuilder: (context, index) {
          return _buildVerticalChild(
            context,
            index,
            _seriiDataFromFirebase,
            _seriiDataFromFirebase.serii.length,
          );
        },
      ),
    );
  }

  Widget _buildVerticalChild(
      BuildContext context, int i, Serii seriiData, int length) {
    if (i > length - 1) return null;
    Serie seriePrimita = seriiData.serii[i];
    i++;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 1.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push<void>(SwipeablePageRoute(
              builder: (_) => MesajeScreen(seriePrimita, fileStream[i - 1])));
        },
        child: Card(
          elevation: 10.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Stack(
              children: [
                Container(
                  color: Colors.transparent,
                  width: double.infinity,
                  foregroundDecoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                        Color(0x00000000),
                        Color(0x00000000),
                        // Color(0x3E3E3E3E),
                        // Color(0xff000000),
                      ])),
                  child: Container(
                    height: 160.0,
                    child: ParallaxImage(
                      image: FileImage(fileStream[i - 1]),
                      extent: 160.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
