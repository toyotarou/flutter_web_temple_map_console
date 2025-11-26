import 'package:equatable/equatable.dart';

class SpotDataModel extends Equatable {
  const SpotDataModel({
    required this.type,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.mark = '',
    this.cnt = 0,
    this.rank = '',
  });

  final String type;
  final String name;
  final String address;
  final String latitude;
  final String longitude;
  final String mark;
  final int cnt;
  final String rank;

  @override
  List<Object?> get props => <Object?>[type, name, address, latitude, longitude, mark, cnt, rank];
}
