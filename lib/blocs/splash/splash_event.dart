import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:story_line/models/app_data.dart';
import 'package:story_line/models/category.dart';

@immutable
abstract class SplashScreenEvent extends Equatable {
  const SplashScreenEvent();

  @override
  List<Object> get props => [];
}


@immutable
class SplashScreenInitEvent extends SplashScreenEvent {
  final String userId;

  SplashScreenInitEvent({this.userId});
}

@immutable
class GetUserProfileEvent extends SplashScreenEvent {
  final String userId;

  GetUserProfileEvent({this.userId});
}

class AddUserProfileEvent extends SplashScreenEvent {
  final String userId;

  AddUserProfileEvent({this.userId});
}
