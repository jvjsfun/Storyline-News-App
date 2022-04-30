import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:story_line/models/app_data.dart';
import 'package:story_line/models/article.dart';
import 'package:story_line/models/category.dart';
import 'package:story_line/models/saved_article.dart';
import 'package:story_line/models/story_line.dart';
import 'package:story_line/models/userModel.dart';

class HomeScreenState extends Equatable {
  final bool isLoading;
  final AppData appData;
  final CountryCodeModel countryCode;
  final List<CountryCodeModel> countryList;
  final List<ArticleModel> articles;
  final List<CategoryModel> categories;
  final String userId;
  final UserModel userModel;
  final List<StoryLineModel> storyLines;
  final List<SaveArticle> savedArticles;
  final DateTime startDate;
  final DateTime endDate;

  HomeScreenState({
    this.isLoading = false,
    this.appData,
    this.countryCode,
    this.countryList = const [],
    this.articles = const [],
    this.categories = const [],
    this.userModel,
    this.userId,
    this.storyLines = const [],
    this.savedArticles = const [],
    this.startDate,
    this.endDate,
  });

  @override
  List<Object> get props => [
    isLoading,
    appData,
    countryCode,
    countryList,
    articles,
    categories,
    userModel,
    userId,
    storyLines,
    savedArticles,
    startDate,
    endDate,
  ];

  HomeScreenState copyWith({
    bool isLoading,
    AppData appData,
    CountryCodeModel countryCode,
    List<CountryCodeModel> countryList,
    List<ArticleModel> articles,
    List<CategoryModel> categories,
    UserModel userModel,
    String userId,
    List<StoryLineModel> storyLines,
    List<SaveArticle> savedArticles,
    DateTime startDate,
    DateTime endDate,
  }) {
    return HomeScreenState(
      isLoading: isLoading ?? this.isLoading,
      appData: appData ?? this.appData,
      countryCode: countryCode ?? this.countryCode,
      countryList: countryList ?? this.countryList,
      articles: articles ?? this.articles,
      categories: categories ?? this.categories,
      userModel: userModel ?? this.userModel,
      userId: userId ?? this.userId,
      storyLines: storyLines ?? this.storyLines,
      savedArticles: savedArticles ?? this.savedArticles,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class HomeScreenStateSuccess extends HomeScreenState {}

class HomeScreenEmptyData extends HomeScreenState {
  final String error;

  HomeScreenEmptyData({@required this.error}) : super();

  @override
  String toString() => 'HomeScreenEmptyData { error: $error }';

}

class HomeScreenStateFailure extends HomeScreenState {
  final String error;

  HomeScreenStateFailure({@required this.error}) : super();

  @override
  String toString() => 'HomeScreenStateFailure { error: $error }';
}

