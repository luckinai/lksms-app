part of 'app_pages.dart';

abstract class Routes {
  Routes._();

  static const LAYOUT = _Paths.LAYOUT;
  static const HOME = _Paths.HOME;
  static const TASKS = _Paths.TASKS;
  static const SETTINGS = _Paths.SETTINGS;
  static const STATISTICS = _Paths.STATISTICS;
}

abstract class _Paths {
  _Paths._();

  static const LAYOUT = '/';
  static const HOME = '/home';
  static const TASKS = '/tasks';
  static const SETTINGS = '/settings';
  static const STATISTICS = '/statistics';
}
