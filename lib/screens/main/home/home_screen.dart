import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:story_line/blocs/home/home.dart';
import 'package:story_line/models/app_data.dart';
import 'package:story_line/models/article.dart';
import 'package:story_line/models/category.dart';
import 'package:story_line/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  final HomeScreenBloc screenBloc;

  HomeScreen({Key key, this.screenBloc});
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin<HomeScreen>{

  @override
  bool get wantKeepAlive => true;

  PanelController _pc = new PanelController();
  BorderRadiusGeometry radius = BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );

  ArticleModel selectedArticle;
  @override
  void initState() {
    // homeScreenBloc.add(HomeScreenInitEvent());
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return BlocListener(
      cubit: widget.screenBloc,
      listener: (BuildContext context, HomeScreenState state) async {
      },
      child: BlocBuilder<HomeScreenBloc, HomeScreenState>(
        cubit: widget.screenBloc,
        builder: (context, state) {
          return SafeArea(
            child: SlidingUpPanel(
              controller: _pc,
              panel: _panel(state),
              collapsed: Container(
                height: 0,
              ),
              onPanelOpened: () {
                setState(() {

                });
              },
              backdropTapClosesPanel: true,
              defaultPanelState: PanelState.CLOSED,
              isDraggable: true,
              minHeight: 0,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              borderRadius: radius,
              body: _body(state),
            ),
          );
        },
      ),
    );
  }

  Widget _body(HomeScreenState state) {
    return Column(
      children: [
        _headerWidget(state),
        SizedBox(height: 8,),
        _categoriesWidget(state),
        SizedBox(height: 8,),
        Expanded(
          child: _articlesWidget(state),
        ),
      ],
    );
  }

  Widget _headerWidget(HomeScreenState state) {
    return Container(
      height: 50,
      padding: EdgeInsets.only(left: 24, right: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Headlines',
            style: TextStyle(
              color: Constants.headlineColor,
              fontSize: 24,
              fontFamily: 'proxima-bold',
            ),
          ),
          Container(
            padding: EdgeInsets.all(0),
            child: PopupMenuButton<CountryCodeModel>(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Text(
                      state.countryCode.name.toUpperCase(),
                      style: TextStyle(
                        color: Constants.mainColor,
                        fontFamily: 'proxima-bold',
                        fontSize: 16,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Image.asset('assets/images/arrow/down.png', width: 16, height: 16,),
                    ),
                  ],
                ),
              ),
              offset: Offset(0, 100),
              onSelected: (CountryCodeModel item)  {
                widget.screenBloc..add(SelectCountryCode(countryCode: item));
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              color: Colors.white,
              itemBuilder: (BuildContext context) {
                return state.countryList.map((CountryCodeModel item) {
                  return PopupMenuItem<CountryCodeModel>(
                    value: item,
                    child: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoriesWidget(HomeScreenState state) {
    return Container(
      height: 36,
      child: ListView.separated(
        padding: EdgeInsets.only(left: 24, right: 24,),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          CategoryModel categoryModel = state.categories[index];
          return Container(
            child: MaterialButton(
              onPressed: () {
                widget.screenBloc..add(SelectCategoryEvent(category: state.categories[index]));
              },
              shape: categoryModel.isChecked ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: BorderSide(
                    color: Constants.mainColor,
                    width: 1,
                  ),
              ): RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              color: categoryModel.isChecked ? Colors.white: Constants.secondaryColor,
              elevation: 0,
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: categoryModel.isChecked ? Image.asset(
                      'assets/images/check.png',
                      width: 16,
                      height: 16,
                    ): Image.asset(
                      'assets/images/checkDefault.png',
                      width: 16,
                      height: 16,
                    ),
                  ),
                  Text(
                    state.appData.topics[index],
                    style: TextStyle(
                      color: categoryModel.isChecked ? Constants.mainColor: Constants.headlineColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return Container(width: 8,);
        },
        itemCount: state.categories.length,
      ),
    );
  }

  Widget _articlesWidget(HomeScreenState state) {
    return Container(
      child: ListView.separated(
        padding: EdgeInsets.only(left: 24, right: 24, bottom: 100),
        itemBuilder: (context, index) {
          ArticleModel article = state.articles[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            color: Colors.white,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedArticle = article;
                });
                _pc.open();
              },
              child: Container(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(
                      article.title ?? '',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'proxima-bold',
                      ),
                      maxLines: 1,
                      softWrap: true,
                    ),
                    SizedBox(height: 8,),
                    Container(
                      height: 100,
                      child: (article.urlToImage ?? '') != '' ? CachedNetworkImage(
                        imageUrl: article.urlToImage ?? '',
                        imageBuilder: (context, imageProvider) => Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        placeholder: (context, url) => Center(
                          child: Container(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: Colors.white,
                            ),
                            child: Center(
                              child: Icon(Icons.error),
                            ),
                          );
                        },
                      ): Center(
                        child: Icon(Icons.error),
                      ),
                    ),
                    SizedBox(height: 8,),
                    Text(
                      article.description ?? '',
                      style: TextStyle(
                        color: Constants.bodyTextColor,
                        fontSize: 14,
                        fontFamily: 'proxima-light',
                      ),
                      softWrap: true,
                      maxLines: 3,
                    ),
                    SizedBox(height: 8,),
                    Row(
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Publisher',
                                style: TextStyle(
                                  color: Constants.bodyTextColor,
                                  fontSize: 12,
                                  fontFamily: 'proxima-light',
                                ),
                                maxLines: 1,
                              ),
                              Text(
                                article.source.name ?? '',
                                style: TextStyle(
                                  color: Constants.mainColor,
                                  fontSize: 12,
                                  fontFamily: 'proxima-light',
                                ),
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 8, right: 8),
                          child: Container(
                            height: 44,
                            width: 1,
                            color: Constants.secondaryColor,
                          ),
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Author',
                                style: TextStyle(
                                  color: Constants.bodyTextColor,
                                  fontSize: 12,
                                  fontFamily: 'proxima-light',
                                ),
                                maxLines: 1,
                              ),
                              Text(
                                article.author ?? '',
                                style: TextStyle(
                                  color: Constants.mainColor,
                                  fontSize: 12,
                                  fontFamily: 'proxima-light',
                                ),
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 8, right: 8),
                          child: Container(
                            height: 44,
                            width: 1,
                            color: Constants.secondaryColor,
                          ),
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Published At',
                                style: TextStyle(
                                  color: Constants.bodyTextColor,
                                  fontSize: 12,
                                  fontFamily: 'proxima-light',
                                ),
                                maxLines: 1,
                              ),
                              Text(
                                article.publishedAt ?? '',
                                style: TextStyle(
                                  color: Constants.mainColor,
                                  fontSize: 12,
                                  fontFamily: 'proxima-light',
                                ),
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return Divider(height: 8, color: Colors.transparent,);
        },
        itemCount: state.articles.length,
      ),
    );
  }

  Widget _panel(HomeScreenState state) {
    if (selectedArticle == null) {
      return Container();
    }
    return Container(
      padding: EdgeInsets.only(left: 24, right: 24, bottom: 24),
      child: Column(
        children: [
          MaterialButton(
            onPressed: () {
              _pc.close();
            },
            child: Container(
              height: 4,
              width: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: Constants.disableColor,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    Text(
                      selectedArticle.title ?? '',
                      style: TextStyle(
                        color: Constants.headlineColor,
                        fontSize: 16,
                        fontFamily: 'proxima-bold',
                      ),
                      softWrap: true,
                    ),
                    SizedBox(height: 8,),
                    Container(
                      height: 200,
                      child: (selectedArticle.urlToImage ?? '') != '' ? CachedNetworkImage(
                        imageUrl: selectedArticle.urlToImage ?? '',
                        imageBuilder: (context, imageProvider) => Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        placeholder: (context, url) => Center(
                          child: Container(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: Colors.white,
                            ),
                            child: Center(
                              child: Icon(Icons.error),
                            ),
                          );
                        },
                      ): Center(
                        child: Icon(Icons.error),
                      ),
                    ),
                    SizedBox(height: 8,),
                    Text(
                      selectedArticle.description ?? '',
                      style: TextStyle(
                        color: Constants.bodyTextColor,
                        fontSize: 14,
                        fontFamily: 'proxima',
                      ),
                      softWrap: true,
                    ),
                    SizedBox(height: 8,),
                    Row(
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Publisher',
                                style: TextStyle(
                                  color: Constants.bodyTextColor,
                                  fontSize: 12,
                                  fontFamily: 'proxima-light',
                                ),
                                maxLines: 1,
                              ),
                              Text(
                                selectedArticle.source.name ?? '',
                                style: TextStyle(
                                  color: Constants.mainColor,
                                  fontSize: 12,
                                  fontFamily: 'proxima-light',
                                ),
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 8, right: 8),
                          child: Container(
                            height: 44,
                            width: 1,
                            color: Constants.secondaryColor,
                          ),
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Author',
                                style: TextStyle(
                                  color: Constants.bodyTextColor,
                                  fontSize: 12,
                                  fontFamily: 'proxima-light',
                                ),
                                maxLines: 1,
                              ),
                              Text(
                                selectedArticle.author ?? '',
                                style: TextStyle(
                                  color: Constants.mainColor,
                                  fontSize: 12,
                                  fontFamily: 'proxima-light',
                                ),
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 8, right: 8),
                          child: Container(
                            height: 44,
                            width: 1,
                            color: Constants.secondaryColor,
                          ),
                        ),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Published At',
                                style: TextStyle(
                                  color: Constants.bodyTextColor,
                                  fontSize: 12,
                                  fontFamily: 'proxima-light',
                                ),
                                maxLines: 1,
                              ),
                              Text(
                                selectedArticle.publishedAt ?? '',
                                style: TextStyle(
                                  color: Constants.mainColor,
                                  fontSize: 12,
                                  fontFamily: 'proxima-light',
                                ),
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      selectedArticle.content ?? '',
                      style: TextStyle(
                        color: Constants.bodyTextColor,
                        fontSize: 14,
                        fontFamily: 'proxima-light',
                      ),
                      softWrap: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16,),
          Container(
            child: Row(
              children: [
                Flexible(
                  child: OutlineButton(
                    onPressed: (selectedArticle.url ?? '') == '' ? null : () {
                      _launchURL(selectedArticle.url ?? '');
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    color: Constants.mainColor,
                    highlightedBorderColor: Constants.mainColor,
                    disabledBorderColor: Constants.disableColor,
                    disabledTextColor: Constants.disableColor,
                    textColor: Constants.mainColor,
                    borderSide: BorderSide(
                      color: Constants.mainColor,
                      width: 1,
                    ),
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      child: Text(
                        'Open URL',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'proxima',
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Flexible(
                  child: MaterialButton(
                    onPressed: (selectedArticle.url ?? '') == '' ? null : () {
                      widget.screenBloc.add(SaveArticleEvent(model: selectedArticle));
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    color: Constants.mainColor,
                    disabledTextColor: Constants.disableColor,
                    disabledColor: Constants.disableColor,
                    disabledElevation: 0,
                    textColor: Colors.white,
                    elevation: 0,
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      child: Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'proxima',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }


  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

}