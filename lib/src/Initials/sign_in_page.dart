// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:chat_app/src/Initials/forget_password_page.dart';
import 'package:chat_app/src/services/storage.service.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/src/Initials/privacy_policy_page.dart';
import 'package:chat_app/src/Initials/terms_conditions_page.dart';

import '../services/app.service.dart';
import '../helper/globals.dart';
import '../pages/tab_bar.dart';
import '../utils/loading_util.dart';
import '../utils/theme_util.dart';

class SignInScreen extends StatefulWidget {
  SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // Services
  var authSer = AppService();
  var appService = AppService();

// Variables
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailPhoneController = TextEditingController();
  var formData = {"phone": "", "email": "", "type": "", "password": ""};

  bool isPasswordValid = true;
  bool obscurePasswordText = true;
  bool isEmailPhoneValid = true;
  String typeOfField = "email";

// Functions
  bool isValidPassword(String password) {
    return password.isNotEmpty && password.length > 6;
  }

  bool _isValidEmail(String email) {
    return emailPhoneController.text.isNotEmpty &&
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String input) {
    return emailPhoneController.text.length == 10 ||
        emailPhoneController.text.length == 11;
  }

  bool _isValidEmailPhone(String input) {
    return _isValidEmail(input) || _isValidPhone(input);
  }

  String _getValidationMessage(String input) {
    if (_isValidEmail(input)) {
      return 'Valid email format';
    } else if (_isValidPhone(input)) {
      return 'Valid phone format';
    } else {
      return 'Invalid format';
    }
  }

  String _getIconName(String input) {
    if (_isValidEmail(input)) {
      return 'email';
    } else if (_isValidPhone(input)) {
      return 'phone';
    } else {
      return 'email';
    }
  }

  @override
  void initState() {
    super.initState();
  }

  void goToAuthentication() {
    if (emailPhoneController.text == '' || passwordController.text.isEmpty) {
      showToast(context, 3, "Invalid credentials detected");
    } else {
      if (typeOfField == 'email') {
        if (!_isValidEmail(emailPhoneController.text)) {
          showToast(context, 3, "SignIn.text2");
          return;
        }
      }

      if (typeOfField == 'phone') {
        if (!_isValidPhone(emailPhoneController.text)) {
          showToast(context, 3, "SignIn.text3");
          return;
        }
      }

      if (passwordController.text.length <= 6) {
        showToast(context, 3, "SignIn.text4");
        return;
      }
      performSignIn();
    }
  }

  performSignIn() {
    unFocus(context);
    showLoader(context, 'Just a moment ...');

    formData['role'] = 'USER';
    if (typeOfField == 'email') {
      formData['email'] = emailPhoneController.text;
      formData['type'] = typeOfField;
    } else if (typeOfField == 'phone') {
      formData['phone'] = emailPhoneController.text;
      formData['type'] = typeOfField;
    }
    formData['password'] = passwordController.text;
    authSer.signIn(formData).then((response) {
      pop(context);
      if (response['status'] == 'success') {
        handleSuccessSignIn(response['data']);
      } else if (response['status'] == 'failed' && response['data'] == null) {
        showToast(context, 3, "Incorrect credentials");
      }
    });
  }

  handleSuccessSignIn(data) {
    userSD = data['user'];
    StorageService.setToken(data['token']).then((_) {
      StorageService.setLogin(userSD).then((_) {
        setWallPaper();
        showToast(context, 3, "Welcome to your account");
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const TabsUserScreen()),
          (Route<dynamic> route) => false,
        );
      });
    });
  }

  setWallPaper() {
    appService.getSetting().then((settingsResponse) {
      if (settingsResponse['status'] == 'success') {
        appwallpaper = settingsResponse['data']['wallpaper'];
        StorageService.setString("appwallpaper", appwallpaper!);
      } else {
        print("Failed to fetch wallpaper settings");
      }
    }).catchError((error) {
      pop(context);
      showToast(context, 3, "Failed to fetch settings. Please try again.");
      print("Settings Error: $error");
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
          child: Container(
            margin: EdgeInsets.all(m),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50, bottom: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Image.asset('assets/logo.png', width: 150),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: "Let's ",
                        style:
                            const TextStyle(fontSize: 20, color: Colors.black),
                        children: <TextSpan>[
                          TextSpan(
                              text: 'Sign In',
                              style: TextStyle(
                                  fontFamily: 'pb', color: primaryColor)),
                          const TextSpan(text: '  👇')
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text("Welcome back, You've been missed",
                          style: TextStyle(fontSize: 15, color: Colors.black)),
                    )
                  ],
                ),
                const SizedBox(height: 30),
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
                            isEmailPhoneValid = _isValidEmailPhone(input);
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
                              : _getValidationMessage(
                                  emailPhoneController.text),
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
                  margin: const EdgeInsets.symmetric(vertical: 5),
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
                        controller: passwordController,
                        obscureText: obscurePasswordText,
                        onSubmitted: (value) {
                          goToAuthentication();
                        },
                        onChanged: (_) {
                          setState(() {
                            isPasswordValid =
                                isValidPassword(passwordController.text);
                          });
                        },
                        cursorColor: primaryColor,
                        cursorWidth: 1.4,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: greyColor,
                            size: 18,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              obscurePasswordText = !obscurePasswordText;
                              setState(() {});
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
                              : 'Password must be a minimum of seven digits',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgetPasswordPage(
                                    emailPhone: emailPhoneController.text,
                                  )),
                        );
                      },
                      child: const Text(
                        'Forgot Password?',
                        style:
                            TextStyle(fontFamily: 'psb', color: Colors.black),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
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
                      onPressed: () {
                        goToAuthentication();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        height: 55,
                        width: MediaQuery.of(context).size.width - 80,
                        alignment: Alignment.center,
                        child: Text(
                          'Sign In',
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
                Text(
                  'By using this app you agreed to TeamPro',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(width: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TermsAndConditions()),
                        );
                      },
                      child: Text(
                        'Terms of use',
                        style: TextStyle(
                          color: primaryColor,
                          fontFamily: 'psb',
                        ),
                      ),
                    ),
                    Text(
                      ' and ',
                      style: TextStyle(
                        color: greyColor,
                        fontFamily: 'pr',
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PrivacyPolicy()),
                        );
                      },
                      child: Text(
                        'Privacy Policy',
                        style: TextStyle(
                          color: primaryColor,
                          fontFamily: 'psb',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'psb',
                        ),
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
