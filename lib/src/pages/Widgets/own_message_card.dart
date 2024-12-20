import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/src/helper/helper.dart';
import 'package:chat_app/src/pages/Widgets/photo_view.dart';
import 'package:chat_app/src/utils/config_util.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:chat_app/src/utils/theme_util.dart';
import 'package:flutter/material.dart';

class OwnMessageCard extends StatefulWidget {
  const OwnMessageCard(
      {Key? key, required this.type, required this.message, required this.time})
      : super(key: key);
  final String message;
  final String time;
  final String type;

  @override
  State<OwnMessageCard> createState() => _OwnMessageCardState();
}

class _OwnMessageCardState extends State<OwnMessageCard> {
  void downloadFile(String fileUrl) async {
    if (await canLaunch(fileUrl)) {
      await launch(fileUrl);
    } else {
      throw 'Could not launch $fileUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 45,
            minWidth: 200,
            minHeight: 60),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: Color(0xffdcf8c6),
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Stack(
            children: [
              if (widget.type == 'text')
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 30,
                    top: 5,
                    bottom: 20,
                  ),
                  child: Text(
                    widget.message,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              if (widget.type == 'file')
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContainerPhotoView(
                          imageUrl: widget.message,
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: CachedNetworkImage(
                      width: 250,
                      height: 250,
                      imageUrl: Config.baseURL + widget.message,
                      placeholder: (context, url) => Container(
                          width: 30, child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if (widget.type == 'video')
                GestureDetector(
                  onTap: () {
                    downloadFile(Config.baseURL + widget.message);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(left: 15, top: 10, bottom: 30),
                    child: Icon(
                      Icons.play_circle_fill,
                      size: 50,
                      color: primaryColor,
                    ),
                  ),
                ),
              Positioned(
                bottom: 2,
                right: 10,
                child: Row(
                  children: [
                    Text(
                      "${dateTimePipe(widget.time)}",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Icon(
                      Icons.done_all,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
