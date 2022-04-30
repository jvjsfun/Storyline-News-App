class ArticleModel {
  String author;
  String title;
  String description;
  String url;
  String urlToImage;
  String publishedAt;
  String content;
  SourceModel source;

  ArticleModel.fromMap(dynamic obj) {
    author = obj['author'];
    title = obj['title'];
    description = obj['description'];
    url = obj['url'];
    urlToImage = obj['urlToImage'];
    publishedAt = obj['publishedAt'];
    content = obj['content'];
    dynamic sourceObj = obj['source'];
    if (sourceObj is Map) {
      source = SourceModel.fromMap(sourceObj);
    }
  }

}

class SourceModel {
  String id;
  String name;

  SourceModel.fromMap(dynamic obj) {
    id = obj['id'];
    name = obj['name'];
  }
}

class HeadlineResponse {
  String status;
  num totalResults;
  List<ArticleModel> articles = [];

  HeadlineResponse.fromMap(dynamic obj) {
    status = obj['status'];
    totalResults = obj['totalResults'];
    dynamic articlesObj = obj['articles'];
    if (articlesObj is List) {
      articlesObj.forEach((element) {
        articles.add(ArticleModel.fromMap(element));
      });
    }
  }
}