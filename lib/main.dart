import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:story_line/env.dart';
import 'package:story_line/screens/splash/splash_screen.dart';
import 'package:story_line/utils/constants.dart';
import 'blocs/app_bloc_delegate.dart';

void main() async {
  Bloc.observer = AppBlocObserver();
  Env();

}

class StoryLineApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Constants.mainColor,
        secondaryHeaderColor: Constants.secondaryColor,
        accentColor: Constants.mainColor,
        backgroundColor: Constants.mainColor,
        disabledColor: Constants.disableColor,
        textTheme: TextTheme(
            headline1: TextStyle(
              fontFamily: 'proxima-bold',
              color: Constants.headlineColor,
              fontSize: 28,
            ),
            headline2: TextStyle(
              fontFamily: 'proxima-bold',
              color: Constants.headlineColor,
              fontSize: 24,
            ),
            headline3: TextStyle(
              fontFamily: 'proxima-bold',
              color: Constants.headlineColor,
              fontSize: 20,
            ),
            headline4: TextStyle(
              fontFamily: 'proxima-bold',
              color: Constants.secondaryColor,
              fontSize: 17,
            ),
            headline5: TextStyle(
              fontFamily: 'proxima-bold',
              color: Constants.secondaryColor,
              fontSize: 16,
            ),
            headline6: TextStyle(
              fontFamily: 'proxima-bold',
              color: Constants.secondaryColor,
              fontSize: 14,
            ),
            bodyText1: TextStyle(
              fontFamily: 'proxima',
              color: Constants.bodyTextColor,
              fontSize: 17,
            ),
            bodyText2: TextStyle(
              fontFamily: 'proxima',
              color: Constants.bodyTextColor,
              fontSize: 15,
            ),
            button: TextStyle(
              fontFamily: 'proxima',
              color: Constants.mainColor,
              fontSize: 12,
            ),
            caption: TextStyle(
              fontFamily: 'proxima',
            )
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
    );
  }
}

