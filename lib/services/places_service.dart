import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../config/app_config.dart';

class Place {
  final String name;
  final LatLng pos;
  final String type; // hospital | pharmacy | clinic
  final String? address;
  final String? phone;
  final double? rating; // OSM rarely has rating; keep optional
  final String? website;
  Place({
    required this.name,
    required this.pos,
    required this.type,
    this.address,
    this.phone,
    this.rating,
    this.website,
  });
}

class PlacesService {
  static Future<List<Place>> search({
    required LatLng center,
    required String query, // 'hospital' or 'pharmacy'
    int radiusMeters = 3500,
    int limit = 40,
  }) async {
    // Use Overpass API for more accurate and rich data (address/phone)
    final email = AppConfig.osmEmail;
    final amenity = query == 'hospital' ? 'hospital|clinic' : 'pharmacy';
    final q = '''[out:json][timeout:25];(
      node(around:$radiusMeters,${center.latitude},${center.longitude})["amenity"~"$amenity"];
      way(around:$radiusMeters,${center.latitude},${center.longitude})["amenity"~"$amenity"];
      relation(around:$radiusMeters,${center.latitude},${center.longitude})["amenity"~"$amenity"];
    );out center $limit;''';
    final uri = Uri.parse('https://overpass-api.de/api/interpreter');
    final res = await http.post(
      uri,
      headers: {
        'User-Agent': 'VITA/1.0 ($email)',
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      },
      body: {'data': q},
    );
    if (res.statusCode != 200) return [];
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final elements = (data['elements'] as List?) ?? const [];
    List<Place> places = [];
    for (final e in elements) {
      final Map<String, dynamic> tags = (e['tags'] as Map?)?.cast<String, dynamic>() ?? {};
      final String name = (tags['name'] as String?) ?? (query == 'hospital' ? 'Hospital/Clinic' : 'Pharmacy');
      double? lat = (e['lat'] as num?)?.toDouble();
      double? lon = (e['lon'] as num?)?.toDouble();
      if (lat == null || lon == null) {
        final centerObj = e['center'] as Map?;
        lat = (centerObj?['lat'] as num?)?.toDouble();
        lon = (centerObj?['lon'] as num?)?.toDouble();
      }
      if (lat == null || lon == null) continue;
      final String? phone = tags['phone'] ?? tags['contact:phone'] ?? tags['contact:telephone'];
      final String? website = tags['website'] ?? tags['contact:website'] ?? tags['url'];
      final address = _composeAddress(tags);
      places.add(Place(
        name: name,
        pos: LatLng(lat, lon),
        type: (tags['amenity'] as String?) ?? query,
        address: address,
        phone: phone,
        rating: null, // OSM typically has no rating
        website: website,
      ));
      if (places.length >= limit) break;
    }
    return places;
  }

  static String? _composeAddress(Map<String, dynamic> tags) {
    final full = tags['addr:full'] as String?;
    if (full != null && full.trim().isNotEmpty) return full.trim();
    final parts = <String?>[
      tags['addr:city'] as String?,
      tags['addr:street'] as String?,
      tags['addr:housenumber'] as String?,
    ];
    final list = parts.whereType<String>().map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (list.isEmpty) return null;
    return list.join(', ');
  }
}
