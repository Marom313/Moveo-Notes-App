import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapControllerService extends ChangeNotifier {
  final MapController controller = MapController();

  void moveTo(double lat, double lng, {double zoom = 13}) {
    controller.move(LatLng(lat, lng), zoom);
  }
}
