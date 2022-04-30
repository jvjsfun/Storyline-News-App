import 'dart:convert';

import 'package:date_format/date_format.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:story_line/apis/api_service.dart';
import 'package:story_line/blocs/bloc.dart';
import 'package:story_line/blocs/home/home.dart';
import 'package:story_line/models/app_data.dart';
import 'package:story_line/models/article.dart';
import 'package:story_line/models/category.dart';
import 'package:story_line/models/saved_article.dart';
import 'package:story_line/models/story_line.dart';
import 'package:story_line/models/userModel.dart';
import 'package:story_line/utils/constants.dart';
import 'package:story_line/utils/global.dart';

class HomeScreenBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  ApiService api = new ApiService();

  HomeScreenBloc(HomeScreenState initialState) : super(initialState);

  HomeScreenState get initialState {
    return HomeScreenState(isLoading: true, countryCode: CountryCodeModel(code: 'world', name: 'World'));
  }

  @override
  Stream<HomeScreenState> mapEventToState(HomeScreenEvent event,) async* {
    if (event is HomeScreenInitEvent) {
      yield state.copyWith(
          userId: event.userModel.userId, userModel: event.userModel);
      yield* loadInitialData();
    } else if (event is GetArticlesEvent) {
      yield* getHeadlines();
    } else if (event is SelectCategoryEvent) {
      yield* selectCategory(event.category);
    } else if (event is SelectCountryCode) {
      yield* selectCountry(event.countryCode);
    } else if (event is SaveArticleEvent) {
      yield* saveArticle(event.model);
    } else if (event is SaveStoryArticleEvent) {
      yield* saveStoryArticle(event.model);
    } else if (event is PostStoryCollectionEvent) {
      yield* postCollection(event.storyLine);
    } else if (event is FetchUserProfileEvent) {
      yield* getProfile(Global.instance.userId);
    } else if (event is GetStoryLineEvent) {
      yield* getStoryLines(event.collectionName, event.topicName, event.keywords);
    } else if (event is GetSavedArticlesEvent) {
      yield* getSavedArticles();
    } else if (event is DeleteSavedArticleEvent) {
      yield* deleteArticle(event.articleId);
    } else if (event is RemoveTopicFromCollection) {
      yield* removeTopicFromCollection(event.storyLine, event.topic);
    } else if (event is RemoveCollectionFromCollections) {
      yield* removeCollectionFromCollections(event.storyLine, event.topic);
    } else if (event is DateRangeUpdatedEvent) {
      yield state.copyWith(startDate: event.startDate, endDate: event.endDate);
      yield* getStoryLines(event.collectionName, event.topicName, event.keywords);
    }
  }

  Stream<HomeScreenState> loadInitialData() async* {
    try {
      yield state.copyWith(isLoading: true,
        startDate: DateTime.now().subtract(new Duration(days: 365)),
        endDate: DateTime.now(),
      );
      dynamic response = await api.getAppData(Constants.apiKey, 'get_headlines_page');
      AppData appData;
      List<CategoryModel> categories = [];
      List<CountryCodeModel> countryCodes = [];
      countryCodes.add(CountryCodeModel(code: 'world', name: 'World'));
      if (response is Map) {
        if (response['status'] == 'ok') {
          dynamic messages = response['message'];
          appData = AppData.fromMap(messages);
          appData.topics.forEach((element) {
            if (categories.length == 0) {
              categories.add(CategoryModel(category: element, isChecked: true));
            } else {
              categories.add(CategoryModel(category: element, isChecked: false));
            }
          });
          appData.countryCodes.forEach((element) {
            countryCodes.add(element);
          });
        }
      }
      yield state.copyWith(
        appData: appData,
        categories: categories,
        countryList: countryCodes,
        countryCode: countryCodes.first,
      );
      add(GetArticlesEvent());
    } catch (error) {
      yield state.copyWith( isLoading: false);
      yield HomeScreenStateFailure(error: error.toString());
    }
  }

  Stream<HomeScreenState> getHeadlines() async* {
    yield state.copyWith(isLoading: true);
    List<ArticleModel> articles = [];
    if (state.countryCode.code == 'world') {
      for (CountryCodeModel countryCodeModel in state.appData.countryCodes) {
        if (countryCodeModel.code != 'world') {
          List<CategoryModel> categories = state.categories.where((element) => element.isChecked).toList();
          for (CategoryModel category in categories) {
            dynamic response = await api.getHeadLines(Constants.apiKey, category.category, countryCodeModel.code);
            HeadlineResponse headlineResponse;
            if (response is Map) {
              if (response['status'] == 'ok') {
                dynamic message = response['message'];
                headlineResponse = HeadlineResponse.fromMap(message);
                articles.addAll(headlineResponse.articles);
              }
            }
          }
        }
      }
    } else {
      List<CategoryModel> categories = state.categories.where((element) => element.isChecked).toList();
      for (CategoryModel category in categories) {
        dynamic response = await api.getHeadLines(Constants.apiKey, category.category, state.countryCode.code);
        HeadlineResponse headlineResponse;
        if (response is Map) {
          if (response['status'] == 'ok') {
            dynamic message = response['message'];
            headlineResponse = HeadlineResponse.fromMap(message);
            articles.addAll(headlineResponse.articles);
          }
        }
      }
    }

    yield state.copyWith(isLoading: false, articles: articles);
  }

  Stream<HomeScreenState> selectCategory(CategoryModel model) async* {
    List<CategoryModel> categories = [];
    categories.addAll(state.categories);
    int index = categories.indexOf(model);
    CategoryModel categoryModel = CategoryModel(category: model.category, isChecked: !model.isChecked);
    categories[index] = categoryModel;

    yield state.copyWith(categories: categories);

    add(GetArticlesEvent());
  }

  Stream<HomeScreenState> selectCountry(CountryCodeModel model) async* {
    yield state.copyWith(countryCode: model);

    add(GetArticlesEvent());
  }

  Stream<HomeScreenState> saveArticle(ArticleModel model) async* {
    yield state.copyWith(isLoading: true);
    dynamic response = await api.saveArticle(
      authKey: Constants.apiKey,
      userId: Global.instance.userId,
      task: 'save_article',
      source: model.source.name,
      author: model.author,
      content: model.content,
      description: model.description,
      publishedAt: model.publishedAt,
      title: model.title,
      url: model.url,
      urlToImage: model.urlToImage,
    );

    add(GetSavedArticlesEvent());
  }

  Stream<HomeScreenState> saveStoryArticle(StoryLineModel model) async* {
    yield state.copyWith(isLoading: true);
    dynamic response = await api.saveArticle(
      authKey: Constants.apiKey,
      userId: Global.instance.userId,
      task: 'save_article',
      source: model.source,
      author: model.author,
      content: model.content,
      description: model.description,
      publishedAt: model.publishedAt,
      title: model.title,
      url: model.url,
      urlToImage: model.urlToImage,
    );

    add(GetSavedArticlesEvent());
  }

  Stream<HomeScreenState> postCollection(StoryLine storyLine) async* {
    try {
      yield state.copyWith(isLoading: true);
      bool isContain = false;
      state.userModel.storyLines.forEach((element) {
        if (element.key == storyLine.key) {
          isContain = true;
        }
      });
      if (isContain) {
        await api.addCollection(Constants.apiKey, Global.instance.userId, 'add_topic_to_collection', storyLine);
      } else {
        await api.addCollection(Constants.apiKey, Global.instance.userId, 'add_collection_to_collection', storyLine);
      }
      add(FetchUserProfileEvent());
    } catch (error) {
      yield state.copyWith(isLoading: false);
    }
  }

  Stream<HomeScreenState> getProfile(String userId) async* {
    try {
      yield state.copyWith(isLoading: true);
      dynamic response = await api.getUserProfile(
          Constants.apiKey, userId, 'get_profile');
      UserModel userModel = UserModel();
      if (response is Map) {
        String status = response['status'];
        if (status != null && status == 'ok') {
          Map<String, dynamic> message = response['message'];
          String userId = message['user_id'];
          userModel.userId = userId;
          List<dynamic> storyLinesList = message['storylines'];
          List<StoryLine> storylines = [];
          storyLinesList.forEach((element) {
            if (element is Map) {
              String key = element.keys.first ?? '';
              List<dynamic> values = element[key];
              List<SubTopic> subTopics = [];
              values.forEach((val) {
                if (val is Map) {
                  String valueString = val.values.first;
                  final body = json.decode(valueString);
                  String topicName = body['topic_name'];
                  String query = body['query'];
                  SubTopic subTopic = SubTopic();
                  subTopic.topic = topicName;
                  subTopic.query = query;
                  subTopics.add(subTopic);
                }
              });

              StoryLine storyLine = StoryLine();
              storyLine.key = key;
              storyLine.subTopics = subTopics;
              storylines.add(storyLine);
            }
          });
          userModel.storyLines = storylines;
          yield state.copyWith(
            isLoading: false,
            userModel: userModel,
          );
        }
      }
      yield state.copyWith(isLoading: false, userModel: userModel);
    } catch (error) {
      yield state.copyWith(isLoading: false);
      yield HomeScreenStateFailure(error: error.toString());
    }
  }

  Stream<HomeScreenState> getStoryLines(String collectionName, String topicName, String keywords) async* {
    try {
      yield state.copyWith(isLoading: true);
      dynamic response  = await api.getStoryLines(
        Constants.apiKey,
        Global.instance.userId,
        'get_storylines',
        collectionName,
        topicName,
        keywords,
        formatDate(state.startDate, [mm, '/', dd, '/', yyyy]),
        formatDate(state.endDate, [mm, '/', dd, '/', yyyy]),
      );
      List<StoryLineModel> storyLines = [];
      if (response is Map) {
        dynamic messages = response['message'];
        if (messages is List) {
          messages.forEach((element) {
            print(element);
            storyLines.add(StoryLineModel.fromMap(element));
          });
        }
      }
      yield state.copyWith(isLoading: false, storyLines: storyLines);
    } catch (error) {
      print(error);
      yield state.copyWith(isLoading: false);
    }
  }

  Stream<HomeScreenState> getSavedArticles() async* {
    try {
      yield state.copyWith(isLoading: true);
      dynamic response  = await api.getSavedArticles(authKey: Constants.apiKey, userId: Global.instance.userId, task: 'get_saved_articles');
      List<SaveArticle> saved = [];
      if (response is Map) {
        dynamic messages = response['message'];
        if (messages is List) {
          messages.forEach((element) {
            print(element);
            saved.add(SaveArticle.fromMap(element));
          });
        }
      }
      yield state.copyWith(isLoading: false, savedArticles: saved);
    } catch (error) {
      print(error);
      yield state.copyWith(isLoading: false);
    }
  }

  Stream<HomeScreenState> deleteArticle(String id) async* {
    try {
      yield state.copyWith(isLoading: true);
      dynamic response  = await api.deleteSavedArticle(authKey: Constants.apiKey, userId: Global.instance.userId, task: 'remove_saved_article', articleId: id);
      add(GetSavedArticlesEvent());
    } catch (error) {
      print(error);
      yield state.copyWith(isLoading: false);
    }
  }

  Stream<HomeScreenState> removeTopicFromCollection(StoryLine storyLine, SubTopic topic) async* {
    try {
      yield state.copyWith(isLoading: true);
      await api.removeTopicFromCollections(
        authKey: Constants.apiKey,
        userId: Global.instance.userId,
        task: 'remove_topic_from_collection',
        collectionName: storyLine.key,
        keywords: topic.query,
        topicName: topic.topic,
      );
      add(FetchUserProfileEvent());
    } catch (error) {
      print(error);
      yield state.copyWith(isLoading: false);
    }
  }

  Stream<HomeScreenState> removeCollectionFromCollections(StoryLine storyLine, SubTopic topic) async* {
    try {
      yield state.copyWith(isLoading: true);
      await api.removeCollectionFromCollections(
        authKey: Constants.apiKey,
        userId: Global.instance.userId,
        task: 'remove_collection_from_collections',
        collectionName: storyLine.key,
        keywords: topic.query,
        topicName: topic.topic,
      );
      add(FetchUserProfileEvent());
    } catch (error) {
      print(error);
      yield state.copyWith(isLoading: false);
    }
  }


}