import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VidPlayer extends StatefulWidget {
  final String vidUrl;
  const VidPlayer({Key? key, required this.vidUrl}) : super(key: key);

  @override
  State<VidPlayer> createState() => _VidPlayerState();
}

class _VidPlayerState extends State<VidPlayer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.vidUrl))..initialize().then((_) {
      setState(() {});
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: const Icon(Icons.arrow_back_ios_new,
          color: Colors.white,
        )
        ),
      ),
      body: Center(
        child: _controller.value.isInitialized ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ) : const CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          setState(() {
            _controller.value.isPlaying ? _controller.pause() : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow
        ),
      ),
    );
  }
}
