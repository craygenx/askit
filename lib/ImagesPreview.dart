import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  final List<dynamic> images;
  const ImagePreview({Key? key, required this.images}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white30,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: const Icon(Icons.arrow_back_ios_new,
          color: Colors.white,
        )),
      ),
      body: Center(
        child: CarouselSlider(
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height *90,
            autoPlay: true,
            enlargeCenterPage: true,
          ),
          items: images.map((imageUrl) {
            return Builder(builder: (BuildContext context){
              return Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover
                  )
                ),
              );
            });
          }).toList(),
        ),
      ),
    );
  }
}
