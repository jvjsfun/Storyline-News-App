import 'dart:convert';

class StoryLineModel {
  String id;
  String source;
  String title;
  String publishedAt;
  String author;
  String description;
  String url;
  String urlToImage;
  String content;

  StoryLineModel.fromMap(dynamic obj) {
    dynamic map = json.decode(obj);

    id = map['id'];
    source = map['source'];
    title = map['title'];
    publishedAt = map['publishedAt'];
    author = map['author'];
    description = map['description'];
    url = map['url'];
    urlToImage = map['urlToImage'];
    content = map['content'];
  }
}