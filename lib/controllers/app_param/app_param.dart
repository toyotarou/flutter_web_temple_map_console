import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/common/spot_data_model.dart';

part 'app_param.freezed.dart';

part 'app_param.g.dart';

@freezed
class AppParamState with _$AppParamState {
  const factory AppParamState({
    ///
    @Default(0) double currentZoom,
    @Default(5) int currentPaddingIndex,

    ///
    @Default('') String selectedDate,

    ///
    @Default(false) bool isMapCenterMove,

    ///
    SpotDataModel? selectedSpotDataModel,
  }) = _AppParamState;
}

@Riverpod(keepAlive: true)
class AppParam extends _$AppParam {
  ///
  @override
  AppParamState build() => const AppParamState();

  ///
  void setCurrentZoom({required double zoom}) => state = state.copyWith(currentZoom: zoom);

  ///
  void setSelectedDate({required String date}) => state = state.copyWith(selectedDate: date);

  ///
  void setIsMapCenterMove({required bool flag}) => state = state.copyWith(isMapCenterMove: flag);

  ///
  void setSelectedSpotDataModel({SpotDataModel? value}) => state = state.copyWith(selectedSpotDataModel: value);
}
