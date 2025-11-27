import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/controllers_mixin.dart';
import '../extensions/extensions.dart';
import '../models/common/spot_data_model.dart';
import '../models/temple_model.dart';
import '../utility/daily_spot_data_functions.dart';

class RightScreen extends ConsumerStatefulWidget {
  const RightScreen({super.key});

  @override
  ConsumerState<RightScreen> createState() => _RightScreenState();
}

class _RightScreenState extends ConsumerState<RightScreen> with ControllersMixin<RightScreen> {
  final MapController mapController = MapController();

  double? currentZoom;

  double currentZoomEightTeen = 18;

  List<SpotDataModel> spotDataModelList = <SpotDataModel>[];

  List<Marker> matchedSpotsMarkerList = <Marker>[];

  List<Marker> notMatchedSpotsMarkerList = <Marker>[];

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

                if (matchedSpotsMarkerList.isNotEmpty) ...<Widget>[MarkerLayer(markers: matchedSpotsMarkerList)],

                if (notMatchedSpotsMarkerList.isNotEmpty) ...<Widget>[MarkerLayer(markers: notMatchedSpotsMarkerList)],
              ],
            ),
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

      spotDataModelList = dailySpotDataInfo['templeDataList'] as List<SpotDataModel>;

      final SpotDataModel firstTempleSpotData = spotDataModelList[1];

      mapController.move(LatLng(firstTempleSpotData.latitude.toDouble(), firstTempleSpotData.longitude.toDouble()), 18);

      appParamNotifier.setIsMapCenterMove(flag: true);

      makeMatchedSpotsMarkerList();
    });
  }

  ///
  void makeMatchedSpotsMarkerList() {
    for (final SpotDataModel element in spotDataModelList) {
      matchedSpotsMarkerList.add(
        Marker(point: LatLng(element.latitude.toDouble(), element.longitude.toDouble()), child: const CircleAvatar()),
      );
    }

    makeNotMatchedSpotsMarkerList();
  }

  ///
  void makeNotMatchedSpotsMarkerList() {
    final List<String> list = <String>[];
    final List<String> list2 = <String>[];

    for (final SpotDataModel element in spotDataModelList) {
      list.add('${element.latitude}|${element.longitude}');

      list2.add(element.name);
    }

    getDataState.keepTempleList.where((TempleModel a) => a.date.yyyymmdd != appParamState.selectedDate).forEach((
      TempleModel element,
    ) {
      final Map<String, dynamic> dailySpotDataInfo = getDailySpotDataInfo(
        templeModel: element,
        templeLatLngMap: getDataState.keepTempleLatLngMap,
        stationMap: getDataState.keepStationMap,
        tokyoMunicipalList: getDataState.keepTokyoMunicipalList,
        templeListMap: getDataState.keepTempleListMap,
      );

      final List<SpotDataModel> templeDataList = dailySpotDataInfo['templeDataList'] as List<SpotDataModel>;

      for (final SpotDataModel element2 in templeDataList) {
        if (!list.contains('${element2.latitude}|${element2.longitude}')) {
          if (!list2.contains(element2.name)) {
            if (element2.type == 'temple') {
              notMatchedSpotsMarkerList.add(
                Marker(
                  point: LatLng(element2.latitude.toDouble(), element2.longitude.toDouble()),
                  child: const CircleAvatar(backgroundColor: Colors.redAccent),
                ),
              );
            }
          }
        }
      }
    });
  }
}
