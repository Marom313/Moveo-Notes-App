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
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../viewmodels/note_vm.dart';
import '../note/note_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Provider.of<NoteViewModel>(context, listen: false).loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    final notes = Provider.of<NoteViewModel>(context).notes;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    Widget content;

    if (selectedIndex == 0) {
      // Notes List Mode
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
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) => NoteScreen(note: note, noteIndex: index),
                        ),
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
      // Map Mode (empty for now)
      // content = const Center(child: Text("Map view coming soon..."));
      content = Padding(
        padding: const EdgeInsets.all(12.0),
        // child: FlutterMap(
        //   options: MapOptions(
        //     center:
        //         notes.isNotEmpty
        //             ? notes.last.locationCreated
        //             : const LatLng(
        //               32.0853,
        //               34.7818,
        //             ), // Tel Aviv as a safe default
        //     zoom: 13,
        //     onTap: (_, __) {},
        //   ),
        //   children: [
        //     TileLayer(
        //       urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        //       userAgentPackageName: 'com.example.app',
        //     ),
        //     MarkerLayer(
        //       markers:
        //           notes.map((note) {
        //             return Marker(
        //               point: note.locationCreated,
        //               width: 40,
        //               height: 40,
        //               builder:
        //                   (ctx) => GestureDetector(
        //                     onTap: () {
        //                       Navigator.of(context).push(
        //                         MaterialPageRoute(
        //                           builder:
        //                               (_) => NoteScreen(
        //                                 note: note,
        //                                 noteIndex: notes.indexOf(note),
        //                               ),
        //                         ),
        //                       );
        //                     },
        //                     child: const Icon(
        //                       Icons.location_pin,
        //                       color: Colors.red,
        //                       size: 36,
        //                     ),
        //                   ),
        //             );
        //           }).toList(),
        //     ),
        //   ],
        // ),
        child: FlutterMap(
          mapController: MapController(),
          options: MapOptions(
            initialCenter:
                notes.isNotEmpty
                    ? notes.last.locationCreated
                    : const LatLng(32.0853, 34.7818),
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
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder:
                                  (_) => NoteScreen(
                                    note: note,
                                    noteIndex: notes.indexOf(note),
                                  ),
                            ),
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
        onTap: (index) => setState(() => selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Note'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(right: width * 0.03, bottom: height * 0.02),
        child: FloatingActionButton(
          onPressed: () {
            // TODO: Navigate to NoteScreen for new note
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const NoteScreen()));
          },
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
