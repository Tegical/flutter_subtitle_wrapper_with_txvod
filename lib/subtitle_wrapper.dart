import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:subtitle_wrapper_package_with_txvod/bloc/subtitle/subtitle_bloc.dart';
import 'package:subtitle_wrapper_package_with_txvod/subtitle_wrapper_package.dart';
import 'package:super_player/super_player.dart';

class SubtitleWrapper extends StatelessWidget {
  const SubtitleWrapper({
    required this.videoChild,
    required this.subtitleController,
    required this.videoPlayerController,
    super.key,
    this.subtitleStyle = const SubtitleStyle(),
    this.backgroundColor,
  });

  final Widget videoChild;
  final SubtitleController subtitleController;
  final TXVodPlayerController videoPlayerController;
  final SubtitleStyle subtitleStyle;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        videoChild,
        if (subtitleController.showSubtitles)
          Positioned(
            top: subtitleStyle.position.top,
            bottom: subtitleStyle.position.bottom,
            left: subtitleStyle.position.left,
            right: subtitleStyle.position.right,
            child: BlocProvider(
              create: (context) => SubtitleBloc(
                txVodPlayerController: videoPlayerController,
                subtitleRepository: SubtitleDataRepository(
                  subtitleController: subtitleController,
                ),
                subtitleController: subtitleController,
              )..add(
                  InitSubtitles(
                    subtitleController: subtitleController,
                  ),
                ),
              child: SubtitleTextView(
                subtitleStyle: subtitleStyle,
                backgroundColor: backgroundColor,
              ),
            ),
          )
        else
          Container(),
      ],
    );
  }
}
