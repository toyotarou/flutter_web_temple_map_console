import '../const/const.dart';
import '../extensions/extensions.dart';
import '../models/common/spot_data_model.dart';
import '../models/municipal_model.dart';
import '../models/station_model.dart';
import '../models/temple_lat_lng_model.dart';
import '../models/temple_list_model.dart';
import '../models/temple_model.dart';

import 'map_functions.dart';

Map<String, dynamic> getDailySpotDataInfo({
  required TempleModel templeModel,
  required Map<String, TempleLatLngModel> templeLatLngMap,
  required Map<String, StationModel> stationMap,
  required List<MunicipalModel> tokyoMunicipalList,
  required Map<String, TempleListModel> templeListMap,
}) {
  final List<SpotDataModel> list = <SpotDataModel>[];

  final List<String> list2 = <String>[];

  if (templeModel.startPoint != '') {
    switch (templeModel.startPoint) {
      case '自宅':
        list.add(
          SpotDataModel(
            type: 'home',
            name: templeModel.startPoint,
            address: '千葉県船橋市二子町492-25-101',
            latitude: funabashiLat.toString(),
            longitude: funabashiLng.toString(),
            mark: (templeModel.startPoint == templeModel.endPoint) ? 'S/E' : 'S',
          ),
        );

      case '実家':
        list.add(
          SpotDataModel(
            type: 'home',
            name: templeModel.startPoint,
            address: '東京都杉並区善福寺4-22-11',
            latitude: zenpukujiLat.toString(),
            longitude: zenpukujiLng.toString(),
            mark: (templeModel.startPoint == templeModel.endPoint) ? 'S/E' : 'S',
          ),
        );

      default:
        final StationModel? stationModel = stationMap[templeModel.startPoint];

        if (stationModel != null) {
          list.add(
            SpotDataModel(
              type: 'station',
              name: stationModel.stationName,
              address: stationModel.address,
              latitude: stationModel.lat,
              longitude: stationModel.lng,
              mark: (templeModel.startPoint == templeModel.endPoint) ? 'S/E' : 'S',
            ),
          );
        }
    }
  }

  //////////////////////////
  final List<String> templeNameList = <String>[templeModel.temple];

  if (templeModel.memo != '') {
    templeNameList.addAll(templeModel.memo.split('、'));
  }

  for (int i = 0; i < templeNameList.length; i++) {
    final TempleLatLngModel? templeLatLngModel = templeLatLngMap[templeNameList[i]];

    final TempleListModel? templeListModel = templeListMap[templeNameList[i]];

    if (templeLatLngModel != null) {
      list.add(
        SpotDataModel(
          type: 'temple',
          name: templeLatLngModel.temple,
          address: templeLatLngModel.address,
          latitude: templeLatLngModel.lat,
          longitude: templeLatLngModel.lng,
          mark: (templeListModel != null) ? templeListModel.id.toString() : '0',
          rank: templeLatLngModel.rank,
        ),
      );

      final String? name = findMunicipalityForPoint(
        templeLatLngModel.lat.toDouble(),
        templeLatLngModel.lng.toDouble(),
        tokyoMunicipalList,
      );

      if (name != null && !list2.contains(name)) {
        list2.add(name);
      }
    }
  }

  //////////////////////////

  if (templeModel.endPoint != '') {
    switch (templeModel.endPoint) {
      case '自宅':
        list.add(
          SpotDataModel(
            type: 'home',
            name: templeModel.endPoint,
            address: '千葉県船橋市二子町492-25-101',
            latitude: funabashiLat.toString(),
            longitude: funabashiLng.toString(),
            mark: (templeModel.startPoint == templeModel.endPoint) ? 'S/E' : 'E',
          ),
        );

      case '実家':
        list.add(
          SpotDataModel(
            type: 'home',
            name: templeModel.endPoint,
            address: '東京都杉並区善福寺4-22-11',
            latitude: zenpukujiLat.toString(),
            longitude: zenpukujiLng.toString(),
            mark: (templeModel.startPoint == templeModel.endPoint) ? 'S/E' : 'E',
          ),
        );

      default:
        final StationModel? stationModel = stationMap[templeModel.endPoint];

        if (stationModel != null) {
          list.add(
            SpotDataModel(
              type: 'station',
              name: stationModel.stationName,
              address: stationModel.address,
              latitude: stationModel.lat,
              longitude: stationModel.lng,
              mark: (templeModel.startPoint == templeModel.endPoint) ? 'S/E' : 'E',
            ),
          );
        }
    }
  }

  list2.sort();

  return <String, dynamic>{'templeDataList': list, 'templeMunicipalList': list2};
}

///
String? findMunicipalityForPoint(double lat, double lng, List<MunicipalModel> tokyoMunicipalList) {
  for (final MunicipalModel m in tokyoMunicipalList) {
    if (spotInMunicipality(lat, lng, m)) {
      return m.name;
    }
  }

  return null;
}
