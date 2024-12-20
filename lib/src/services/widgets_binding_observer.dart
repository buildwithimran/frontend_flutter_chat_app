import 'package:flutter/material.dart';

class AppLifecycleObserver with WidgetsBindingObserver {
  Function? onBackgroundCallback;

  void initialize({required Function onBackground}) {
    onBackgroundCallback = onBackground;
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App is in the background
      if (onBackgroundCallback != null) {
        onBackgroundCallback!();
      }
    }
  }

  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
  }
}
