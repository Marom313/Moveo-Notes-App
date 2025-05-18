import 'package:latlong2/latlong.dart';

class Note {
  final LatLng locationCreated;
  final DateTime dateCreated;
  final String title;
  final String body;
  // final dynamic image; // <-- We'll add this later

  Note({
    required this.locationCreated,
    required this.dateCreated,
    required this.title,
    required this.body,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      locationCreated: LatLng(
        json['locationCreated']['lat'],
        json['locationCreated']['lng'],
      ),
      dateCreated: DateTime.parse(json['dateCreated']),
      title: json['title'],
      body: json['body'],
    );
  }

  Map<String, dynamic> toJson() => {
    'locationCreated': {
      'lat': locationCreated.latitude,
      'lng': locationCreated.longitude,
    },
    'dateCreated': dateCreated.toIso8601String(),
    'title': title,
    'body': body,
  };
}
