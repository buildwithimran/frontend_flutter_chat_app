import 'dart:async';
import 'package:chat_app/src/services/app.service.dart';
import 'package:chat_app/src/pages/tab_bar.dart';
import 'package:chat_app/src/services/storage.service.dart';
import 'package:chat_app/src/utils/loading_util.dart';
import 'package:flutter/material.dart';
import 'package:sms_otp_auto_verify/sms_otp_auto_verify.dart';
import 'reset_password_page.dart';
import '../helper/globals.dart';
import '../utils/theme_util.dart';

class OtpVerifyScreen extends StatefulWidget {
  final purpose;
  final typeOfField;
  final data;

  const OtpVerifyScreen({
    required this.purpose,
    required this.typeOfField,
    this.data,
  });
  @override
  _OtpVerifyScreenState createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  // Services
  var authService = AppService();

  // Variables
  var token;
  var data;
  var otp;
  late Timer timer;
  TextEditingController otpController = TextEditingController();
  int counter = 60;

  BoxDecoration get _pinPutDecoration {
    return BoxDecoration(
      border: Border.all(color: Theme.of(context).primaryColor),
      borderRadius: BorderRadius.circular(5.0),
    );
  }

  @override
  void initState() {
    countDown();
    if (widget.purpose == 'login') {
      token = widget.data['token'];
      data = widget.data['user'];
    } else if (widget.purpose == 'signUp' ||
        widget.purpose == 'forgotPassword') {
      data = widget.data;
    }

    Timer(const Duration(milliseconds: 100), () {
      sendCode();
    });

    super.initState();
  }

  sendCode() {
    counter = 60;
    countDown();
    if (mounted) setState(() {});
    if (widget.typeOfField == 'email') {
      sendEmailOTP();
    } else if (widget.typeOfField == 'phone') {
      sendPhoneOTP();
    }
  }

  countDown() {
    timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      counter--;
      if (mounted) setState(() {});
      if (counter == 0) {
        timer.cancel();
      }
    });
  }

  sendEmailOTP() {
    showLoader(context, 'Sending Otp ...');
    authService.sendEmailOTP({'email': data['email']}).then((value) {
      pop(context);
      if (value['status'] == 'success') {
        otp = value['data'];
        showToast(context, 3, "OTP has been sent to your email");
        if (mounted) setState(() {});
      } else {
        showToast(context, 3, "Something went wrong. Try again later");
      }
    });
  }

  sendPhoneOTP() {
    showLoader(context, 'Sending Otp ...');
    authService
        .sendPhoneOTP({'phone': countryCode + data['phone']}).then((value) {
      pop(context);
      if (value['status'] == 'success') {
        otp = value['data'];
        showToast(context, 3, "OTP has been sent to your phone number");
        if (mounted) setState(() {});
      } else {
        showToast(context, 3, "Something went wrong. Try again later");
      }
    });
  }

  goAuth() {
    unFocus(context);
    if (otp.toString() == otpController.text) {
      doAction();
    } else {
      showToast(context, 3, "Incorrect Verification Code");
    }
  }

  doAction() {
    if (widget.purpose == 'login') {
      doLogin();
    } else if (widget.purpose == 'signUp') {
      doSignUp();
    } else if (widget.purpose == 'forgotPassword') {
      doReset();
    }
  }

  doLogin() {
    userSD = data;
    if (mounted) setState(() {});
    showToast(context, 3, "Welcome to your account");
    StorageService.setToken(token).then((a) {
      StorageService.setLogin(data).then((a) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const TabsUserScreen()),
            (Route<dynamic> route) => false);
      });
    });
  }

  doSignUp() {
    authService.signUp(data).then((result) {
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

  doReset() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResetPasswordPage(
          userId: data['id'].toString(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: lightColor,
        body: SingleChildScrollView(
          child: SafeArea(
            child: Container(
              margin: EdgeInsets.all(m),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 55),
                  Image.asset('assets/logo.png', width: 150),
                  const SizedBox(height: 40),
                  RichText(
                    text: TextSpan(
                      text: "Enter correct ",
                      style: TextStyle(fontSize: 20, color: darkColor),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'OTP',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: darkColor,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                  TextFieldPin(
                    textController: otpController,
                    codeLength: 6,
                    defaultBoxSize: 45.0,
                    margin: 3,
                    textStyle: const TextStyle(fontSize: 16),
                    defaultDecoration: _pinPutDecoration.copyWith(
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withOpacity(0.6),
                      ),
                    ),
                    selectedDecoration: _pinPutDecoration,
                    onChange: (String val) {
                      if (val.length == 6) {
                        goAuth();
                      }
                      if (mounted) setState(() {});
                    },
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
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: lightColor,
                        backgroundColor: primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        goAuth();
                      },
                      child: Container(
                        height: 55,
                        width: MediaQuery.of(context).size.width - 80,
                        alignment: Alignment.center,
                        child: Text(
                          'Verify',
                          style: TextStyle(
                            color: lightColor,
                            fontFamily: 'rb',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  counter > 0
                      ? Text(
                          'Resend Verification Code in $counter seconds',
                          style: TextStyle(
                            color: greyColor,
                          ),
                        )
                      : TextButton(
                          onPressed: () {
                            sendCode();
                          },
                          child: Text(
                            'Resend Verification Code',
                            style: TextStyle(
                              color: primaryColor,
                            ),
                          ),
                        )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
