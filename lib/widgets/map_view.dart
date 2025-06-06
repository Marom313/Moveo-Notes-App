import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/note_model.dart';

import '../viewmodels/main_vm.dart';

class MapView extends StatelessWidget {
  const MapView({
    super.key,
    required this.notes,
    required LatLng? currentPosition,
  }) : _currentPosition = currentPosition;

  final List<Note> notes;
  final LatLng? _currentPosition;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: FlutterMap(
        mapController: context.read<MainViewModel>().controller,
        options: MapOptions(
          initialCenter:
              notes.isNotEmpty
                  ? LatLng(notes.last.lat ?? 0, notes.last.long ?? 0)
                  : _currentPosition!,
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers:
                notes
                    .where((note) => note.lat != null && note.long != null)
                    .map((note) {
                      return Marker(
                        point: LatLng(note.lat!, note.long!),
                        width: width * 0.5,
                        height: height * 0.5,
                        child: GestureDetector(
                          onTap: () {
                            context.go(
                              '/note_edit',
                              extra: {
                                'note': note,
                                'index': notes.indexOf(note),
                              },
                            );
                          },
                          child: Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: height * 0.04,
                          ),
                        ),
                      );
                    })
                    .toList(),
          ),
        ],
      ),
    );
  }
}
