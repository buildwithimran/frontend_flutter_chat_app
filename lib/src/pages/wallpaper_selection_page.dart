import 'package:carousel_slider/carousel_slider.dart';
import 'package:chat_app/src/helper/arrayList.dart';
import 'package:chat_app/src/helper/globals.dart';
import 'package:chat_app/src/models/SettingModel.dart';
import 'package:chat_app/src/services/app.service.dart';
import 'package:chat_app/src/services/storage.service.dart';
import 'package:chat_app/src/utils/loading_util.dart';
import 'package:chat_app/src/utils/theme_util.dart';
import 'package:flutter/material.dart';

class WallPaperSelectionPage extends StatefulWidget {
  const WallPaperSelectionPage({super.key});

  @override
  State<WallPaperSelectionPage> createState() => _WallStatePapersPage();
}

class _WallStatePapersPage extends State<WallPaperSelectionPage> {
  // Services
  var appService = AppService();

  // variables
  int _currentWallpaperIndex = 0;
  bool loader = true;
  SettingModel appSetting = SettingModel(fontType: '', wallpaper: '');

  // Functions
  @override
  void initState() {
    super.initState();
    initialSetting();
  }

  initialSetting() {
    appService.getSetting().then((response) {
      if (response['status'] == 'success') {
        for (var i = 0; i < wallPapersArray.length; i++) {
          if (wallPapersArray[i] == response['data']['wallpaper']) {
            _currentWallpaperIndex = i;
          }
        }
        appSetting = SettingModel(
          fontType: response['data']['fontType'],
          wallpaper: response['data']['wallpaper'],
        );
      }
      loader = false;
      if (mounted) setState(() {});
    });
  }

  updateWallpaper() {
    var formObj = {"wallpaper": wallPapersArray[_currentWallpaperIndex]};
    appService.updateSetting(formObj).then((response) {
      if (response['status'] == 'success') {
        StorageService.setString(
                "appwallpaper", wallPapersArray[_currentWallpaperIndex])
            .then((wallpaperResponse) {
          appwallpaper = wallPapersArray[_currentWallpaperIndex];
        });
        pop(context);
        showSnackBar("Updated");
      }
      if (mounted) setState(() {});
    });
  }

  showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new_sharp,
            size: appicon,
          ),
        ),
        title: Text(
          'WallPaper Preview',
          style: TextStyle(fontFamily: 'psb', fontSize: apptit),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(2),
            ),
          ),
          child: loader == true
              ? Center(
                  child: CircularProgressIndicator(
                    backgroundColor: backgroundColor,
                    color: primaryColor,
                  ),
                )
              : Stack(
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        initialPage: _currentWallpaperIndex,
                        height: MediaQuery.of(context).size.height,
                        autoPlay: false,
                        pageSnapping: true,
                        viewportFraction: 1,
                        enableInfiniteScroll: true,
                        pauseAutoPlayOnTouch: true,
                        onPageChanged: (index, reason) {
                          _currentWallpaperIndex = index;
                          if (mounted) setState(() {});
                        },
                      ),
                      items: List.generate(wallPapersArray.length, (index) {
                        return GestureDetector(
                          onTap: () {},
                          child: Image.asset(
                            "assets/images/wallpapers/${wallPapersArray[_currentWallpaperIndex]}",
                            fit: BoxFit.cover,
                          ),
                        );
                      }),
                    ),
                    Positioned(
                      bottom: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 35),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: List.generate(wallPapersArray.length,
                                    (index) {
                                  return _currentWallpaperIndex == index
                                      ? Container(
                                          height: 5,
                                          width: 15,
                                          margin: const EdgeInsets.only(
                                              right: 3, left: 3),
                                          decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        )
                                      : Container(
                                          height: 4,
                                          width: 7,
                                          margin:
                                              const EdgeInsets.only(left: 1),
                                          decoration: BoxDecoration(
                                            color: lightColor.withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        );
                                }),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: EdgeInsets.all(p),
                            child: MaterialButton(
                              onPressed: () {
                                updateWallpaper();
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
                                  constraints: const BoxConstraints(
                                    maxWidth: 300,
                                    minHeight: 50,
                                    maxHeight: 50,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Set wallpaper',
                                    style: TextStyle(
                                      color: lightColor,
                                      fontFamily: 'psb',
                                    ),
                                  ),
                                ),
                              ),
                            ),
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
