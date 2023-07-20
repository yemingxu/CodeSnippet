import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tongdao/model/coach_exp.dart';
import 'package:tongdao/constants/constants.dart';
import 'package:tongdao/model/judge_exp.dart';
import 'package:tongdao/pages/detail/judge/experience/judge_exp_detail_cell.dart';
import 'package:tongdao/util_widgets/detail_grid_info_view.dart';
import 'package:tongdao/util_widgets/perch/perch.dart';
import 'package:tongdao/util_widgets/toast/toast.dart';
import 'package:tongdao/util_widgets/ui_helper.dart';
import 'judge_exp_logic.dart';

class JudgeExpWidget extends StatelessWidget {
  final int id;
  JudgeExpWidget({required this.id});
  String get _logicTag => id.toString();
  JudgeExpLogic get logic => Get.find<JudgeExpLogic>(tag: _logicTag);

  final titleStyle = const TextStyle(
    color: TdColors.textOpacity65Color,
    fontSize: 12,
    fontFamily: Constants.pingFangSCRegular,
    fontWeight: FontWeight.normal,
  );
  final valueStyle = const TextStyle(
    color: TdColors.textOpacity90Color,
    fontSize: 14,
    fontFamily: Constants.pingFangSCRegular,
    fontWeight: FontWeight.normal,
  );
  final FToast fToast = FToast();

  final List<String> titles = const [
    "职责",
    "赛事",
    "年份",
    "场数",
    "净比赛时间",
    "主/客场胜率",
  ];
  final List<int> titleFlexs = const [
    1,
    2,
    1,
    1,
    2,
    3,
  ];

  List<Widget> _buildRowTexts({required List<String> texts, required bool isTitle}) {
    final TextStyle textStyle = isTitle ? titleStyle : valueStyle;
    return texts.asMap().entries.map((e) {
      final isLast = e.key == (titles.length - 1);
      final Text text = Text(
        e.value,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textStyle,
      );
      return Expanded(
        flex: e.key >= titleFlexs.length ? 1 : titleFlexs[e.key],
        child: (isLast && !isTitle)
            ? Row(
                children: [
                  Expanded(child: text),
                  Padding(
                    padding: EdgeInsets.only(left: 8, right: 16),
                    child: Image.asset("assets/icon/arrow_right.png", width: 5.5),
                  ),
                ],
              )
            : text,
      );
    }).toList();
  }

  // 打开下一页详情
  void onNextForAnExp(BuildContext context, {required JudgeExp exp}) async {
    fToast.showLoading();
    final result = await logic.queryDetailForExp(exp);
    fToast.removeQueuedCustomToasts();
    if (result.isEmpty) {
      fToast.showFail("数据异常");
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) {
          return UIHelper.buildScaffold(
            ctx,
            title: "执法经历详情",
            body: ListView.separated(
              padding: const EdgeInsets.only(top: 16),
              itemCount: result.length,
              separatorBuilder: (_, __) => SizedBox(height: 16),
              itemBuilder: (_, index) {
                final item = result[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UIHelper.buildInfoModuleTitle(title: "${NumberFormat('00').format(index + 1)}"),
                    JudgeExpDetailCell(item: item),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Get.put(JudgeExpLogic(id: id), tag: _logicTag);
    fToast.init(context);

    final safeBottom = MediaQuery.of(context).viewPadding.bottom;

    return GetBuilder(
        global: false,
        init: logic,
        builder: (_) {
          if (logic.isLoading.value) return EasyPerch.loading();
          if (logic.didLoadErr.value)
            return EasyPerch.error(() {
              logic.requestData();
            });
          final isEmpty = logic.expList == null || logic.expList!.isEmpty;
          if (isEmpty) {
            return EasyPerch.emptyData();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              UIHelper.buildInfoModuleTitle(title: "执法经历"),
              Container(
                height: 48,
                color: TdColors.backgroundColor2,
                child: Row(
                  children: _buildRowTexts(texts: titles, isTitle: true),
                ),
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: logic.expList!.length,
                    itemBuilder: (_, index) {
                      final exp = logic.expList![index];
                      final isHighlight = index % 2 == 1;
                      final ratioFormat = NumberFormat("0.#", "en_US");

                      final hostWinRateStr;
                      if (exp.hostWinRate.isEmpty) {
                        hostWinRateStr = "-";
                      } else {
                        hostWinRateStr = ratioFormat.format((double.tryParse(exp.hostWinRate) ?? 0) * 100.0) + "%";
                      }

                      final clientWinRateStr;
                      if (exp.hostWinRate.isEmpty) {
                        clientWinRateStr = "-";
                      } else {
                        clientWinRateStr = ratioFormat.format((double.tryParse(exp.clientWinRate) ?? 0) * 100.0) + "%";
                      }
                      final gameTimeStr;
                      if (exp.gameTime.isEmpty) {
                        gameTimeStr = "-";
                      } else {
                        gameTimeStr = exp.gameTime.replaceAll(".", "′") + "″";
                      }
                      return GestureDetector(
                        child: Container(
                          height: 48,
                          color: isHighlight ? TdColors.backgroundColor2 : TdColors.backgroundColor1,
                          child: Row(
                            children: [
                              ..._buildRowTexts(
                                texts: [
                                  exp.duty == 1 ? "主裁" : "未知",
                                  exp.leagueName,
                                  exp.leagueyear,
                                  exp.gamesession,
                                  gameTimeStr,
                                  "${hostWinRateStr}/${clientWinRateStr}",
                                ],
                                isTitle: false,
                              ),
                            ],
                          ),
                        ),
                        onTap: () => onNextForAnExp(context, exp: exp),
                      );
                    }),
              ),
            ],
          );
        });
  }
}
