import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tongdao/model/competition.dart';
import 'package:tongdao/model/team.dart';
import 'package:tongdao/constants/constants.dart';
import 'package:tongdao/model/team_schedule_info.dart';
import 'package:tongdao/pages/detail/competition/competition_detail_page.dart';
import 'package:tongdao/pages/detail/team/schedule/team_schedule_cell.dart';
import 'package:tongdao/util_widgets/dialog.dart';
import 'package:tongdao/util_widgets/perch/perch.dart';
import 'package:tongdao/util_widgets/ui_helper.dart';

import 'team_schedule_logic.dart';

class TeamScheduleWidget extends StatelessWidget {
  TeamScheduleLogic get logic => Get.find<TeamScheduleLogic>(tag: teamCode);
  final String teamCode;
  const TeamScheduleWidget({required this.teamCode});

  /// 选择赛季
  void onPickLeagueYears(BuildContext context) {
    TdDialog.onGeneralSheetPick(
      context,
      title: "选择赛季",
      list: logic.yearLeagues.map((e) => e.leagueYear).toList(),
      onValue: (index) {
        logic.onPickLeagueYears(logic.yearLeagues[index]);
      },
    );
  }

  /// 选择赛事
  void onPickLeagueItems(BuildContext context) {
    if (logic.pickedLeagueYear.value == null) return;
    TdDialog.onGeneralListPick(
      context,
      title: "选择赛事",
      list: logic.pickedLeagueYear.value!.leagueList.map((e) => e.leagueName).toList(),
      onValue: (index) {
        logic.onPickLeagueItems(logic.pickedLeagueYear.value!.leagueList[index]);
      },
    );
  }

  /// 打开比赛详情
  void onOpenGameDetail(BuildContext context, {required TeamScheduleInfo info}) {
    if (info.gameid == null || info.gamescore == null || info.gamescore!.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return CompetitionDetailPage(info.gameid!);
        },
      ),
    );
  }

  bool _isVisibleTopBar({required int index}) {
    if (index >= logic.scheduleList.length) return false;

    final schedule = logic.scheduleList[index];
    bool visibleTopBar = true;
    if (index > 0) {
      final last_schedule = logic.scheduleList[index - 1];
      if (schedule.gametime != null && last_schedule.gametime != null) {
        final l = schedule.gametime!.split(" ").first;
        final r = last_schedule.gametime!.split(" ").first;
        final l_components = l.split("-");
        final r_components = r.split("-");
        if (l_components.length != 3 || r_components.length != 3) {
          visibleTopBar = false;
        } else {
          visibleTopBar = (l_components[0] != r_components[0] || l_components[1] != r_components[1]);
        }
      }
    }
    return visibleTopBar;
  }

  @override
  Widget build(BuildContext context) {
    Get.put(TeamScheduleLogic(teamCode: teamCode), tag: teamCode);

    final double safeBottom = MediaQuery.of(context).viewPadding.bottom;

    return GetBuilder(
        global: false,
        init: logic,
        builder: (_) {
          if (logic.isInitLoading.value) {
            return EasyPerch.loading();
          }
          if (logic.didInitData == false) {
            return EasyPerch.error(() {
              logic.requestData();
            });
          }
          return Column(
            children: [
              // 赛季+赛事选择
              Container(
                height: 68,
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Obx(() {
                  return Row(
                    children: [
                      Expanded(
                        child: UIHelperLeague.buildPickLeagueYear(
                          value: logic.pickedLeagueYear.value?.leagueYear ?? "",
                          onTap: () => onPickLeagueYears(context),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: UIHelperLeague.buildPickLeagueName(
                          value: logic.pickedLeagueItem.value?.leagueName ?? "",
                          onTap: () => onPickLeagueItems(context),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              Expanded(
                child: Obx(() {
                  if (logic.isLoading.value) return EasyPerch.loading();
                  if (logic.isErrorRequest.value) {
                    return EasyPerch.error(() {
                      logic.requestData();
                    });
                  }
                  return ListView.separated(
                    padding: EdgeInsets.only(top: 8, bottom: safeBottom > 0 ? safeBottom : 20),
                    itemBuilder: (_, index) {
                      final schedule = logic.scheduleList[index];
                      return GestureDetector(
                        child: TeamScheduleCell(
                          info: schedule,
                          visibleTopBar: _isVisibleTopBar(index: index),
                        ),
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onOpenGameDetail(context, info: schedule),
                      );
                    },
                    separatorBuilder: (_, index) {
                      if (_isVisibleTopBar(index: index + 1)) {
                        return Container(height: 16);
                      }
                      return Container(height: 1, color: TdColors.spColor);
                    },
                    itemCount: logic.scheduleList.length,
                  );
                }),
              ),
            ],
          );
        });
  }
}
