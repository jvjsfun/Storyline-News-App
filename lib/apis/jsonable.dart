abstract class Jsonable {
  Map toJson();

  fromJson(Map<String, dynamic> json);
}