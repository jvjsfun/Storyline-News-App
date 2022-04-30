class SaveArticle {
  String id;
  String source;
  String title;
  String publishedAt;
  String author;
  String description;
  String url;
  String urlToImage;
  String content;

  SaveArticle.fromMap(dynamic map) {
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