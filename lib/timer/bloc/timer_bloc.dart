import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dodo_timer/ticker.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;

  static int duration = 0;
  static int _hours = 0;
  static int _minutes = 0;
  static int _seconds = 0;

  StreamSubscription<int>? _tickerSubscription;

  TimerBloc({required Ticker ticker})
      : _ticker = ticker,
        super(TimerInitial(duration));

  @override
  Stream<TimerState> mapEventToState(
    TimerEvent event,
  ) async* {
    if (event is TimerChanged) {
      yield* _mapTimerChangedToState(event);
    } else if (event is TimerStarted) {
      yield* _mapTimerStartedToState(event);
    } else if (event is TimerPaused) {
      yield* _mapTimerPausedToState(event);
    } else if (event is TimerResumed) {
      yield* _mapTimerResumedToState(event);
    } else if (event is TimerReset) {
      yield* _mapTimerResetToState(event);
    } else if (event is TimerTicked) {
      yield* _mapTimerTickedToState(event);
    }
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();

    return super.close();
  }

  Stream<TimerState> _mapTimerChangedToState(TimerChanged change) async* {
    switch (change.type) {
      case "h":
        hours = change.duration;
        break;
      case "m":
        minutes = change.duration;
        break;
      case "s":
        seconds = change.duration;
        break;
    }
    yield TimerInitial(duration);
  }

  Stream<TimerState> _mapTimerStartedToState(TimerStarted start) async* {
    yield TimerRunInProgress(start.duration);
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
        .tick(ticks: start.duration)
        .listen((duration) => add(TimerTicked(duration: duration)));
  }

  Stream<TimerState> _mapTimerPausedToState(TimerPaused pause) async* {
    if (state is TimerRunInProgress) {
      _tickerSubscription?.pause();
      yield TimerRunPause(state.duration);
    }
  }

  Stream<TimerState> _mapTimerResumedToState(TimerResumed resume) async* {
    if (state is TimerRunPause) {
      _tickerSubscription?.resume();
      yield TimerRunInProgress(state.duration);
    }
  }

  Stream<TimerState> _mapTimerResetToState(TimerReset reset) async* {
    _tickerSubscription?.cancel();
    yield TimerInitial(duration);
  }

  Stream<TimerState> _mapTimerTickedToState(TimerTicked tick) async* {
    yield tick.duration > 0
        ? TimerRunInProgress(tick.duration)
        : const TimerRunComplete();
  }

  static int get hours => _hours;

  static set hours(int value) {
    _hours = value;
    duration = (_hours * 3600) + (_minutes * 60) + _seconds;
  }

  static int get minutes => _minutes;

  static set minutes(int value) {
    _minutes = value;
    duration = (_hours * 3600) + (_minutes * 60) + _seconds;
  }

  static int get seconds => _seconds;

  static set seconds(int value) {
    _seconds = value;
    duration = (_hours * 3600) + (_minutes * 60) + _seconds;
  }
}
