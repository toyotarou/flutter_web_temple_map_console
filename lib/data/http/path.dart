enum APIPath {
  getAllTemple,
  getTempleLatLng,
  getTempleDatePhoto,
  getAllStation,
  getDupSpot,
  getTempleListTemple,
  getTokyoTrainStation,
  getTrain,
  insertTempleRoute,
  getBusInfo,
  getBusTotalInfo,
}

extension APIPathExtension on APIPath {
  String? get value {
    switch (this) {
      case APIPath.getAllTemple:
        return 'getAllTemple';
      case APIPath.getTempleLatLng:
        return 'getTempleLatLng';
      case APIPath.getTempleDatePhoto:
        return 'getTempleDatePhoto';
      case APIPath.getAllStation:
        return 'getAllStation';
      case APIPath.getDupSpot:
        return 'getDupSpot';
      case APIPath.getTempleListTemple:
        return 'getTempleListTemple';
      case APIPath.getTokyoTrainStation:
        return 'getTokyoTrainStation';
      case APIPath.getTrain:
        return 'getTrain';
      case APIPath.insertTempleRoute:
        return 'insertTempleRoute';
      case APIPath.getBusInfo:
        return 'getBusInfo';
      case APIPath.getBusTotalInfo:
        return 'getBusTotalInfo';
    }
  }
}
