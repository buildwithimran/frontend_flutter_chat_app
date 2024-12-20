import 'package:chat_app/src/pages/tab_bar.dart';
import 'package:chat_app/src/services/storage.service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:chat_app/src/Initials/otp_verify_page.dart';
import 'package:chat_app/src/services/app.service.dart';
import 'package:chat_app/src/helper/globals.dart';
import 'package:chat_app/src/utils/loading_util.dart';
import 'package:chat_app/src/utils/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Services
  var authSer = AppService();

  // Variables
  bool isFullNameValid = true;
  bool isEmailPhoneValid = true;
  bool isPasswordValid = true;
  bool isConfirmPasswordValid = true;

  final FocusNode fullNameFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();

  final fullNameController = TextEditingController();
  final emailPhoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String typeOfField = "email";
  var fcm = "";

  var formData = {
    "fullName": "",
    "email": "",
    "phone": "",
    "type": "",
    "password": "",
    "fcm": "",
    // "otpVerified": true,
  };

  bool obscurePasswordText = true;
  bool obscureConfirmPasswordText = true;

  @override
  void initState() {
    super.initState();
    generateFcmToken();
  }

  Future<void> generateFcmToken() async {
    // Request permission on iOS (optional)
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Obtain the FCM token
    String? token = await messaging.getToken();
    // Print the token or send it to your backend
    if (token != null) {
      fcm = token;
    }
  }

  bool isValidFullName(String fullNameController) {
    return fullNameController.isNotEmpty && fullNameController.length > 3;
  }

  bool isValidEmail(String email) {
    return emailPhoneController.text.isNotEmpty &&
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool isValidPhone(String input) {
    return emailPhoneController.text.length == 10 ||
        emailPhoneController.text.length == 11;
  }

  bool isValidEmailPhone(String input) {
    return isValidEmail(input) || isValidPhone(input);
  }

  bool isValidPassword(String password) {
    return password.isNotEmpty && password.length > 6;
  }

  bool isValidConfirmPassword(String confirmPassword) {
    return confirmPassword.isNotEmpty && confirmPassword.length > 6;
  }

  String _getIconName(String input) {
    if (isValidEmail(input)) {
      return 'email';
    } else if (isValidPhone(input)) {
      return 'phone';
    } else {
      return 'email';
    }
  }

  String getValidationMessage(String input) {
    if (isValidEmail(input)) {
      return 'Valid email format';
    } else if (isValidPhone(input)) {
      return 'Valid phone format';
    } else {
      return 'Invalid format';
    }
  }

  goToAuthentication() {
    if (fullNameController.text.isEmpty ||
        emailPhoneController.text == '' ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      showToast(context, 3, "Invalid credentials");
    } else {
      if (typeOfField == 'email') {
        if (!isValidEmail(emailPhoneController.text)) {
          showToast(
              context, 3, "Full Name must be at least 4 characters long.");
          return;
        }
      }

      if (typeOfField == 'phone') {
        if (!isValidPhone(emailPhoneController.text)) {
          showToast(context, 3, "Invalid Email Address.");
          return;
        }
      }

      if (passwordController.text.length <= 3) {
        showToast(context, 3, "Password must be at least 4 characters long.");
        return;
      }

      if (confirmPasswordController.text.length <= 3) {
        showToast(
            context, 3, "Confirm Password must be at least 4 characters long.");
        return;
      }

      if (passwordController.text != confirmPasswordController.text) {
        showToast(context, 3, "Password mismatch");
        return;
      }

      performSignUp();
    }
  }

  performSignUp() {
    formData['fullName'] = fullNameController.text;
    formData['password'] = passwordController.text;
    formData['role'] = "USER";
    formData['fcm'] = fcm;

    if (typeOfField == 'email') {
      formData['email'] = emailPhoneController.text;
      formData['type'] = typeOfField;
    } else if (typeOfField == 'phone') {
      formData['phone'] = emailPhoneController.text;
      formData['type'] = typeOfField;
    }
    checkUserExist();
  }

  checkUserExist() {
    showLoader(context, '${'Just a moment'} ...');
    authSer.checkUserExist(formData).then((value) {
      pop(context);
      if (value['status'] == 'user_not_exist') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerifyScreen(
              purpose: 'signUp',
              typeOfField: typeOfField,
              data: formData,
            ),
          ),
        );
      } else {
        if (typeOfField == 'email') {
          showToast(
              context, 3, "Email already taken, please use a different one.");
        } else if (typeOfField == 'phone') {
          showToast(context, 3,
              "Phone Number already taken, please use a different one.");
        }
      }
    });
  }

  doSignUp(data) {
    authSer.signUp(data).then((result) {
      if (result['status'] == 'success') {
        userSD = result['data']['user'];
        if (mounted) setState(() {});
        StorageService.setToken(result['data']['token']).then((a) {
          StorageService.setLogin(userSD).then((a) {
            showToast(context, 3, "Welcome to your account");
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const TabsUserScreen()),
                (Route<dynamic> route) => false);
          });
        });
      } else if (result['status'] == 'user_mobile_already_exist') {
        showToast(context, 3,
            "Phone Number already taken, please use a different one.");
      } else if (result['status'] == 'user_email_already_exist') {
        showToast(
            context, 3, "Email already taken, please use a different one.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        unFocus(context);
      },
      child: Scaffold(
        backgroundColor: lightColor,
        appBar: AppBar(toolbarHeight: 0),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(p),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2cb56b),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 20,
                            color: lightColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: "Let's ",
                        style: TextStyle(fontSize: 20, color: darkColor),
                        children: <TextSpan>[
                          TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(
                                  fontFamily: 'pb', color: darkColor)),
                          const TextSpan(text: '  👇')
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text("Welcome back, You've been missed",
                          style: TextStyle(fontSize: 15, color: darkColor)),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Full Name',
                        style: TextStyle(
                          fontFamily: 'rb',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        focusNode: fullNameFocus,
                        controller: fullNameController,
                        onChanged: (_) {
                          setState(() {
                            isFullNameValid =
                                isValidFullName(fullNameController.text);
                          });
                        },
                        cursorColor: primaryColor,
                        cursorWidth: 1.4,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            OctIcons.person_16,
                            color: greyColor,
                            size: 18,
                          ),
                          hintText: 'Full Name',
                          hintStyle: TextStyle(color: greyColor),
                          errorText: isFullNameValid
                              ? null
                              : 'Full Name must be at least 4 characters long.',
                          errorStyle: TextStyle(color: primaryColor),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: greyColor, width: 1),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: primaryColor, width: 2),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email or Phone Number',
                        style: TextStyle(
                          fontFamily: 'rb',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: emailPhoneController,
                        onChanged: (_) {
                          setState(() {
                            final input = emailPhoneController.text;
                            isEmailPhoneValid = isValidEmailPhone(input);
                            typeOfField = _getIconName(input);
                          });
                        },
                        cursorColor: primaryColor,
                        cursorWidth: 1.4,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            typeOfField == 'email' ? Icons.email : Icons.phone,
                            color: greyColor,
                            size: 18,
                          ),
                          hintText: 'Enter Email or Phone Number',
                          hintStyle: TextStyle(color: greyColor),
                          errorText: isEmailPhoneValid
                              ? null
                              : getValidationMessage(emailPhoneController.text),
                          errorStyle: TextStyle(color: primaryColor),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: greyColor, width: 1),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: primaryColor, width: 2),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontFamily: 'rb',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        focusNode: passwordFocus,
                        controller: passwordController,
                        obscureText: obscurePasswordText,
                        onChanged: (_) {
                          setState(() {
                            isPasswordValid =
                                isValidPassword(passwordController.text);
                          });
                        },
                        cursorColor: primaryColor,
                        cursorWidth: 1.4,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: greyColor,
                            size: 18,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscurePasswordText = !obscurePasswordText;
                              });
                            },
                            icon: Icon(
                              obscurePasswordText
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: greyColor,
                              size: 18,
                            ),
                          ),
                          hintText: '******',
                          hintStyle: TextStyle(color: greyColor),
                          errorText: isPasswordValid
                              ? null
                              : 'Password must be at least 4 characters long.',
                          errorStyle: TextStyle(color: primaryColor),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: greyColor, width: 1),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: primaryColor, width: 2),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Confirm Password',
                        style: TextStyle(
                          fontFamily: 'rb',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        focusNode: confirmPasswordFocus,
                        controller: confirmPasswordController,
                        obscureText: obscureConfirmPasswordText,
                        onChanged: (_) {
                          setState(() {
                            isConfirmPasswordValid = isValidConfirmPassword(
                                confirmPasswordController.text);
                          });
                        },
                        cursorColor: primaryColor,
                        cursorWidth: 1.4,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: greyColor,
                            size: 18,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscureConfirmPasswordText =
                                    !obscureConfirmPasswordText;
                              });
                            },
                            icon: Icon(
                              obscureConfirmPasswordText
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: greyColor,
                              size: 18,
                            ),
                          ),
                          hintText: '******',
                          hintStyle: TextStyle(color: greyColor),
                          errorText: isConfirmPasswordValid
                              ? null
                              : 'Confirm Password must be at least 4 characters long.',
                          errorStyle: TextStyle(color: primaryColor),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: greyColor, width: 1),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: primaryColor, width: 2),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: shadowLightColor,
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(primaryColor),
                        overlayColor:
                            MaterialStateProperty.all<Color>(primaryLightColor),
                      ),
                      onPressed: () => goToAuthentication(),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        height: 55,
                        width: MediaQuery.of(context).size.width - 80,
                        alignment: Alignment.center,
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: lightColor,
                            fontFamily: 'psb',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/signin');
                      },
                      child: Text(
                        'Sign In',
                        style: TextStyle(color: darkColor, fontFamily: 'psb'),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
