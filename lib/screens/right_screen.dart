import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/controllers_mixin.dart';
import '../extensions/extensions.dart';
import '../models/common/spot_data_model.dart';
import '../models/temple_lat_lng_model.dart';
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

  List<Marker> templeMarkerList = <Marker>[];

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
                            children: <Widget>[Text(appParamState.selectedSpotDataModel!.name)],
                          )
                        : (spotDataModelList.isNotEmpty)
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(appParamState.selectedDate),

                              Expanded(
                                child: ListView.builder(
                                  itemBuilder: (BuildContext context, int index) {
                                    return (spotDataModelList[index].type == 'temple')
                                        ? Text(spotDataModelList[index].name)
                                        : const SizedBox.shrink();
                                  },
                                  itemCount: spotDataModelList.length,
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

      spotDataModelList = dailySpotDataInfo['templeDataList'] as List<SpotDataModel>;

      final SpotDataModel firstTempleSpotData = spotDataModelList[1];

      mapController.move(LatLng(firstTempleSpotData.latitude.toDouble(), firstTempleSpotData.longitude.toDouble()), 16);

      appParamNotifier.setIsMapCenterMove(flag: true);

      makeTempleMarkerList();
    });
  }

  ///
  void makeTempleMarkerList() {
    getDataState.keepTempleLatLngMap.forEach((String key, TempleLatLngModel value) {
      templeMarkerList.add(
        Marker(
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
            },
            child: CircleAvatar(
              backgroundColor: Colors.redAccent.withValues(alpha: 0.6),
              child: Text(value.rank, style: const TextStyle(color: Colors.white, fontSize: 20)),
            ),
          ),
        ),
      );
    });
  }
}
