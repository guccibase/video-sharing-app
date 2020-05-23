import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:videosharingapp/video_info.dart';

class ChewiePlayer extends StatefulWidget {
  final VideoInfo video;

  ChewiePlayer({Key key, this.video}) : super(key: key);

  @override
  _ChewiePlayerState createState() => _ChewiePlayerState();
}

class _ChewiePlayerState extends State<ChewiePlayer> {
  ChewieController chewieCntrl;
  VideoPlayerController vdCntrl;

  @override
  void initState() {
    vdCntrl = VideoPlayerController.network(widget.video.videoUrl);
    chewieCntrl = ChewieController(
        videoPlayerController: vdCntrl,
        autoPlay: true,
        autoInitialize: true,
        aspectRatio: widget.video.aspectRatio,
        placeholder: Center(
          child: Image.network(widget.video.videoUrl),
        ));

    super.initState();
  }

  @override
  void dispose() {
    if (chewieCntrl != null) chewieCntrl.dispose();
    if (vdCntrl != null) vdCntrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          Chewie(
            controller: chewieCntrl,
          ),
          Container(
            padding: EdgeInsets.all(30.0),
            child: IconButton(
              icon: Icon(
                Icons.close,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          )
        ],
      ),
    );
  }
}
