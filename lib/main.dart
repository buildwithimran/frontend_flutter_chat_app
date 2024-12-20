import 'package:chat_app/src/Initials/sign_in_page.dart';
import 'package:chat_app/src/Initials/sign_up_page.dart';
import 'package:chat_app/src/Initials/splash_screen_page.dart';
import 'package:chat_app/src/helper/helper.dart';
import 'package:chat_app/src/services/app.service.dart';
import 'package:chat_app/src/services/storage.service.dart';
import 'package:chat_app/src/services/widgets_binding_observer.dart';
import 'package:chat_app/src/utils/theme_util.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
// Services
  var appService = AppService();

  // Variables
  final AppLifecycleObserver appLifecycleObserver = AppLifecycleObserver();

  // Functions
  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();

    // START UPDATE IF USER LOGGED IN LAST SCENE
    StorageService.getLogin().then((user) {
      if (user != false) {
        appLifecycleObserver.initialize(onBackground: () {
          appService.updateLastSceneTime({
            "lastScene": createTimestamp(),
          });
        });
        appService.updateLastSceneTime({
          "lastScene": "Online",
        });
      }
    });
    // END
  }

  @override
  void dispose() {
    appLifecycleObserver.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'pr',
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: primaryColor,
          iconTheme: IconThemeData(color: lightColor),
          titleTextStyle: TextStyle(color: lightColor, fontFamily: 'pb'),
        ),
        textTheme: TextTheme(
          titleMedium: TextStyle(color: darkColor, fontSize: 14),
          bodyLarge: TextStyle(color: darkColor, fontSize: 14),
          bodyMedium: TextStyle(color: darkColor, fontSize: 14),
        ),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: primaryColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: redColor, width: 1),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: fillColor, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: greyColor, width: 1),
            borderRadius: BorderRadius.circular(4.0),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: greyColor, width: 1),
            borderRadius: BorderRadius.circular(4.0),
          ),
          errorStyle: TextStyle(color: primaryColor),
          hintStyle: TextStyle(color: greyColor),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashPage(),
        '/signin': (context) => SignInScreen(),
        '/signup': (context) => SignUpScreen(),
      },
    );
  }
}
