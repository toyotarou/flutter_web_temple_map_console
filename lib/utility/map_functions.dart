import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/common/spot_data_model.dart';
import '../models/municipal_model.dart';

const double _eps = 1e-12;

///
bool spotInMunicipality(double lat, double lng, MunicipalModel muni) {
  for (final List<List<List<double>>> polygon in muni.polygons) {
    if (polygon.isEmpty) {
      continue;
    }

    final List<List<double>> outerRing = polygon.first;

    if (!_pointInRingOrOnEdge(lat, lng, outerRing)) {
      continue;
    }

    bool inAnyHole = false;

    for (int i = 1; i < polygon.length; i++) {
      final List<List<double>> holeRing = polygon[i];

      if (_pointInRingOrOnEdge(lat, lng, holeRing)) {
        inAnyHole = true;

        break;
      }
    }

    if (!inAnyHole) {
      return true;
    }
  }

  return false;
}

///
bool _pointInRingOrOnEdge(double lat, double lng, List<List<double>> ring) {
  for (int i = 0; i < ring.length; i++) {
    final List<double> a = ring[i];

    final List<double> b = ring[(i + 1) % ring.length];

    final double aLng = a[0], aLat = a[1];

    final double bLng = b[0], bLat = b[1];

    if (_pointOnSegment(lat, lng, aLat, aLng, bLat, bLng)) {
      return true;
    }
  }

  return _rayCasting(lat, lng, ring);
}

///
bool _rayCasting(double lat, double lng, List<List<double>> ring) {
  bool inside = false;

  for (int i = 0, j = ring.length - 1; i < ring.length; j = i++) {
    final double xiLat = ring[i][1], xiLng = ring[i][0];

    final double xjLat = ring[j][1], xjLng = ring[j][0];

    final bool crossesVertically = (xiLat > lat) != (xjLat > lat);

    if (!crossesVertically) {
      continue;
    }

    final double t = (lat - xiLat) / (xjLat - xiLat);

    final double intersectionLng = xiLng + t * (xjLng - xiLng);

    if (intersectionLng > lng) {
      inside = !inside;
    }
  }

  return inside;
}

///
bool _pointOnSegment(double pLat, double pLng, double aLat, double aLng, double bLat, double bLng) {
  final double minLat = (aLat < bLat) ? aLat : bLat;

  final double maxLat = (aLat > bLat) ? aLat : bLat;

  final double minLng = (aLng < bLng) ? aLng : bLng;

  final double maxLng = (aLng > bLng) ? aLng : bLng;

  final bool withinBox =
      (pLat >= minLat - _eps) && (pLat <= maxLat + _eps) && (pLng >= minLng - _eps) && (pLng <= maxLng + _eps);

  if (!withinBox) {
    return false;
  }

  final double vLat = bLat - aLat;

  final double vLng = bLng - aLng;

  final double wLat = pLat - aLat;

  final double wLng = pLng - aLng;

  final double cross = (vLng * wLat) - (vLat * wLng);

  if (cross.abs() > 1e-10) {
    return false;
  }

  final double vLen2 = vLat * vLat + vLng * vLng;

  if (vLen2 < 1e-20) {
    final double d2 = wLat * wLat + wLng * wLng;

    return d2 < 1e-20;
  }

  final double t = (wLat * vLat + wLng * vLng) / vLen2;

  return t >= -_eps && t <= 1 + _eps;
}

///
List<SpotDataModel> getUniqueTemples(List<SpotDataModel> input) {
  final Map<String, List<SpotDataModel>> map = <String, List<SpotDataModel>>{};

  for (final SpotDataModel t in input) {
    map.putIfAbsent(t.name, () => <SpotDataModel>[]).add(t);
  }

  final List<SpotDataModel> result = <SpotDataModel>[];

  for (final MapEntry<String, List<SpotDataModel>> entry in map.entries) {
    if (entry.value.length == 1) {
      result.add(entry.value.first);
    } else {
      final double avgLat = _averageOf<SpotDataModel>(entry.value, (SpotDataModel e) => double.tryParse(e.latitude));

      final double avgLng = _averageOf<SpotDataModel>(entry.value, (SpotDataModel e) => double.tryParse(e.longitude));

      result.add(
        SpotDataModel(
          type: 'temple',
          name: entry.key,
          address: '',
          latitude: avgLat.toString(),
          longitude: avgLng.toString(),
          rank: entry.value.first.rank,
        ),
      );
    }
  }
  return result;
}

///
double _averageOf<T>(Iterable<T> items, double? Function(T) selector) {
  double sum = 0.0;

  int count = 0;

  // ignore: always_specify_types
  for (final it in items) {
    final double? v = selector(it);

    if (v != null && v.isFinite) {
      sum += v;

      count++;
    }
  }
  return count == 0 ? 0.0 : sum / count;
}

///
// ignore: always_specify_types
Polygon? getColorPaintPolygon({required List<List<List<double>>> polygon, required Color color}) {
  if (polygon.isEmpty) {
    return null;
  }

  /////////////////////////////////////
  final List<LatLng> outer = polygon.first.map((List<double> element) => LatLng(element[1], element[0])).toList();
  /////////////////////////////////////

  /////////////////////////////////////
  final List<List<LatLng>> holes = <List<LatLng>>[];

  for (int i = 1; i < polygon.length; i++) {
    holes.add(polygon[i].map((List<double> element4) => LatLng(element4[1], element4[0])).toList());
  }
  /////////////////////////////////////

  // ignore: always_specify_types
  return Polygon(
    points: outer,
    holePointsList: holes.isEmpty ? null : holes,
    isFilled: true,
    color: color.withValues(alpha: 0.3),
    borderColor: color.withValues(alpha: 0.8),
    borderStrokeWidth: 1.5,
  );
}

///
List<MunicipalModel> getNeighborsArea({required MunicipalModel target, required List<MunicipalModel> all}) {
  final List<MunicipalModel> out = <MunicipalModel>[];

  for (final MunicipalModel m in all) {
    if (identical(m, target)) {
      continue;
    }

    if (_areAdjacent(target, m)) {
      out.add(m);
    }
  }

  out.sort((MunicipalModel a, MunicipalModel b) {
    final double da = (a.centroidLat - target.centroidLat).abs() + (a.centroidLng - target.centroidLng).abs();

    final double db = (b.centroidLat - target.centroidLat).abs() + (b.centroidLng - target.centroidLng).abs();

    return da.compareTo(db);
  });

  return out;
}

///
bool _areAdjacent(MunicipalModel a, MunicipalModel b) {
  if (!_bBoxOverlap(a, b)) {
    return false;
  }

  for (final List<List<List<double>>> polyA in a.polygons) {
    for (final List<List<List<double>>> polyB in b.polygons) {
      if (_polygonsTouchOrIntersect(polyA, polyB)) {
        return true;
      }

      if (polyA.isNotEmpty && polyB.isNotEmpty) {
        final List<double> pa = polyA.first.first;

        final List<double> pb = polyB.first.first;

        if (spotInMunicipality(pa[1], pa[0], b)) {
          return true;
        }

        if (spotInMunicipality(pb[1], pb[0], a)) {
          return true;
        }
      }
    }
  }

  return false;
}

///
bool _bBoxOverlap(MunicipalModel a, MunicipalModel b) {
  final bool latOverlap = !(a.maxLat < b.minLat - _eps || b.maxLat < a.minLat - _eps);

  final bool lngOverlap = !(a.maxLng < b.minLng - _eps || b.maxLng < a.minLng - _eps);

  return latOverlap && lngOverlap;
}

///
bool _polygonsTouchOrIntersect(List<List<List<double>>> polyA, List<List<List<double>>> polyB) {
  for (final List<List<double>> ringA in polyA) {
    for (final List<List<double>> ringB in polyB) {
      if (_ringsTouchOrIntersect(ringA, ringB)) {
        return true;
      }
    }
  }

  return false;
}

///
bool _ringsTouchOrIntersect(List<List<double>> ringA, List<List<double>> ringB) {
  for (int i = 0; i < ringA.length; i++) {
    final List<double> a1 = ringA[i];

    final List<double> a2 = ringA[(i + 1) % ringA.length];

    for (int j = 0; j < ringB.length; j++) {
      final List<double> b1 = ringB[j];

      final List<double> b2 = ringB[(j + 1) % ringB.length];

      if (_segmentsIntersectOrTouch(a1, a2, b1, b2)) {
        return true;
      }
    }
  }

  return false;
}

///
bool _segmentsIntersectOrTouch(List<double> aStart, List<double> aEnd, List<double> bStart, List<double> bEnd) {
  final Coordinate a1 = Coordinate(aStart[0], aStart[1]);

  final Coordinate a2 = Coordinate(aEnd[0], aEnd[1]);

  final Coordinate b1 = Coordinate(bStart[0], bStart[1]);

  final Coordinate b2 = Coordinate(bEnd[0], bEnd[1]);

  final int o1 = _orientation(a1, a2, b1);

  final int o2 = _orientation(a1, a2, b2);

  final int o3 = _orientation(b1, b2, a1);

  final int o4 = _orientation(b1, b2, a2);

  if (o1 * o2 < 0 && o3 * o4 < 0) {
    return true;
  }

  if (o1 == 0 && _onSegment(a1, a2, b1)) {
    return true;
  }

  if (o2 == 0 && _onSegment(a1, a2, b2)) {
    return true;
  }

  if (o3 == 0 && _onSegment(b1, b2, a1)) {
    return true;
  }

  if (o4 == 0 && _onSegment(b1, b2, a2)) {
    return true;
  }

  return false;
}

///
class Coordinate {
  const Coordinate(this.x, this.y);

  final double x;

  final double y;
}

///
int _orientation(Coordinate a, Coordinate b, Coordinate c) {
  final double val = (b.y - a.y) * (c.x - b.x) - (b.x - a.x) * (c.y - b.y);

  if (val.abs() <= _eps) {
    return 0;
  }

  return (val > 0) ? 1 : -1;
}

///
bool _onSegment(Coordinate a, Coordinate b, Coordinate p) {
  final double minX = a.x < b.x ? a.x : b.x;

  final double maxX = a.x > b.x ? a.x : b.x;

  final double minY = a.y < b.y ? a.y : b.y;

  final double maxY = a.y > b.y ? a.y : b.y;

  return p.x <= maxX + _eps && p.x >= minX - _eps && p.y <= maxY + _eps && p.y >= minY - _eps;
}

///
Map<String, List<double>> getMunicipalLatLng({List<List<List<List<double>>>>? polygons}) {
  final List<double> latList = polygons == null
      ? <double>[]
      : polygons
            .expand((List<List<List<double>>> e2) => e2)
            .expand((List<List<double>> e3) => e3)
            .map((List<double> p) => p[1])
            .toList();

  final List<double> lngList = polygons == null
      ? <double>[]
      : polygons
            .expand((List<List<List<double>>> e2) => e2)
            .expand((List<List<double>> e3) => e3)
            .map((List<double> p) => p[0])
            .toList();

  return <String, List<double>>{'latList': latList, 'lngList': lngList};
}
