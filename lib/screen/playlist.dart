import 'package:Riverto/API/saavn.dart';
import 'package:Riverto/Models/queueModel.dart';
import 'package:Riverto/const.dart';
import 'package:Riverto/screen/playlistScreen.dart';
import 'package:Riverto/style/appColors.dart';
import 'package:Riverto/widgets/particle.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:flutter_media_notification/flutter_media_notification.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
// import '../music.dart';
import '../music.dart';

class Playlists extends StatefulWidget {
  @override
  _PlaylistsState createState() => _PlaylistsState();
}

class _PlaylistsState extends State<Playlists> {
  List<QueueModel> songs = [];
  int i;
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
      statusBarColor: Colors.transparent,
    ));

    Const.change();
    // Const.recentSongs = Const.recentSongs.reversed;
    Const.recentSongs.forEach((element) {
      QueueModel s = QueueModel()
        ..album = element.album
        ..artist = element.artist
        ..id = element.id
        ..lyrics = element.lyrics
        ..title = element.title
        ..url = element.url;
      songs.add(s);
    });
  }

  getSongDetails(String id, var context, int index) async {
    try {
      await fetchSongDetails(id);
      // recentSongs.add(recentlyPlayed);
      Const.change();
    } catch (e) {
      artist = "Unknown";
    }
    setState(() {
      checker = "yes";
    });

    print(this.songs);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AudioApp(this.songs, index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: Colors.black,
        bottomNavigationBar: kUrl != ""
            ? Container(
                height: 75,
                //color: Color(0xff1c252a),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18)),
                  color: Colors.black,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0, bottom: 2),
                  child: GestureDetector(
                    onTap: () {
                      checker = "no";
                      if (kUrl != "") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AudioApp(songs, i)),
                        );
                      }
                    },
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 8.0,
                          ),
                          child: IconButton(
                            icon: Icon(
                              MdiIcons.appleKeyboardControl,
                              size: 22,
                            ),
                            onPressed: null,
                            disabledColor: accent,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 0.0, top: 7, bottom: 7, right: 15),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: CachedNetworkImage(
                              imageUrl: image,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 0.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                title,
                                style: TextStyle(
                                    color: accent,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                artist,
                                style:
                                    TextStyle(color: accentLight, fontSize: 15),
                              )
                            ],
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          icon: playerState == PlayerState.playing
                              ? Icon(MdiIcons.pause)
                              : Icon(MdiIcons.playOutline),
                          color: accent,
                          splashColor: Colors.transparent,
                          onPressed: () {
                            setState(() {
                              if (playerState == PlayerState.playing) {
                                audioPlayer.pause();
                                playerState = PlayerState.paused;
                                MediaNotification.showNotification(
                                    title: title,
                                    author: artist,
                                    artUri: image,
                                    isPlaying: false);
                              } else if (playerState == PlayerState.paused) {
                                audioPlayer.play(kUrl);
                                playerState = PlayerState.playing;
                                MediaNotification.showNotification(
                                    title: title,
                                    author: artist,
                                    artUri: image,
                                    isPlaying: true);
                              }
                            });
                          },
                          iconSize: 45,
                        )
                      ],
                    ),
                  ),
                ),
              )
            : SizedBox.shrink(),
        body: Stack(
          children: [
            particle(context),
            SingleChildScrollView(
              padding: EdgeInsets.all(12.0),
              child: Column(
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 30, bottom: 20.0)),
                  Center(
                    child: Row(children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            "Playlists.",
                            style: TextStyle(
                              color: Color(0xff61e88a),
                              fontSize: 45,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),

                      //recentlyPlayed button
                    ]),
                  ),
                  Padding(padding: EdgeInsets.only(top: 20)),
                  //Search bar
                  Playlist.playlists != null
                      //searched songs
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: Playlist.playlists.length,
                          itemBuilder: (BuildContext ctxt, int index) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 5, bottom: 5),
                              child: Card(
                                color: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                elevation: 0,
                                child: InkWell(
                                  onTap: () => Navigator.of(context).push(
                                      CupertinoPageRoute(
                                          builder: (context) => PlaylistScreen(
                                              Playlist.playlists[index]))),
                                  borderRadius: BorderRadius.circular(10.0),
                                  splashColor: accent,
                                  hoverColor: accent,
                                  focusColor: accent,
                                  highlightColor: accent,
                                  child: Column(
                                    children: <Widget>[
                                      ListTile(
                                        title: Text(
                                          (Playlist.playlists[index])
                                              .toString()
                                              .split("(")[0]
                                              .replaceAll("&quot;", "\"")
                                              .replaceAll("&amp;", "&"),
                                          style: TextStyle(
                                              color: accent, fontSize: 25),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )

                      //No search
                      : Container()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
