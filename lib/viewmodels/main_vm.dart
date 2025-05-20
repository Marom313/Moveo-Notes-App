import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MainViewModel extends ChangeNotifier {
  final MapController controller = MapController();
  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void setTab(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void moveTo(double lat, double lng, {double zoom = 13}) {
    controller.move(LatLng(lat, lng), zoom);
    // notifyListeners();
  }
}
