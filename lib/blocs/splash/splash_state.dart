import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:story_line/models/app_data.dart';
import 'package:story_line/models/article.dart';
import 'package:story_line/models/category.dart';
import 'package:story_line/models/userModel.dart';

class SplashScreenState extends Equatable {
  final bool isLoading;
  final String userId;
  final UserModel userModel;

  SplashScreenState({
    this.isLoading = false,
    this.userModel,
    this.userId,
  });

  @override
  List<Object> get props => [
    isLoading,
    userModel,
    userId,
  ];

  SplashScreenState copyWith({
    bool isLoading,
    UserModel userModel,
    String userId,
  }) {
    return SplashScreenState(
      isLoading: isLoading ?? this.isLoading,
      userModel: userModel ?? this.userModel,
      userId: userId ?? this.userId,
    );
  }
}

class SplashScreenStateSuccess extends SplashScreenState {
  final UserModel userModel;
  
  SplashScreenStateSuccess({this.userModel});
}

class SplashScreenStateFailure extends SplashScreenState {
  final String error;

  SplashScreenStateFailure({@required this.error}) : super();

  @override
  String toString() => 'SplashScreenStateFailure { error: $error }';
}

