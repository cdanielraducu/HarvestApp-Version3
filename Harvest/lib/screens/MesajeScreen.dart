import 'dart:io';

import 'package:Harvest/MpArguments.dart';
import 'package:Harvest/providers/Mesaj.dart';
import 'package:Harvest/providers/Serie.dart';
import 'package:Harvest/screens/MpScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:video_player/video_player.dart';

class MesajeScreen extends StatefulWidget {
  static const routeName = '/mesaje';
  final Serie serie;
  final File imagine;

  MesajeScreen(this.serie, this.imagine);

  @override
  _MesajeScreenState createState() => _MesajeScreenState();
}

class _MesajeScreenState extends State<MesajeScreen> {
  VideoPlayerController _controller;

  Icon playIcon = Icon(
    Icons.pause,
    color: Colors.black,
    size: 25,
  );

  Icon volumeIcon = Icon(
    Icons.volume_off,
    color: Colors.black,
    size: 20,
  );

  var hasVolume = false;

  File video;
  var _videoLoading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // pentru varianta cu file ( cached ) decomenteaza...
    // _getVideo().then((_) {
    // in loc de widget.serie.videolink pune video
    if (widget.serie.videoLink != null) {
      _controller = VideoPlayerController.network(widget.serie.videoLink)
        ..initialize().then((_) {
          //The mounted checks whether Whether this State object is currently in a tree
          if (this.mounted) {
            setState(() {
              _videoLoading = false;
            });
          }
        });
      _controller.addListener(checkVideo);
      _controller.setVolume(0.0);
      _controller.play();
    }
    // });
  }

  var _isVideoDisposed = false;

  void checkVideo() {
    if (_controller.value.position ==
        Duration(seconds: 0, minutes: 0, hours: 0)) {
      print('video Started');
    }

    if (_controller.value.position == _controller.value.duration) {
      print('video Ended');
      //The mounted checks whether Whether this State object is currently in a tree
      if (this.mounted) {
        setState(() {
          _videoLoading = true;
          _isVideoDisposed = true;
        });
      }
    }
  }

  Future<void> _getVideo() async {
    File readVideo =
        await DefaultCacheManager().getSingleFile(widget.serie.videoLink);
    setState(() {
      video = readVideo;
    });
    print(video);
  }

  volumeState() {
    setState(() {
      hasVolume
          ? {
              _controller.setVolume(0.0),
              hasVolume = false,
              volumeIcon = Icon(
                Icons.volume_off,
                color: Colors.black,
                size: 20,
              )
            }
          : {
              _controller.setVolume(100.0),
              hasVolume = true,
              volumeIcon = Icon(
                Icons.volume_up,
                color: Colors.black,
                size: 20,
              )
            };
    });
  }

  videoState() {
    setState(() {
      _controller.value.isPlaying
          ? {
              _controller.pause(),
              playIcon = Icon(
                Icons.play_arrow,
                color: Colors.black,
                size: 25,
              )
            }
          : {
              _controller.play(),
              playIcon = Icon(
                Icons.pause,
                color: Colors.black,
                size: 25,
              )
            };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 25,
            decoration: BoxDecoration(color: Colors.black),
          ),
          Stack(
            children: [
              Container(
                foregroundDecoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xff000000),
                      Color(0x1E1E1E1E),
                      Color(0x00000000),
                      Color(0x00000000),
                      Color(0x00000000),
                      Color(0x00000000),
                    ],
                  ),
                ),
                height: MediaQuery.of(context).size.height * 0.3,
                width: double.infinity,
                child: _videoLoading
                    ? Image.file(widget.imagine)
                    : Stack(
                        children: [
                          InkWell(
                            onTap: () => videoState(),
                            child: Container(
                              child: _controller.value.initialized
                                  ? AspectRatio(
                                      aspectRatio:
                                          _controller.value.aspectRatio,
                                      child: VideoPlayer(_controller),
                                    )
                                  : Container(),
                            ),
                          ),
                          Container(
                            alignment: Alignment.bottomLeft,
                            padding: EdgeInsets.only(left: 5.0),
                            child: RawMaterialButton(
                              constraints: BoxConstraints(
                                maxHeight: 50,
                                maxWidth: 50,
                              ),
                              onPressed: () => videoState(),
                              elevation: 2.0,
                              fillColor: Colors.white,
                              child: playIcon,
                              padding: EdgeInsets.all(4.0),
                              shape: CircleBorder(),
                            ),
                          ),
                          Container(
                            alignment: Alignment.bottomRight,
                            padding: EdgeInsets.only(right: 2.5),
                            child: RawMaterialButton(
                              constraints: BoxConstraints(
                                maxHeight: 40,
                                maxWidth: 40,
                              ),
                              onPressed: () => volumeState(),
                              elevation: 2.0,
                              fillColor: Colors.white,
                              child: volumeIcon,
                              padding: EdgeInsets.all(2.0),
                              shape: CircleBorder(),
                            ),
                          )
                        ],
                      ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 30,
                ),
                // child: Container(
                //   height: 40,
                //   decoration: BoxDecoration(
                //       shape: BoxShape.circle, color: Colors.white),
                //   child: IconButton(
                //     icon: Icon(Icons.arrow_back_ios),
                //     onPressed: () {
                //       Navigator.of(context).pop();
                //     },
                //   ),
                // ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
            alignment: Alignment.centerLeft,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  side: BorderSide(color: Colors.black54)),
              color: Colors.white,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      elevation: 16,
                      child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 18.0),
                          height: MediaQuery.of(context).size.height * 0.5,
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: Stack(
                            children: [
                              SingleChildScrollView(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Rezumat: ',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontFamily: 'PTSans',
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text: widget.serie.rezumat,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontFamily: 'PTSans',
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0.0,
                                right: 0.0,
                                child: Container(
                                  width: 25.0,
                                  height: 25.0,
                                  child: FloatingActionButton(
                                    backgroundColor: Colors.black54,
                                    child: Icon(
                                      Icons.close,
                                    ),
                                    onPressed: Navigator.of(context).pop,
                                  ),
                                ),
                              ),
                            ],
                          )),
                    );
                  },
                );
              },
              child: Text(
                'Rezumat',
                style: TextStyle(fontFamily: 'PTSans', fontSize: 16),
              ),
            ),
          ),
          Expanded(
            child: _listaMesaje(context, widget.serie),
          )
        ],
      ),
    );
  }

  Widget _listaMesaje(BuildContext context, Serie serie) {
    return Container(
      child: ListView.builder(
          padding: EdgeInsets.only(top: 0),
          itemBuilder: (ctx, index) {
            if (index == serie.mesaje.length) {
              return null;
            }
            Mesaj currentMesaj =
                serie.mesaje[serie.mesaje.length - (index + 1)];

            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _card(
                  context,
                  currentMesaj,
                  serie.mesaje.length - index,
                ),
                Divider(),
              ],
            );
          }),
    );
  }

  Widget _card(BuildContext context, Mesaj currentMesaj, int index) {
    return GestureDetector(
      onTap: () {
        print("clicked");
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.1,
        width: double.infinity,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(right: 50, left: 25),
              width: double.infinity,
              child: Text(
                '$index. ${currentMesaj.titlu}',
                style: TextStyle(
                  fontFamily: 'PTSans',
                  fontSize: 18.0,
                  color: Colors.black,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(right: 50, top: 50.0, left: 25),
              width: double.infinity,
              child: Text('${currentMesaj.data}'),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.8),
              child: IconButton(
                iconSize: 30.0,
                icon: Icon(Icons.navigate_next),
                color: Colors.black87,
                onPressed: () {
                  if (_isVideoDisposed != true) {
                    bool disposed = false;
                    if (_videoLoading) {
                      print("video is not shown on the screen");
                    } else {
                      print("video is shown on the screen");

                      _controller.seekTo(_controller.value.duration);

                      // se face deja la onDispose cand _loadingVideo == false
                      // _controller.dispose();

                      disposed = true;
                    }

                    if (!disposed) {
                      if (_controller.value.position ==
                          Duration(seconds: 0, minutes: 0, hours: 0)) {
                        _controller.removeListener(checkVideo);
                        _controller.dispose();
                      } else {
                        _controller.seekTo(_controller.value.duration);
                      }
                    }
                  }
                  _isVideoDisposed = true;
                  Navigator.of(context).pushNamed(
                    MpScreen.routeName,
                    arguments: MpArguments(
                      currentMesaj,
                      widget.serie.titlu,
                      widget.serie.imageUrlForMp,
                    ),
                  );

                  // .push<void>(SwipeablePageRoute(builder: (_) {

                  // if (_controller != null) {
                  //   // atunci cand mergem in alt screen oprim videoul
                  //   if (_controller.value.initialized) {
                  //     _controller.seekTo(_controller.value.duration);
                  //   } else if () {
                  //     _controller.seekTo(_controller.value.duration);
                  //   }

                  // }
                  // bool disposed = false;

                  //video loading is coming true before _controller starts
                  /// TODO: UN COMMENT
                  // if (_videoLoading) {
                  //   print("video is not shown on the screen");
                  // } else {
                  //   print("video is shown on the screen");

                  //   _controller.seekTo(_controller.value.duration);

                  //   // se face deja la onDispose cand _loadingVideo == false
                  //   // _controller.dispose();

                  //   disposed = true;
                  // }

                  // if (!disposed) {
                  //   if (_controller.value.position ==
                  //       Duration(seconds: 0, minutes: 0, hours: 0)) {
                  //     _controller.removeListener(checkVideo);
                  //     _controller.dispose();
                  //   } else {
                  //     _controller.seekTo(_controller.value.duration);
                  //   }
                  // }
                  //   return MpScreen(currentMesaj, widget.serie.imageUrlForMp);
                  // }));
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();

    //cazul special cand il inchid atunci cand a pornit dar nu s-a schimbat pe ecran
    // trebuie sa-l inchid
    if (_videoLoading == false) {
      _controller.removeListener(checkVideo);
      _controller.dispose();
    }
  }
}
