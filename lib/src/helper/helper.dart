import 'dart:convert';
import 'dart:io';
import 'package:chat_app/src/Initials/sign_in_page.dart';
import 'package:chat_app/src/services/app.service.dart';
import 'package:chat_app/src/services/storage.service.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import 'package:intl/intl.dart';
import '../utils/loading_util.dart';

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

datePipe(date) {
  DateTime dateTime = DateTime.parse(date);
  dateTime = dateTime.toLocal();
  return timeAgo.format(
    dateTime,
    locale: 'en',
    clock: DateTime.now(),
    allowFromNow: true,
  );
}

dateTimePipe(date) {
  DateTime dateTime = DateTime.parse(date);
  dateTime = dateTime.toLocal();

  // Define your desired date and time format
  final DateFormat formatter = DateFormat('dd MMM yy hh:mm a');

  // Format the DateTime object
  return formatter.format(dateTime);
}

dateTimeChatPipe(date) {
  DateTime dateTime = DateTime.parse(date);
  dateTime = dateTime.toLocal();

  // Define your desired date and time format
  final DateFormat formatter = DateFormat('dd MMM hh:mm a');

  // Format the DateTime object
  return formatter.format(dateTime);
}

String dateAndTimePipe(String date) {
  DateTime dateTime = DateTime.parse(date);
  dateTime = dateTime.toLocal();
  String formattedDateTime =
      '${dateTime.month}/${dateTime.day}/${dateTime.year} ${_formatTime(dateTime)}';
  return formattedDateTime;
}

String _formatTime(DateTime dateTime) {
  String hour = dateTime.hour.toString().padLeft(2, '0');
  String minute = dateTime.minute.toString().padLeft(2, '0');
  String period = dateTime.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

String formatUSPhoneNumber(String phoneNumber) {
  final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
  if (cleanedNumber.length >= 11 && cleanedNumber.startsWith('+91') ||
      cleanedNumber.startsWith('+92') ||
      cleanedNumber.startsWith('+1')) {
    return '(${cleanedNumber.substring(1, 4)}) ${cleanedNumber.substring(4, 7)}-${cleanedNumber.substring(7)}';
  } else {
    return phoneNumber;
  }
}

logout(BuildContext context) {
  StorageService.logout();
  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => SignInScreen()),
      (Route<dynamic> route) => false);
}

Future doUploadImage(context, File file) async {
  var uploaderSer = AppService();

  String fileName = DateTime.now().millisecondsSinceEpoch.toString() +
      file.path.split("/").last;
  var uploaderTemp = {
    "name": fileName,
    "file": base64Encode(file.readAsBytesSync()),
  };
  var res = await uploaderSer.uploader(uploaderTemp);
  if (res['status'] == 'success') {
    return res['data'];
  } else {
    showToast(context, 3, "Image upload unsuccessful");
    return false;
  }
}

Future doUploadVideo(context, File file) async {
  var uploaderSer = AppService();

  String fileName = DateTime.now().millisecondsSinceEpoch.toString() +
      file.path.split("/").last;
  var uploaderTemp = {
    "name": fileName,
    "file": base64Encode(file.readAsBytesSync()),
  };

  var res = await uploaderSer.uploader(uploaderTemp);
  if (res['status'] == 'success') {
    return res['data'];
  } else {
    showToast(context, 3, "Video upload unsuccessful");
    return false;
  }
}

// Function to create a timestamp string in ISO 8601 format
String createTimestamp() {
  DateTime now = DateTime.now();
  String formatted = now.toIso8601String();
  return formatted;
}
