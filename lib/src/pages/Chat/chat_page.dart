import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/src/pages/Widgets/own_message_card.dart';
import 'package:chat_app/src/pages/Widgets/reply_message_card.dart';
import 'package:chat_app/src/helper/helper.dart';
import 'package:chat_app/src/models/MessageModel.dart';
import 'package:chat_app/src/models/SettingModel.dart';
import 'package:chat_app/src/services/app.service.dart';
import 'package:chat_app/src/utils/loading_util.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:chat_app/src/helper/globals.dart';
import 'package:chat_app/src/utils/config_util.dart';
import 'package:chat_app/src/utils/theme_util.dart';

class ChatDetailPage extends StatefulWidget {
  final dynamic personInfo;

  const ChatDetailPage({super.key, this.personInfo});
  @override
  State<ChatDetailPage> createState() => _ChatDetailPage();
}

class _ChatDetailPage extends State<ChatDetailPage> {
  // Services
  var appService = AppService();

  // variables
  bool show = false;
  bool loader = true;
  bool sendButton = true;
  FocusNode focusNode = FocusNode();
  List<MessageModel> messages = [];
  TextEditingController controller = TextEditingController();
  TextEditingController avatarController = TextEditingController();
  TextEditingController videoController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool imageSelected = false;
  bool videoSelected = false;
  File _img = File('');
  File _video = File('');
  SettingModel appSetting = SettingModel(fontType: '', wallpaper: '');
  late IO.Socket socket;
  var userDetail;
  var lastScene = '';

  // Functions
  @override
  void initState() {
    super.initState();
    userDetail = widget.personInfo;
    fetchMessages();
    chatUserLastSceneTime();
    socket = IO.io(
      Platform.isIOS ? Config.baseURL : Config.baseURL,
      IO.OptionBuilder().setTransports(['websocket']).setQuery(
          {'senderUserId': userSD['_id']}).build(),
    );
    connectSocket();
  }

  connectSocket() {
    socket.onConnect((data) => print('Connection established'));
    socket.onConnectError((data) => print('Connect Error: $data'));
    socket.onDisconnect((data) => print('Socket.IO server disconnected'));
    socket.on("message", (message) {
      setMessage(message["message"], message["time"], message["type"],
          message["senderUserId"]);
      appScrollController();
    });
  }

  void sendMessage(typeOfMessage) async {
    var currentTime = createTimestamp();
    if (typeOfMessage == 'text' && controller.text.isNotEmpty) {
      var messageFormObj = {
        "time": currentTime,
        "message": controller.text.trim(),
        "type": "text",
        "senderUserId": userSD['_id'],
        "receiverUserId": userDetail['friend']['_id']
      };
      socket.emit("message", messageFormObj);
      controller.clear();
    } else if (typeOfMessage == 'file') {
      showLoader(context, 'Just a moment ...');
      if (imageSelected) {
        avatarController.text = await doUploadImage(context, _img);
      }
      var messageFormObj = {
        "time": currentTime,
        "message": avatarController.text,
        "type": "file",
        "senderUserId": userSD['_id'],
        "receiverUserId": userDetail['friend']['_id']
      };
      pop(context);
      socket.emit("message", messageFormObj);
      avatarController.clear();
    } else if (typeOfMessage == 'video') {
      showLoader(context, 'Just a moment ...');
      if (videoSelected)
        videoController.text = await doUploadVideo(context, _video);
      var messageFormObj = {
        "time": currentTime,
        "message": videoController.text,
        "type": "video",
        "senderUserId": userSD['_id'],
        "receiverUserId": userDetail['friend']['_id']
      };
      pop(context);
      socket.emit("message", messageFormObj);
      videoController.clear();
    }
  }

  void setMessage(message, time, type, senderUserId) {
    MessageModel messageModel = MessageModel(
      receiverUserId: userDetail['friend']['_id'],
      senderUserId: senderUserId,
      message: message,
      time: time,
      type: type,
    );
    messages.add(messageModel);
    if (mounted) setState(() {});
  }

  void fetchMessages() {
    var formObject = {"receiverUserId": userDetail['friend']['_id']};
    appService.fetchMessageHistory(formObject).then((response) {
      if (response['status'] == 'success') {
        if (response['data'].isNotEmpty) {
          messages = response['data'].map<MessageModel>((data) {
            return MessageModel(
              message: data['message'],
              time: data['createdAt'],
              type: data['type'],
              receiverUserId: data['receiverUserId']['_id'],
              senderUserId: data['senderUserId']['_id'],
            );
          }).toList();
        }
        loader = false;
        appScrollController();
      }
      if (mounted) setState(() {});
    });
  }

  Future avatarCamera(BuildContext context) async {
    final dynamic image = await ImagePicker.platform.pickImage(
      source: ImageSource.camera,
      imageQuality: 60,
    );
    if (image != null) {
      _img = File(image.path);
      imageSelected = true;
      sendMessage('file');
      if (mounted) setState(() {});
    }
  }

  Future avatarGallery(BuildContext context) async {
    final dynamic image = await ImagePicker.platform.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
    );
    if (image != null) {
      _img = File(image.path);
      imageSelected = true;
      sendMessage('file');
      if (mounted) setState(() {});
    }
  }

  Future videoGallery(BuildContext context) async {
    final dynamic video = await ImagePicker.platform.pickVideo(
      source: ImageSource.gallery,
    );
    if (video != null) {
      _video = File(video.path);
      videoSelected = true;
      sendMessage('video');
      if (mounted) setState(() {});
    }
  }

  appScrollController() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void chatUserLastSceneTime() {
    var formObject = {"receiverUserId": userDetail['friend']['_id']};
    appService.getChatUserLastSceneTime(formObject).then((response) {
      if (response['status'] == 'success') {
        if (response['lastScene'] == "Online") {
          lastScene = 'User is Online now';
        } else if (response['lastScene'] != "Online" &&
            response['lastScene'] != "") {
          lastScene = "last scene " + dateTimePipe(response['lastScene']);
        } else if (response['lastScene'] == "") {
          lastScene = "last scene is not available yet";
        }
      }
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/wallpapers/$appwallpaper"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: AppBar(
              leadingWidth: 70,
              titleSpacing: 0,
              leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.arrow_back,
                      size: 22,
                    ),
                    const SizedBox(
                      width: 2,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: CachedNetworkImage(
                        width: 40,
                        height: 40,
                        imageUrl:
                            Config.baseURL + userDetail['friend']['avatar'],
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
              title: InkWell(
                onTap: () {},
                child: Container(
                  margin: const EdgeInsets.all(5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${userDetail['friend']['fullName']}",
                        style: TextStyle(
                          fontSize: apptit,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        lastScene,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                // IconButton(
                //     icon: Icon(Icons.videocam),
                //     onPressed: () {
                //       Navigator.push(context,
                //           MaterialPageRoute(builder: (context) => CallPage()));
                //     }),
                // IconButton(icon: Icon(Icons.call), onPressed: () {}),
                PopupMenuButton<String>(
                  padding: const EdgeInsets.all(0),
                  onSelected: (value) {},
                  itemBuilder: (BuildContext contesxt) {
                    return [
                      const PopupMenuItem(
                        value: "View Contact",
                        child: Text("View Contact"),
                      ),
                      const PopupMenuItem(
                        value: "Media, links, and docs",
                        child: Text("Media, links, and docs"),
                      ),
                      const PopupMenuItem(
                        value: "Whatsapp Web",
                        child: Text("Whatsapp Web"),
                      ),
                      const PopupMenuItem(
                        value: "Search",
                        child: Text("Search"),
                      ),
                      const PopupMenuItem(
                        value: "Mute Notification",
                        child: Text("Mute Notification"),
                      ),
                      const PopupMenuItem(
                        value: "Wallpaper",
                        child: Text("Wallpaper"),
                      ),
                    ];
                  },
                ),
              ],
            ),
          ),
          body: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: loader
                ? Center(
                    child: CircularProgressIndicator(
                      backgroundColor: lightColor,
                      color: primaryColor,
                    ),
                  )
                : WillPopScope(
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            controller: _scrollController,
                            itemCount: messages.length + 1,
                            itemBuilder: (context, index) {
                              if (index == messages.length) {
                                return Container(
                                  height: 70,
                                );
                              }
                              if (messages[index].senderUserId ==
                                  userSD['_id']) {
                                return OwnMessageCard(
                                  message: messages[index].message,
                                  time: messages[index].time,
                                  type: messages[index].type,
                                );
                              } else {
                                return ReplyCard(
                                  message: messages[index].message,
                                  time: messages[index].time,
                                  type: messages[index].type,
                                );
                              }
                            },
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            // height: 70,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width -
                                          60,
                                      child: Card(
                                        margin: const EdgeInsets.only(
                                            left: 2, right: 2, bottom: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        child: TextField(
                                          controller: controller,
                                          focusNode: focusNode,
                                          textAlignVertical:
                                              TextAlignVertical.center,
                                          keyboardType: TextInputType.multiline,
                                          maxLines: 5,
                                          minLines: 1,
                                          // onChanged: (value) {
                                          //   if (value.length > 0) {
                                          //     setState(() {
                                          //       sendButton = true;
                                          //     });
                                          //   } else {
                                          //     setState(() {
                                          //       sendButton = false;
                                          //     });
                                          //   }
                                          // },
                                          decoration: InputDecoration(
                                            focusedBorder:
                                                const OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            border: const OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder:
                                                const OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            hintText: "Type a message",
                                            hintStyle: const TextStyle(
                                                color: Colors.grey),
                                            prefixIcon: IconButton(
                                              icon: Icon(
                                                show
                                                    ? Icons.keyboard
                                                    : Icons.keyboard,
                                              ),
                                              onPressed: () {
                                                if (!show) {
                                                  focusNode.unfocus();
                                                  focusNode.canRequestFocus =
                                                      false;
                                                }
                                                setState(() {
                                                  show = !show;
                                                });
                                              },
                                            ),
                                            suffixIcon: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.attach_file),
                                                  onPressed: () {
                                                    showModalBottomSheet(
                                                        backgroundColor:
                                                            Colors.transparent,
                                                        context: context,
                                                        builder: (builder) =>
                                                            bottomSheet());
                                                  },
                                                ),
                                              ],
                                            ),
                                            contentPadding:
                                                const EdgeInsets.all(5),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 8,
                                        right: 2,
                                        left: 2,
                                      ),
                                      child: CircleAvatar(
                                        radius: 25,
                                        backgroundColor:
                                            const Color(0xFF128C7E),
                                        child: IconButton(
                                          icon: Icon(
                                            sendButton ? Icons.send : Icons.mic,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            if (sendButton) {
                                              sendMessage("text");
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                show ? Container() : Container(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    onWillPop: () {
                      if (show) {
                        setState(() {
                          show = false;
                        });
                      } else {
                        Navigator.pop(context);
                      }
                      return Future.value(false);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 278,
      width: MediaQuery.of(context).size.width,
      child: Card(
        margin: const EdgeInsets.all(18.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      videoGallery(context);
                    },
                    child: iconCreation(Icons.video_camera_front_rounded,
                        Colors.indigo, "Video"),
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      avatarCamera(context);
                    },
                    child:
                        iconCreation(Icons.camera_alt, Colors.pink, "Camera"),
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        avatarGallery(context);
                      },
                      child: iconCreation(
                          Icons.insert_photo, Colors.purple, "Gallery")),
                ],
              ),
              // SizedBox(
              //   height: 30,
              // ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     iconCreation(Icons.headset, Colors.orange, "Audio"),
              //     SizedBox(
              //       width: 40,
              //     ),
              //     iconCreation(Icons.location_pin, Colors.teal, "Location"),
              //     SizedBox(
              //       width: 40,
              //     ),
              //     iconCreation(Icons.person, Colors.blue, "Contact"),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget iconCreation(IconData icons, Color color, String text) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: color,
          child: Icon(
            icons,
            // semanticLabel: "Help",
            size: 29,
            color: Colors.white,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            // fontWeight: FontWeight.w100,
          ),
        )
      ],
    );
  }
}
