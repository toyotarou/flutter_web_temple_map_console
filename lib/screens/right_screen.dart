import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../controllers/controllers_mixin.dart';
import '../extensions/extensions.dart';
import '../models/common/spot_data_model.dart';
import '../models/temple_lat_lng_model.dart';
import '../models/temple_list_model.dart';
import '../models/temple_model.dart';
import '../utility/daily_spot_data_functions.dart';
import '../utility/map_functions.dart';
import '../utility/utility.dart';

///////////////////////////////////////////////////////////////////////

class RightScreen extends ConsumerStatefulWidget {
  const RightScreen({super.key, this.allPolygons});

  final List<List<List<List<double>>>>? allPolygons;

  @override
  ConsumerState<RightScreen> createState() => _RightScreenState();
}

class _RightScreenState extends ConsumerState<RightScreen> with ControllersMixin<RightScreen> {
  final MapController mapController = MapController();

  double? currentZoom;
  double currentZoomEightTeen = 15;

  List<SpotDataModel> selectedSpotDataModelList = <SpotDataModel>[];
  List<Marker> templeMarkerList = <Marker>[];
  List<Marker> selectedSpotDataModelMarkerList = <Marker>[];

  Utility utility = Utility();

  static const double _cellWidth = 120;
  static const double _collapsedHeight = 70;
  static const double _expandedHeight = 260;
  static const double _buttonHeight = 40;

  ///
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext contest, BoxConstraints constraints) {
        final Size _ = MediaQuery.of(context).size;

        final List<TempleModel> templeList = getDataState.keepTempleList;
        final List<_TimelineItem> timelineItems = _buildTimelineItems(templeList);

        final bool isNarrow = constraints.maxWidth < 900;

        debugPrint(
          'RightScreen Layout: maxW=${constraints.maxWidth}, '
          'isNarrow=$isNarrow, '
          'templeList.len=${templeList.length}, '
          'timelineItems.len=${timelineItems.length}',
        );

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!appParamState.isMapCenterMove) {
            moveMapCenterPosition(isNarrow: isNarrow);
          }
        });

        return SafeArea(
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(35.718532, 139.586639),
                    initialZoom: currentZoomEightTeen,
                    onPositionChanged: (MapCamera position, bool isMoving) {
                      if (isMoving) {
                        appParamNotifier.setCurrentZoom(zoom: position.zoom);
                      }
                    },
                  ),
                  children: <Widget>[
                    TileLayer(urlTemplate: 'https://cyberjapandata.gsi.go.jp/xyz/pale/{z}/{x}/{y}.png'),
                    // ignore: always_specify_types
                    if (widget.allPolygons != null) ...<Widget>[PolygonLayer(polygons: makeAreaPolygons())],
                    // ignore: always_specify_types
                    PolylineLayer(polylines: makeDateRoutePolyline()),
                    if (selectedSpotDataModelMarkerList.isNotEmpty)
                      MarkerLayer(markers: selectedSpotDataModelMarkerList),
                    if (templeMarkerList.isNotEmpty) MarkerLayer(markers: templeMarkerList),
                  ],
                ),
              ),

              Positioned(
                top: 10,
                right: 10,
                left: 10,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: double.infinity,
                  constraints: BoxConstraints(maxHeight: isNarrow ? 150 : 180),
                  padding: const EdgeInsets.all(10),
                  child: DefaultTextStyle(
                    style: TextStyle(fontSize: isNarrow ? 12 : 20, color: Colors.white),
                    child: _buildTopInfoBox(isNarrow),
                  ),
                ),
              ),

              if (appParamState.selectedDate != '') ...<Widget>[
                Positioned(
                  top: 150,
                  right: 20,
                  child: Row(
                    children: <String>['S', 'A', 'B', 'C'].map((String e) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: GestureDetector(
                          onTap: () {
                            appParamNotifier.setDisplayTempleRankList(rank: e);
                            makeTempleMarkerList(isNarrow: isNarrow);
                          },
                          child: CircleAvatar(
                            backgroundColor: (appParamState.displayTempleRankList.contains(e))
                                ? Colors.orangeAccent.withValues(alpha: 0.6)
                                : Colors.redAccent.withValues(alpha: 0.6),
                            child: Text(e, style: const TextStyle(color: Colors.white)),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],

              if (isNarrow && timelineItems.isNotEmpty) ...<Widget>[
                Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: SizedBox(
                    height: _expandedHeight,
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        dragDevices: <PointerDeviceKind>{
                          PointerDeviceKind.touch,
                          PointerDeviceKind.mouse,
                          PointerDeviceKind.trackpad,
                        },
                      ),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: timelineItems.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (BuildContext context, int index) {
                          final _TimelineItem item = timelineItems[index];

                          if (item is _YearHeaderItem) {
                            return SizedBox(
                              width: _cellWidth * 0.8,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  height: _collapsedHeight,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(border: Border.all(width: 2), color: Colors.grey.shade300),
                                  child: Text(
                                    '${item.year} 年',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            );
                          }

                          final TempleModel temple = (item as _TempleItem).temple;

                          return SizedBox(
                            width: _cellWidth,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: _TempleCell(
                                temple: temple,
                                width: _cellWidth,
                                collapsedHeight: _collapsedHeight,
                                expandedHeight: _expandedHeight,
                                buttonHeight: _buttonHeight,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
              if (isNarrow && timelineItems.isEmpty) ...<Widget>[
                Positioned(
                  bottom: 40,
                  left: 10,
                  right: 10,
                  child: Container(
                    color: Colors.red.withValues(alpha: 0.7),
                    padding: const EdgeInsets.all(4),
                    child: const Text(
                      'templeList が空なので、タイムラインを表示するデータがありません',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  ///
  Widget _buildTopInfoBox(bool isNarrow) {
    if (appParamState.selectedSpotDataModel != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[SelectableText(appParamState.selectedSpotDataModel!.name)],
      );
    }

    if (selectedSpotDataModelList.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(appParamState.selectedDate),
          Flexible(
            child: DefaultTextStyle(
              style: TextStyle(fontSize: isNarrow ? 10 : 12, color: Colors.greenAccent),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(selectedSpotDataModelList[0].name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      selectedSpotDataModelList[selectedSpotDataModelList.length - 1].name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return (selectedSpotDataModelList[index].type == 'temple')
                    ? Text(
                        selectedSpotDataModelList[index].name,
                        style: const TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : const SizedBox.shrink();
              },
              itemCount: selectedSpotDataModelList.length,
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  ///
  List<_TimelineItem> _buildTimelineItems(List<TempleModel> temples) {
    final List<_TimelineItem> list = <_TimelineItem>[];
    if (temples.isEmpty) {
      return list;
    }

    final List<TempleModel> sorted = <TempleModel>[...temples]
      ..sort((TempleModel a, TempleModel b) => a.date.compareTo(b.date));

    int? currentYear;
    for (final TempleModel t in sorted) {
      if (currentYear != t.date.year) {
        currentYear = t.date.year;
        list.add(_YearHeaderItem(currentYear));
      }
      list.add(_TempleItem(t));
    }
    return list;
  }

  ///
  void moveMapCenterPosition({required bool isNarrow}) {
    getDataState.keepTempleList.where((TempleModel a) => a.date.yyyymmdd == appParamState.selectedDate).forEach((
      TempleModel element,
    ) {
      final Map<String, dynamic> dailySpotDataInfo = getDailySpotDataInfo(
        templeModel: element,
        templeLatLngMap: getDataState.keepTempleLatLngMap,
        stationMap: getDataState.keepStationMap,
        tokyoMunicipalList: getDataState.keepTokyoMunicipalList,
        templeListMap: getDataState.keepTempleListMap,
      );

      selectedSpotDataModelList = dailySpotDataInfo['templeDataList'] as List<SpotDataModel>;

      final SpotDataModel firstTempleSpotData = selectedSpotDataModelList[1];

      mapController.move(LatLng(firstTempleSpotData.latitude.toDouble(), firstTempleSpotData.longitude.toDouble()), 15);

      appParamNotifier.setIsMapCenterMove(flag: true);

      makeTempleMarkerList(isNarrow: isNarrow);
      makeSelectedSpotDataModelMarkerList();
    });
  }

  ///
  void makeTempleMarkerList({required bool isNarrow}) {
    templeMarkerList.clear();

    final List<String> templeNames = <String>[];

    getDataState.keepTempleLatLngMap.forEach((String key, TempleLatLngModel value) {
      templeNames.add(value.temple);

      bool flag = false;

      if (appParamState.displayTempleRankList.contains(value.rank)) {
        flag = true;
      }

      if (flag) {
        templeMarkerList.add(
          Marker(
            width: 40,
            height: 40,
            point: LatLng(value.lat.toDouble(), value.lng.toDouble()),
            child: GestureDetector(
              onTap: () {
                appParamNotifier.setSelectedSpotDataModel(
                  value: SpotDataModel(
                    type: '',
                    name: value.temple,
                    address: value.address,
                    latitude: value.lat,
                    longitude: value.lng,
                  ),
                );
                makeTempleMarkerList(isNarrow: isNarrow);
              },
              child:
                  (appParamState.selectedSpotDataModel?.latitude == value.lat &&
                      appParamState.selectedSpotDataModel?.longitude == value.lng)
                  ? Container(
                      decoration: BoxDecoration(border: Border.all(width: 2), shape: BoxShape.circle),
                      padding: const EdgeInsets.all(3),
                      child: CircleAvatar(
                        backgroundColor: Colors.redAccent.withValues(alpha: 0.6),
                        child: Text(value.rank, style: const TextStyle(color: Colors.white, fontSize: 20)),
                      ),
                    )
                  : CircleAvatar(
                      backgroundColor: Colors.redAccent.withValues(alpha: 0.6),
                      child: Text(value.rank, style: const TextStyle(color: Colors.white, fontSize: 20)),
                    ),
            ),
          ),
        );
      }
    });

    for (final TempleListModel element in getDataState.keepFilteredNotVisitTempleList) {
      templeNames.add(element.name);

      templeMarkerList.add(
        Marker(
          width: 40,
          height: 40,
          point: LatLng(element.lat.toDouble(), element.lng.toDouble()),
          child: GestureDetector(
            onTap: () {
              appParamNotifier.setSelectedSpotDataModel(
                value: SpotDataModel(
                  type: '',
                  name: element.name,
                  address: element.address,
                  latitude: element.lat,
                  longitude: element.lng,
                ),
              );
              makeTempleMarkerList(isNarrow: isNarrow);
            },
            child:
                (appParamState.selectedSpotDataModel?.latitude == element.lat &&
                    appParamState.selectedSpotDataModel?.longitude == element.lng)
                ? Container(
                    decoration: BoxDecoration(border: Border.all(width: 2), shape: BoxShape.circle),
                    padding: const EdgeInsets.all(3),
                    child: CircleAvatar(
                      backgroundColor: Colors.purpleAccent.withValues(alpha: 0.6),
                      child: const SizedBox.shrink(),
                    ),
                  )
                : CircleAvatar(
                    backgroundColor: Colors.purpleAccent.withValues(alpha: 0.6),
                    child: const SizedBox.shrink(),
                  ),
          ),
        ),
      );
    }

    getDataState.keepTempleListNavitimeMap.forEach((String key, TempleListModel value) {
      if (templeNames.contains(value.name)) {
      } else {
        if (double.tryParse(value.lat) != null && double.tryParse(value.lng) != null) {
          templeMarkerList.add(
            Marker(
              width: 40,
              height: 40,
              point: LatLng(value.lat.toDouble(), value.lng.toDouble()),
              child: GestureDetector(
                onTap: () {
                  appParamNotifier.setSelectedSpotDataModel(
                    value: SpotDataModel(
                      type: '',
                      name: value.name,
                      address: value.address,
                      latitude: value.lat,
                      longitude: value.lng,
                    ),
                  );
                  makeTempleMarkerList(isNarrow: isNarrow);
                },
                child:
                    (appParamState.selectedSpotDataModel?.latitude == value.lat &&
                        appParamState.selectedSpotDataModel?.longitude == value.lng)
                    ? Container(
                        decoration: BoxDecoration(border: Border.all(width: 2), shape: BoxShape.circle),
                        padding: const EdgeInsets.all(3),
                        child: CircleAvatar(
                          backgroundColor: Colors.blueAccent.withValues(alpha: 0.6),
                          child: const SizedBox.shrink(),
                        ),
                      )
                    : CircleAvatar(
                        backgroundColor: Colors.blueAccent.withValues(alpha: 0.6),
                        child: const SizedBox.shrink(),
                      ),
              ),
            ),
          );
        }
      }
    });
  }

  ///
  void makeSelectedSpotDataModelMarkerList() {
    selectedSpotDataModelMarkerList.clear();

    int i = 0;
    for (final SpotDataModel element in selectedSpotDataModelList) {
      selectedSpotDataModelMarkerList.add(
        Marker(
          width: 50,
          height: 50,
          alignment: Alignment.center,
          point: LatLng(element.latitude.toDouble(), element.longitude.toDouble()),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green[900]!, width: 3),
            ),
            child: Center(child: displayStartEndStationMark(index: i)),
          ),
        ),
      );
      i++;
    }
  }

  ////
  Widget displayStartEndStationMark({required int index}) {
    if (index == 0) {
      return CircleAvatar(
        backgroundColor: Colors.green[900],
        child: Text(selectedSpotDataModelList[index].mark, style: const TextStyle(color: Colors.white)),
      );
    } else {
      if (index == selectedSpotDataModelList.length - 1) {
        if (selectedSpotDataModelList[index].mark != 'S/E') {
          return CircleAvatar(
            backgroundColor: Colors.green[900],
            child: Text(selectedSpotDataModelList[index].mark, style: const TextStyle(color: Colors.white)),
          );
        }
      }
    }

    return const SizedBox.shrink();
  }

  ///
  // ignore: always_specify_types
  List<Polyline> makeDateRoutePolyline() {
    // ignore: always_specify_types
    return <Polyline>[
      for (int i = 0; i < selectedSpotDataModelList.length; i++)
        // ignore: always_specify_types
        Polyline(
          points: selectedSpotDataModelList
              .map((SpotDataModel e) => LatLng(e.latitude.toDouble(), e.longitude.toDouble()))
              .toList(),
          color: Colors.green[900]!,
          strokeWidth: 5,
        ),
    ];
  }

  ///
  // ignore: always_specify_types
  List<Polygon> makeAreaPolygons() {
    // ignore: always_specify_types
    final List<Polygon> polygonList = <Polygon>[];

    final List<List<List<List<double>>>>? all = widget.allPolygons;

    if (all == null || all.isEmpty) {
      return polygonList;
    }

    final List<Color> twentyFourColor = utility.getTwentyFourColor();

    final Map<String, List<List<List<double>>>> uniquePolygons = <String, List<List<List<double>>>>{};

    for (final List<List<List<double>>> poly in all) {
      final String key = poly.toString();
      uniquePolygons[key] = poly;
    }

    int idx = 0;
    for (final List<List<List<double>>> poly in uniquePolygons.values) {
      // ignore: always_specify_types
      final Polygon? polygon = getColorPaintPolygon(
        polygon: poly,
        color: twentyFourColor[idx % 24].withValues(alpha: 0.3),
      );

      if (polygon != null) {
        polygonList.add(polygon);
        idx++;
      }
    }

    return polygonList;
  }
}

///////////////////////////////////////////////////////////////////////

abstract class _TimelineItem {}

class _TempleItem extends _TimelineItem {
  _TempleItem(this.temple);

  final TempleModel temple;
}

class _YearHeaderItem extends _TimelineItem {
  _YearHeaderItem(this.year);

  final int year;
}

///////////////////////////////////////////////////////////////////////

class _TempleCell extends StatefulWidget {
  const _TempleCell({
    required this.temple,
    required this.width,
    required this.collapsedHeight,
    required this.expandedHeight,
    required this.buttonHeight,
  });

  final TempleModel temple;
  final double width;
  final double collapsedHeight;
  final double expandedHeight;
  final double buttonHeight;

  @override
  State<_TempleCell> createState() => _TempleCellState();
}

///////////////////////////////////////////////////////////////////////

class _TempleCellState extends State<_TempleCell> {
  bool _isExpanded = false;

  String get _dateString =>
      '${widget.temple.date.year.toString().padLeft(4, '0')}/'
      '${widget.temple.date.month.toString().padLeft(2, '0')}/'
      '${widget.temple.date.day.toString().padLeft(2, '0')}';

  ///
  @override
  Widget build(BuildContext context) {
    final double height = _isExpanded ? widget.expandedHeight : widget.collapsedHeight;

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: widget.width,
        height: height,
        decoration: BoxDecoration(border: Border.all(width: 2), color: Colors.green.shade100),

        child: _isExpanded ? _buildExpanded() : _buildCollapsed(),
      ),
    );
  }

  ///
  Widget _buildExpanded() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(_dateString, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                Text(widget.temple.temple, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
        SizedBox(
          height: widget.buttonHeight,
          child: Container(
            color: Colors.green.shade700,
            alignment: Alignment.center,
            child: const Text('詳細を見る', style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ),
      ],
    );
  }

  ///
  Widget _buildCollapsed() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: FittedBox(
        alignment: Alignment.centerLeft,
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(_dateString, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              widget.temple.temple,
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
