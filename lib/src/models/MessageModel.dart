// ignore_for_file: file_names

class MessageModel {
  String message;
  String time;
  String type;
  String receiverUserId;
  String senderUserId;
  MessageModel(
      {required this.message,
      required this.time,
      required this.type,
      required this.receiverUserId,
      required this.senderUserId});
}
