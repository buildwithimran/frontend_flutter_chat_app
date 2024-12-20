import 'package:chat_app/src/services/request_structure.dart';
import 'package:chat_app/src/utils/config_util.dart';

class AppService {
  var req = Req();

  // Authentication APIs
  Future<dynamic> signIn(data) async {
    return await req.post('${Config.baseURL}user/login', data);
  }

  Future<dynamic> signUp(data) async {
    return await req.post('${Config.baseURL}user/register', data);
  }

  Future<dynamic> resetPassword(data) async {
    return await req.post('${Config.baseURL}user/reset-password', data);
  }

  Future<dynamic> updateProfile(data, id) async {
    return await req.post('${Config.baseURL}user/update-profile/$id', data);
  }

  Future<dynamic> getParticipants() async {
    return await req.get('${Config.baseURL}user/participants');
  }

  Future<dynamic> getMyFriends() async {
    return await req.get('${Config.baseURL}user/fetch-friends');
  }

  Future<dynamic> uploader(data) async {
    return await req.post('${Config.baseURL}user/uploader', data);
  }

  // Send Message
  Future<dynamic> sendMessage(data) async {
    return await req.post('${Config.baseURL}message/sendMessage', data);
  }

  // Chat History
  Future<dynamic> fetchMessageHistory(data) async {
    return await req.post('${Config.baseURL}message/messageHistory', data);
  }

  // getAllNotifications
  Future<dynamic> getAllNotifications() async {
    return await req.get('${Config.baseURL}message/getAllNotifications');
  }

  // My Invitations
  Future<dynamic> myInvitations() async {
    return await req.get('${Config.baseURL}invitation/myInvitation');
  }

  // Accept Invitation
  Future<dynamic> acceptInvitation(data) async {
    return await req.post('${Config.baseURL}invitation/accepted', data);
  }

  // Sent Invitation
  Future<dynamic> sentInvitation(data) async {
    return await req.post('${Config.baseURL}invitation/create', data);
  }

  // Like And Dislike Button
  Future<dynamic> adToFavUser(data) async {
    return await req.post('${Config.baseURL}user/adToFavUser', data);
  }

  Future<dynamic> removeToFavUser(data) async {
    return await req.post('${Config.baseURL}user/removeToFavUser', data);
  }

  // Get Setting
  Future<dynamic> getSetting() async {
    return await req.get('${Config.baseURL}setting/getSetting');
  }

  // Update Setting
  Future<dynamic> updateSetting(data) async {
    return await req.post('${Config.baseURL}setting/updateSetting', data);
  }

  // get Last Scene Time
  Future<dynamic> getChatUserLastSceneTime(data) async {
    return await req.post(
        '${Config.baseURL}user/getChatUserLastSceneTime', data);
  }

  // update Last Scene Time
  Future<dynamic> updateLastSceneTime(formObj) async {
    await req.post('${Config.baseURL}user/updateLastSceneTime', formObj);
  }

  // New Apis
  Future<dynamic> checkUserExist(data) async {
    return await req.post('${Config.baseURL}user/checkUserExist', data);
  }

  Future<dynamic> sendEmailOTP(data) async {
    return await req.post('${Config.baseURL}user/sendEmailOTP', data);
  }

  Future<dynamic> sendPhoneOTP(data) async {
    return await req.post('${Config.baseURL}user/sendPhoneOTP', data);
  }
}
