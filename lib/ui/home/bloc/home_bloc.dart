import 'dart:io';
import 'package:bot_timer/services/notification_service.dart';
import 'package:bot_timer/ui/home/bloc/home_event.dart';
import 'package:bot_timer/ui/home/bloc/home_state.dart';
import 'package:bot_timer/utils/local_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  int timer = 0;
  final NotificationService _notificationService = NotificationService();
  List<String> _soundFiles = [];

  HomeBloc() : super(InitialHomeState()) {
    on<InitializeHomeEvent>((event, emit) async {
      await LocalStorage().init();
      timer = LocalStorage().getTimer();
      await _carregarArquivosAudio();
      await _notificationService.initialize();
      emit(InitializeSuccessHomeState(timer));
    });

    on<TimerEndedEvent>((event, emit) async {
      await _mostrarNotificacao();
      emit(TimerEndedState());
      emit(InitializeSuccessHomeState(timer));
    });

    on<SetVolumeEvent>((event, emit) async {
      NotificationService().setVolume(event.volume);
    });
  }

  Future<void> _carregarArquivosAudio() async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final soundsDir = Directory(path.join(appDocDir.path, 'audios_bot'));

      if (await soundsDir.exists()) {
        List<FileSystemEntity> files = soundsDir.listSync();
        _soundFiles = files
            .where((file) => file is File && (file.path.endsWith('.mp3') || file.path.endsWith('.wav')))
            .map((file) => file.path)
            .toList();
      }
    } catch (e) {
      print("Erro ao carregar arquivos de áudio: $e");
    }
  }

  Future<void> _mostrarNotificacao() async {
    try {
      await _notificationService.showNotification(
        id: 1,
        title: "Timer finalizado!",
        body: "Seu tempo acabou.",
      );
    } catch (e) {
      print("Erro ao mostrar notificação: $e");
    }
  }
}
