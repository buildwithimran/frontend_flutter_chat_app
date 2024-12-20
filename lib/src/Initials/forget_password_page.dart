import 'package:chat_app/src/Initials/otp_verify_page.dart';
import 'package:chat_app/src/services/app.service.dart';
import 'package:chat_app/src/helper/globals.dart';
import 'package:chat_app/src/utils/loading_util.dart';
import 'package:chat_app/src/utils/theme_util.dart';
import 'package:flutter/material.dart';

class ForgetPasswordPage extends StatefulWidget {
  final dynamic emailPhone;
  const ForgetPasswordPage({Key? key, required this.emailPhone})
      : super(key: key);

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  // Services
  final authSer = AppService();

  // Variables
  var emailPhoneController = TextEditingController();
  bool isEmailPhoneValid = true;
  String typeOfField = "email";

  // Functions
  bool _isValidEmail(String email) {
    return emailPhoneController.text.isNotEmpty &&
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidPhone(String input) {
    return emailPhoneController.text.length == phoneCharLimit;
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

  goToAuthentication() async {
    if (emailPhoneController.text == '') {
      showToast(context, 3, "Invalid credentials");
    } else {
      if (typeOfField == 'email') {
        if (!_isValidEmail(emailPhoneController.text)) {
          showToast(context, 3, "Invalid email address provided");
          return;
        }
      }

      if (typeOfField == 'phone') {
        if (!_isValidPhone(emailPhoneController.text)) {
          showToast(context, 3, "Phone Number 10 digit required");
          return;
        }
      }

      verifyExist();
    }
  }

  verifyExist() {
    var form = {'email': '', 'phone': ''};
    if (typeOfField == 'email') {
      form['email'] = emailPhoneController.text;
    } else {
      form['phone'] = emailPhoneController.text;
    }
    authSer.checkUserExist(form).then((val) {
      if (val['status'] == 'exist') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerifyScreen(
              purpose: 'forgotPassword',
              typeOfField: typeOfField,
              data: val['data'],
            ),
          ),
        );
        // }
      } else if (val['status'] == 'user_not_exist' && val['data'] == null) {
        showToast(context, 3, val['message']);
        return;
      }
    });
  }

  @override
  void dispose() {
    emailPhoneController.dispose(); // Dispose controller to avoid memory leaks
    super.dispose();
  }

  @override
  void initState() {
    print("widget.emailPhone ----------------- ${widget.emailPhone}");
    emailPhoneController = TextEditingController(
        text: widget.emailPhone); // Initialize with emailPhone
    super.initState();
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
                const SizedBox(height: 50),
                Center(
                  child: Image.asset('assets/logo.png', width: 150),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: "Reset your",
                        style: TextStyle(fontSize: 20, color: darkColor),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Password',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: darkColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 80),
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
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(primaryColor),
                        overlayColor:
                            MaterialStateProperty.all<Color>(lightColor),
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
                          'Submit',
                          style: TextStyle(
                            color: lightColor,
                            fontFamily: 'rb',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
