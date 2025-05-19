// // import 'package:flutter/material.dart';
// // import 'package:go_router/go_router.dart';
// // import '../../services/auth_service.dart';
// //
// // class MainScreen extends StatelessWidget {
// //   const MainScreen({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final height = MediaQuery.of(context).size.height;
// //     final width = MediaQuery.of(context).size.width;
// //
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text("Moveo Notes App"),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.logout),
// //             onPressed: () async {
// //               await AuthService().logout();
// //               context.go('/login');
// //             },
// //           ),
// //         ],
// //       ),
// //       body: Center(
// //         child: Text(
// //           "Welcome to the Main Screen!",
// //           style: Theme.of(context).textTheme.headlineSmall,
// //         ),
// //       ),
// //       floatingActionButton: Padding(
// //         padding: EdgeInsets.only(right: width * 0.03, bottom: height * 0.02),
// //         child: FloatingActionButton(
// //           onPressed: () {
// //             // Later: navigate to "add note" or "map" page
// //           },
// //           child: const Icon(Icons.add),
// //         ),
// //       ),
// //       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
// //     );
// //   }
// // }
// // This patch fixes the rendering and rebuild timing issues for the map and SharedPreferences.
// // It delays map rendering until after loadNotes() completes and location is retrieved.
//
// import 'package:assignment_app/models/old_note_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:go_router/go_router.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:provider/provider.dart';
// import '../../constants/colors.dart';
// import '../../services/auth_service.dart';
// import '../../services/map_controller_service.dart';
// import '../../viewmodels/auth_vm.dart';
// import '../../viewmodels/main_vm.dart';
// import '../../viewmodels/note_vm.dart';
// import '../../widgets/main_tab.dart';
// import '../../widgets/map_view.dart';
// import '../note/note_screen.dart';
// import 'package:geolocator/geolocator.dart';
//
// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});
//
//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }
//
// class _MainScreenState extends State<MainScreen> {
//   bool _isReady = false;
//   LatLng? _currentPosition;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await Provider.of<NoteViewModel>(context, listen: false).loadNotes();
//       try {
//         final pos = await Geolocator.getCurrentPosition();
//         setState(() {
//           _currentPosition = LatLng(pos.latitude, pos.longitude);
//           _isReady = true;
//         });
//       } catch (e) {
//         debugPrint('Location error: $e');
//         setState(() {
//           _currentPosition = const LatLng(32.0853, 34.7818); // fallback to TLV
//           _isReady = true;
//         });
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final navVM = context.read<MainViewModel>();
//     // final navVM = Provider.of<NavigationViewModel>(context);
//     bool _sortDescending = true;
//
//     final originalNotes = Provider.of<NoteViewModel>(context).notes;
//     final notes = [...originalNotes]..sort(
//       (a, b) =>
//           _sortDescending
//               ? b.dateCreated.compareTo(a.dateCreated)
//               : a.dateCreated.compareTo(b.dateCreated),
//     );
//
//     final height = MediaQuery.of(context).size.height;
//     final width = MediaQuery.of(context).size.width;
//     int selectedIndex = navVM.selectedIndex;
//
//     // if (!_isReady) {
//     //   return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     // }
//
//     // Padding(
//     //   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
//     //   child: GestureDetector(
//     //     onTap: () {
//     //       setState(() {
//     //         _sortDescending = !_sortDescending;
//     //       });
//     //     },
//     //     child: Row(
//     //       children: [
//     //         const Text(
//     //           'Sort by Date',
//     //           style: TextStyle(fontWeight: FontWeight.bold),
//     //         ),
//     //         const SizedBox(width: 8),
//     //         Icon(
//     //           _sortDescending ? Icons.arrow_downward : Icons.arrow_upward,
//     //           size: 18,
//     //         ),
//     //       ],
//     //     ),
//     //   ),
//     // );
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Moveo Notes App"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () async {
//               // await Provider.of<AuthViewModel>(context).logout();
//
//               context.go('/login');
//             },
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child:
//             selectedIndex == 0
//                 ? MainTab(notes: notes)
//                 : MapView(notes: notes, currentPosition: _currentPosition),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: selectedIndex,
//         onTap: (index) => navVM.setTab(index),
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Note'),
//           BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
//         ],
//       ),
//       floatingActionButton: Padding(
//         padding: EdgeInsets.only(right: width * 0.03, bottom: height * 0.02),
//         child: FloatingActionButton(
//           onPressed: () {
//             context.push('/note_edit');
//           },
//           child: const Icon(Icons.add),
//         ),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../viewmodels/main_vm.dart';
import '../../viewmodels/note_vm.dart';
import '../../widgets/main_tab.dart';
import '../../widgets/map_view.dart';
import 'package:geolocator/geolocator.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isReady = false;
  LatLng? _currentPosition;
  bool _sortDescending = true;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<NoteViewModel>(
        context,
        listen: false,
      ).loadNotesWithContext(context);
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

  void _onPageChanged(int index) {
    context.read<MainViewModel>().setTab(index);
  }

  @override
  Widget build(BuildContext context) {
    final navVM = Provider.of<MainViewModel>(context);
    final notesVM = Provider.of<NoteViewModel>(context);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    int selectedIndex = navVM.selectedIndex;

    // Sort the notes by date
    final notes = [...notesVM.notes]..sort(
      (a, b) =>
          _sortDescending
              ? b.dateCreated!.compareTo(a.dateCreated!)
              : a.dateCreated!.compareTo(b.dateCreated!),
    );

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
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          SafeArea(
            child:
                selectedIndex == 0
                    ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _sortDescending = !_sortDescending;
                              });
                            },
                            child: Row(
                              children: [
                                const Text(
                                  'Sort by Date',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _sortDescending
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(child: MainTab(notes: notes)),
                      ],
                    )
                    : MapView(notes: notes, currentPosition: _currentPosition),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => navVM.setTab(index),
        // onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Note'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(right: width * 0.03, bottom: height * 0.02),
        child: FloatingActionButton(
          onPressed: () => context.push('/note_edit'),
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
