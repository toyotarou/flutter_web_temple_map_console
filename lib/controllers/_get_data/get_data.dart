import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/municipal_model.dart';
import '../../models/station_model.dart';
import '../../models/temple_lat_lng_model.dart';

import '../../models/temple_list_model.dart';
import '../../models/temple_model.dart';

import '../../utility/utility.dart';

part 'get_data.freezed.dart';

part 'get_data.g.dart';

@freezed
class GetDataState with _$GetDataState {
  const factory GetDataState({
    @Default(<TempleModel>[]) List<TempleModel> keepTempleList,
    @Default(<TempleLatLngModel>[]) List<TempleLatLngModel> keepTempleLatLngList,
    @Default(<String, TempleLatLngModel>{}) Map<String, TempleLatLngModel> keepTempleLatLngMap,

    @Default(<String, StationModel>{}) Map<String, StationModel> keepStationMap,

    @Default(<MunicipalModel>[]) List<MunicipalModel> keepTokyoMunicipalList,
    @Default(<String, MunicipalModel>{}) Map<String, MunicipalModel> keepTokyoMunicipalMap,

    @Default(<String, TempleListModel>{}) Map<String, TempleListModel> keepTempleListMap,
    @Default(<TempleListModel>[]) List<TempleListModel> keepTempleListList,
  }) = _GetDataState;
}

@Riverpod(keepAlive: true)
class GetData extends _$GetData {
  final Utility utility = Utility();

  ///
  @override
  GetDataState build() => const GetDataState();

  ///
  void setKeepTempleList({required List<TempleModel> list}) => state = state.copyWith(keepTempleList: list);

  ///
  void setKeepTempleLatLngList({required List<TempleLatLngModel> list}) =>
      state = state.copyWith(keepTempleLatLngList: list);

  ///
  void setKeepTempleLatLngMap({required Map<String, TempleLatLngModel> map}) =>
      state = state.copyWith(keepTempleLatLngMap: map);

  ///
  void setKeepStationMap({required Map<String, StationModel> map}) => state = state.copyWith(keepStationMap: map);

  ///
  void setKeepTokyoMunicipalList({required List<MunicipalModel> list}) =>
      state = state.copyWith(keepTokyoMunicipalList: list);

  ///
  void setKeepTokyoMunicipalMap({required Map<String, MunicipalModel> map}) =>
      state = state.copyWith(keepTokyoMunicipalMap: map);

  ///
  void setKeepTempleListMap({required Map<String, TempleListModel> map}) =>
      state = state.copyWith(keepTempleListMap: map);

  ///
  void setKeepTempleListList({required List<TempleListModel> list}) => state = state.copyWith(keepTempleListList: list);
}
