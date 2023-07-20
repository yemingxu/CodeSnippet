import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tongdao/model/goal.dart';
import 'package:tongdao/model/skill.dart';
import 'package:tongdao/constants/constants.dart';
import 'package:tongdao/util_widgets/video_player/video_player_logic.dart';
import 'package:tongdao/util_widgets/video_player/video_player_widget.dart';

class SkillVideoWidget extends StatefulWidget {
  // 是否展开
  final bool isExpansion;
  final Function() onExpand;
  final Function()? didExpanded;
  final String name;
  final String skillName;
  final SkillVideo data;
  SkillVideoWidget({
    required this.name,
    required this.isExpansion,
    required this.onExpand,
    required this.skillName,
    required this.data,
    this.didExpanded,
  }) : super(key: ValueKey(data.videourl));

  @override
  State<StatefulWidget> createState() => SkillVideoWidgetState();
}

class SkillVideoWidgetState extends State<SkillVideoWidget> with SingleTickerProviderStateMixin {
  bool get isExpansion => widget.isExpansion;
  Function() get onExpand => widget.onExpand;
  String get name => widget.name;
  String get skillName => widget.skillName;
  SkillVideo get data => widget.data;

  String get videoDurationString => "${widget.data.videoTime}";
  String get snapshoot => widget.data.videoPreviewUrl;
  String get videoUrlString => widget.data.videourl;

  String get gameTimeString => widget.data.gametime;
  String get score => widget.data.score;

  //
  static double defaultPaddingLR = 16;
  static double defaultThumbnailWidth = 142;
  static double defaultThumbnailHeight = 80;
  static double expansionVideoAspectRatio = 375.0 / 210.0;
  Size get expansionVideoSize => Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.width / expansionVideoAspectRatio,
      );
  static double expansionBottomHeight = 71;

  late AnimationController _animationController;
  @override
  void initState() {
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    super.initState();
    if (isExpansion) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // 默认(收起)状态 - 缩略图+视频时长
  Widget _buildDefaultThumbnail({double? width, double? height}) => ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: [
            // 视频缩略图
            CachedNetworkImage(
              imageUrl: snapshoot,
              width: width ?? defaultThumbnailWidth,
              height: height ?? defaultThumbnailHeight,
              fit: BoxFit.fill,
              errorWidget: (_, __, ___) => Container(color: TdColors.backgroundColor2),
              placeholder: (_, __) => Container(color: TdColors.backgroundColor2),
            ),
            // 视频时长
            if (videoDurationString.trim().isNotEmpty)
              Positioned(
                right: 8,
                bottom: 5,
                child: Container(
                  height: 12,
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 4, right: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    videoDurationString,
                    style: TextStyle(
                      color: TdColors.textOpacity90Color,
                      fontSize: 10,
                      fontFamily: Constants.dinRegular,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );

  // 已展开状态 - 视频 + 时长
  Widget _buildExpansionVideo() => AspectRatio(
        aspectRatio: expansionVideoAspectRatio,
        child: VideoPlayer(
          url: videoUrlString,
          snapshoot: snapshoot,
          durationWidget: videoDurationString.trim().isNotEmpty
              ? Container(
                  height: 16,
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 8, right: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    videoDurationString,
                    style: const TextStyle(
                      color: TdColors.textOpacity90Color,
                      fontSize: 12,
                      fontFamily: Constants.dinRegular,
                    ),
                  ),
                )
              : null,
        ),
      );

  Widget _buildDefaultTexts() => SizedBox(
        height: defaultThumbnailHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$skillName ${data.time}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: TdColors.textOpacity90Color,
                fontSize: 17,
                fontFamily: Constants.pingFangSCRegular,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            Text(
              "${data.hostteam} $score ${data.clientteam}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: TdColors.textOpacity65Color,
                fontSize: 14,
                fontFamily: Constants.pingFangSCRegular,
                fontWeight: FontWeight.normal,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "$gameTimeString ${data.leagueid} 第${data.gamesession}轮",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: TdColors.textOpacity65Color,
                fontSize: 14,
                fontFamily: Constants.pingFangSCRegular,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      );

  Widget _buildExpansionTextsContainer({Widget? child, required double height}) => Container(
        height: height,
        color: TdColors.backgroundColor2,
        padding: const EdgeInsets.only(left: 16, right: 16),
        alignment: Alignment.centerLeft,
        child: child,
      );

  Widget _buildExpansionTexts() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$name $skillName ${data.time}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: TdColors.textOpacity90Color,
              fontSize: 17,
              fontFamily: Constants.pingFangSCRegular,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 3),
          Text(
            "$gameTimeString ${data.leagueid}第${data.gamesession}轮 ${data.hostteam} ${score} ${data.clientteam}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: TdColors.textOpacity65Color,
              fontSize: 14,
              fontFamily: Constants.pingFangSCRegular,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _animationController,
        builder: (_, __) {
          final animation = _animationController;
          // 0-0.1 隐藏收起状态的文本
          if (animation.value <= 0.2) {
            final double opacity = (1.0 - (animation.value - 0.0) / 0.2);

            return GestureDetector(
              child: Container(
                // width: double.infinity,
                // padding: EdgeInsets.only(left: defaultPaddingLR, right: defaultPaddingLR),
                // height: 250,
                child: Row(
                  children: [
                    SizedBox(width: defaultPaddingLR),
                    // 缩略图+视频时长
                    _buildDefaultThumbnail(),

                    SizedBox(width: 16),
                    // 文本信息
                    Expanded(
                      child: Opacity(opacity: opacity, child: _buildDefaultTexts()),
                    ),

                    SizedBox(width: defaultPaddingLR),
                  ],
                ),
              ),
              behavior: HitTestBehavior.opaque,
              onTap: animation.value == 0 ? onExpand : null,
            );
          } else if (animation.value <= 0.8) {
            // 0.2-0.8 高度变换的过程
            // 缩略图展开至视频位置 + 底部文本容器
            final stepValue = (animation.value - 0.2) / (0.8 - 0.2);
            final videoSize = expansionVideoSize;
            final stepThumbnailWidth = (videoSize.width - defaultThumbnailWidth) * stepValue + defaultThumbnailWidth;
            final stepThumbnailHeight =
                (videoSize.height - defaultThumbnailHeight) * stepValue + defaultThumbnailHeight;
            return Container(
              // color: TdColors.backgroundColor2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 视频 + 时长
                  Padding(
                    padding: EdgeInsets.only(left: defaultPaddingLR * (1.0 - stepValue)),
                    child: _buildDefaultThumbnail(width: stepThumbnailWidth, height: stepThumbnailHeight),
                  ),

                  // 文本信息
                  SizedBox(height: expansionBottomHeight * stepValue),
                  // _buildExpansionTextsContainer(height: expansionBottomHeight * stepValue),
                ],
              ),
            );
          } else {
            final stepValue = (animation.value - 0.8) / (1.0 - 0.8);
            return Container(
              // color: TdColors.backgroundColor2,
              child: Column(
                children: [
                  // 视频 + 时长
                  _buildExpansionVideo(),

                  // 文本信息
                  Opacity(
                    opacity: stepValue,
                    child: _buildExpansionTextsContainer(
                      child: _buildExpansionTexts(),
                      height: expansionBottomHeight,
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }

  @override
  void didUpdateWidget(covariant SkillVideoWidget oldWidget) {
    final needAnimation = oldWidget.isExpansion != isExpansion;
    super.didUpdateWidget(oldWidget);
    if (!needAnimation) return;

    _startAnimation();
  }

  void _startAnimation() async {
    if (isExpansion) {
      await _animationController.forward(from: 0.0);
      Future.delayed(Duration(milliseconds: 200), () {
        if (_animationController.isAnimating) return;
        if (_animationController.isCompleted == false) return;

        final VideoPlayerLogic videoPlayerLogic = VideoPlayerLogicForURL(data.videourl);
        videoPlayerLogic.onPlay();
      });
    } else {
      _animationController.reverse(from: 1.0);
    }
  }
}
