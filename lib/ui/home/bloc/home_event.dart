abstract class HomeEvent {}

class InitializeHomeEvent extends HomeEvent {}

class TimerEndedEvent extends HomeEvent {}

class SetVolumeEvent extends HomeEvent {
  final double volume;

  SetVolumeEvent(this.volume);
}
