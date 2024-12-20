import 'package:flutter/material.dart';
import 'package:chat_app/src/utils/theme_util.dart';

class OnboardingCard extends StatelessWidget {
  final String image, title, description, buttonText;
  final Function onPressed;

  const OnboardingCard({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 450,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(
                    50,
                  ),
                  child: Image.asset(
                    image,
                    fit: BoxFit.contain,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontFamily: 'rr', color: primaryLightColor),
                    )
                  ],
                ),
              ],
            ),
          ),
          MaterialButton(
            minWidth: MediaQuery.of(context).size.width - 50,
            height: 50,
            onPressed: () => onPressed(),
            color: primaryColor,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))),
            child: Text(
              buttonText,
              style: TextStyle(
                color: lightColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
      ),
    );
  }
}
