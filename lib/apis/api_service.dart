import 'package:story_line/env.dart';
import 'package:story_line/models/userModel.dart';
import 'package:story_line/utils/constants.dart';
import 'package:story_line/utils/global.dart';

import 'base_client.dart';

class ApiService {

  BaseClient _client = BaseClient();

  Future<dynamic> getAppData(String authKey, String tag) async {
    try {
      print(' - getAppData()');
      dynamic response = await _client.getTypeless(
          '${Env.baseUrl}${Constants.appData}',
          queryParameters: {
            Constants.authKey: authKey,
            Constants.task: tag,
            Constants.userId: Global.instance.userId,
          }
      );
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<dynamic> getHeadLines(String authKey, String category, String countryCode) async {
    try {
      print(' - getHeadLines()');
      dynamic response = await _client.getTypeless(
          '${Env.baseUrl}${Constants.headLines}',
          queryParameters: {
            Constants.authKey: authKey,
            Constants.category: category,
            Constants.countryCode: countryCode,
            Constants.userId: Global.instance.userId,
            Constants.task: 'get_headlines',
          }
      );
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<dynamic> getUserProfile(String authKey, String userId, String task) async {
    try {
      print(' - getUserProfile()');
      dynamic response = await _client.getTypeless(
          '${Env.baseUrl}${Constants.user}',
          queryParameters: {
            Constants.authKey: authKey,
            Constants.userId: userId,
            Constants.task: task,
          }
      );
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<dynamic> addUserProfile(String authKey, String userId, String task) async {
    try {
      print(' - addUserProfile()');
      dynamic response = await _client.getTypeless(
          '${Env.baseUrl}${Constants.user}',
          queryParameters: {
            Constants.authKey: authKey,
            Constants.userId: userId,
            Constants.task: task,
          }
      );
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<dynamic> addCollection(String authKey, String userId, String task, StoryLine storyLine) async {
    try {
      print(' - addCollection()');
      dynamic response = await _client.getTypeless(
          '${Env.baseUrl}${Constants.user}',
          queryParameters: {
            Constants.authKey: authKey,
            Constants.userId: userId,
            Constants.task: task,
            Constants.storyCollectionName: storyLine.key,
            Constants.topicName: storyLine.subTopics.first.topic,
            Constants.keywords: storyLine.subTopics.first.query,
          }
      );
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<dynamic> getStoryLines(String authKey, String userId, String task, String name, String topic, String keywords, String from, String to) async {
    try {
      print(' - getStoryLines()');
      dynamic response = await _client.getTypeless(
          '${Env.baseUrl}${Constants.storyLines}',
          queryParameters: {
            Constants.authKey: authKey,
            Constants.userId: userId,
            Constants.task: task,
            Constants.storyCollectionName: name,
            Constants.topicName: topic,
            Constants.keywords: keywords,
            'from_date': from,
            'to_date': to,
          }
      );
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<dynamic> saveArticle({
    String authKey,
    String userId,
    String task,
    String source,
    String author,
    String title,
    String description,
    String url,
    String publishedAt,
    String urlToImage,
    String content
  }) async {
    try {
      print(' - saveArticle()');
      dynamic response = await _client.postTypeLess(
          '${Env.baseUrl}${Constants.user}',
          queryParameters: {
            Constants.authKey: authKey,
            Constants.userId: userId,
            Constants.task: task,
            'source': source,
            'author': author,
            'title': title,
            'description': description,
            'url': url,
            'publishedAt': publishedAt,
            'urlToImage': urlToImage,
            'content': content,
          }
      );
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<dynamic> getSavedArticles({
    String authKey,
    String userId,
    String task,
  }) async {
    try {
      print(' - getSavedArticles()');
      dynamic response = await _client.getTypeless(
          '${Env.baseUrl}${Constants.user}',
          queryParameters: {
            Constants.authKey: authKey,
            Constants.userId: userId,
            Constants.task: task,
          }
      );
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<dynamic> deleteSavedArticle({
    String authKey,
    String userId,
    String task,
    String articleId,
  }) async {
    try {
      print(' - deleteSavedArticle()');
      dynamic response = await _client.deleteTypeless(
          '${Env.baseUrl}${Constants.user}',
          queryParameters: {
            Constants.authKey: authKey,
            Constants.userId: userId,
            Constants.task: task,
            'article_id': articleId,
          }
      );
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<dynamic> removeTopicFromCollections({
    String authKey,
    String userId,
    String task,
    String collectionName,
    String topicName,
    String keywords,
  }) async {
    try {
      print(' - removeTopicFromCollections()');
      dynamic response = await _client.deleteTypeless(
          '${Env.baseUrl}${Constants.user}',
          queryParameters: {
            Constants.authKey: authKey,
            Constants.userId: userId,
            Constants.task: task,
            Constants.storyCollectionName: collectionName,
            Constants.topicName: topicName,
            Constants.keywords: keywords,
          }
      );
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<dynamic> removeCollectionFromCollections({
    String authKey,
    String userId,
    String task,
    String collectionName,
    String topicName,
    String keywords,
  }) async {
    try {
      print(' - removeCollectionFromCollections()');
      dynamic response = await _client.deleteTypeless(
          '${Env.baseUrl}${Constants.user}',
          queryParameters: {
            Constants.authKey: authKey,
            Constants.userId: userId,
            Constants.task: task,
            Constants.storyCollectionName: collectionName,
            Constants.topicName: topicName,
            Constants.keywords: keywords,
          }
      );
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

}