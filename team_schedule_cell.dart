import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tongdao/model/competition.dart';
import 'package:tongdao/model/team_schedule_info.dart';
import 'package:tongdao/constants/constants.dart';
import 'package:tongdao/model/highlights.dart';
import 'package:tongdao/util_widgets/ui_helper.dart';
import 'package:tongdao/util_widgets/utils.dart';

DateFormat TeamScheduleCellTopDateFormat = DateFormat("yyyy.MM");
DateFormat TeamScheduleCellDateFormat = DateFormat("MM-dd HH:mm");

class TeamScheduleCell extends StatelessWidget {
  final TeamScheduleInfo info;
  final bool visibleTopBar;
  TeamScheduleCell({
    Key? key,
    required this.info,
    this.visibleTopBar = false,
  }) : super(key: key);

  String get leagueName => info.league ?? "";

  Widget _buildBody(BuildContext context) {
    return Container(
      color: TdColors.backgroundColor4,
      padding: EdgeInsets.only(top: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              "${info.gametime ?? ''} ${leagueName} 第${info.gamesession ?? ""}轮",
              style: const TextStyle(
                color: TdColors.textOpacity45Color,
                fontFamily: Constants.pingFangSCRegular,
                fontSize: 12,
              ),
            ),
          ),

          // 球队
          Row(
            children: [
              // 左侧球队
              Expanded(
                child: _buildTeamNameAndPic(isLeft: true),
              ),
              // 比分(已开始、已结束) or 比赛时间(未开始)
              Container(
                width: 80,
                alignment: Alignment.center,
                child: Text(
                  "${info.gamescore != null && info.gamescore!.isNotEmpty ? info.gamescore : "-"}",
                  style: TextStyle(
                    color: TdColors.textColor,
                    fontFamily: Constants.dinMedium,
                    fontSize: 22,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 右侧球队
              Expanded(
                child: _buildTeamNameAndPic(isLeft: false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 球队名称和图像
  Widget _buildTeamNameAndPic({required bool isLeft}) {
    final CachedNetworkImage teamPicWidget = CachedNetworkImage(
      imageUrl: isLeft ? (info.hostlogo ?? "") : (info.clientlogo ?? ""),
      placeholder: (_, __) => Image.asset("assets/icon/football_club.png"),
      errorWidget: (_, __, ___) => Image.asset("assets/icon/football_club.png"),
      width: 30,
      height: 30,
    );
    final Widget teamNameWidget = Expanded(
      child: Text(
        isLeft ? (info.hostteam ?? "-") : (info.clientteam ?? "-"),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: isLeft ? TextAlign.end : TextAlign.start,
        style: const TextStyle(
          color: TdColors.textOpacity90Color,
          fontSize: 14,
          fontFamily: Constants.pingFangSCRegular,
        ),
      ),
    );

    final sp = const SizedBox(width: 8);

    return Row(
      mainAxisAlignment: isLeft ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: isLeft ? [teamNameWidget, sp, teamPicWidget] : [teamPicWidget, sp, teamNameWidget],
    );
  }

  /// 头部
  Widget _buildTopBar() {
    final String gameTimeStr;
    if (info.gametime != null) {
      final day = info.gametime!.split(" ").first;
      final dayComponents = day.split("-");
      final monthComponents = dayComponents.sublist(0, 2);
      gameTimeStr = monthComponents.join("-");
    } else {
      gameTimeStr = '';
    }
    return UIHelper.buildInfoModuleTitle(title: gameTimeStr);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 0, right: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (visibleTopBar == true) _buildTopBar(),
          _buildBody(context),
        ],
      ),
    );
  }
}
