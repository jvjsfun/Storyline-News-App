import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:story_line/models/app_data.dart';
import 'package:story_line/models/article.dart';
import 'package:story_line/models/category.dart';
import 'package:story_line/models/story_line.dart';
import 'package:story_line/models/userModel.dart';

@immutable
abstract class HomeScreenEvent extends Equatable {
  const HomeScreenEvent();

  @override
  List<Object> get props => [];
}


@immutable
class HomeScreenInitEvent extends HomeScreenEvent {
  final UserModel userModel;

  HomeScreenInitEvent({this.userModel});
}

@immutable
class GetArticlesEvent extends HomeScreenEvent {}

class SelectCategoryEvent extends HomeScreenEvent {
  final CategoryModel category;

  SelectCategoryEvent({this.category});
}

class DeselectCategoryEvent extends HomeScreenEvent {
  final CategoryModel category;

  DeselectCategoryEvent({this.category});
}

class SelectCountryCode extends HomeScreenEvent {
  final CountryCodeModel countryCode;

  SelectCountryCode({this.countryCode});
}

class SaveArticleEvent extends HomeScreenEvent {
  final ArticleModel model;

  SaveArticleEvent({this.model});
}

class SaveStoryArticleEvent extends HomeScreenEvent {
  final StoryLineModel model;

  SaveStoryArticleEvent({this.model});
}

@immutable
class PostStoryCollectionEvent extends HomeScreenEvent {
  final StoryLine storyLine;

  PostStoryCollectionEvent({this.storyLine});
}

class FetchUserProfileEvent extends HomeScreenEvent {}

class GetStoryLineEvent extends HomeScreenEvent {
  final String collectionName;
  final String topicName;
  final String keywords;

  GetStoryLineEvent({this.collectionName, this.topicName, this.keywords});
}

class GetSavedArticlesEvent extends HomeScreenEvent {}

class DeleteSavedArticleEvent extends HomeScreenEvent {
  final String articleId;

  DeleteSavedArticleEvent({this.articleId});
}
class RemoveTopicFromCollection extends HomeScreenEvent {
  final StoryLine storyLine;
  final SubTopic topic;
  RemoveTopicFromCollection({this.storyLine, this.topic});
}
class RemoveCollectionFromCollections extends HomeScreenEvent {
  final StoryLine storyLine;
  final SubTopic topic;

  RemoveCollectionFromCollections({this.storyLine, this.topic});
}

class DateRangeUpdatedEvent extends HomeScreenEvent {
  final DateTime startDate;
  final DateTime endDate;
  final String collectionName;
  final String topicName;
  final String keywords;

  DateRangeUpdatedEvent({this.collectionName, this.topicName, this.keywords, this.startDate, this.endDate});
}