import 'dart:math';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:tongdao/model/team.dart';
import 'package:tongdao/model/team_overview.dart';
import 'package:tongdao/constants/constants.dart';
import 'package:tongdao/constants/types.dart';
import 'package:tongdao/pages/detail/coach/coach_detail_page.dart';
import 'package:tongdao/pages/detail/team/overview/team_overview_logic.dart';
import 'package:tongdao/util_widgets/charts/hexagonal_chart.dart';
import 'package:tongdao/util_widgets/charts/round_percent_widget.dart';
import 'package:tongdao/util_widgets/dialog.dart';
import 'package:tongdao/util_widgets/fourfold_widget.dart';
import 'package:tongdao/util_widgets/perch/perch.dart';
import 'package:tongdao/util_widgets/ui_helper.dart';

class TeamOverviewWidget extends StatelessWidget {
  TeamOverviewLogic get logic => Get.find<TeamOverviewLogic>(tag: teamCode);
  final String teamCode;
  TeamOverviewWidget({required this.teamCode});

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

  List<TeamDeepData> getDeepDatas({required int index}) {
    List<TeamDeepData> deepDatas = [];
    if (index == 0) {
      deepDatas = logic.aDeepDatas;
    } else if (index == 1) {
      deepDatas = logic.bDeepDatas;
    } else if (index == 2) {
      deepDatas = logic.cDeepDatas;
    }
    return deepDatas;
  }

  List<String> dataSetTitles({required int index}) {
    List<TeamDeepData> deepDatas = getDeepDatas(index: index);
    return deepDatas.map((e) => "${e.name}" + (e.rank == null ? "" : "(${e.rank})")).toList();
  }

  List<HexagonalChartDataSet> dataSets({required int index}) {
    List<TeamDeepData> deepDatas = getDeepDatas(index: index);
    final noClub = deepDatas.where((element) => element.data == null).length > 0;
    return [
      if (!noClub)
        HexagonalChartDataSet(
          title: '俱乐部值',
          color: TdColors.chartColor1,
          values: deepDatas.map((e) => e.data?.toDouble() ?? 0).toList(),
        ),
      HexagonalChartDataSet(
        title: '平均值',
        color: TdColors.chartColor2,
        values: deepDatas.map((e) => e.avgData?.toDouble() ?? 0).toList(),
      ),
    ];
  }

  /// 构建主教练
  Widget _buildCoach() {
    final topLeftItem = FourfoldItem(title: "姓名", value: logic.coachName);
    final topRightItem = FourfoldItem(title: "执教时间", value: logic.teachTime);
    final bottomLeftItem = FourfoldItem(title: "等级", value: logic.coachLevelString);
    final bottomRightItem = FourfoldItem(
      title: "生涯胜率",
      customValue: IntrinsicHeight(
        child: Column(
          children: [
            Text(
              logic.winRateString,
              style: TextStyle(
                color: TdColors.themeColor,
                fontSize: 12,
                fontFamily: Constants.pingFangSCRegular,
                fontWeight: FontWeight.normal,
              ),
            ),
            SizedBox(height: 4),
            FractionallySizedBox(
              widthFactor: 1.0,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: TdColors.borderColor.withOpacity(0.25),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: logic.winRateProgress,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: TdColors.themeColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomRight: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );

    return FourfoldWidget(
      picUrl: logic.coachLogo,
      topLeftItem: topLeftItem,
      topRightItem: topRightItem,
      bottomLeftItem: bottomLeftItem,
      bottomRightItem: bottomRightItem,
    );
  }

  Widget _buildSeparateLine({double? width = 1, double? height = 77}) {
    return Container(color: Colors.white.withOpacity(0.07), height: height, width: width);
  }

  /// 构建近期数据
  Widget _buildRecentData() {
    // 文本信息
    Widget _buildTextItem({required String title, required String value}) {
      return Container(
        height: 77,
        padding: EdgeInsets.only(top: 16, bottom: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: TdColors.textOpacity90Color,
                fontSize: 17,
                fontFamily: Constants.pingFangSCRegular,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: TdColors.textOpacity65Color,
                fontSize: 12,
                fontFamily: Constants.pingFangSCRegular,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    // 圆环进度
    Widget _buildCircleItem({
      required String title,
      required double value,
      required Color color,
    }) {
      return Container(
        height: 121,
        padding: EdgeInsets.only(top: 16, bottom: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RoundPercentWidget(
              percent: value,
              size: 60,
              strokeWidth: 5,
              fontSize: 17,
              color: color,
            ),
            Text(
              title,
              style: TextStyle(
                color: TdColors.textOpacity65Color,
                fontSize: 12,
                fontFamily: Constants.pingFangSCRegular,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    // 近五场比赛结果
    Widget _buildCompetitionResult({required CompetitionResultType type}) {
      final String text = type.text();
      final Color color;
      switch (type) {
        case CompetitionResultType.win:
          color = TdColors.competitionResultWinColor;
          break;
        case CompetitionResultType.flat:
          color = TdColors.competitionResultFlatColor;
          break;
        case CompetitionResultType.lose:
          color = TdColors.competitionResultLoseColor;
          break;
      }
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: TdColors.textOpacity90Color,
            fontSize: 16,
            fontFamily: Constants.pingFangSCRegular,
            fontWeight: FontWeight.normal,
          ),
        ),
      );
    }

    return Container(
      // width: double.infinity,
      color: TdColors.backgroundColor4,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Obx(() => _buildTextItem(
                      title: "参加赛事",
                      value:
                          "${logic.pickedLeagueYear.value!.leagueYear}赛季 ${logic.pickedLeagueItem.value!.leagueName}",
                    )),
              ),
              _buildSeparateLine(),
              Expanded(
                child: _buildTextItem(title: "积分/排名", value: logic.pointsAndRanking),
              ),
            ],
          ),
          _buildSeparateLine(height: 1, width: null),
          Row(
            children: [
              Expanded(
                child: _buildTextItem(title: "参赛场次", value: logic.numberOfEntries),
              ),
              _buildSeparateLine(),
              Expanded(
                child: _buildTextItem(title: "胜平负", value: logic.winLoseAndFlat),
              ),
              _buildSeparateLine(),
              Expanded(
                child: _buildTextItem(title: "进失球", value: logic.goalAndLoseBall),
              ),
            ],
          ),
          _buildSeparateLine(height: 1, width: null),
          // 近五场比赛结果
          if (logic.nearlyFiveGameResultTypes.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: logic.nearlyFiveGameResultTypes.map((e) => _buildCompetitionResult(type: e)).toList(),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "近五场比赛",
                    style: TextStyle(
                      color: TdColors.textOpacity65Color,
                      fontSize: 12,
                      fontFamily: Constants.pingFangSCRegular,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          if (logic.nearlyFiveGameResultTypes.isNotEmpty) _buildSeparateLine(height: 1, width: null),
          Row(
            children: [
              Expanded(
                child: _buildCircleItem(title: "主场胜率", value: logic.hostWinLv, color: TdColors.chartColor1),
              ),
              _buildSeparateLine(height: 121),
              Expanded(
                child: _buildCircleItem(title: "客场胜率", value: logic.clientwinlv, color: TdColors.chartColor2),
              ),
              _buildSeparateLine(height: 121),
              Expanded(
                child: _buildCircleItem(title: "综合胜率", value: logic.winLv, color: TdColors.chartColor3),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 打开教练员详情
  void onCoachDetail(BuildContext context) {
    final name = logic.recent?.teamInfo.coachModel?.name;
    final id = logic.recent?.teamInfo.coachModel?.id;
    if (id == null || name == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return CoachDetailPage(
            name: name!,
            id: id!,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Get.put(TeamOverviewLogic(teamCode: teamCode), tag: teamCode);

    return GetBuilder(
      global: false,
      init: logic,
      builder: (_) {
        if (logic.isLoading.value) {
          return EasyPerch.loading();
        }
        if (logic.isErrorRequest.value) {
          return EasyPerch.error(() {
            logic.requestData();
          });
        }
        return SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
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
                SizedBox(height: 8),
                // 主教练
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UIHelper.buildInfoModuleTitle(title: "主教练"),
                    GestureDetector(
                      child: _buildCoach(),
                      onTap: () => onCoachDetail(context),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // 近期数据
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UIHelper.buildInfoModuleTitle(title: "近期数据"),
                    _buildRecentData(),
                  ],
                ),
                SizedBox(height: 16),
                // 能力分析
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UIHelper.buildInfoModuleTitle(title: "能力分析"),
                    Container(
                      color: TdColors.backgroundColor4,
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: dataSets(index: 0).buildTitleListWidget(),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 45, bottom: 45),
                            child: HexagonalChart(
                              size: 190,
                              titles: dataSetTitles(index: 0),
                              dataSets: dataSets(index: 0),
                            ),
                          ),
                          _buildSeparateLine(width: null, height: 1),
                          Padding(
                            padding: EdgeInsets.only(top: 45, bottom: 45),
                            child: HexagonalChart(
                              size: 190,
                              titles: dataSetTitles(index: 1),
                              dataSets: dataSets(index: 1),
                            ),
                          ),
                          _buildSeparateLine(width: null, height: 1),
                          Padding(
                            padding: EdgeInsets.only(top: 45, bottom: 45),
                            child: HexagonalChart(
                              size: 190,
                              titles: dataSetTitles(index: 2),
                              dataSets: dataSets(index: 2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
