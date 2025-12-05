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

  ///
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!appParamState.isMapCenterMove) {
        moveMapCenterPosition();
      }
    });

    return SafeArea(
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              SizedBox(
                height: context.screenSize.height,
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

                    if (widget.allPolygons != null) ...<Widget>[
                      // ignore: always_specify_types
                      PolygonLayer(polygons: makeAreaPolygons()),
                    ],

                    // ignore: always_specify_types
                    PolylineLayer(polylines: makeDateRoutePolyline()),

                    if (selectedSpotDataModelMarkerList.isNotEmpty) ...<Widget>[
                      MarkerLayer(markers: selectedSpotDataModelMarkerList),
                    ],

                    if (templeMarkerList.isNotEmpty) ...<Widget>[MarkerLayer(markers: templeMarkerList)],
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
                  height: 130,
                  padding: const EdgeInsets.all(10),
                  child: DefaultTextStyle(
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                    child: (appParamState.selectedSpotDataModel != null)
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[SelectableText(appParamState.selectedSpotDataModel!.name)],
                          )
                        : (selectedSpotDataModelList.isNotEmpty)
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(appParamState.selectedDate),
                              DefaultTextStyle(
                                style: const TextStyle(fontSize: 12, color: Colors.greenAccent),
                                child: Row(
                                  children: <Widget>[
                                    Text(selectedSpotDataModelList[0].name),
                                    const SizedBox(width: 20),
                                    Text(selectedSpotDataModelList[selectedSpotDataModelList.length - 1].name),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemBuilder: (BuildContext context, int index) {
                                    return (selectedSpotDataModelList[index].type == 'temple')
                                        ? Text(selectedSpotDataModelList[index].name)
                                        : const SizedBox.shrink();
                                  },
                                  itemCount: selectedSpotDataModelList.length,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///
  void moveMapCenterPosition() {
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

      makeTempleMarkerList();
      makeSelectedSpotDataModelMarkerList();
    });
  }

  ///
  void makeTempleMarkerList() {
    templeMarkerList.clear();

    final List<String> templeNames = <String>[];

    getDataState.keepTempleLatLngMap.forEach((String key, TempleLatLngModel value) {
      templeNames.add(value.temple);

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
              makeTempleMarkerList();
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
              makeTempleMarkerList();
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
        //        print(value.name);
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
                  makeTempleMarkerList();
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

  ///
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
    return <Polyline<Object>>[
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
    final List<Polygon<Object>> polygonList = <Polygon<Object>>[];

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
      final Polygon<Object>? polygon = getColorPaintPolygon(
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
