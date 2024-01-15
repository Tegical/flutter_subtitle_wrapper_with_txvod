import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:subtitle_wrapper_package_with_txvod/bloc/subtitle/subtitle_bloc.dart';
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
    'Subtitle controller',
    () {
      test('attach', () async {
        subtitleController.attach(
          SubtitleBloc(
            subtitleController: subtitleController,
            subtitleRepository: SubtitleDataRepository(
              subtitleController: subtitleController,
            ),
            txVodPlayerController: MockVideoPlayerController(),
          ),
        );
      });
      test('detach', () async {
        subtitleController.detach();
      });

      test('update subtitle url', () async {
        subtitleController
          ..attach(
            SubtitleBloc(
              subtitleController: subtitleController,
              subtitleRepository: SubtitleDataRepository(
                subtitleController: subtitleController,
              ),
              txVodPlayerController: MockVideoPlayerController(),
            ),
          )
          ..updateSubtitleUrl(
            url: 'https://pastebin.com/raw/ZWWAL7fK',
          );
      });

      test('update subtitle content', () async {
        subtitleController
          ..attach(
            SubtitleBloc(
              subtitleController: subtitleController,
              subtitleRepository: SubtitleDataRepository(
                subtitleController: subtitleController,
              ),
              txVodPlayerController: MockVideoPlayerController(),
            ),
          )
          ..updateSubtitleContent(
            content: '',
          );
      });

      test(
        'update subtitle content without attach',
        () {
          expect(
            () {
              subtitleController
                ..detach()
                ..updateSubtitleContent(
                  content: '',
                );
            },
            throwsException,
          );
        },
      );

      test('update subtitle url without attach', () {
        expect(
          () {
            subtitleController
              ..detach()
              ..updateSubtitleUrl(
                url: 'https://pastebin.com/raw/ZWWAL7fK',
              );
          },
          throwsException,
        );
      });
    },
  );
}
