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
            },

            child: Text(element.date.yyyymmdd),
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
