import 'dart:io';

import 'package:Riverto/API/saavn.dart';
import 'package:Riverto/Models/recentlyPlayed.dart';
import 'package:Riverto/const.dart';
import 'package:Riverto/style/appColors.dart';
import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:flutter_media_notification/flutter_media_notification.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import '../music.dart';
import 'feedback.dart';

class RecentlyPlayedScreen extends StatefulWidget {
  @override
  _RecentlyPlayedScreenState createState() => _RecentlyPlayedScreenState();
}

class _RecentlyPlayedScreenState extends State<RecentlyPlayedScreen> {
  @override
  void initState() {
    super.initState();
    Const.change();
    if (Const.recentSongs != null) {
      Const.recentSongs
          .getRange(0, Const.recentSongs.length)
          .forEach((element) {
        print(element.id);
      });
    }
  }

  getSongDetails(String id) async {
    try {
      print(title);
      await fetchSongDetails(id);
      print(title);
    } catch (e) {
      artist = "Unknown";
    }
    setState(() {
      checker = "yes";
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AudioApp(),
      ),
    );
  }

  toast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Color(0xff61e88a),
      fontSize: 14.0,
    );
  }

  downloadSong(id) async {
    String filepath;
    String filepath2;
    var status = await Permission.storage.status;
    if (status.isUndetermined || status.isDenied) {
      //Getting permissions
      await [
        Permission.storage,
      ].request();
    }
    status = await Permission.storage.status;
    await fetchSongDetails(id);
    if (status.isGranted) {
      ProgressDialog pr = ProgressDialog(context);
      pr = ProgressDialog(
        context,
        type: ProgressDialogType.Normal,
        isDismissible: false,
        showLogs: false,
      );

      pr.style(
        backgroundColor: Color(0xff263238),
        elevation: 4,
        textAlign: TextAlign.left,
        progressTextStyle: TextStyle(color: Colors.white),
        message: "Downloading " + title,
        messageTextStyle: TextStyle(color: accent),
        progressWidget: Padding(
          padding: const EdgeInsets.all(20.0),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(accent),
          ),
        ),
      );
      await pr.show();

      final filename = title + ".m4a";
      final artname = title + "_artwork.jpg";

      //Path for saving the song
      String dlPath = await ExtStorage.getExternalStoragePublicDirectory(
          ExtStorage.DIRECTORY_MUSIC);
      await File(dlPath + "/" + filename)
          .create(recursive: true)
          .then((value) => filepath = value.path);
      await File(dlPath + "/" + artname)
          .create(recursive: true)
          .then((value) => filepath2 = value.path);

      if (has_320 == "true") {
        kUrl = rawkUrl.replaceAll("_96.mp4", "_320.mp4");
        final client = http.Client();
        final request = http.Request('HEAD', Uri.parse(kUrl))
          ..followRedirects = false;
        final response = await client.send(request);
        kUrl = (response.headers['location']);
        final request2 = http.Request('HEAD', Uri.parse(kUrl))
          ..followRedirects = false;
        final response2 = await client.send(request2);
        if (response2.statusCode != 200) {
          kUrl = kUrl.replaceAll(".mp4", ".mp3");
        }
      }
      var request = await HttpClient().getUrl(Uri.parse(kUrl));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      File file = File(filepath);

      var request2 = await HttpClient().getUrl(Uri.parse(image));
      var response2 = await request2.close();
      var bytes2 = await consolidateHttpClientResponseBytes(response2);
      File file2 = File(filepath2);

      await file.writeAsBytes(bytes);
      await file2.writeAsBytes(bytes2);

      final tag = Tag(
        title: title,
        artist: artist,
        artwork: filepath2,
        album: album,
        lyrics: lyrics,
        genre: null,
      );

      final tagger = Audiotagger();
      await tagger.writeTags(
        path: filepath,
        tag: tag,
      );
      await Future.delayed(const Duration(seconds: 1), () {});
      await pr.hide();

      if (await file2.exists()) await file2.delete();

      toast("Download Complete!");
    } else if (status.isDenied || status.isPermanentlyDenied)
      toast("Storage Permission Denied!\nCan't Download Songs");
    else
      toast("Permission Error!");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xff384850),
            Color(0xff263238),
            Color(0xff263238),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: kUrl != ""
            ? Container(
                height: 75,
                //color: Color(0xff1c252a),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18)),
                    color: Color(0xff1c252a)),
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0, bottom: 2),
                  child: GestureDetector(
                    onTap: () {
                      checker = "no";
                      if (kUrl != "") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AudioApp()),
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
        body: SingleChildScrollView(
          padding: EdgeInsets.all(12.0),
          child: Column(
            children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 30, bottom: 20.0)),
              Center(
                child: Row(children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: GradientText(
                        "Recent.",
                        shaderRect: Rect.fromLTWH(13.0, 0.0, 100.0, 50.0),
                        gradient: LinearGradient(colors: [
                          Color(0xff4db6ac),
                          Color(0xff61e88a),
                        ]),
                        style: TextStyle(
                          fontSize: 45,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  //feedback button
                  Container(
                    child: IconButton(
                      iconSize: 26,
                      alignment: Alignment.center,
                      icon: Icon(MdiIcons.messageOutline),
                      color: accent,
                      onPressed: () => {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => Feed(),
                          ),
                        ),
                      },
                    ),
                  ),
                  //recentlyPlayed button
                ]),
              ),
              Padding(padding: EdgeInsets.only(top: 20)),
              //Search bar
              Const.recentSongs != null
                  //searched songs
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: Const.recentSongs.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 5, bottom: 5),
                          child: Card(
                            color: Colors.black12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            elevation: 0,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10.0),
                              onTap: () =>
                                  getSongDetails(Const.recentSongs[index].id),
                              onLongPress: () => topSongs(),
                              splashColor: accent,
                              hoverColor: accent,
                              focusColor: accent,
                              highlightColor: accent,
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    leading: Padding(
                                      padding: const EdgeInsets.all(.0),
                                      child: Icon(
                                        MdiIcons.musicNoteOutline,
                                        size: 30,
                                        color: accent,
                                      ),
                                      // Icon(
                                      //   MdiIcons.musicNoteOutline,
                                      //   size: 30,
                                      //   color: accent,
                                      // ),
                                    ),
                                    title: Text(
                                      (Const.recentSongs[index].title)
                                          .toString()
                                          .split("(")[0]
                                          .replaceAll("&quot;", "\"")
                                          .replaceAll("&amp;", "&"),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      Const.recentSongs[index].artist,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    trailing: IconButton(
                                      color: accent,
                                      icon: Icon(MdiIcons.downloadOutline),
                                      onPressed: () async {
                                        toast("Starting Download!");
                                        downloadSong(
                                          Const.recentSongs[index].id,
                                        );
                                      },
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
      ),
    );
  }
}
