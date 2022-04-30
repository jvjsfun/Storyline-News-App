import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:story_line/screens/main/main_screen.dart';
import 'package:story_line/utils/constants.dart';

class LoginScreen extends StatelessWidget {
  final Function onTap;
  LoginScreen({this.onTap});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'STORY LINES.',
                style: TextStyle(
                  fontSize: 28,
                  fontFamily: 'proxima-bold',
                  color: Constants.mainColor,
                ),
              ),
              Text(
                'Sign in to compose and track',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'proxima',
                  color: Constants.headlineColor,
                ),
              ),
              SizedBox(height: 44,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OutlineButton(
                    onPressed: onTap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    color: Constants.mainColor,
                    highlightedBorderColor: Constants.mainColor,
                    disabledBorderColor: Constants.disableColor,
                    borderSide: BorderSide(
                      color: Constants.mainColor,
                      width: 1,
                    ),
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 1,
                            child: Image.asset('assets/images/google.png'),
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              'Sign in with Google',
                              style: TextStyle(
                                color: Constants.mainColor,
                                fontSize: 18,
                                fontFamily: 'proxima',
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16,),
                  OutlineButton(
                    onPressed: onTap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    color: Constants.mainColor,
                    highlightedBorderColor: Constants.mainColor,
                    disabledBorderColor: Constants.disableColor,
                    borderSide: BorderSide(
                      color: Constants.mainColor,
                      width: 1,
                    ),
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 1,
                            child: Image.asset('assets/images/facebook.png'),
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              'Sign in with Facebook',
                              style: TextStyle(
                                color: Constants.mainColor,
                                fontSize: 18,
                                fontFamily: 'proxima',
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16,),
                  OutlineButton(
                    onPressed: onTap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    color: Constants.mainColor,
                    highlightedBorderColor: Constants.mainColor,
                    disabledBorderColor: Constants.disableColor,
                    borderSide: BorderSide(
                      color: Constants.mainColor,
                      width: 1,
                    ),
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 1,
                            child: Image.asset('assets/images/twitter.png'),
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              'Sign in with Twitter',
                              style: TextStyle(
                                color: Constants.mainColor,
                                fontSize: 18,
                                fontFamily: 'proxima',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}