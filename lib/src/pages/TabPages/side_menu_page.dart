import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/src/Initials/privacy_policy_page.dart';
import 'package:chat_app/src/Initials/terms_conditions_page.dart';
import 'package:chat_app/src/helper/globals.dart';
import 'package:chat_app/src/pages/wallpaper_selection_page.dart';
import 'package:chat_app/src/pages/Notifications/notifications_page.dart';
import 'package:chat_app/src/pages/Profile/profile_edit_page.dart';
import 'package:chat_app/src/services/storage.service.dart';
import 'package:chat_app/src/utils/config_util.dart';
import 'package:chat_app/src/utils/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:open_store/open_store.dart';
import 'package:url_launcher/url_launcher.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => SideMenuState();
}

class SideMenuState extends State<SideMenu> {
  var userData = {"fullName": '', "avatar": ''};

  @override
  void initState() {
    if (userSD != false) {
      userData['fullName'] = userSD['fullName'];
      userData['avatar'] = userSD['avatar'];
    }
    super.initState();
  }

  Future<void> _launchEmail() async {
    const String subject = 'Hello';
    const String body =
        "I hope you're well. I'm interested in understanding your app's flow and exploring potential advertising opportunities.";

    final String emailUrl =
        'mailto:example@gmail.com?subject=$subject&body=${Uri.encodeComponent(body)}';

    if (await canLaunch(emailUrl)) {
      await launch(emailUrl);
    } else {
      throw 'Could not launch email';
    }
  }

  Future<void> _launchFacebook() async {
    const facebookUrl = 'https://www.facebook.com';
    await _launchUrl(facebookUrl);
  }

  Future<void> _launchInstagram() async {
    const instagramUrl = 'https://www.instagram.com';
    await _launchUrl(instagramUrl);
  }

  Future<void> _launchTwitter() async {
    const twitterUrl = 'https://twitter.com';
    await _launchUrl(twitterUrl);
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  logout() async {
    await StorageService.logout();
    userSD = false;
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/signin', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: SingleChildScrollView(
        child: Padding(
            padding: EdgeInsets.all(p),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(80)),
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: CachedNetworkImage(
                          imageUrl: "${Config.baseURL}${userData['avatar']}",
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${userSD['fullName']}",
                            style: const TextStyle(
                                fontFamily: 'psb', fontSize: 20),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (userSD['email'].isNotEmpty)
                            Row(
                              children: [
                                const Icon(Icons.mail, size: 15),
                                const SizedBox(width: 5),
                                Text(
                                  "${userSD['email']}",
                                  style: const TextStyle(
                                    fontFamily: 'pr',
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          if (userSD['phone'].isNotEmpty)
                            Row(
                              children: [
                                const Icon(Icons.phone, size: 15),
                                const SizedBox(width: 5),
                                Text(
                                  "${userSD['countryCode']} ${userSD['phone']}",
                                  style: const TextStyle(
                                    fontFamily: 'pr',
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          child: Padding(
                            padding: EdgeInsets.all(p),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Settings',
                                  style: TextStyle(
                                      fontFamily: 'psb', fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const UpdateProfilePage(),
                                ));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: lightColor,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: fillColor),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(p),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.person,
                                        color: primaryColor,
                                      ),
                                      Container(
                                        height: 22,
                                        width: 0.5,
                                        color: greyColor,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                      ),
                                      const Text(
                                        'Update Profile',
                                        style: TextStyle(fontFamily: 'pr'),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_sharp,
                                    size: 12,
                                    color: greyColor,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            OpenStore.instance.open(
                              androidAppBundleId: 'com.android.chrome',
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                              color: lightColor,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: fillColor),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(p),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: primaryColor,
                                      ),
                                      Container(
                                        height: 22,
                                        width: 0.5,
                                        color: greyColor,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                      ),
                                      const Text(
                                        'Rate Us',
                                        style: TextStyle(fontFamily: 'pr'),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_sharp,
                                    size: 12,
                                    color: greyColor,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const WallPaperSelectionPage(),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                              color: lightColor,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: fillColor),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(p),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.image_outlined,
                                        color: primaryColor,
                                      ),
                                      Container(
                                        height: 22,
                                        width: 0.5,
                                        color: greyColor,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                      ),
                                      const Text(
                                        'Wallpapers',
                                        style: TextStyle(fontFamily: 'pr'),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_sharp,
                                    size: 12,
                                    color: greyColor,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    NotificationPage(),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                              color: lightColor,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: fillColor),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(p),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.notifications,
                                        color: primaryColor,
                                      ),
                                      Container(
                                        height: 22,
                                        width: 0.5,
                                        color: greyColor,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                      ),
                                      const Text(
                                        'Notifications',
                                        style: TextStyle(fontFamily: 'pr'),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_sharp,
                                    size: 12,
                                    color: greyColor,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          child: Padding(
                            padding: EdgeInsets.all(p),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'About us',
                                  style: TextStyle(
                                      fontFamily: 'psb', fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _launchEmail();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: lightColor,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: fillColor),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(p),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.contact_mail,
                                        color: primaryColor,
                                      ),
                                      Container(
                                        height: 22,
                                        width: 0.5,
                                        color: greyColor,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                      ),
                                      const Text(
                                        'Contact Us',
                                        style: TextStyle(fontFamily: 'pr'),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_sharp,
                                    size: 12,
                                    color: greyColor,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const PrivacyPolicy(),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(top: 5),
                            decoration: BoxDecoration(
                              color: lightColor,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: fillColor),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(p),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.security,
                                        color: primaryColor,
                                      ),
                                      Container(
                                        height: 22,
                                        width: 0.5,
                                        color: greyColor,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                      ),
                                      const Text(
                                        'Privacy Policy',
                                        style: TextStyle(fontFamily: 'pr'),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_sharp,
                                    size: 12,
                                    color: greyColor,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const TermsAndConditions(),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                              color: lightColor,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: fillColor),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(p),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.note,
                                        color: primaryColor,
                                      ),
                                      Container(
                                        height: 22,
                                        width: 0.5,
                                        color: greyColor,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                      ),
                                      const Text(
                                        'Terms & Conditions',
                                        style: TextStyle(fontFamily: 'pr'),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_sharp,
                                    size: 12,
                                    color: greyColor,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          child: Padding(
                            padding: EdgeInsets.all(p),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Join Us',
                                  style: TextStyle(
                                      fontFamily: 'psb', fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _launchFacebook();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: lightColor,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: fillColor),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(p),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Iconsax.facebook,
                                        color: primaryColor,
                                      ),
                                      Container(
                                        height: 22,
                                        width: 0.5,
                                        color: greyColor,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                      ),
                                      const Text(
                                        'Facebook',
                                        style: TextStyle(fontFamily: 'pr'),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_sharp,
                                    size: 12,
                                    color: greyColor,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _launchInstagram();
                          },
                          child: Container(
                            margin: const EdgeInsets.only(top: 5),
                            decoration: BoxDecoration(
                              color: lightColor,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: fillColor),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(p),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Iconsax.instagram,
                                        color: primaryColor,
                                      ),
                                      Container(
                                        height: 22,
                                        width: 0.5,
                                        color: greyColor,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                      ),
                                      const Text(
                                        'Instagram',
                                        style: TextStyle(fontFamily: 'pr'),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_sharp,
                                    size: 12,
                                    color: greyColor,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _launchTwitter();
                          },
                          child: Container(
                            margin: const EdgeInsets.only(top: 5),
                            decoration: BoxDecoration(
                              color: lightColor,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: fillColor),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(p),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        FontAwesomeIcons.twitter,
                                        color: primaryColor,
                                      ),
                                      Container(
                                        height: 22,
                                        width: 0.5,
                                        color: greyColor,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                      ),
                                      const Text(
                                        'Twitter',
                                        style: TextStyle(fontFamily: 'pr'),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_sharp,
                                    size: 12,
                                    color: greyColor,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            logout();
                          },
                          child: Container(
                            margin: const EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                              color: lightColor,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: fillColor),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(p),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Iconsax.logout,
                                        color: primaryColor,
                                      ),
                                      Container(
                                        height: 22,
                                        width: 0.5,
                                        color: greyColor,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                      ),
                                      const Text(
                                        'Logout',
                                        style: TextStyle(
                                          fontFamily: 'pr',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_sharp,
                                    size: 12,
                                    color: greyColor,
                                  )
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      Config.version,
                      style: TextStyle(
                        fontSize: 12,
                        color: greyColor,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ],
            )),
      ),
    );
  }
}
