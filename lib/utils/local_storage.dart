import 'package:bot_timer/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();

  factory LocalStorage() => _instance;

  LocalStorage._internal();

  late SharedPreferences _sharedPreferences;

  Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  int getTimer() {
    var value = _sharedPreferences.getInt(keyTimer);
    return value ?? 0;
  }

  double getVolume() {
    var value = _sharedPreferences.getDouble(keyVolume);
    return value ?? 0;
  }

  Future<void> setTimer(int minutes) async {
    await _sharedPreferences.setInt(keyTimer, minutes);
  }

  Future<void> setVolume(double volume) async {
    await _sharedPreferences.setDouble(keyVolume, volume);
  }
}
