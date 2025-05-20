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
        });
      } catch (e) {
        debugPrint('Location error: $e');
        setState(() {
          _currentPosition = const LatLng(
            32.0853,
            34.7818,
          ); //location is Tel Aviv
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
    final devicePadding = MediaQuery.of(context).viewInsets;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    int selectedIndex = navVM.selectedIndex;

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
                          padding: devicePadding,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _sortDescending = !_sortDescending;
                              });
                            },
                            child: Row(
                              children: [
                                SizedBox(width: width * 0.05),
                                const Text(
                                  'Sort by Date',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: width * 0.02),
                                Icon(
                                  _sortDescending
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  size: height * 0.02,
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
          onPressed: () => context.go('/note_edit'),
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
