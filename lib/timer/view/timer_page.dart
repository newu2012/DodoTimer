import 'package:dodo_timer/timer/bloc/timer_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dodo_timer/ticker.dart';
import 'package:dodo_timer/timer/timer.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TimerBloc(ticker: const Ticker()),
      child: const TimerView(),
    );
  }
}

class TimerView extends StatelessWidget {
  const TimerView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Background(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 100.0),
                child: Center(child: TimerText()),
              ),
              Actions(),
            ],
          ),
        ],
      ),
    );
  }
}

class TimerText extends StatelessWidget {
  const TimerText({Key? key}) : super(key: key);
  final int hoursInDay = 24, minutesInHour = 60, secondsInMinute = 60;

  @override
  Widget build(BuildContext context) {
    int duration = context.select((TimerBloc bloc) => bloc.state.duration);
    final hoursStr = ((duration / minutesInHour / secondsInMinute) % hoursInDay)
        .floor()
        .toString()
        .padLeft(2, '0');
    final minutesStr = ((duration / secondsInMinute) % secondsInMinute)
        .floor()
        .toString()
        .padLeft(2, '0');
    final secondsStr =
        (duration % secondsInMinute).floor().toString().padLeft(2, '0');

    var timeStyle = Theme.of(context).textTheme.headline2;
    var timeSize = timeStyle?.fontSize?.toDouble();
    timeSize ??= 6;

    return BlocBuilder<TimerBloc, TimerState>(
      buildWhen: (prev, state) => prev.runtimeType != state.runtimeType,
      builder: (context, state) {
        if (state is TimerInitial) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 65,
                height: 200,
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 65,
                  diameterRatio: 1.5,
                  physics: const FixedExtentScrollPhysics(),
                  controller: FixedExtentScrollController(
                    initialItem: int.parse(hoursStr),
                  ),
                  onSelectedItemChanged: (val) {
                    context.read<TimerBloc>().add(
                          TimerChanged(
                            type: "h",
                            duration: val,
                          ),
                        );
                  },
                  childDelegate: ListWheelChildLoopingListDelegate(
                    children: List<Widget>.generate(
                      hoursInDay,
                      (index) => Text(
                        '$index'.padLeft(2, '0'),
                        style: timeStyle,
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                ":",
                style: timeStyle,
              ),
              SizedBox(
                width: 65,
                height: 200,
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 65,
                  diameterRatio: 1.5,
                  physics: const FixedExtentScrollPhysics(),
                  controller: FixedExtentScrollController(
                    initialItem: int.parse(minutesStr),
                  ),
                  onSelectedItemChanged: (val) {
                    context.read<TimerBloc>().add(
                          TimerChanged(
                            type: "m",
                            duration: val,
                          ),
                        );
                  },
                  childDelegate: ListWheelChildLoopingListDelegate(
                    children: List<Widget>.generate(
                      minutesInHour,
                      (index) => Text(
                        '$index'.padLeft(2, '0'),
                        style: timeStyle,
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                ":",
                style: timeStyle,
              ),
              SizedBox(
                width: 65,
                height: 200,
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 65,
                  diameterRatio: 1.5,
                  physics: const FixedExtentScrollPhysics(),
                  controller: FixedExtentScrollController(
                    initialItem: int.parse(secondsStr),
                  ),
                  onSelectedItemChanged: (val) {
                    context.read<TimerBloc>().add(
                          TimerChanged(
                            type: "s",
                            duration: val,
                          ),
                        );
                  },
                  childDelegate: ListWheelChildLoopingListDelegate(
                    children: List<Widget>.generate(
                      secondsInMinute,
                      (index) => Text(
                        '$index'.padLeft(2, '0'),
                        style: timeStyle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        } else if (state is! TimerInitial) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                '$hoursStr:$minutesStr:$secondsStr',
                style: Theme.of(context).textTheme.headline2,
              ),
            ],
          );
        } else {
          return Container();
        }
      },
    );
  }
}

class Actions extends StatelessWidget {
  const Actions({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    int far = context.select((TimerBloc bloc) => bloc.state.duration);

    return BlocBuilder<TimerBloc, TimerState>(
      buildWhen: (prev, state) => prev.runtimeType != state.runtimeType,
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (state is TimerInitial) ...[
              FloatingActionButton(
                child: const Icon(Icons.play_arrow),
                onPressed: () =>
                    context.read<TimerBloc>().add(TimerStarted(duration: far)),
              ),
            ],
            if (state is TimerRunInProgress) ...[
              FloatingActionButton(
                child: const Icon(Icons.pause),
                onPressed: () =>
                    context.read<TimerBloc>().add(const TimerPaused()),
              ),
              FloatingActionButton(
                child: const Icon(Icons.stop),
                onPressed: () =>
                    context.read<TimerBloc>().add(const TimerReset()),
              ),
            ],
            if (state is TimerRunPause) ...[
              FloatingActionButton(
                child: const Icon(Icons.play_arrow),
                onPressed: () =>
                    context.read<TimerBloc>().add(const TimerResumed()),
              ),
              FloatingActionButton(
                child: const Icon(Icons.stop),
                onPressed: () =>
                    context.read<TimerBloc>().add(const TimerReset()),
              ),
            ],
            if (state is TimerRunComplete) ...[
              FloatingActionButton(
                child: const Icon(Icons.stop),
                onPressed: () =>
                    context.read<TimerBloc>().add(const TimerReset()),
              ),
            ],
          ],
        );
      },
    );
  }
}

class Background extends StatelessWidget {
  const Background({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade500,
          ],
        ),
      ),
    );
  }
}
