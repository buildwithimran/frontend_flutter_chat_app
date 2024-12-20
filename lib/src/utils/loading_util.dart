import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'theme_util.dart';

FToast fToast = FToast();

showLoader(BuildContext context, message) {
  Dialog customDialog = Dialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Container(
      padding: const EdgeInsets.all(16),
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: lightColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(1),
              child: CircularProgressIndicator(
                backgroundColor: lightColor,
                color: primaryColor,
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.all(7),
              child: Text(
                message,
                maxLines: 5,
              ),
            )),
          ],
        ),
      ),
    ),
  );

  // Show the custom dialog
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return customDialog;
    },
  );
}

pop(BuildContext context) {
  Navigator.pop(context);
}

rootPop(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop();
}

unFocus(BuildContext context) {
  FocusScope.of(context).unfocus();
}

showToast(BuildContext context, duration, msg) {
  fToast.init(context);
  fToast.showToast(
    toastDuration: Duration(seconds: duration),
    gravity: ToastGravity.BOTTOM,
    child: Container(
      padding: const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0), color: primaryLightColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            msg,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: lightColor,
              fontFamily: 'pr',
              fontSize: 14,
            ),
          ),
        ],
      ),
    ),
  );
}

// showToast(BuildContext context, duration, msg) {
//   fToast.init(context);
//   fToast.showToast(
//     toastDuration: Duration(seconds: duration),
//     gravity: ToastGravity.BOTTOM,
//     child: Container(
//       padding: const EdgeInsets.only(left: 13, top: 20, right: 5, bottom: 20),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(5.0),
//         color: lightColor,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 7,
//             offset: const Offset(2, 3),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Image.asset('assets/images/android/androidAppIcon.png', height: 30),
//           const SizedBox(width: 13),
//           Expanded(
//             child: Text(
//               msg,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               textAlign: TextAlign.left,
//               style: TextStyle(
//                 color: darkColor,
//                 fontFamily: 'pr',
//                 fontSize: 12.5,
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

underDevelopment(context) {
  showToast(context, 3, "Feature is under development");
}
