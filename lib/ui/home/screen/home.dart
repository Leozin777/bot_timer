import 'package:bot_timer/ui/config/config.dart';
import 'package:bot_timer/ui/home/bloc/home_bloc.dart';
import 'package:bot_timer/ui/home/bloc/home_event.dart';
import 'package:bot_timer/ui/home/bloc/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countDown,
  );

  @override
  void initState() {
    super.initState();
    BlocProvider.of<HomeBloc>(context).add(InitializeHomeEvent());
    _stopWatchTimer.fetchEnded.listen((value) {
      _stopWatchTimer.onResetTimer();
      setState(() {});
      BlocProvider.of<HomeBloc>(context).add((TimerEndedEvent()));
    });
  }

  @override
  void dispose() {
    _stopWatchTimer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(""),
        actions: [
          IconButton(
            onPressed: () async {
              _stopWatchTimer.onStopTimer();
              await showDialog(context: context, builder: (_) => Config());
              BlocProvider.of<HomeBloc>(context).add(InitializeHomeEvent());
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {},
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is InitializeSuccessHomeState) {
              _stopWatchTimer.clearPresetTime();
              _stopWatchTimer.setPresetMinuteTime(state.timer);
              return Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StreamBuilder(
                        stream: _stopWatchTimer.rawTime,
                        builder: (context, snap) {
                          final value = snap.data;
                          final displayTime = StopWatchTimer.getDisplayTime(value ?? 0);
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  displayTime,
                                  style: TextStyle(fontSize: 40, fontFamily: 'Helvetica', fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              if (_stopWatchTimer.isRunning) {
                                _stopWatchTimer.onStopTimer();
                              } else {
                                _stopWatchTimer.onStartTimer();
                              }
                              setState(() {});
                            },
                            icon: _stopWatchTimer.isRunning ? Icon(Icons.pause) : Icon(Icons.play_arrow),
                          ),
                          IconButton(
                            onPressed: () {
                              _stopWatchTimer.onResetTimer();
                              setState(() {});
                            },
                            icon: Icon(Icons.stop),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }
            return SizedBox();
          },
        ),
      ),
    );
  }
}
