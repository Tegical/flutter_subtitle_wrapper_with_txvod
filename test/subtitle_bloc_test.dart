import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:subtitle_wrapper_package_with_txvod/bloc/subtitle/subtitle_bloc.dart';
import 'package:subtitle_wrapper_package_with_txvod/data/models/subtitle.dart';
import 'package:subtitle_wrapper_package_with_txvod/data/repository/subtitle_repository.dart';
import 'package:subtitle_wrapper_package_with_txvod/subtitle_controller.dart';
import 'package:super_player/super_player.dart';

class MockVideoPlayerController extends Mock implements TXVodPlayerController {}

void main() {
  final subtitleController = SubtitleController(
    subtitleUrl: 'https://pastebin.com/raw/ZWWAL7fK',
    subtitleDecoder: SubtitleDecoder.utf8,
  );

  group(
    'Subtitle BLoC',
    () {
      blocTest<SubtitleBloc, SubtitleState>(
        'subtitle init',
        build: () => SubtitleBloc(
          subtitleController: subtitleController,
          subtitleRepository: SubtitleDataRepository(
            subtitleController: subtitleController,
          ),
          txVodPlayerController: MockVideoPlayerController(),
        ),
        act: (SubtitleBloc bloc) => bloc.add(
          InitSubtitles(
            subtitleController: subtitleController,
          ),
        ),
        expect: () => [
          SubtitleInitializing(),
        ],
      );
      blocTest<SubtitleBloc, SubtitleState>(
        'subtitle update',
        build: () => SubtitleBloc(
          subtitleController: subtitleController,
          subtitleRepository: SubtitleDataRepository(
            subtitleController: subtitleController,
          ),
          txVodPlayerController: MockVideoPlayerController(),
        ),
        act: (SubtitleBloc bloc) => bloc.add(
          UpdateLoadedSubtitle(
            subtitle: const Subtitle(
              startTime: Duration.zero,
              endTime: Duration(
                seconds: 10,
              ),
              text: 'test',
            ),
          ),
        ),
        expect: () => [
          const LoadedSubtitle(
            Subtitle(
              startTime: Duration.zero,
              endTime: Duration(
                seconds: 10,
              ),
              text: 'test',
            ),
          ),
        ],
      );

      blocTest<SubtitleBloc, SubtitleState>(
        'subtitle load',
        build: () => SubtitleBloc(
          subtitleController: subtitleController,
          subtitleRepository: SubtitleDataRepository(
            subtitleController: subtitleController,
          ),
          txVodPlayerController: MockVideoPlayerController(),
        ),
        act: (SubtitleBloc bloc) {
          bloc.txVodPlayerController.notifyListeners();
          return bloc.add(
            LoadSubtitle(),
          );
        },
        expect: () => [
          LoadingSubtitle(),
        ],
      );
    },
  );
}
