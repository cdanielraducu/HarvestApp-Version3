import 'dart:async';
import 'dart:math';

import 'package:Harvest/providers/Mesaj.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class MediaPlayerItem extends StatefulWidget {
  final Mesaj mesaj;

  MediaPlayerItem(this.mesaj);

  @override
  _MediaPlayerItemState createState() => _MediaPlayerItemState();
}

class _MediaPlayerItemState extends State<MediaPlayerItem> {
  @override
  Widget build(BuildContext context) {
    return AudioServiceWidget(
        child: MediaPlayer(widget.mesaj, widget.mesaj.mediaItem));
  }
}

class MediaPlayer extends StatefulWidget {
  final Mesaj mesaj;
  final MediaItem mediaItemFromMesaj;
  // final BuildContext contextItemScreen;

  MediaPlayer(
    this.mesaj,
    this.mediaItemFromMesaj,
  );

  @override
  _MediaPlayerState createState() => _MediaPlayerState();
}

class _MediaPlayerState extends State<MediaPlayer> {
  /// Tracks the position while the user drags the seek bar.
  final BehaviorSubject<double> _dragPositionSubject =
      BehaviorSubject.seeded(null);

  double _valueForSpeed = 1.0;

  @override
  void dispose() {
    // TODO: implement dispose
    AudioService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      child: StreamBuilder<ScreenState>(
        stream: _screenStateStream,
        builder: (context, snapshot) {
          final screenState = snapshot.data;
          //final queue = screenState?.queue;

          /// aici a trebuit sa fac un mediaItem de la zero punand Duration-ul de la mesaj
          /// in loc de duration de la mediaItemReceived pentru ca e o problema cu primirea
          /// datelor la duration, pentru a vedea asta decomenteaza liniile 61-62 de la Serii.dart
          final mediaItem = MediaItem(
            id: widget.mediaItemFromMesaj.id,
            album: widget.mediaItemFromMesaj.album,
            title: widget.mediaItemFromMesaj.title,
            artist: widget.mediaItemFromMesaj.artist,
            duration: Duration(
                minutes: widget.mesaj.durataMin,
                seconds: widget.mesaj.durataSec),
            artUri: widget.mediaItemFromMesaj.artUri,
          );
          //  widget.mediaItemFromMesaj;
          final state = screenState?.playbackState;
          final processingState =
              state?.processingState ?? AudioProcessingState.none;
          final playing = state?.playing ?? false;
          // final duration = mediaItem.duration.inMilliseconds;

          AudioService.start(
            backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
            androidNotificationChannelName: mediaItem.title,
            params: {
              'id': mediaItem.id,
              'album': mediaItem.album,
              'title': mediaItem.title,
              'artist': mediaItem.artist,
              'duration': mediaItem.duration.inMilliseconds,
              'artUri': mediaItem.artUri,
            },
            androidNotificationColor: 0xFF2196f3,
            androidNotificationIcon: 'mipmap/ic_launcher',
            androidEnableQueue: true,
          );

          return Container(
            padding: EdgeInsets.only(bottom: 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (mediaItem?.title != null)
                  //Text(mediaItem.title),
                  positionIndicator(mediaItem, state),
                Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(0),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          //color: Colors.grey,
                        ),
                        // padding: EdgeInsets.only(
                        //     left: MediaQuery.of(context).size.width * 0.03,
                        //     right: MediaQuery.of(context).size.width * 0),
                        padding: EdgeInsets.only(left: 22, right: 0),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                              dropdownColor: Color(0xffCCA870),
                              value: _valueForSpeed,
                              iconSize: 0.0,
                              items: [
                                DropdownMenuItem(
                                  child: Text(
                                    '0.5x',
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.white),
                                  ),
                                  value: 0.5,
                                ),
                                DropdownMenuItem(
                                  child: Text(
                                    '0.75x',
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.white),
                                  ),
                                  value: 0.75,
                                ),
                                DropdownMenuItem(
                                  child: Text(
                                    "1x ",
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.white),
                                  ),
                                  value: 1.0,
                                ),
                                DropdownMenuItem(
                                  child: Text(
                                    "1.25x ",
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.white),
                                  ),
                                  value: 1.25,
                                ),
                                DropdownMenuItem(
                                  child: Text(
                                    "1.5x",
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.white),
                                  ),
                                  value: 1.5,
                                ),
                                DropdownMenuItem(
                                  child: Text(
                                    "1.75x ",
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.white),
                                  ),
                                  value: 1.75,
                                ),
                                DropdownMenuItem(
                                  child: Text(
                                    "2x ",
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.white),
                                  ),
                                  value: 2.0,
                                )
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _valueForSpeed = value;
                                });
                                AudioService.setSpeed(_valueForSpeed);
                              }),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Container(),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(),
                    ),
                    Row(
                      children: [
                        rewindButton(),
                        if (playing) pauseButton() else playButton(),
                        // stopButton(),
                        fastForwardButton(),

                        //IconButton(onPressed: AudioService.setSpeed(10),),
                      ],
                    ),
                    Expanded(
                      flex: 10,
                      child: Container(),
                    ),
                    Container(
                      padding: EdgeInsets.only(right: 12),
                      // padding: EdgeInsets.only(
                      //     left: MediaQuery.of(context).size.width * 0.04,
                      //     right: MediaQuery.of(context).size.width * 0.04),
                      child: PopupMenuButton<int>(
                        color: Color(0xffCCA870),
                        icon: Icon(
                          Icons.share,
                          color: Colors.white,
                          size: 25,
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 1,
                            child: Text(
                              'Copiaza link Spotify',
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
                              'Copiaza link Soundcloud',
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
                              'Copiaza link intrebari',
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
                                Clipboard.setData(ClipboardData(
                                    text:
                                        'https://open.spotify.com/episode/0o3H7OVF7z4iBfYS2H43M0?si=pRuqja7RQ-uF-MTXnll3yg'));
                                break;
                              }
                            case 2:
                              {
                                Clipboard.setData(ClipboardData(
                                    text:
                                        'https://soundcloud.com/harvestbucuresti/fiti-devotati-unii-altora-evrei-1019-25'));
                                break;
                              }
                            case 3:
                              {
                                Clipboard.setData(ClipboardData(
                                    text:
                                        'https://harvestbucuresti.ro/wp-content/uploads/2020/06/Serie-%C3%8En-Ora%C5%9F-%C3%8Endemna%C5%A3i-S%C4%83-Practic%C4%83m-Ce-Am-Devenit-%C3%8Entreb%C4%83ri-GM.pdf'));
                                break;
                              }
                            default:
                              break;
                          }
                        },
                      ),
                    ),
                  ],
                )
              ],
              // ],
            ),
          );
        },
      ),
    );
  }

  /// Encapsulate all the different data we're interested in into a single
  /// stream so we don't have to nest StreamBuilders.
  Stream<ScreenState> get _screenStateStream =>
      Rx.combineLatest3<List<MediaItem>, MediaItem, PlaybackState, ScreenState>(
          AudioService.queueStream,
          AudioService.currentMediaItemStream,
          AudioService.playbackStateStream,
          (queue, mediaItem, playbackState) =>
              ScreenState(queue, mediaItem, playbackState));

  FlatButton audioPlayerButton(String id, String album, String title,
          String artist, int duration, String artUri) =>
      startButton(
        'Start Predica',
        () async {
          await AudioService.start(
            backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint,
            androidNotificationChannelName: title,
            params: {
              'id': id,
              'album': album,
              'title': title,
              'artist': artist,
              'duration': duration,
              'artUri': artUri
            },
            androidNotificationColor: 0xFF2196f3,
            androidNotificationIcon: 'mipmap/ic_launcher',
            androidEnableQueue: true,
          );
        },
      );

  FlatButton startButton(String label, VoidCallback onPressed) => FlatButton(
        child: Container(
          height: 50,
          width: 50,
          child: Image.asset(
            'assets/asset-play-button.png',
            fit: BoxFit.contain,
          ),
        ),
        onPressed: onPressed,
        // color: Colors.black,
      );

  IconButton playButton() => IconButton(
        padding: EdgeInsets.symmetric(horizontal: 5),
        icon: Icon(
          Icons.play_arrow,
          color: Colors.white,
        ),
        iconSize: MediaQuery.of(context).size.width * 0.18,
        onPressed: AudioService.play,
      );

  IconButton pauseButton() => IconButton(
        padding: EdgeInsets.symmetric(horizontal: 5),
        icon: Icon(
          Icons.pause,
          color: Colors.white,
        ),
        iconSize: MediaQuery.of(context).size.width * 0.18,
        onPressed: AudioService.pause,
      );

  IconButton stopButton() => IconButton(
        icon: Icon(Icons.stop),
        iconSize: MediaQuery.of(context).size.width * 0.1,
        onPressed: AudioService.stop,
      );

  IconButton fastForwardButton() => IconButton(
        padding: EdgeInsets.symmetric(horizontal: 15),
        icon: Icon(
          Icons.fast_forward,
          color: Colors.white,
        ),
        iconSize: MediaQuery.of(context).size.width * 0.09,
        onPressed: AudioService.fastForward,
      );

  IconButton rewindButton() => IconButton(
        padding: EdgeInsets.symmetric(horizontal: 15),
        icon: Icon(
          Icons.fast_rewind,
          color: Colors.white,
        ),
        iconSize: MediaQuery.of(context).size.width * 0.09,
        onPressed: AudioService.rewind,
      );

  Widget positionIndicator(MediaItem mediaItem, PlaybackState state) {
    double seekPos;
    return mediaItem == null || state == null
        ? Container()
        : StreamBuilder(
            stream: Rx.combineLatest2<double, double, double>(
                _dragPositionSubject.stream,
                Stream.periodic(Duration(milliseconds: 200)),
                (dragPosition, _) => dragPosition),
            builder: (context, snapshot) {
              double position = snapshot.data ??
                  state.currentPosition.inMilliseconds.toDouble();

              double duration = mediaItem?.duration?.inMilliseconds?.toDouble();

              return Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                          accentTextTheme: TextTheme(
                              bodyText2: TextStyle(color: Colors.white))),
                      child: Container(
                        height: 20,
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.white.withOpacity(0.5),
                            // trackShape: RoundSliderTrackShape(),
                            trackHeight: 3.5,
                            thumbShape:
                                RoundSliderThumbShape(enabledThumbRadius: 5.0),
                            overlayColor: Colors.white,
                            overlayShape:
                                RoundSliderOverlayShape(overlayRadius: 15.0),
                          ),
                          child: Slider(
                            activeColor: Colors.white,
                            min: 0.0,
                            max: duration,
                            divisions: 100,
                            value: seekPos ?? max(0.0, min(position, duration)),
                            onChanged: (value) {
                              _dragPositionSubject.add(value);
                            },
                            onChangeEnd: (value) {
                              AudioService.seekTo(
                                  Duration(milliseconds: value.toInt()));
                              // Due to a delay in platform channel communication, there is
                              // a brief moment after releasing the Slider thumb before the
                              // new position is broadcast from the platform side. This
                              // hack is to hold onto seekPos until the next state update
                              // comes through.
                              // TODO: Improve this code.
                              seekPos = value;
                              _dragPositionSubject.add(null);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (duration != null)
                    Row(
                      children: [
                        Container(
                            padding: EdgeInsets.only(left: 22),
                            child: Text(
                              "${format(state.currentPosition)}",
                              style: TextStyle(
                                fontFamily: 'PTSans',
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            )),
                        Spacer(),
                        Container(
                            padding: EdgeInsets.only(right: 22),
                            child: Text(
                              "${format(mediaItem.duration)}",
                              style: TextStyle(
                                fontFamily: 'PTSans',
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            )),
                      ],
                    ),
                ],
              );
            },
          );
  }
}

format(Duration d) => d.toString().split('.').first.padLeft(8, "0");

class ScreenState {
  final List<MediaItem> queue;
  final MediaItem mediaItem;
  final PlaybackState playbackState;

  ScreenState(this.queue, this.mediaItem, this.playbackState);
}

// NOTE: Your entrypoint MUST be a top-level function.
void _audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

/// This task defines logic for playing a list of podcast episodes.
class AudioPlayerTask extends BackgroundAudioTask {
  final _mediaLibrary = MediaLibrary();
  AudioPlayer _player = new AudioPlayer();
  AudioProcessingState _skipState;
  bool _interrupted = false;
  StreamSubscription<PlaybackEvent> _eventSubscription;

  List<MediaItem> get queue => _mediaLibrary.items;
  int get index => _player.currentIndex;
  MediaItem mediaItem;

  @override
  Future<void> onStart(Map<String, dynamic> params) async {
    // String titlu = params['title'];
    // String artUri = params['artUri'];
    MediaItem mediaItemReceived = MediaItem(
      id: params['id'],
      album: params['album'],
      title: params['title'],
      artist: params['artist'],
      duration: Duration(milliseconds: params['duration']),
      artUri: params['artUri'],
    );
    mediaItem = mediaItemReceived;

    // print('AAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
    // print(mediaItemReceived.title);
    // Broadcast media item changes.
    _player.currentIndexStream.listen((index) {
      if (index != null) AudioServiceBackground.setMediaItem(mediaItemReceived);
    });
    // Propagate all events from the audio player to AudioService clients.
    _eventSubscription = _player.playbackEventStream.listen((event) {
      _broadcastState();
    });
    // Special processing for state transitions.
    _player.processingStateStream.listen((state) {
      switch (state) {
        case ProcessingState.completed:
          // In this example, the service stops when reaching the end.
          onStop();
          break;
        case ProcessingState.ready:
          // If we just came from skipping between tracks, clear the skip
          // state now that we're ready to play.
          _skipState = null;
          break;
        default:
          break;
      }
    });

    // Load and broadcast the queue
    AudioServiceBackground.setQueue(queue);
    try {
      await _player.load(
        // ConcatenatingAudioSource(
        // children:
        // queue.map((item) => AudioSource.uri(Uri.parse(item.id))).toList(),
        AudioSource.uri(Uri.parse(mediaItemReceived.id)),
        // )
      );
      // In this example, we automatically start playing on start.
      onPlay();
    } catch (e) {
      print("Error: $e");
      onStop();
    }
  }

  @override
  Future<void> onPlay() => _player.play();

  @override
  Future<void> onPause() => _player.pause();

  @override
  Future<void> onSeekTo(Duration position) => _player.seek(position);

  @override
  void onSetSpeed(double speed) {
    _player.setSpeed(speed);
  }

  @override
  Future<void> onFastForward() => _seekRelative(fastForwardInterval);

  @override
  Future<void> onRewind() => _seekRelative(-rewindInterval);

  @override
  Future<void> onSeekForward(bool begin) async => null;

  @override
  Future<void> onSeekBackward(bool begin) async => null;

  @override
  Future<void> onAudioFocusLost(AudioInterruption interruption) async {
    // We override the default behaviour to duck when appropriate.
    // First, remember if we were playing when the interruption occurred.
    if (_player.playing) _interrupted = true;
    // If another app wants to take over the audio focus, we either pause (e.g.
    // during a phonecall) or duck (e.g. if Maps Navigator starts speaking).
    if (interruption == AudioInterruption.temporaryDuck) {
      _player.setVolume(0.5);
    } else {
      onPause();
    }
  }

  @override
  Future<void> onAudioFocusGained(AudioInterruption interruption) async {
    // Restore normal playback depending on whether we paused or ducked.
    switch (interruption) {
      case AudioInterruption.temporaryPause:
        // Resume playback again. But only if we *were* originally playing at
        // the time the phone call came through. If we were paused when the
        // phone call came, we shouldn't suddenly start playing when they hang
        // up.
        if (!_player.playing && _interrupted) onPlay();
        break;
      case AudioInterruption.temporaryDuck:
        // Resume normal volume after a duck.
        _player.setVolume(1.0);
        break;
      default:
        break;
    }
    _interrupted = false;
  }

  @override
  Future<void> onStop() async {
    await _player.pause();
    await _player.dispose();
    _eventSubscription.cancel();
    // It is important to wait for this state to be broadcast before we shut
    // down the task. If we don't, the background task will be destroyed before
    // the message gets sent to the UI.
    await _broadcastState();
    // Shut down this task
    await super.onStop();
  }

  /// Jumps away from the current position by [offset].
  Future<void> _seekRelative(Duration offset) async {
    var newPosition = _player.position + offset;
    // Make sure we don't jump out of bounds.
    if (newPosition < Duration.zero) newPosition = Duration.zero;
    if (newPosition > mediaItem.duration) newPosition = mediaItem.duration;
    // Perform the jump via a seek.
    await _player.seek(newPosition);
  }

  /// Begins or stops a continuous seek in [direction]. After it begins it will
  /// continue seeking forward or backward by 10 seconds within the audio, at
  /// intervals of 1 second in app time.

  /// Broadcasts the current state to all clients.
  /// for notification control
  Future<void> _broadcastState() async {
    await AudioServiceBackground.setState(
      controls: [
        MediaControl.rewind,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        // MediaControl.stop,
        MediaControl.fastForward,
      ],
      systemActions: [
        MediaAction.seekTo,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      ],
      processingState: _getProcessingState(),
      playing: _player.playing,
      position: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
    );
  }

  /// Maps just_audio's processing state into into audio_service's playing
  /// state. If we are in the middle of a skip, we use [_skipState] instead.
  AudioProcessingState _getProcessingState() {
    if (_skipState != null) return _skipState;
    switch (_player.processingState) {
      case ProcessingState.none:
        return AudioProcessingState.stopped;
      case ProcessingState.loading:
        return AudioProcessingState.connecting;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
      default:
        throw Exception("Invalid state: ${_player.processingState}");
    }
  }
}

/// Provides access to a library of media items. In your app, this could come
/// from a database or web service.
class MediaLibrary {
  final _items = <MediaItem>[
    // MediaItem(
    //   id: 'https://firebasestorage.googleapis.com/v0/b/harvestapp-24d89.appspot.com/o/Songs%2FDansul%20conjugal%2FCe%20conteaza%20cu%20adevarat%20in%20familie.mp3?alt=media&token=900edb1a-518f-47ea-a1ec-39b6b9b838f0',
    //   album: 'Dansul conjugal',
    //   title: 'De la basm la realitate',
    //   duration: Duration(minutes: 59),
    //   artUri:
    //       'https://harvestbucuresti.ro/wp-content/uploads/2020/07/Grafica-Serie-Dansul-Conjugal-SD.jpg',
    // ),
  ];

  List<MediaItem> get items => _items;
}
