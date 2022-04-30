import 'package:flutter/material.dart';
import 'package:story_line/models/userModel.dart';

import '../env.dart';

/// Global env
class Global extends ChangeNotifier{
  Global._private();

  static final Global instance = Global._private();
  String userId = '';
  UserModel userModel;
  BuildContext homeContext;

  String _pushToken;

  String get token {
    return _pushToken;
  }

  factory Global({Env environment}) {
    if (environment != null) {
      instance.env = environment;
    }
    return instance;
  }

  Env env;
}
