
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:story_line/apis/api_service.dart';
import 'package:story_line/blocs/home/home.dart';
import 'package:story_line/blocs/splash/splash_event.dart';
import 'package:story_line/blocs/splash/splash_state.dart';
import 'package:story_line/models/app_data.dart';
import 'package:story_line/models/article.dart';
import 'package:story_line/models/category.dart';
import 'package:story_line/models/userModel.dart';
import 'package:story_line/utils/constants.dart';

class SplashScreenBloc extends Bloc<SplashScreenEvent, SplashScreenState> {
  ApiService api = new ApiService();

  SplashScreenBloc(SplashScreenState initialState) : super(initialState);

  SplashScreenState get initialState {
    return SplashScreenState(isLoading: true,);
  }

  @override
  Stream<SplashScreenState> mapEventToState(SplashScreenEvent event,) async* {
    if (event is SplashScreenInitEvent) {
      yield* getProfile(event.userId);
    } else if (event is GetUserProfileEvent) {
      yield* getProfile(event.userId);
    } else if (event is AddUserProfileEvent) {
      yield* addUserProfile(event.userId);
    }
  }

  Stream<SplashScreenState> getProfile(String userId) async* {
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
          yield SplashScreenStateSuccess(userModel: userModel);
        } else {
          add(AddUserProfileEvent(userId: userId));
        }
      } else {
        add(AddUserProfileEvent(userId: userId));
      }
    } catch (error) {
      yield state.copyWith(isLoading: false);
      yield SplashScreenStateFailure(error: error.toString());
    }
  }

  Stream<SplashScreenState> addUserProfile(String userId) async* {
    yield state.copyWith(isLoading: true);
    dynamic response = await api.addUserProfile(
        Constants.apiKey, userId, 'add_profile');
    add(GetUserProfileEvent(userId: userId));

  }
}