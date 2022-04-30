import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:mp_chart/mp/chart/bar_chart.dart';
import 'package:mp_chart/mp/controller/bar_chart_controller.dart';
import 'package:mp_chart/mp/core/data/bar_data.dart';
import 'package:mp_chart/mp/core/data_interfaces/i_bar_data_set.dart';
import 'package:mp_chart/mp/core/data_set/bar_data_set.dart';
import 'package:mp_chart/mp/core/description.dart';
import 'package:mp_chart/mp/core/entry/bar_entry.dart';
import 'package:mp_chart/mp/core/enums/x_axis_position.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:story_line/blocs/bloc.dart';
import 'package:story_line/models/story_line.dart';
import 'package:story_line/models/userModel.dart';
import 'package:story_line/utils/constants.dart';
import 'package:story_line/utils/global.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;

class MyTopicScreen extends StatefulWidget {
  final HomeScreenBloc screenBloc;

  MyTopicScreen({Key key, this.screenBloc});
  @override
  State<StatefulWidget> createState() {
    return _MyTopicScreenState();
  }
}

class _MyTopicScreenState extends State<MyTopicScreen> with AutomaticKeepAliveClientMixin<MyTopicScreen>{

  @override
  bool get wantKeepAlive => true;
  TextEditingController headingController = TextEditingController();
  TextEditingController subController = TextEditingController();
  TextEditingController keywordController = TextEditingController();
  FocusNode headingFocus = FocusNode();
  FocusNode subFocus = FocusNode();
  FocusNode keywordFocus = FocusNode();

  List<String> keywords = [];
  PanelController _pc = new PanelController();
  PanelController _pcDetail = new PanelController();
  PanelController _pcTopicDetail = new PanelController();
  BorderRadiusGeometry radius = BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );

  String myCollection = '';
  String myTopic = '';
  String myKeywords = '';
  String myKeys = '';
  bool showChart = false;
  List<charts.Series> seriesList = [];
  BarChartController controller;
  List<String> chartFilters = [
    'Today',
    'This Week',
    'This Month',
    'This Year',
    'Max',
  ];
  int selectedFilter = 0;
  StoryLineModel selectedArticle;
  StoryLine selectedStoryLine;
  SubTopic selectedTopic;
  @override
  void initState() {
    super.initState();
    seriesList = _createSampleData();
    _initController();
    _initBarData(10, 100);
  }

  @override
  void dispose() {
    headingController.dispose();
    headingFocus.dispose();
    subController.dispose();
    subFocus.dispose();
    keywordController.dispose();
    keywordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocListener(
      cubit: widget.screenBloc,
      listener: (BuildContext context, HomeScreenState state) async {
      },
      child: BlocBuilder<HomeScreenBloc, HomeScreenState>(
        cubit: widget.screenBloc,
        builder: (context, state) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
              resizeToAvoidBottomPadding: false,
              resizeToAvoidBottomInset: false,
              body: SafeArea(
                child: SlidingUpPanel(
                  controller: _pcTopicDetail,
                  panel: _panelTopicDetail(state),
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
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                  borderRadius: radius,
                  body: SlidingUpPanel(
                    controller: _pc,
                    renderPanelSheet: true,
                    panel: _panel(state),
                    collapsed: Container(
                      height: 0,
                    ),
                    onPanelOpened: () {
                    },
                    onPanelClosed: () {
                      setState(() {
                        headingController.text = '';
                        subController.text = '';
                        keywordController.text = '';
                        keywords.clear();
                      });
                      FocusScope.of(context).unfocus();
                    },
                    backdropTapClosesPanel: true,
                    defaultPanelState: Global.instance.userModel.storyLines.length > 0 ? PanelState.CLOSED: PanelState.OPEN,
                    isDraggable: true,
                    minHeight: 0,
                    maxHeight: MediaQuery.of(context).size.height * 0.9,
                    borderRadius: radius,
                    body: SlidingUpPanel(
                      controller: _pcDetail,
                      renderPanelSheet: true,
                      panel: _storyLinePanel(state),
                      collapsed: Container(
                        height: 0,
                      ),
                      onPanelOpened: () {
                      },
                      onPanelClosed: () {
                        setState(() {
                          headingController.text = '';
                          subController.text = '';
                          keywordController.text = '';
                          keywords.clear();
                        });
                        FocusScope.of(context).unfocus();
                      },
                      backdropTapClosesPanel: true,
                      isDraggable: true,
                      minHeight: 0,
                      maxHeight: MediaQuery.of(context).size.height * 0.9,
                      borderRadius: radius,
                      body: _body(state),
                    ),
                  ),
                ) ,
              ),
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
        Expanded(
          child: _storyLinesWidget(state),
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
            'My Topics',
            style: TextStyle(
              color: Constants.headlineColor,
              fontSize: 24,
              fontFamily: 'proxima-bold',
            ),
          ),
          Container(
            padding: EdgeInsets.all(0),
            child: MaterialButton(
              onPressed: () {
                _pcTopicDetail.close();
                _pcDetail.close();
                _pc.open();
              },
              child: Text(
                'Create New',
                style: TextStyle(
                  color: Constants.mainColor,
                  fontSize: 14,
                  fontFamily: 'proxima-bold',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _storyLinesWidget(HomeScreenState state) {
    return Container(
      height: 36,
      child: ListView.separated(
        padding: EdgeInsets.only(left: 24, right: 24,),
        itemBuilder: (context, index) {
          StoryLine storyLine = state.userModel.storyLines[index];
          return ExpansionTile(
            title: Row(
              children: [
                Padding(
                  padding: EdgeInsets.zero,
                  child: IconButton(
                    onPressed: () {
                      headingController.text = storyLine.key;
                      _pc.open();
                    },
                    icon: Icon(
                      Icons.add,
                      color: Constants.headlineColor,
                    ),
                  ),
                ),
                Text(
                  storyLine.key,
                  style: TextStyle(
                    color: Constants.headlineColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            children: List.generate(storyLine.subTopics.length, (index) {
              SubTopic subTopic = storyLine.subTopics[index];
              String query = subTopic.query;
              String _keywords = '';
              List<String> queries = query.split(' AND ').toList();
              queries.forEach((element) {
                String k = element.replaceAll('(', '').replaceAll(')', '');
                if (_keywords == '') {
                  _keywords = '#$k';
                } else {
                  _keywords = '$_keywords #$k';
                }
              });

              return InkWell(
                onTap: () {
                  String collectionName = storyLine.key;
                  String topicName = subTopic.topic;
                  String keys = '';
                  queries.forEach((element) {
                    String k = element.replaceAll('(', '').replaceAll(')', '');
                    if (keys == '') {
                      keys = k;
                    } else {
                      keys = '$keys,$k';
                    }
                  });
                  setState(() {
                    myCollection = collectionName;
                    myTopic = topicName;
                    myKeywords = _keywords;
                    myKeys = keys;
                  });
                  widget.screenBloc.add(GetStoryLineEvent(collectionName: collectionName, topicName: topicName, keywords: keys));
                  _pcDetail.open();
                },
                child: ListTile(
                  dense: true,
                  title: Text(
                    subTopic.topic,
                    style: TextStyle(
                      color: Constants.headlineColor,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    _keywords,
                    style: TextStyle(
                      color: Constants.bodyTextColor,
                      fontSize: 12,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete_outline),
                    onPressed: () {
                      if (storyLine.subTopics.length == 0) {
                        widget.screenBloc.add(RemoveCollectionFromCollections(storyLine: storyLine, topic: subTopic));
                      } else {
                        widget.screenBloc.add(RemoveTopicFromCollection(storyLine: storyLine, topic: subTopic));
                      }
                    },
                  ),
                ),
              );
            }),
          );
        },
        separatorBuilder: (context, index) {
          return Divider(height: 0, thickness: 0.5,);
        },
        itemCount: state.userModel.storyLines.length,
      ),
    );
  }

  Widget _panel(HomeScreenState state) {
    if (state.userModel == null) {
      return Container();
    }
    return Container(
      padding: EdgeInsets.only(left: 24, right: 24, bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        children: [
          MaterialButton(
            onPressed: () {
              _pc.close();
              FocusScope.of(context).unfocus();
            },
            child: Container(
              height: 4,
              width: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: Constants.disableColor,
              ),
            ),
          ),
          Expanded(
            child: KeyboardAvoider(
              autoScroll: true,
              focusPadding: 20,
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Create new storyline',
                        style: TextStyle(
                          color: Constants.headlineColor,
                          fontSize: 16,
                          fontFamily: 'proxima-bold',
                        ),
                        softWrap: true,
                      ),
                      SizedBox(height: 24,),
                      Container(
                        height: 72,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Collection',
                              style: TextStyle(
                                color: Constants.hintColor,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 8,),
                            Flexible(
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Color(0xFFF4F4F4),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextFormField(
                                  focusNode: headingFocus,
                                  validator: (val) {
                                    if (val.isEmpty) {
                                      return 'Collection is required';
                                    }
                                    return null;
                                  },
                                  controller: headingController,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  textCapitalization: TextCapitalization.words,
                                  style: TextStyle(
                                    fontFamily: 'proxima-bold',
                                    color: Constants.headlineColor,
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all( 16),
                                    hintText: 'Ex: My Favorite',
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                      color: Constants.hintColor,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  onFieldSubmitted: (val) {
                                    FocusScope.of(context).requestFocus(subFocus);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12,),
                      Container(
                        height: 72,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Topic',
                              style: TextStyle(
                                color: Constants.hintColor,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 8,),
                            Flexible(
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Color(0xFFF4F4F4),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: TextFormField(
                                  focusNode: subFocus,
                                  validator: (val) {
                                    if (val.isEmpty) {
                                      return 'Topic is required';
                                    }
                                    return null;
                                  },
                                  controller: subController,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  textCapitalization: TextCapitalization.words,
                                  style: TextStyle(
                                    fontFamily: 'proxima-bold',
                                    color: Constants.headlineColor,
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all( 16),
                                    hintText: 'Ex: Tesla Car',
                                    hintStyle: TextStyle(
                                      fontSize: 14,
                                      color: Constants.hintColor,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  onFieldSubmitted: (val) {
                                    FocusScope.of(context).requestFocus(keywordFocus);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12,),
                      Container(
                        height: 72,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Keywords',
                              style: TextStyle(
                                color: Constants.hintColor,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(height: 8,),
                            Flexible(
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Color(0xFFF4F4F4),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: TextFormField(
                                        focusNode: keywordFocus,
                                        validator: (val) {
                                          if (val.isEmpty && keywords.length == 0) {
                                            return 'Keywords are required';
                                          }
                                          return null;
                                        },
                                        controller: keywordController,
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.next,
                                        textCapitalization: TextCapitalization.words,
                                        style: TextStyle(
                                          fontFamily: 'proxima-bold',
                                          color: Constants.headlineColor,
                                          fontSize: 16,
                                        ),
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.all(16),
                                          hintText: 'Ex: Tesla Car',
                                          hintStyle: TextStyle(
                                            fontSize: 14,
                                            color: Constants.hintColor,
                                          ),
                                          border: InputBorder.none,
                                        ),
                                        onFieldSubmitted: (val) {
                                          FocusScope.of(context).unfocus();
                                        },
                                      ),
                                    ),
                                    MaterialButton(
                                      onPressed: () {
                                        if (keywordController.text.isEmpty) {
                                          return;
                                        }
                                        setState(() {
                                          keywords.add(keywordController.text);
                                          keywordController.text = '';
                                        });
                                      },
                                      shape: CircleBorder(),
                                      padding: EdgeInsets.zero,
                                      height: 36,
                                      minWidth: 0,
                                      child: SvgPicture.asset(
                                        'assets/images/pluse.svg',
                                        width: 24,
                                        height: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            String keyword = keywords[index];
                            return Container(
                              child: MaterialButton(
                                onPressed: () {
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  side: BorderSide(
                                    color: Constants.mainColor,
                                    width: 1,
                                  ),
                                ),
                                color: Colors.white,
                                elevation: 0,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: Image.asset(
                                        'assets/images/check.png',
                                        width: 16,
                                        height: 16,
                                      ),
                                    ),
                                    Text(
                                      keyword,
                                      style: TextStyle(
                                        color: Constants.mainColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(left: 8),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            keywords.remove(keyword);
                                          });
                                        },
                                        child: Icon(Icons.cancel_outlined, size: 16, color: Constants.mainColor,),
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
                          itemCount: keywords.length,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ) ,
          ),
          SizedBox(height: 16,),
          Container(
            child: MaterialButton(
              onPressed: () {
                if (headingController.text.isEmpty) {
                  return;
                }
                if (subController.text.isEmpty) {
                  return;
                }
                if (keywordController.text.isEmpty && keywords.length == 0) {
                  return;
                }

                StoryLine storyLine = StoryLine();
                storyLine.key = headingController.text;
                SubTopic subtopic = SubTopic();
                subtopic.topic = subController.text;
                String keys = '';
                if (keywordController.text.length > 0) {
                  keywords.add(keywordController.text);
                }
                keywords.forEach((element) {
                  if (keys.isEmpty) {
                    keys = element;
                  } else {
                    keys = '$keys,$element';
                  }
                });
                subtopic.query = keys;
                storyLine.subTopics = [subtopic];
                widget.screenBloc.add(PostStoryCollectionEvent(storyLine: storyLine));
                _pc.close();
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
                  'Create Topic',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'proxima',
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 100,),
        ],
      ),
    );
  }

  Widget _storyLinePanel(HomeScreenState state) {
    return Container(
      padding: EdgeInsets.only(left: 24, right: 24, bottom: 24),
      child: Column(
        children: [
          Container(
            height: 64,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: MaterialButton(
                    onPressed: () {
                      _pcDetail.close();
                    },
                    padding: EdgeInsets.zero,
                    minWidth: 0,
                    child: Container(
                      height: 4,
                      width: 44,
                      padding: EdgeInsets.zero,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Constants.disableColor,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: MaterialButton(
                    onPressed: () {
                      setState(() {
                        showChart = !showChart;
                      });
                    },
                    padding: EdgeInsets.zero,
                    minWidth: 0,
                    child: Text(
                      showChart ? 'Close':'History',
                      style: TextStyle(
                        color: Constants.mainColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '$myCollection - $myTopic',
                  style: TextStyle(
                    color: Constants.headlineColor,
                    fontSize: 12,
                    fontFamily: 'proxima-bold',
                  ),
                  softWrap: true,
                ),
                SizedBox(height: 4,),
                Text(
                  myKeywords,
                  style: TextStyle(
                    color: Constants.bodyTextColor,
                    fontSize: 11,
                    fontFamily: 'proxima',
                  ),
                  softWrap: true,
                ),
                SizedBox(height: 8,),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 100),
                    child: Column(
                      children: List.generate(state.storyLines.length + 1, (index) {
                        if (index == 0) {
                          return showChart ? Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Flexible(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'From',
                                        style: TextStyle(
                                          color: Constants.bodyTextColor,
                                          fontSize: 14,
                                          fontFamily: 'proxima',
                                        ),
                                      ),
                                      MaterialButton(
                                        child: Text(
                                          formatDate(state.startDate, [mm, '/', dd, '/', yyyy]),
                                          style: TextStyle(
                                            color: Constants.mainColor,
                                            fontSize: 14,
                                            fontFamily: 'proxima-bold',
                                          ),
                                        ),
                                        onPressed: () async {
                                          final List<DateTime> picked = await DateRagePicker.showDatePicker(
                                              context: context,
                                              initialFirstDate: state.startDate,
                                              initialLastDate: state.endDate,
                                              firstDate: new DateTime(2000),
                                              lastDate: new DateTime(2050)
                                          );
                                          if (picked != null && picked.length == 2) {
                                            print(picked);
                                            widget.screenBloc.add(DateRangeUpdatedEvent(
                                              collectionName: myCollection,
                                              topicName: myTopic,
                                              keywords: myKeys,
                                              startDate: picked.first,
                                              endDate: picked.last,
                                            ));
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Flexible(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'To',
                                        style: TextStyle(
                                          color: Constants.bodyTextColor,
                                          fontSize: 14,
                                          fontFamily: 'proxima',
                                        ),
                                      ),
                                      MaterialButton(
                                        child: Text(
                                          formatDate(state.endDate, [mm, '/', dd, '/', yyyy]),
                                          style: TextStyle(
                                            color: Constants.mainColor,
                                            fontSize: 14,
                                            fontFamily: 'proxima-bold',
                                          ),
                                        ),
                                        onPressed: () async {
                                          final List<DateTime> picked = await DateRagePicker.showDatePicker(
                                              context: context,
                                              initialFirstDate: state.startDate,
                                              initialLastDate: state.endDate,
                                              firstDate: new DateTime(2000),
                                              lastDate: new DateTime(2050)
                                          );
                                          if (picked != null && picked.length == 2) {
                                            print(picked);
                                            widget.screenBloc.add(DateRangeUpdatedEvent(
                                              collectionName: myCollection,
                                              topicName: myTopic,
                                              keywords: myKeys,
                                              startDate: picked.first,
                                              endDate: picked.last,
                                            ));
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ) : Container();
                        }
                        StoryLineModel article = state.storyLines[index - 1];
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
                              _pcTopicDetail.open();
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
                                              article.source ?? '',
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
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _panelTopicDetail(HomeScreenState state) {
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
                                selectedArticle.source ?? '',
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
                      widget.screenBloc.add(SaveStoryArticleEvent(model: selectedArticle));
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

  /// Create one series with sample hard coded data.
  static List<charts.Series<SampleChartData, String>> _createSampleData() {
    final data = [
      new SampleChartData('2009', 5),
      new SampleChartData('2010', 23),
      new SampleChartData('2011', 42),
      new SampleChartData('2012', 54),
      new SampleChartData('2014', 23),
      new SampleChartData('2014', 43),
      new SampleChartData('2015', 54),
      new SampleChartData('2016', 43),
      new SampleChartData('2017', 75),
      new SampleChartData('2018', 53),
      new SampleChartData('2019', 43),
      new SampleChartData('2020', 23),
    ];

    return [
      new charts.Series<SampleChartData, String>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.purple.shadeDefault,
        seriesColor: charts.MaterialPalette.purple.shadeDefault,
        domainFn: (SampleChartData sales, _) => sales.year,
        measureFn: (SampleChartData sales, _) => sales.sales,
        data: data,
      )
    ];
  }

  var random = Random(1);

  void _initBarData(int count, double range) async {
    List<BarEntry> values = List();

    for (int i = 0; i < count; i++) {
      double multi = (range + 1);
      double val = (random.nextDouble() * multi) + multi / 3;
      values.add(new BarEntry(x: i.toDouble(), y: val,));
    }

    BarDataSet set1;

    set1 = new BarDataSet(values, "Data Set");
    set1.setColors1([Constants.headlineColor, Constants.mainColor]);
    set1.setDrawValues(false);

    List<IBarDataSet> dataSets = List();
    dataSets.add(set1);

    controller.data = BarData(dataSets);
    controller.data
      ..setValueTextSize(10)
      ..barWidth = 0.9;

    setState(() {});
  }

  void _initController() {
    var desc = Description()..enabled = false;
    controller = BarChartController(
      axisLeftSettingFunction: (axisLeft, controller) {
        axisLeft.drawGridLines = false;
      },
      legendSettingFunction: (legend, controller) {
        legend.enabled = false;
      },
      xAxisSettingFunction: (xAxis, controller) {
        xAxis
          ..position = XAxisPosition.BOTTOM
          ..drawGridLines = false;
      },
      drawGridBackground: false,
      dragXEnabled: false,
      dragYEnabled: false,
      scaleXEnabled: false,
      scaleYEnabled: false,
      pinchZoomEnabled: false,
      maxVisibleCount: 60,
      description: desc,
      fitBars: true,
    );
  }

  Widget _initBarChart() {
    var barChart = BarChart(controller);
    controller.animator
      ..reset()
      ..animateY1(1500);
    return barChart;
  }

}

/// Sample ordinal data type.
class SampleChartData {
  final String year;
  final int sales;

  SampleChartData(this.year, this.sales);
}
