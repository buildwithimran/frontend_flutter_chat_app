// ignore_for_file: file_names, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import '../../utils/config_util.dart';
import '../../utils/theme_util.dart';

class ContainerPhotoView extends StatelessWidget {
  final String imageUrl;

  const ContainerPhotoView({Key? key, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: primaryColor,
          title: Text(
            "View Photo",
            style: TextStyle(fontSize: apptit),
          )),
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          color: primaryColor,
          child: Center(
            child: PhotoView(
              imageProvider: NetworkImage(Config.baseURL + imageUrl),
              backgroundDecoration: BoxDecoration(
                color: backgroundColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
