import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/src/helper/helper.dart';
import 'package:chat_app/src/pages/Widgets/photo_view.dart';
import 'package:chat_app/src/utils/config_util.dart';
import 'package:chat_app/src/utils/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ReplyCard extends StatefulWidget {
  const ReplyCard(
      {Key? key, required this.type, required this.message, required this.time})
      : super(key: key);
  final String message;
  final String time;
  final String type;

  @override
  State<ReplyCard> createState() => _ReplyCardState();
}

class _ReplyCardState extends State<ReplyCard> {
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
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 45,
            minWidth: 200,
            minHeight: 60),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
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
                    style: const TextStyle(
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
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
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
                    padding:
                        const EdgeInsets.only(left: 15, top: 10, bottom: 30),
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
                child: Text(
                  "${dateTimePipe(widget.time)}",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:icons_plus/icons_plus.dart';
// import 'package:chat_app/src/utils/config.dart';
// import '../helper/helper.dart';
// import '../utils/theme_util.dart';

// class ReplyCard extends StatefulWidget {
//   final dynamic messageObj;
//   const ReplyCard({super.key, this.messageObj});

//   @override
//   State<ReplyCard> createState() => _ReplyCardState();
// }

// class _ReplyCardState extends State<ReplyCard> {
//   // variables
//   var messageObj;

//   // Functions

//   @override
//   void initState() {
//     super.initState();
//     messageObj = widget.messageObj;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 10),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(100),
//             child: Container(
//               width: 40,
//               height: 40,
//               child: CachedNetworkImage(
//                 imageUrl: Config.baseURL + messageObj['senderUserId']['avatar'],
//                 placeholder: (context, url) =>
//                     Center(child: CircularProgressIndicator()),
//                 errorWidget: (context, url, error) => Icon(OctIcons.info_16),
//                 fit: BoxFit.cover,
//                 width: 40,
//                 height: 40,
//               ),
//             ),
//           ),
//           SizedBox(
//             width: 10,
//           ),
//           Container(
//             constraints:
//                 BoxConstraints(minHeight: 40, minWidth: 40, maxWidth: 250),
//             decoration: BoxDecoration(
//                 color: lightColor,
//                 borderRadius: BorderRadius.all(Radius.circular(5))),
//             padding: EdgeInsets.symmetric(horizontal: p, vertical: 5),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "${messageObj['message']}",
//                   style: TextStyle(fontFamily: 'pr'),
//                 ),
//                 Align(
//                   alignment: Alignment.bottomRight,
//                   child: Text(
//                     "${datePipe(messageObj['createdAt'])}",
//                     style: TextStyle(
//                         fontFamily: 'pr', fontSize: 12, color: primaryColor),
//                   ),
//                 )
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
