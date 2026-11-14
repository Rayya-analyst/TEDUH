import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPointsService extends ChangeNotifier {
  UserPointsService._() {
    _load();
  }

  static final UserPointsService instance = UserPointsService._();

  static const String _keyPoints = 'teduh_user_points';
  static const String _keyActivities = 'teduh_user_activities_count';

  int _points = 0;
  int _activitiesCompleted = 0;
  bool _initialized = false;

  int get points => _points;
  int get activitiesCompleted => _activitiesCompleted;
  bool get isInitialized => _initialized;

  int get currentTarget {
    if (_points < 100) return 100;
    return ((_points ~/ 100) + 1) * 100;
  }

  String get rankTitle {
    if (_points < 40) return 'Pemula Bugar';
    if (_points < 100) return 'Pencegah Polusi';
    if (_points < 200) return 'Sahabat Paru Bersih';
    return 'Pahlawan Kebugaran TEDUH';
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _points = prefs.getInt(_keyPoints) ?? 0;
      _activitiesCompleted = prefs.getInt(_keyActivities) ?? 0;
      _initialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('[UserPointsService] Gagal memuat poin: $e');
    }
  }

  Future<void> reload() => _load();

  Future<int> addPoints(int earned) async {
    _points += earned;
    _activitiesCompleted += 1;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyPoints, _points);
      await prefs.setInt(_keyActivities, _activitiesCompleted);
    } catch (e) {
      debugPrint('[UserPointsService] Gagal menyimpan poin: $e');
    }

    return _points;
  }
}

