class UserModel {
  String userId;
  List<StoryLine> storyLines = [];
}

class StoryLine {
  String key;
  List<SubTopic> subTopics = [];
}

class SubTopic {
  String topic;
  String query;
}