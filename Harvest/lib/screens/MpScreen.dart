import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:Harvest/MediaPlayerItem.dart';
import 'package:Harvest/MpArguments.dart';
import 'package:Harvest/OpenItem.dart';
import 'package:Harvest/providers/Mesaj.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:marquee/marquee.dart';
import 'package:url_launcher/url_launcher.dart';

class MpScreen extends StatefulWidget {
  static const routeName = '/mp';
  static const double pi = 3.1415926535897932;

  // final Mesaj mesaj;
  // final String imagine;

  // MpScreen(this.mesaj, this.imagine);

  @override
  _MpScreenState createState() => _MpScreenState();
}

class _MpScreenState extends State<MpScreen> {
  Mesaj mesaj;
  MediaItem mediaItemFromMesaj;
  String titlulSeriei;
  File imagine;
  String imagineUrl;
  var _loadingImagine = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(Duration.zero, () {
      MpArguments mpArguments =
          ModalRoute.of(context).settings.arguments as MpArguments;
      mesaj = mpArguments.mesajDeTrimis;
      imagineUrl = mpArguments.imagineDeIncarcat;
      titlulSeriei = mpArguments.titlulSeriei;
      mediaItemFromMesaj = mesaj.mediaItem;
    }).then((_) {
      _getImagine();
    });
  }

  _getImagine() async {
    var imagineFromCache =
        await DefaultCacheManager().getSingleFile(imagineUrl);
    setState(() {
      imagine = imagineFromCache;
      _loadingImagine = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.grey,
          primaryColor: Colors.black,
        ),
        routes: {},
        home: _loadingImagine
            ? Center(child: CircularProgressIndicator())
            : MainScreen(
                mesaj, mediaItemFromMesaj, context, imagine, titlulSeriei),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final MediaItem mediaItemFromMesaj;
  final Mesaj mesaj;
  final BuildContext contextMpScreen;
  final File imagine;
  final String titlulSeriei;
  MainScreen(this.mesaj, this.mediaItemFromMesaj, this.contextMpScreen,
      this.imagine, this.titlulSeriei);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    String ideiContent = '';
    int j = 1;
    widget.mesaj.puncte.forEach((punct) {
      String i = '    ' + j.toString() + '. ';
      ideiContent += i + punct.titluPunct;
      j++;
      ideiContent += '\n';
    });

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              stops: [0.1, 0.9],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xffCCA870),
                Color(0xff54452E),
              ],
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      top: 30,
                    ),
                    child: IconButton(
                      iconSize: 25,
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () =>
                          Navigator.of(widget.contextMpScreen).pop(),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      top: 25,
                    ),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'PTSans',
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: 'Se reda din seria\n',
                          ),
                          TextSpan(
                            text: widget.titlulSeriei,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  // child: IconButton(
                  //   onPressed: () {
                  //     print('open spotify link');
                  //     PdfItem pdfItem = PdfItem(
                  //         'https://open.spotify.com/episode/0o3H7OVF7z4iBfYS2H43M0?si=pRuqja7RQ-uF-MTXnll3yg');

                  //   },
                  //   icon: Icon(
                  //     Icons.apps,
                  //     color: Colors.white,
                  //   ),
                  // ),
                  Container(
                    padding: EdgeInsets.only(top: 30, right: 5),
                    child: PopupMenuButton<int>(
                      color: Color(0xffCCA870),
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 30,
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 1,
                          child: Text(
                            'Deschide cu Spotify',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'PTSans',
                              fontSize: 16,
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: 2,
                          child: Text(
                            'Deschide cu Soundcloud',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'PTSans',
                              fontSize: 16,
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: 3,
                          child: Text(
                            'Deschide intrebari',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'PTSans',
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 1:
                            {
                              _launchInBrowser(
                                  'https://open.spotify.com/episode/0o3H7OVF7z4iBfYS2H43M0?si=pRuqja7RQ-uF-MTXnll3yg');
                              // make a toast
                              break;
                            }
                          case 2:
                            {
                              _launchInBrowser(
                                  'https://soundcloud.com/harvestbucuresti/fiti-devotati-unii-altora-evrei-1019-25');
                              // make a toast
                              break;
                            }
                          case 3:
                            {
                              _launchInBrowser(
                                  'https://harvestbucuresti.ro/wp-content/uploads/2020/06/Serie-%C3%8En-Ora%C5%9F-%C3%8Endemna%C5%A3i-S%C4%83-Practic%C4%83m-Ce-Am-Devenit-%C3%8Entreb%C4%83ri-GM.pdf');
                              // make a toast
                              break;
                            }
                          default:
                            break;
                        }
                      },
                    ),
                  ),
                  // DropdownButtonHideUnderline(
                  //     child: DropdownButton(
                  //   dropdownColor: Color(0xffCCA870),
                  //   value: Icon(
                  //     Icons.apps,
                  //     color: Colors.white,
                  //   ),
                  //   iconSize: 20,
                  //   items: [
                  //     DropdownMenuItem(
                  //       child: Container(
                  //         padding: EdgeInsets.only(
                  //           right: 10,
                  //           top: 25,
                  //         ),
                  //         child: OpenItem(
                  //             'https://open.spotify.com/episode/0o3H7OVF7z4iBfYS2H43M0?si=pRuqja7RQ-uF-MTXnll3yg'),
                  //       ),
                  //       value: 'Open spotify',
                  //     ),
                  //     DropdownMenuItem(
                  //       child: Container(
                  //         padding: EdgeInsets.only(
                  //           right: 10,
                  //           top: 25,
                  //         ),
                  //         child: OpenItem(
                  //             'https://open.spotify.com/episode/0o3H7OVF7z4iBfYS2H43M0?si=pRuqja7RQ-uF-MTXnll3yg'),
                  //       ),
                  //       value: 'Open spotify',
                  //     )
                  //   ],
                  // ))
                ],
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 30,
                  bottom: 30,
                ),
                // left: 25,
                //MediaQuery.of(context).size.width * 0.063,
                // top: 108,
                //MediaQuery.of(context).size.height * 0.147,
                // height: 344,
                // width: 344,
                //MediaQuery.of(context).size.width * 0.878,
                child: Image.file(
                  widget.imagine,
                ),
              ),
              titluWidget(),
              Container(
                padding: EdgeInsets.only(right: 75, bottom: 40),
                width: MediaQuery.of(context).size.width - 50,
                child: Text(
                  widget.mediaItemFromMesaj.artist,
                  style: TextStyle(
                    fontFamily: 'PTSans',
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Container(
              //       padding: EdgeInsets.only(
              //         left: 25,
              //         bottom: 30,
              //       ),
              //       child: Column(
              //         children: [
              //           Container(
              //             alignment: Alignment.centerLeft,
              //             child: RichText(
              //               text: TextSpan(children: [
              //                 TextSpan(
              //                   text: widget.mediaItemFromMesaj.title + '\n',
              //                   style: TextStyle(
              //                     fontFamily: 'PTSans',
              //                     color: Colors.white,
              //                     fontSize: 20,
              //                     fontWeight: FontWeight.bold,
              //                   ),
              //                 ),
              //                 TextSpan(
              //                   text: widget.mediaItemFromMesaj.artist,
              //                   style: TextStyle(
              //                     fontFamily: 'PTSans',
              //                     color: Colors.white.withOpacity(0.8),
              //                     fontSize: 14,
              //                   ),
              //                 )
              //               ]),
              //             ),
              //           )
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
              MediaPlayerItem(widget.mesaj),
              Container(
                width: MediaQuery.of(context).size.width - 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Color(0xffCCA870),
                ),
                child: Container(
                  padding:
                      EdgeInsets.only(top: 10, bottom: 10, left: 25, right: 25),
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: 'Ideea centrala: \n\n',
                        style: TextStyle(
                          fontFamily: 'PTSans',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                      TextSpan(
                        text: widget.mesaj.ideeaCentrala + '\n',
                        style: TextStyle(
                          fontFamily: 'PTSans',
                          fontSize: 17,
                        ),
                      ),
                      TextSpan(
                        text: ideiContent,
                        style: TextStyle(
                          fontFamily: 'PTSans',
                          fontSize: 16,
                        ),
                      )
                    ]),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget titluWidget() {
    RenderParagraph textForCheckInfinite = RenderParagraph(
      TextSpan(
        text: widget.mediaItemFromMesaj.title,
        style: TextStyle(
          fontFamily: 'PTSans',
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );

    double textLen =
        textForCheckInfinite.getMinIntrinsicWidth(20).ceilToDouble();

    if (textLen > MediaQuery.of(context).size.width - 125) {
      print('aaaaa');
      return Container(
        padding: EdgeInsets.only(right: 75),
        width: MediaQuery.of(context).size.width - 50,
        height: 25,
        child: Marquee(
          text: widget.mediaItemFromMesaj.title,
          style: TextStyle(
            fontFamily: 'PTSans',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          scrollAxis: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          blankSpace: 75,
          velocity: 50.0,
        ),
      );
    } else {
      print('bbbbb');
      return Container(
        padding: EdgeInsets.only(right: 75),
        width: MediaQuery.of(context).size.width - 50,
        child: Text(
          widget.mediaItemFromMesaj.title,
          style: TextStyle(
            fontFamily: 'PTSans',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.start,
        ),
      );
    }
  }
}
