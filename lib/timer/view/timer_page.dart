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
    final duration = context.select((TimerBloc bloc) => bloc.state.duration);
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

    Row row = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: 70,
          height: 200,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 65,
            onSelectedItemChanged: (val) {},
            controller: FixedExtentScrollController(initialItem: 0),
            childDelegate: ListWheelChildLoopingListDelegate(
              children: List<Widget>.generate(
                hoursInDay,
                (index) => Text(
                  '$index', style: timeStyle,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 70,
          height: 200,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 65,
            onSelectedItemChanged: (val) {},
            controller: FixedExtentScrollController(initialItem: 0),
            childDelegate: ListWheelChildLoopingListDelegate(
              children: List<Widget>.generate(
                minutesInHour,
                    (index) => Text(
                  '$index', style: timeStyle,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 70,
          height: 200,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 65,
            onSelectedItemChanged: (val) {},
            controller: FixedExtentScrollController(initialItem: 0),
            childDelegate: ListWheelChildLoopingListDelegate(
              children: List<Widget>.generate(
                secondsInMinute,
                    (index) => Text(
                  '$index', style: timeStyle,
                ),
              ),
            ),
          ),
        ),
      ],
    );

    // Text(
    //   '$hoursStr:$minutesStr:$secondsStr',
    //   style: Theme.of(context).textTheme.headline2,
    // );

    return row;
  }
}

class Actions extends StatelessWidget {
  const Actions({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      buildWhen: (prev, state) => prev.runtimeType != state.runtimeType,
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (state is TimerInitial) ...[
              FloatingActionButton(
                child: const Icon(Icons.play_arrow),
                onPressed: () => context
                    .read<TimerBloc>()
                    .add(TimerStarted(duration: state.duration)),
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
