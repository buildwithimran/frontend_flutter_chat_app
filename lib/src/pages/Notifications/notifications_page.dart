import 'dart:convert';
import 'package:chat_app/src/helper/helper.dart';
import 'package:chat_app/src/services/app.service.dart';
import 'package:chat_app/src/utils/config_util.dart';
import 'package:chat_app/src/utils/loading_util.dart';
import 'package:chat_app/src/utils/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final AppService appService = AppService();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flp = FlutterLocalNotificationsPlugin();
  List<Map<String, dynamic>> notifications = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    getAllNotifications();
    notificationListener();
  }

  void notificationListener() async {
    // Notification channel setup
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'chat_app_channel',
      'Chat App',
      description: 'Chat app description',
      importance: Importance.max,
    );

    await flp
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Requesting permission for receiving notifications
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      var initialzationSettingsAndroid =
          const AndroidInitializationSettings('@mipmap/ic_launcher');
      var initializationSettings = InitializationSettings(
        android: initialzationSettingsAndroid,
        iOS: const DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      );

      flp.initialize(initializationSettings);

      // Listening for incoming messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        var data = jsonDecode(message.data['data']);
        notifications.insert(0, data);
        if (mounted) setState(() {});
        RemoteNotification notification = message.notification!;
        AndroidNotification android = (message.notification?.android)!;

        flp.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: android.smallIcon,
              color: Colors.white,
              colorized: true,
              enableVibration: true,
              styleInformation: const BigTextStyleInformation(''),
            ),
          ),
        );
      });

      // Handling notification open event
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (message.data.isNotEmpty) {
          var page = message.data['page'];
          if (page == 'project') {
            // Do something with project page notification
          }
        }
      });
    }
  }

  void getAllNotifications() {
    loading = true;
    if (mounted) setState(() {});

    appService.getAllNotifications().then((result) {
      if (result['status'] == 'success') {
        notifications = List<Map<String, dynamic>>.from(result['data']);
        loading = false;
      } else {
        showToast(context, 3, "Error. Please retry later.");
      }
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(fontSize: apptit, fontFamily: 'psb'),
        ),
      ),
      body: loading
          ? Center(
              child: CircularProgressIndicator(
                backgroundColor: lightColor,
                color: primaryColor,
              ),
            )
          : notifications.isEmpty
              ? const Center(
                  child: Text(
                    'No notifications available.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: p, vertical: 0),
                  height: notifications.length * 110,
                  child: ListView(
                    children: List.generate(notifications.length, (index) {
                      var notification = notifications[index];

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        margin: const EdgeInsets.only(bottom: 5),
                        decoration: BoxDecoration(
                            color: lightColor,
                            border: Border(
                              bottom: BorderSide(color: fillColor),
                            )),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(5),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: CachedNetworkImage(
                              width: 55,
                              height: 55,
                              imageUrl: Config.baseURL + notification['photo'],
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            notification['title'].toString().toTitleCase(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontFamily: 'pr'),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dateAndTimePipe(notification['createdAt']),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: greyColor,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
    );
  }
}
