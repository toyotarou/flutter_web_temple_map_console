import 'package:flutter_riverpod/flutter_riverpod.dart';
import '_get_data/get_data.dart';
import '_get_data/station/station.dart';
import '_get_data/temple/temple.dart';
import '_get_data/temple_lat_lng/temple_lat_lng.dart';

import '_get_data/temple_list/temple_list.dart';
import '_get_data/temple_list_navitime/temple_list_navitime.dart';
import '_get_data/tokyo_municipal/tokyo_municipal.dart';
import 'app_param/app_param.dart';

mixin ControllersMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  //==========================================//

  AppParamState get appParamState => ref.watch(appParamProvider);

  AppParam get appParamNotifier => ref.read(appParamProvider.notifier);

  //==========================================//

  GetDataState get getDataState => ref.watch(getDataProvider);

  GetData get getDataNotifier => ref.read(getDataProvider.notifier);

  //==========================================//

  TempleState get templeState => ref.watch(templeProvider);

  Temple get templeNotifier => ref.read(templeProvider.notifier);

  //==========================================//

  TempleLatLngState get templeLatLngState => ref.watch(templeLatLngProvider);

  TempleLatLng get templeLatLngNotifier => ref.read(templeLatLngProvider.notifier);

  //==========================================//

  StationState get stationState => ref.watch(stationProvider);

  Station get stationNotifier => ref.read(stationProvider.notifier);

  //==========================================//

  TokyoMunicipalState get tokyoMunicipalState => ref.watch(tokyoMunicipalProvider);

  TokyoMunicipal get tokyoMunicipalNotifier => ref.read(tokyoMunicipalProvider.notifier);

  //==========================================//

  TempleListState get templeListState => ref.watch(templeListProvider);

  TempleList get templeListNotifier => ref.read(templeListProvider.notifier);

  //==========================================//

  TempleListNavitimeState get templeListNavitimeState => ref.watch(templeListNavitimeProvider);

  TempleListNavitime get templeListNavitimeNotifier => ref.read(templeListNavitimeProvider.notifier);

  //==========================================//
}
