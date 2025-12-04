class TempleListModel {
  TempleListModel({
    required this.id,

    required this.name,
    required this.address,
    required this.lat,
    required this.lng,

    required this.city,
    required this.jinjachouId,
    required this.url,
    required this.nearStation,
  });

  factory TempleListModel.fromJson(Map<String, dynamic> json) => TempleListModel(
    id: int.parse(json['id'].toString()),

    name: json['name'].toString(),
    address: json['address'].toString(),
    lat: json['lat'].toString(),
    lng: json['lng'].toString(),

    city: (json['city'] != '') ? json['city'].toString() : '',
    jinjachouId: (json['jinjachou_id'] != '') ? json['jinjachou_id'].toString() : '',
    url: (json['url'] != '') ? json['url'].toString() : '',
    nearStation: (json['near_station'] != '') ? json['near_station'].toString() : '',
  );

  int id;

  String name;
  String address;
  String lat;
  String lng;

  String city;
  String jinjachouId;
  String url;
  String nearStation;
}
