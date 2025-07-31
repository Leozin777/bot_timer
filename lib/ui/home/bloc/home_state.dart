abstract class HomeState {}

class InitialHomeState extends HomeState {}

class InitializeSuccessHomeState extends HomeState {
  final int timer;

  InitializeSuccessHomeState(this.timer);
}

class TimerEndedState extends HomeState {}
