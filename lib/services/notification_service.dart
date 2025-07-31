import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:bot_timer/utils/local_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _lastPlayedFile;
  double _volume = 1.0;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> initialize() async {
    InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await LocalStorage().setVolume(_volume);
  }

  Future<double> getVolume() async {
    _volume = LocalStorage().getVolume();
    return _volume;
  }

  Future<void> showNotification({required int id, required String title, required String body}) async {
    NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'bot_timer_channel',
        'Bot Timer',
        channelDescription: 'Bot Timer notifications',
        importance: Importance.high,
        priority: Priority.high,
        playSound: false,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: false,
      ),
    );
    try {
      final soundFile = await _getRandomSoundFile();
      if (soundFile != null) {
        await _playSoundOnMainThread(DeviceFileSource(soundFile));
      } else {
        await _playSoundOnMainThread(AssetSource('test.wav'));
      }
    } catch (e) {
      await _playSoundOnMainThread(AssetSource('test.wav'));
    }

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }

  Future<String?> _getRandomSoundFile() async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final soundsDir = Directory(path.join(appDocDir.path, 'audios_bot'));

      if (await soundsDir.exists()) {
        List<FileSystemEntity> files = soundsDir.listSync();
        List<String> audioFiles = files
            .where((file) => file is File && (file.path.endsWith('.mp3') || file.path.endsWith('.wav')))
            .map((file) => file.path)
            .toList();

        if (audioFiles.isEmpty) return null;
        if (audioFiles.length == 1) return audioFiles[0];
        final random = Random();

        List<String> possibleFiles = List.from(audioFiles);
        if (_lastPlayedFile != null && possibleFiles.contains(_lastPlayedFile)) {
          if (random.nextDouble() > 0.2) {
            possibleFiles.remove(_lastPlayedFile);
          }
        }
        final selectedFile = possibleFiles[random.nextInt(possibleFiles.length)];
        _lastPlayedFile = selectedFile;

        return selectedFile;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _playSoundOnMainThread(Source source) async {
    await Future.delayed(Duration.zero, () async {
      await _audioPlayer.play(source);
    });
  }
}
