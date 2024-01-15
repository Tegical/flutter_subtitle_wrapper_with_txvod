import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:subtitle_wrapper_package_with_txvod/subtitle_wrapper_package.dart';
import 'package:super_player/super_player.dart';

part 'subtitle_event.dart';
part 'subtitle_state.dart';

class SubtitleBloc extends Bloc<SubtitleEvent, SubtitleState> {
  SubtitleBloc({
    required this.txVodPlayerController,
    required this.subtitleRepository,
    required this.subtitleController,
  }) : super(SubtitleInitial()) {
    subtitleController.attach(this);
    on<LoadSubtitle>((event, emit) => loadSubtitle(emit: emit));
    on<InitSubtitles>((event, emit) => initSubtitles(emit: emit));
    on<UpdateLoadedSubtitle>(
      (event, emit) => emit(LoadedSubtitle(event.subtitle)),
    );
    on<CompletedShowingSubtitles>(
      (event, emit) => emit(CompletedSubtitle()),
    );
  }

  final TXVodPlayerController txVodPlayerController;
  final SubtitleRepository subtitleRepository;
  final SubtitleController subtitleController;

  late Subtitles subtitles;
  Subtitle? _currentSubtitle;

  Future<void> initSubtitles({
    required Emitter<SubtitleState> emit,
  }) async {
    emit(SubtitleInitializing());
    subtitles = await subtitleRepository.getSubtitles();
    emit(SubtitleInitialized());
  }

  Future<void> loadSubtitle({
    required Emitter<SubtitleState> emit,
  }) async {
    emit(LoadingSubtitle());

    await txVodPlayerController.onPlayerEventBroadcast
        .listen((Map<dynamic, dynamic> event) async {
      if (!event.containsKey('event')) {
        return;
      }
      final eventType = event['event'];
      // debugPrint('onPlayerEventBroadcast event: $eventType');
      if (eventType == TXVodPlayEvent.PLAY_EVT_PLAY_PROGRESS) {
        // debugPrint('subtitle PLAY_EVT_PLAY_PROGRESS event: $event');
        if (!event.containsKey('EVT_PLAY_PROGRESS') ||
            !event.containsKey('EVT_PLAY_DURATION')) {
          return;
        }
        // final currentProgress = event['EVT_PLAY_PROGRESS'] as num;
        // final videoDuration = event['EVT_PLAY_DURATION'] as num;
        final currentProgressInMills = event['EVT_PLAY_PROGRESS_MS'] as int;
        // debugPrint('loadSubtitle $currentProgressInMills');
        if (subtitles.subtitles.isNotEmpty &&
            currentProgressInMills >
                subtitles.subtitles.last.endTime.inMilliseconds) {
          add(CompletedShowingSubtitles());
        }
        for (final subtitleItem in subtitles.subtitles) {
          final validStartTime =
              currentProgressInMills > subtitleItem.startTime.inMilliseconds;
          final validEndTime =
              currentProgressInMills < subtitleItem.endTime.inMilliseconds;
          final subtitle = validStartTime && validEndTime ? subtitleItem : null;
          if (validStartTime && validEndTime && subtitle != _currentSubtitle) {
            _currentSubtitle = subtitle;
          } else if (!_currentSubtitleIsValid(
            videoPlayerPosition: currentProgressInMills.toInt(),
          )) {
            _currentSubtitle = null;
          }
          // emit(LoadedSubtitle(_currentSubtitle));
          add(
            UpdateLoadedSubtitle(
              subtitle: _currentSubtitle,
            ),
          );
        }
      }
      if (eventType == TXVodPlayEvent.PLAY_EVT_PLAY_END) {}
      if (eventType == TXVodPlayEvent.PLAY_EVT_PLAY_BEGIN) {}
    });
    // txVodPlayerController.addListener(
    //   () {
    //     final videoPlayerPosition = txVodPlayerController.value.position;
    //     if (subtitles.subtitles.isNotEmpty &&
    //         videoPlayerPosition.inMilliseconds >
    //             subtitles.subtitles.last.endTime.inMilliseconds) {
    //       add(CompletedShowingSubtitles());
    //     }
    //     for (final subtitleItem in subtitles.subtitles) {
    //       final validStartTime = videoPlayerPosition.inMilliseconds >
    //           subtitleItem.startTime.inMilliseconds;
    //       final validEndTime = videoPlayerPosition.inMilliseconds <
    //           subtitleItem.endTime.inMilliseconds;
    //       final subtitle = validStartTime && validEndTime ? subtitleItem : null;
    //       if (validStartTime && validEndTime && subtitle != _currentSubtitle) {
    //         _currentSubtitle = subtitle;
    //       } else if (!_currentSubtitleIsValid(
    //         videoPlayerPosition: videoPlayerPosition.inMilliseconds,
    //       )) {
    //         _currentSubtitle = null;
    //       }
    //       add(
    //         UpdateLoadedSubtitle(
    //           subtitle: _currentSubtitle,
    //         ),
    //       );
    //     }
    //   },
    // );
  }

  @override
  Future<void> close() {
    subtitleController.detach();

    return super.close();
  }

  bool _currentSubtitleIsValid({required int videoPlayerPosition}) {
    if (_currentSubtitle == null) return false;
    final validStartTime =
        videoPlayerPosition > _currentSubtitle!.startTime.inMilliseconds;
    final validEndTime =
        videoPlayerPosition < _currentSubtitle!.endTime.inMilliseconds;

    return validStartTime && validEndTime;
  }
}
