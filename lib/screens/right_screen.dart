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

  List<Marker> selectedSpotsMarkerList = <Marker>[];

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

                if (selectedSpotsMarkerList.isNotEmpty) ...<Widget>[MarkerLayer(markers: selectedSpotsMarkerList)],
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

      makeSelectedSpotsMarkerList();
    });
  }

  ///
  void makeSelectedSpotsMarkerList() {
    for (final SpotDataModel element in spotDataModelList) {
      selectedSpotsMarkerList.add(
        Marker(point: LatLng(element.latitude.toDouble(), element.longitude.toDouble()), child: const CircleAvatar()),
      );
    }
  }
}
