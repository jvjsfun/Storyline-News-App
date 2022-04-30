import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:story_line/blocs/bloc.dart';
import 'package:story_line/models/app_data.dart';
import 'package:story_line/screens/login/login_screen.dart';
import 'package:story_line/screens/main/home/home_screen.dart';
import 'package:story_line/screens/main/profile/saved_screen.dart';
import 'package:story_line/utils/constants.dart';
import 'package:story_line/utils/global.dart';

import 'my_topic/my_topic_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MainScreenState();
  }
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin{

  int _currentIndex = 0;
  TabController _tabController;

  HomeScreenBloc screenBloc = new HomeScreenBloc(
      HomeScreenState(
          isLoading: true,
          userModel: Global.instance.userModel,
          countryCode: new CountryCodeModel(code: 'world', name: 'World')
      )
  );

  @override
  void initState() {
    screenBloc.add(HomeScreenInitEvent(userModel: Global.instance.userModel));
    super.initState();
    if (Global.instance.userModel.storyLines.length == 0) {
      setState(() {
        _currentIndex = 1;
      });
    }
    _tabController = new TabController(vsync: this, length: 3, initialIndex: _currentIndex);
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    screenBloc.close();
    super.dispose();
  }

  void _handleTabSelection() {
    if (screenBloc.state.savedArticles.length == 0) {
      screenBloc.add(GetSavedArticlesEvent());
    }
    setState(() {
      _currentIndex = _tabController.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      cubit: screenBloc,
      listener: (BuildContext context, HomeScreenState state) async {
      },
      child: BlocBuilder<HomeScreenBloc, HomeScreenState>(
        cubit: screenBloc,
        builder: (context, state) {
          return ModalProgressHUD(
            inAsyncCall: state.isLoading,
            child: DefaultTabController(
              length: 3,
              child: Scaffold(
                body: TabBarView(
                  controller: _tabController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    HomeScreen(screenBloc: screenBloc,),
                    MyTopicScreen(screenBloc: screenBloc,),
                    SavedScreen(screenBloc: screenBloc,),
                  ],
                ),
                bottomNavigationBar: TabBar(
                  isScrollable: false,
                  controller: _tabController,
                  labelColor: Constants.mainColor,
                  unselectedLabelColor: Constants.disableColor,
                  tabs: [
                    Tab(
                      icon: _currentIndex == 0 ? Image.asset('assets/images/news/active.png', width: 24, height: 24,)
                          : Image.asset('assets/images/news/default.png', width: 24, height: 24,),
                    ),
                    Tab(
                      icon: _currentIndex == 1 ? Image.asset('assets/images/home/active.png', width: 24, height: 24,)
                          : Image.asset('assets/images/home/default.png', width: 24, height: 24,),
                    ),
                    Tab(
                      icon: _currentIndex == 2 ? Image.asset('assets/images/profile/active.png', width: 24, height: 24,)
                          : Image.asset('assets/images/profile/default.png', width: 24, height: 24,),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void onTabTapped(HomeScreenState state, int index) {
    setState(() {
      _currentIndex = index;
    });
  }

}
