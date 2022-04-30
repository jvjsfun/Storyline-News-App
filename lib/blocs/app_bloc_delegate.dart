import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    assert(() {
      print(event);
      return true; // assert doesn't run in production
    }());
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    assert(() {
      print(transition);
      return true; // assert doesn't run in production
    }());
  }

  @override
  void onChange(Cubit cubit, Change change) {
    super.onChange(cubit, change);
    assert(() {
      print(change);
      return true; // assert doesn't run in production
    }());
  }

  @override
  void onError(Cubit cubit, Object error, StackTrace stackTrace) {
    super.onError(cubit, error, stackTrace);
    assert(() {
      print(error);
      return true; // assert doesn't run in production
    }());

  }
}
