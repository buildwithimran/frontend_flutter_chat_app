import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/src/helper/globals.dart';
import 'package:chat_app/src/helper/helper.dart';
import 'package:chat_app/src/pages/tab_bar.dart';
import 'package:chat_app/src/services/app.service.dart';
import 'package:chat_app/src/services/storage.service.dart';
import 'package:chat_app/src/utils/config_util.dart';
import 'package:chat_app/src/utils/loading_util.dart';
import 'package:chat_app/src/utils/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';

class UpdateProfilePage extends StatefulWidget {
  const UpdateProfilePage({super.key});

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  // Services
  var appSer = AppService();

  // Variables
  bool imageSelected = false;
  File img = File('');

  final avatar = TextEditingController();
  final FocusNode _fullNameFocus = FocusNode();

  final fullNameController = TextEditingController();

  bool _isValidFullName(String fullNameController) {
    return fullNameController.isNotEmpty && fullNameController.length > 3;
  }

  imageBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          return Container(
            height: 200,
            decoration: BoxDecoration(
              color: lightColor,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Wrap(
              children: <Widget>[
                const Center(
                    child: Text(
                  'Choose Source',
                  style: TextStyle(fontSize: 20, fontFamily: 'pr'),
                )),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: ListTile(
                      leading: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.5, 0.5],
                            colors: [Colors.purple, Colors.purple.shade400],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Icon(
                            Icons.image_outlined,
                            color: lightColor,
                          ),
                        ),
                      ),
                      title: const Text(
                        'Gallery',
                        style: TextStyle(fontFamily: 'pr'),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        avatarGallery(context);
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: ListTile(
                    leading: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.5, 0.5],
                              colors: [Colors.pink, Colors.pink.shade400])),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Icon(
                          Icons.camera_alt_outlined,
                          color: lightColor,
                        ),
                      ),
                    ),
                    title: const Text(
                      'Camera',
                      style: TextStyle(fontFamily: 'pr'),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      avatarCamera(context);
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future avatarCamera(BuildContext context) async {
    final dynamic image = await ImagePicker.platform.pickImage(
      source: ImageSource.camera,
      imageQuality: 60,
    );
    if (image != null) {
      img = File(image.path);
      imageSelected = true;
      if (mounted) setState(() {});
    }
  }

  Future avatarGallery(BuildContext context) async {
    final dynamic image = await ImagePicker.platform.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
    );
    if (image != null) {
      img = File(image.path);
      imageSelected = true;
      if (mounted) setState(() {});
    }
  }

  goAuth() {
    unFocus(context);

    if (fullNameController.text.isEmpty) {
      showToast(context, 3, 'All fields are required');
      return;
    }
    doAction();
  }

  doAction() async {
    showLoader(context, 'Just a moment ...');
    if (imageSelected) avatar.text = await doUploadImage(context, img);

    var form = {
      "fullName": fullNameController.text,
      "avatar": avatar.text,
    };

    appSer.updateProfile(form, userSD['_id']).then((result) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const TabsUserScreen()),
          (Route<dynamic> route) => false);
      if (result['status'] == 'success') {
        userSD = result['data'];
        StorageService.setLogin(result['data']);
        if (mounted) setState(() {});
        showToast(context, 3, "Profile updated");
      }
    });
  }

  @override
  void initState() {
    avatar.text = userSD['avatar'] ?? '';
    fullNameController.text = userSD['fullName'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => {Navigator.pop(context)},
          icon: Icon(
            Icons.arrow_back_ios_new_sharp,
            color: lightColor,
            size: appicon,
          ),
        ),
        title: Text(
          'Update Profile',
          style:
              TextStyle(color: lightColor, fontFamily: 'psb', fontSize: apptit),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => unFocus(context),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: p),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Profile details',
                    style: TextStyle(
                      fontFamily: 'psb',
                      fontSize: 15,
                    ),
                  ),
                ),
                const Align(
                  alignment: Alignment.topLeft,
                  child: Text('Change the personal information and save them.'),
                ),
                Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      padding: const EdgeInsets.all(0),
                      child: Stack(
                        children: [
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                  width: 120,
                                  height: 120,
                                  child: imageSelected == false
                                      ? CachedNetworkImage(
                                          imageUrl:
                                              Config.baseURL + userSD['avatar'],
                                          placeholder: (context, url) =>
                                              const Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                          errorWidget: (context, url, error) =>
                                              const Icon(OctIcons.info_16),
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(img, fit: BoxFit.cover)),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 0,
                            child: InkWell(
                              onTap: () {
                                imageBottomSheet(context);
                              },
                              child: Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: lightColor,
                                    width: 4,
                                  ),
                                  color: primaryColor,
                                ),
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  size: 15,
                                  color: lightColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Full Name',
                                  style: TextStyle(fontFamily: 'pr'),
                                ),
                                const SizedBox(height: 5),
                                TextField(
                                  focusNode: _fullNameFocus,
                                  controller: fullNameController,
                                  cursorColor: primaryColor,
                                  cursorWidth: 1.4,
                                  keyboardType: TextInputType.name,
                                  decoration: const InputDecoration(
                                      hintText: 'Enter Full Name'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: EdgeInsets.symmetric(horizontal: p),
        child: MaterialButton(
          onPressed: () {
            goAuth();
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          padding: const EdgeInsets.all(0),
          child: Ink(
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Container(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width,
                minHeight: 50,
                maxHeight: 50,
              ),
              alignment: Alignment.center,
              child: Text(
                'Save',
                style: TextStyle(
                  color: lightColor,
                  fontFamily: 'psb',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
