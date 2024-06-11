class AppState {
  static final AppState _singleton = AppState._internal();
  bool _hasCompletedOnboarding = false;

  factory AppState() {
    return _singleton;
  }

  AppState._internal();

  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  void completeOnboarding() {
    _hasCompletedOnboarding = true;
  }
}
