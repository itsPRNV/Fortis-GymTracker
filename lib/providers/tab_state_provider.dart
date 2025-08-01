import 'package:flutter/foundation.dart';

class TabStateProvider extends ChangeNotifier {
  int _timerTabIndex = 0;
  int _progressTabIndex = 0;

  int get timerTabIndex => _timerTabIndex;
  int get progressTabIndex => _progressTabIndex;

  void setTimerTabIndex(int index) {
    _timerTabIndex = index;
    notifyListeners();
  }

  void setProgressTabIndex(int index) {
    _progressTabIndex = index;
    notifyListeners();
  }
}