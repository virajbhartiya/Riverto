import 'dart:convert';
import 'dart:ui';
import 'package:Riverto/Models/queueModel.dart';
import 'package:Riverto/Models/recentlyPlayed.dart';
import 'package:Riverto/screen/queueScreen.dart';
import 'package:Riverto/screen/recentlyPlayedScreen.dart';
import 'package:Riverto/widgets/particle.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:des_plugin/des_plugin.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_media_notification/flutter_media_notification.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:Riverto/API/saavn.dart';
// import 'package:Riverto/music.dart';
import 'package:Riverto/style/appColors.dart';
import 'package:Riverto/screen/feedback.dart';
import 'package:Riverto/const.dart';
import 'package:http/http.dart' as http;

import '../queueMusic.dart';

class Riverto extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AppState();
  }
}

class AppState extends State<Riverto> {
  TextEditingController searchBar = TextEditingController();
  bool fetchingSongs = false;
  List<QueueModel> songs = [];
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
      statusBarColor: Colors.transparent,
    ));

    //=============================================================================
    //Notifications
    MediaNotification.setListener('play', () {
      setState(() {
        playerState = PlayerState.playing;
        status = 'play';
        audioPlayer.play(kUrl);
      });
    });

    MediaNotification.setListener('pause', () {
      setState(() {
        status = 'pause';
        audioPlayer.pause();
      });
    });

    MediaNotification.setListener("close", () {
      audioPlayer.stop();
      dispose();
      checker = "no";
      MediaNotification.hideNotification();
    });
  }
  //====================================================

  search() async {
    String searchQuery = searchBar.text;
    if (searchQuery.isEmpty) return;

    setState(() {
      fetchingSongs = true;
    });
    await fetchSongsList(searchQuery);
    setState(() {
      fetchingSongs = false;
    });
    searchedList.forEach((element) {
      QueueModel s = new QueueModel()
        ..title = element['title']
        ..album = element['more_info']['album']
        ..artist = element['more_info']["singers"]
        ..id = element["id"];

      this.songs.add(s);
    });
  }

  getSongDetails(String id, var context, int index) async {
    try {
      await fetchSongDetails(id);
      RecentlyPlayed recentlyPlayed = new RecentlyPlayed()
        ..title = title
        ..url = kUrl
        ..album = album
        ..artist = artist
        ..lyrics = lyrics
        ..image = image
        ..id = id;

      // recentSongs.add(recentlyPlayed);
      await Const.insertRecent(recentlyPlayed);
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
        builder: (context) => QueueAudioApp(this.songs, index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String lyr, url, raw;
    Future fetchLyrics(id, art, tit) async {
      String songUrl =
          "https://www.jiosaavn.com/api.php?app_version=5.18.3&api_version=4&readable_version=5.18.3&v=79&_format=json&__call=song.getDetails&pids=" +
              id;
      var res =
          await http.get(songUrl, headers: {"Accept": "application/json"});
      var resEdited = (res.body).split("-->");
      var getMain = json.decode(resEdited[1]);

      title = (getMain[id]["title"])
          .toString()
          .split("(")[0]
          .replaceAll("&amp;", "&")
          .replaceAll("&#039;", "'")
          .replaceAll("&quot;", "\"");
      image = (getMain[id]["image"]).replaceAll("150x150", "500x500");
      album = (getMain[id]["more_info"]["album"])
          .toString()
          .replaceAll("&quot;", "\"")
          .replaceAll("&#039;", "'")
          .replaceAll("&amp;", "&");

      try {
        artist =
            getMain[id]['more_info']['artistMap']['primary_artists'][0]['name'];
      } catch (e) {
        artist = "-";
      }
      if (getMain[id]["more_info"]["has_lyrics"] == "true") {
        String lyricsUrl =
            "https://www.jiosaavn.com/api.php?__call=lyrics.getLyrics&lyrics_id=" +
                id +
                "&ctx=web6dot0&api_version=4&_format=json";
        var lyricsRes =
            await http.get(lyricsUrl, headers: {"Accept": "application/json"});
        var lyricsEdited = (lyricsRes.body).split("-->");
        var fetchedLyrics = json.decode(lyricsEdited[1]);
        lyr = fetchedLyrics["lyrics"].toString().replaceAll("<br>", "\n");
      } else {
        lyr = "null";
        String lyricsApiUrl =
            "https://sumanjay.vercel.app/lyrics/" + artist + "/" + title;
        var lyricsApiRes = await http
            .get(lyricsApiUrl, headers: {"Accept": "application/json"});
        var lyricsResponse = json.decode(lyricsApiRes.body);
        if (lyricsResponse['status'] == true &&
            lyricsResponse['lyrics'] != null) {
          lyr = lyricsResponse['lyrics'];
        }
      }

      url = await DesPlugin.decrypt(
          key, getMain[id]["more_info"]["encrypted_media_url"]);

      raw = url;

      final client = http.Client();
      final request = http.Request('HEAD', Uri.parse(url))
        ..followRedirects = false;
      final response = await client.send(request);
      url = (response.headers['location']);
      artist = (getMain[id]["more_info"]["artistMap"]["primary_artists"][0]
              ["name"])
          .toString()
          .replaceAll("&quot;", "\"")
          .replaceAll("&#039;", "'")
          .replaceAll("&amp;", "&");
    }

    return Container(
      child: Scaffold(
        // resizeToAvoidBottomPadding: false,
        backgroundColor: Colors.transparent,
        //backgroundColor: Color(0xff384850),
        bottomNavigationBar: kUrl != ""
            ? Container(
                height: 75,
                //color: Color(0xff1c252a),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18)),
                    color: Colors.black),
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0, bottom: 2),
                  child: GestureDetector(
                    onTap: () {
                      checker = "no";
                      if (kUrl != "") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  QueueAudioApp(this.songs, 0)),
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
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 30, bottom: 20.0)),
                  Center(
                    child: Row(children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20)),
                            child: Text(
                              "Riverto.",
                              style: TextStyle(
                                color: Color(0xff61e88a),
                                fontSize: 45,
                                fontWeight: FontWeight.w800,
                              ),
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
                      Container(
                        child: IconButton(
                          iconSize: 26,
                          alignment: Alignment.center,
                          icon: Icon(MdiIcons.music),
                          color: accent,
                          onPressed: () => {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => RecentlyPlayedScreen(),
                              ),
                            ),
                          },
                        ),
                      ),
                      //queue button
                      Container(
                        child: IconButton(
                          iconSize: 26,
                          alignment: Alignment.center,
                          icon: Icon(MdiIcons.apacheKafka),
                          color: accent,
                          onPressed: () => {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => QueueScreen(),
                              ),
                            ),
                          },
                        ),
                      )
                    ]),
                  ),
                  Padding(padding: EdgeInsets.only(top: 20)),
                  //Search bar
                  TextField(
                    onSubmitted: (String value) {
                      search();
                    },
                    controller: searchBar,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xff61e88a),
                    ),
                    cursorColor: Colors.green[50],
                    decoration: InputDecoration(
                      // fillColor: Color(0xff263238),
                      fillColor: Colors.black,
                      filled: true,
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(100),
                        ),
                        borderSide: BorderSide(
                          // color: Color(0xff263238),
                          color: Color(0xff61e88a),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(100),
                        ),
                        borderSide: BorderSide(color: accent),
                      ),
                      suffixIcon: IconButton(
                        icon: fetchingSongs
                            ? SizedBox(
                                height: 18,
                                width: 18,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor:
                                        AlwaysStoppedAnimation<Color>(accent),
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.search,
                                color: accent,
                              ),
                        color: accent,
                        onPressed: () {
                          search();
                        },
                      ),
                      border: InputBorder.none,
                      hintText: "Search...",
                      hintStyle: TextStyle(
                        color: accent,
                      ),
                      contentPadding: const EdgeInsets.only(
                        left: 18,
                        right: 20,
                        top: 14,
                        bottom: 14,
                      ),
                    ),
                  ),
                  searchedList.isNotEmpty
                      //searched songs
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: searchedList.length,
                          itemBuilder: (BuildContext ctxt, int index) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 5, bottom: 5),
                              child: Card(
                                color: Colors.black,
                                // color: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                elevation: 10,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10.0),
                                  onTap: () {
                                    getSongDetails(searchedList[index]["id"],
                                        context, index);
                                  },
                                  onLongPress: () => topSongs(),
                                  splashColor: accent,
                                  hoverColor: accent,
                                  focusColor: accent,
                                  highlightColor: accent,
                                  child: ListTile(
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
                                      (searchedList[index]['title'])
                                          .toString()
                                          .split("(")[0]
                                          .replaceAll("&quot;", "\"")
                                          .replaceAll("&amp;", "&"),
                                      style: TextStyle(color: accent),
                                    ),
                                    subtitle: Text(
                                      searchedList[index]['more_info']
                                          ["singers"],
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          color: accent,
                                          icon: Icon(MdiIcons.apacheKafka),
                                          onPressed: () async {
                                            await fetchLyrics(
                                                    searchedList[index]["id"],
                                                    searchedList[index]
                                                            ['more_info']
                                                        ["singers"],
                                                    searchedList[index]
                                                        ['title'])
                                                .then((_) => {});
                                            QueueModel queueItem =
                                                new QueueModel()
                                                  ..title = searchedList[index]
                                                      ['title']
                                                  ..album = searchedList[index]
                                                      ['more_info']['album']
                                                  ..artist = searchedList[index]
                                                      ['more_info']["singers"]
                                                  ..id =
                                                      searchedList[index]["id"]
                                                  ..lyrics = lyr
                                                  ..url = url;

                                            Const.queueSongs.add(queueItem);
                                          },
                                        ),
                                        IconButton(
                                          color: accent,
                                          icon: Icon(MdiIcons.downloadOutline),
                                          onPressed: () async {
                                            Const.toast("Starting Download!");
                                            Const.downloadSong(
                                                searchedList[index]["id"],
                                                context);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )

                      //No search
                      : FutureBuilder(
                          future: topSongs(),
                          builder: (context, data) {
                            if (data.hasData)
                              return Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 30.0, bottom: 10, left: 8),
                                      child: Text(
                                        "Top Songs",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontSize: 22,
                                          color: accent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: SingleChildScrollView(
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height -
                                              250,
                                          child: SafeArea(
                                            child: GridView.count(
                                              crossAxisCount: 2,
                                              children: List.generate(
                                                28,
                                                (index) {
                                                  return getTopSong(
                                                      data.data[index]["image"],
                                                      data.data[index]["title"],
                                                      data.data[index][
                                                                      "more_info"]
                                                                  ["artistMap"][
                                                              "primary_artists"]
                                                          [0]["name"],
                                                      data.data[index]["id"],
                                                      index);
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    // SizedBox(height: 20),
                                  ],
                                ),
                              );
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(35.0),
                                child: CircularProgressIndicator(
                                  valueColor:
                                      new AlwaysStoppedAnimation<Color>(accent),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Home screen songs
  Widget getTopSong(
      String image, String title, String subtitle, String id, int index) {
    return InkWell(
      onTap: () {
        getSongDetails(id, context, index);
      },
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.22,
            width: MediaQuery.of(context).size.width / 2,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: CachedNetworkImageProvider(image),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 2,
          ),
          Text(
            title
                .split("(")[0]
                .replaceAll("&amp;", "&")
                .replaceAll("&#039;", "'")
                .replaceAll("&quot;", "\""),
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 2,
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
