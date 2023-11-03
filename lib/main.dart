import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:assets_audio_player/assets_audio_player.dart';

void main() {
  runApp(MusicPlayerApp());
}

class MusicPlayerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MusicPlayerScreen(),
    );
  }
}

class MusicPlayerScreen extends StatefulWidget {
  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final youtube = YoutubeExplode();
  final assetsAudioPlayer = AssetsAudioPlayer.newPlayer();
  final TextEditingController searchController = TextEditingController();
  List searchResults = [];
  bool swit = false;

  @override
  void initState() {
    super.initState();
    assetsAudioPlayer.stop();
    assetsAudioPlayer.playlistAudioFinished.listen((Playing playing) {
      stopAudio();
    });
  }



  @override
  void dispose() {
    youtube.close();
    assetsAudioPlayer.dispose();
    super.dispose();
  }

  void searchMusic() async {
    String query = searchController.text.trim();
    if (query.isNotEmpty) {
      var searchResult = await youtube.search.getVideos(query);
      setState(() {
        searchResults = searchResult.toList();
      });
    }
  }

  void playAudio(String videoId) async {
    //var video = await youtube.videos.get(videoId);
    var manifest = await youtube.videos.streamsClient.getManifest(videoId);
    var audioStream = manifest.audioOnly.last;
   // var response = await youtube.videos.streamsClient.get(audioStream);

    await assetsAudioPlayer.stop();
    await assetsAudioPlayer.open(
      //Audio.liveStream(audioStream.codec.mimeType)
      Audio.network(
        audioStream.url.toString(),
      ),
    );
  }

  void stopAudio() {
    assetsAudioPlayer.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Music Player'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for music...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: searchMusic,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                var video = searchResults[index];
                return ListTile(
                  title: Text(video.title),
                  onTap: () {
                    setState(() {
                      swit = true;
                    });
                    playAudio(video.id.value);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(swit ? Icons.play_arrow : Icons.pause),
        onPressed: () {
          setState(() {
            swit = !swit;
          });
          stopAudio();
        },
      ),
    );
  }
}