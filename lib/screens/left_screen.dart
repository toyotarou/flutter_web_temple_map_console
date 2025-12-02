import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/controllers_mixin.dart';
import '../extensions/extensions.dart';
import '../models/temple_model.dart';

class LeftScreen extends ConsumerStatefulWidget {
  const LeftScreen({super.key});

  @override
  ConsumerState<LeftScreen> createState() => _LeftScreenState();
}

class _LeftScreenState extends ConsumerState<LeftScreen> with ControllersMixin<LeftScreen> {
  ///
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(children: <Widget>[Expanded(child: displayTempleVisitedDateList())]),
    );
  }

  ///
  Widget displayTempleVisitedDateList() {
    final List<Widget> list = <Widget>[];

    for (final TempleModel element in getDataState.keepTempleList) {
      list.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              appParamNotifier.setIsMapCenterMove(flag: false);

              appParamNotifier.setSelectedDate(date: element.date.yyyymmdd);

              appParamNotifier.setSelectedSpotDataModel();
            },

            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: (appParamState.selectedDate == element.date.yyyymmdd)
                      ? Colors.yellowAccent.withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.2),
                ),

                borderRadius: BorderRadius.circular(10),
              ),

              padding: const EdgeInsets.all(5),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(element.date.yyyymmdd),
                  Text(element.temple),

                  if (element.memo != '') ...<Widget>[Text(element.memo, style: const TextStyle(color: Colors.grey))],
                ],
              ),
            ),
          ),
        ),
      );
    }

    return CustomScrollView(
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) => list[index],
            childCount: list.length,
          ),
        ),
      ],
    );
  }
}
