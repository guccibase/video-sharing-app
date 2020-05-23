import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_publitio/flutter_publitio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:videosharingapp/video_info.dart';

import 'chewie_player.dart';

void main() {
  runApp(MaterialApp(
    home: MyHomePage(),
  ));
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<VideoInfo> _videos = [];
  bool _imagePickerActive = false;
  bool _uploading = false;
  static const PUBLITIO_PREFIX = "https://media.publit.io/file";

  static getCoverUrl(respose) {
    final publicId = respose["public_id"];
    return "$PUBLITIO_PREFIX/$publicId.jpg";
  }

  void _recordVid() async {
    if (_imagePickerActive) return;

    _imagePickerActive = true;
    final File videoFile =
        await ImagePicker.pickVideo(source: ImageSource.camera);

    if (videoFile == null) return;

    _uploading = true;
    setState(() {});

    _imagePickerActive = false;

    try {
      final response = await _uploadVid(videoFile);

      final width = await response["width"];
      final height = await response["height"];
      final double aspectRatio = width / height;

      _videos.add(
        VideoInfo(
            videoUrl: response["url_preview"],
            thumbUrl: response["url_thumbnail"],
            aspectRatio: aspectRatio,
            coverUrl: getCoverUrl(response)),
      );

      setState(() {});
    } on PlatformException catch (e) {
      debugPrint("${e.code} : ${e.message}");
    } finally {
      setState(() {
        _uploading = false;
      });
    }
  }

  @override
  void initState() {
    configurePublitio();
    super.initState();
  }

  static configurePublitio() async {
    await DotEnv().load('.env');
    await FlutterPublitio.configure(
        DotEnv().env['publitio_key'], DotEnv().env["publitio_secret"]);
  }

  static _uploadVid(videoFile) async {
    debugPrint("starting upload");
    final uploadOptions = {
      "privacy": "1",
      "option_download": "1",
      "option_transform": "1"
    };

    final response =
        await FlutterPublitio.uploadFile(videoFile.path, uploadOptions);

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Picker"),
      ),
      body: Center(
        child: ListView.builder(
            itemCount: _videos.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ChewiePlayer(
                          video: _videos[index],
                        );
                      },
                    ),
                  );
                },
                child: Card(
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Center(
                        child: Container(
                      child: Column(
                        children: <Widget>[
                          Stack(
                            children: <Widget>[
                              Center(
                                child: CircularProgressIndicator(),
                              ),
                              Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: FadeInImage.memoryNetwork(
                                    placeholder: kTransparentImage,
                                    image: _videos[index].thumbUrl,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          ListTile(
                            title: Text(_videos[index].thumbUrl),
                          )
                        ],
                      ),
                    )),
                  ),
                ),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _recordVid,
        tooltip: 'Record Video',
        child: !_uploading
            ? Icon(Icons.add)
            : CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
      ),
    );
  }
}
