class CountryCodeModel {
  final String code;
  final String name;
  CountryCodeModel({this.code, this.name});
}

class AppData {
  List<CountryCodeModel> countryCodes = [];
  List<String> topics = [];

  AppData.fromMap(dynamic obj) {
    dynamic countryCodesObj = obj['CountryCodes'];
    if (countryCodesObj is List) {
      countryCodesObj.forEach((element) {
        if (element is Map) {
          countryCodes.add(CountryCodeModel(code: element.keys.first, name: element.values.first));
        }
      });
    }
    dynamic topicsObj = obj['Topics'];
    if (topicsObj is List) {
      topicsObj.forEach((element) {
        topics.add(element);
      });
    }
  }
}

