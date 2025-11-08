import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';
import '../services/places_service.dart';
import '../widgets/lumi_overlay.dart';
import '../widgets/lumi_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng _center = const LatLng(43.238949, 76.889709); // Default: Almaty
  LatLng? _myPos; // actual user position, independent from map center
  final _mapController = MapController();

  List<Place> _places = [];
  String _filter = 'hospital';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _locate();
    // optional live updates of my position
    final stream = LocationService.positionStream(distanceFilter: 25);
    stream?.listen((pos) {
      if (!mounted) return;
      setState(() => _myPos = LatLng(pos.latitude, pos.longitude));
    });
  }

  Future<void> _locate() async {
    final pos = await LocationService.currentPosition();
    if (pos != null && mounted) {
      setState(() {
        final here = LatLng(pos.latitude, pos.longitude);
        _center = here; // on first locate center the map too
        _myPos = here;
      });
      _mapController.move(_center, 14);
      await _refresh();
      return;
    }
    await _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final results = await PlacesService.search(center: _center, query: _filter);
    setState(() {
      _places = results;
      _loading = false;
    });
  }

  void _openPlace(Place p) {
    final d = const Distance().as(LengthUnit.Meter, _center, p.pos).round();
    final distStr = d < 1000 ? '$d m' : '${(d / 1000).toStringAsFixed(1)} km';
    LumiOverlay.set(
      emotion: LumiEmotion.pointing,
      speech: '${p.name} - $distStr',
      anchor: const Offset(0.15, 0.8),
    );
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _filter == 'hospital'
                        ? Icons.local_hospital
                        : Icons.local_pharmacy,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      p.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (p.address != null)
                Text(p.address!, style: const TextStyle(color: Colors.black87)),
              Text(
                'Distance: $distStr',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (p.rating != null) ...[
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(p.rating!.toStringAsFixed(1)),
                    const SizedBox(width: 12),
                  ],
                  if (p.phone != null && p.phone!.trim().isNotEmpty)
                    FilledButton.icon(
                      onPressed: () async {
                        final tel = p.phone!
                            .split(';')
                            .first
                            .trim()
                            .replaceAll(' ', '');
                        final uri = Uri.parse('tel:$tel');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                      icon: const Icon(Icons.call),
                      label: const Text('Call'),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.call),
                      label: const Text('No phone'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'hospital',
                      label: Text('Hospitals'),
                      icon: Icon(Icons.local_hospital),
                    ),
                    ButtonSegment(
                      value: 'pharmacy',
                      label: Text('Pharmacies'),
                      icon: Icon(Icons.local_pharmacy),
                    ),
                  ],
                  selected: {_filter},
                  onSelectionChanged: (s) {
                    setState(() => _filter = s.first);
                    _refresh();
                  },
                ),
              ),
              IconButton(
                onPressed: () async {
                  final pos = await LocationService.currentPosition();
                  if (pos != null) {
                    final here = LatLng(pos.latitude, pos.longitude);
                    setState(() {
                      _myPos = here;
                      _center = here;
                    });
                    _mapController.move(here, 15);
                    await _refresh();
                  }
                },
                icon: const Icon(Icons.my_location),
              ),
            ],
          ),
        ),
        Expanded(
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: _center, initialZoom: 13),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.flutter_vite',
              ),
              if (_loading) const MarkerLayer(markers: []),
              MarkerLayer(
                markers: [
                  if (_myPos != null)
                    Marker(
                      point: _myPos!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 30,
                      ),
                    ),
                  ..._places.map(
                    (p) => Marker(
                      point: p.pos,
                      width: 46,
                      height: 46,
                      child: GestureDetector(
                        onTap: () => _openPlace(p),
                        child: Tooltip(
                          message: p.name,
                          child: Icon(
                            _filter == 'hospital'
                                ? Icons.local_hospital
                                : Icons.local_pharmacy,
                            color: Colors.redAccent,
                            size: 42,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
