import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:story_line/blocs/bloc.dart';
import 'dart:io' show Platform;
import 'package:story_line/screens/main/main_screen.dart';
import 'package:story_line/utils/global.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  final SplashScreenBloc screenBloc = SplashScreenBloc(SplashScreenState());
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    screenBloc.close();
  }

  Future<String> _getId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getId(),
      builder: (BuildContext context, AsyncSnapshot snap){
        // do nothing...
        if (snap.hasData){
          screenBloc.add(SplashScreenInitEvent(userId: snap.data));
          //your logic goes here.
          return BlocListener(
            cubit: screenBloc,
            listener: (BuildContext context, SplashScreenState state) {
              if (state is SplashScreenStateSuccess) {
                Global.instance.userModel = state.userModel;
                Global.instance.userId = state.userModel.userId;
                Navigator.pushReplacement(context, PageTransition(
                  child: MainScreen(),
                  type: PageTransitionType.fade,
                  duration: Duration(microseconds: 300),
                ));
              }
            },
            child: BlocBuilder<SplashScreenBloc, SplashScreenState>(
              cubit: screenBloc,
              builder: (context, state) {
                return Scaffold(
                  backgroundColor: Theme.of(context).backgroundColor,
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'STORY LINES.',
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: 'proxima-bold',
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }else {
          return Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'STORY LINES.',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'proxima-bold',
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
