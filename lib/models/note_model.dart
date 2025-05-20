import 'package:isar/isar.dart';

part 'note_model.g.dart';

@Collection()
class Note {
  Id id = Isar.autoIncrement;
  @Index()
  late String userId;

  DateTime? dateCreated;
  String? title;
  String? body;
  double? lat;
  double? long;
  String? imagePath;
}
