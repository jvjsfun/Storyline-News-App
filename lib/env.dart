import 'package:flutter/material.dart';
import 'package:story_line/main.dart';
import 'package:story_line/utils/constants.dart';

class Env {
  static Env value;

  static String baseUrl = Constants.baseUrl;

  // Support contact info

  Env() {
    value = this;
    WidgetsFlutterBinding.ensureInitialized();
    runApp(StoryLineApp());
  }

  String get name => runtimeType.toString();
}
