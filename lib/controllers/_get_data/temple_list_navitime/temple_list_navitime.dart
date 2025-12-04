import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/http/client.dart';
import '../../../data/http/path.dart';
import '../../../extensions/extensions.dart';
import '../../../models/temple_list_model.dart';
import '../../../utility/utility.dart';

part 'temple_list_navitime.freezed.dart';

part 'temple_list_navitime.g.dart';

@freezed
class TempleListNavitimeState with _$TempleListNavitimeState {
  const factory TempleListNavitimeState({
    @Default(<TempleListModel>[]) List<TempleListModel> templeListNavitimeList,
    @Default(<String, TempleListModel>{}) Map<String, TempleListModel> templeListNavitimeMap,
  }) = _TempleListNavitimeState;
}

@Riverpod(keepAlive: true)
class TempleListNavitime extends _$TempleListNavitime {
  final Utility utility = Utility();

  ///
  @override
  TempleListNavitimeState build() => const TempleListNavitimeState();

  //============================================== api

  ///
  Future<TempleListNavitimeState> fetchAllTempleListNavitimeData() async {
    final HttpClient client = ref.read(httpClientProvider);

    try {
      final dynamic value = await client.post(path: APIPath.getTempleListNavitimeTemple);

      final Map<String, TempleListModel> map = <String, TempleListModel>{};

      // ignore: avoid_dynamic_calls
      for (int i = 0; i < value['data'].length.toString().toInt(); i++) {
        final TempleListModel val = TempleListModel.fromJson(
          // ignore: avoid_dynamic_calls
          value['data'][i] as Map<String, dynamic>,
        );

        map[val.name] = val;
      }

      return state.copyWith(templeListNavitimeMap: map);
    } catch (e) {
      utility.showError('予期せぬエラーが発生しました');
      rethrow; // これにより呼び出し元でキャッチできる
    }
  }

  ///
  Future<void> getAllTempleListNavitime() async {
    try {
      final TempleListNavitimeState newState = await fetchAllTempleListNavitimeData();

      state = newState;
    } catch (_) {}
  }

  //============================================== api
}
