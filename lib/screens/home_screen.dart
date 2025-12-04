import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/controllers_mixin.dart';
import '../extensions/extensions.dart';
import '../models/municipal_model.dart';
import '../models/station_model.dart';
import '../models/temple_lat_lng_model.dart';
import '../models/temple_list_model.dart';
import '../models/temple_model.dart';
import 'left_screen.dart';
import 'right_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    required this.templeList,
    required this.templeLatLngList,
    required this.templeLatLngMap,
    required this.stationMap,
    required this.tokyoMunicipalList,
    required this.tokyoMunicipalMap,
    required this.templeListMap,
    required this.templeListList,
    required this.templeListNavitimeMap,
  });

  final List<TempleModel> templeList;
  final List<TempleLatLngModel> templeLatLngList;
  final Map<String, TempleLatLngModel> templeLatLngMap;
  final Map<String, StationModel> stationMap;
  final List<MunicipalModel> tokyoMunicipalList;
  final Map<String, MunicipalModel> tokyoMunicipalMap;
  final Map<String, TempleListModel> templeListMap;
  final List<TempleListModel> templeListList;
  final Map<String, TempleListModel> templeListNavitimeMap;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with ControllersMixin<HomeScreen> {
  List<List<List<List<double>>>>? allPolygons = <List<List<List<double>>>>[];

  ///
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getDataNotifier.setKeepTempleList(list: widget.templeList);
      getDataNotifier.setKeepTempleLatLngList(list: widget.templeLatLngList);
      getDataNotifier.setKeepTempleLatLngMap(map: widget.templeLatLngMap);
      getDataNotifier.setKeepStationMap(map: widget.stationMap);
      getDataNotifier.setKeepTokyoMunicipalList(list: widget.tokyoMunicipalList);
      getDataNotifier.setKeepTokyoMunicipalMap(map: widget.tokyoMunicipalMap);
      getDataNotifier.setKeepTempleListMap(map: widget.templeListMap);
      getDataNotifier.setKeepTempleListList(list: widget.templeListList);
      getDataNotifier.setKeepTempleListNavitimeMap(map: widget.templeListNavitimeMap);

      /////////////////////////////////

      final Set<String> existingTempleNames = widget.templeLatLngList.map((TempleLatLngModel e) => e.temple).toSet();

      final List<TempleListModel> filteredNotVisitTempleList = widget.templeListList
          .where((TempleListModel temple) => !existingTempleNames.contains(temple.name))
          .toList();

      getDataNotifier.setKeepFilteredNotVisitTempleList(list: filteredNotVisitTempleList);

      /////////////////////////////////

      for (final MunicipalModel element in widget.tokyoMunicipalList) {
        allPolygons?.addAll(element.polygons);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: <Widget>[
            Container(
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: Colors.white, width: 5)),
              ),

              width: context.screenSize.width * 0.2,
              child: const LeftScreen(),
            ),

            Expanded(child: RightScreen(allPolygons: allPolygons)),
          ],
        ),
      ),
    );
  }
}
