// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import '../../services/auth_service.dart';
//
// class MainScreen extends StatelessWidget {
//   const MainScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;
//     final width = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Moveo Notes App"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () async {
//               await AuthService().logout();
//               context.go('/login');
//             },
//           ),
//         ],
//       ),
//       body: Center(
//         child: Text(
//           "Welcome to the Main Screen!",
//           style: Theme.of(context).textTheme.headlineSmall,
//         ),
//       ),
//       floatingActionButton: Padding(
//         padding: EdgeInsets.only(right: width * 0.03, bottom: height * 0.02),
//         child: FloatingActionButton(
//           onPressed: () {
//             // Later: navigate to "add note" or "map" page
//           },
//           child: const Icon(Icons.add),
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//     );
//   }
// }
// This patch fixes the rendering and rebuild timing issues for the map and SharedPreferences.
// It delays map rendering until after loadNotes() completes and location is retrieved.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/map_controller_service.dart';
import '../../viewmodels/navigation_vm.dart';
import '../../viewmodels/note_vm.dart';
import '../note/note_screen.dart';
import 'package:geolocator/geolocator.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isReady = false;
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<NoteViewModel>(context, listen: false).loadNotes();
      try {
        final pos = await Geolocator.getCurrentPosition();
        setState(() {
          _currentPosition = LatLng(pos.latitude, pos.longitude);
          _isReady = true;
        });
      } catch (e) {
        debugPrint('Location error: $e');
        setState(() {
          _currentPosition = const LatLng(32.0853, 34.7818); // fallback to TLV
          _isReady = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mapController = Provider.of<MapControllerService>(context).controller;
    final notes = Provider.of<NoteViewModel>(context).notes;
    final navVM = Provider.of<NavigationViewModel>(context);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    int selectedIndex = navVM.selectedIndex;

    if (!_isReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    Widget content;

    if (selectedIndex == 0) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Welcome to Note App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          if (notes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'No notes yet, press the plus sign and make a new one!',
              ),
            )
          else
            SizedBox(
              height: 100,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                scrollDirection: Axis.horizontal,
                itemCount: notes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return GestureDetector(
                    onTap: () {
                      context.push(
                        '/note_edit',
                        extra: {'note': note, 'index': index},
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      width: 180,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            note.body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      );
    } else {
      content = Padding(
        padding: const EdgeInsets.all(12.0),
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter:
                notes.isNotEmpty
                    ? notes.last.locationCreated
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
                  notes.map((note) {
                    return Marker(
                      point: note.locationCreated,
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () {
                          context.push(
                            '/note_edit',
                            extra: {'note': note, 'index': notes.indexOf(note)},
                          );
                        },
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 36,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Moveo Notes App"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: SafeArea(child: content),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => navVM.setTab(index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Note'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(right: width * 0.03, bottom: height * 0.02),
        child: FloatingActionButton(
          onPressed: () {
            context.push('/note_edit');
          },
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
