import 'package:chat_app/src/Initials/sign_in_page.dart';
import 'package:chat_app/src/services/app.service.dart';
import 'package:chat_app/src/utils/loading_util.dart';
import 'package:chat_app/src/utils/theme_util.dart';
import 'package:flutter/material.dart';

class ResetPasswordPage extends StatefulWidget {
  final String userId;
  ResetPasswordPage({required this.userId});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  // Services
  final appService = AppService();

  // Variables
  var formData = {"userId": "", "password": ""};

  bool _isPasswordValid = true;
  bool _isConfirmPasswordValid = true;

  bool _obscurePasswordText = true;
  bool _obscureConfirmPasswordText = true;

  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Functions
  bool _isValidPassword(String password) {
    return password.isNotEmpty && password.length > 6;
  }

  bool _isValidConfirmPassword(String confirmPassword) {
    return confirmPassword.isNotEmpty && confirmPassword.length > 6;
  }

  goToAuthentication() {
    if (passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      showToast(context, 3, "Invalid credentials detected");
    } else {
      if (passwordController.text.length <= 6) {
        showToast(context, 3, "Password: 6+ characters, please!");
        return;
      }

      if (confirmPasswordController.text.length <= 6) {
        showToast(context, 3, "Confirm Password: 6+ characters, please!");
        return;
      }

      if (passwordController.text != confirmPasswordController.text) {
        showToast(context, 3, "Password mismatch detected");
        return;
      }

      performResetPassword();
    }
  }

  performResetPassword() {
    showLoader(context, 'Just a moment ...');

    formData['userId'] = widget.userId;
    formData['password'] = passwordController.text;

    appService.resetPassword(formData).then((result) {
      pop(context);
      unFocus(context);
      if (result['status'] == 'success') {
        showSnackBar(result['message']);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => SignInScreen()),
            (Route<dynamic> route) => false);
      } else {
        showSnackBar(result['message']);
      }
    });
  }

  showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
                        text: "Reset your ",
                        style: TextStyle(fontSize: 20, color: darkColor),
                        children: <TextSpan>[
                          TextSpan(
                            text: 'password',
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
                  margin: const EdgeInsets.only(bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Password',
                        style: TextStyle(fontFamily: 'pr'),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        focusNode: _passwordFocus,
                        controller: passwordController,
                        obscureText: _obscurePasswordText,
                        onChanged: (_) {
                          setState(() {
                            _isPasswordValid =
                                _isValidPassword(passwordController.text);
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
                                  _obscurePasswordText = !_obscurePasswordText;
                                });
                              },
                              icon: Icon(
                                _obscurePasswordText
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: greyColor,
                                size: 18,
                              ),
                            ),
                            hintText: '******',
                            errorText: _isPasswordValid
                                ? null
                                : 'Password: 6+ characters, please!'),
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
                        style: TextStyle(fontFamily: 'pr'),
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        focusNode: _confirmPasswordFocus,
                        controller: confirmPasswordController,
                        obscureText: _obscureConfirmPasswordText,
                        onChanged: (_) {
                          setState(() {
                            _isConfirmPasswordValid = _isValidConfirmPassword(
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
                                  _obscureConfirmPasswordText =
                                      !_obscureConfirmPasswordText;
                                });
                              },
                              icon: Icon(
                                _obscureConfirmPasswordText
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: greyColor,
                                size: 18,
                              ),
                            ),
                            hintText: '******',
                            errorText: _isConfirmPasswordValid
                                ? null
                                : 'Confirm Password: 6+ characters, please!'),
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
                          'Submit',
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
        ),
      ),
    );
  }
}
