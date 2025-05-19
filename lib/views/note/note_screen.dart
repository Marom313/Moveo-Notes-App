import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../models/note_model.dart';
import '../../services/map_controller_service.dart';
import '../../viewmodels/navigation_vm.dart';
import '../../viewmodels/note_vm.dart';

class NoteScreen extends StatefulWidget {
  final Note? note;
  final int? noteIndex;

  const NoteScreen({super.key, this.note, this.noteIndex});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _bodyController.text = widget.note!.body;
      _selectedDate = widget.note!.dateCreated;
    }
  }

  Future<bool> _ensureLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('❌ Location permission denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('❌ Location permission permanently denied');
      return false;
    }

    return true;
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all fields before saving."),
        ),
      );
      return;
    }

    if (!await _ensureLocationPermission()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission is required.")),
      );
      return;
    }

    final pos = await Geolocator.getCurrentPosition();
    final location = LatLng(pos.latitude, pos.longitude);

    final newNote = Note(
      locationCreated: location,
      dateCreated: _selectedDate,
      title: title,
      body: body,
    );

    final noteVM = Provider.of<NoteViewModel>(context, listen: false);
    if (widget.noteIndex != null) {
      await noteVM.updateNote(widget.noteIndex!, newNote);
    } else {
      await noteVM.addNote(newNote);
    }

    //SET tab to Map and pop
    final navVM = Provider.of<NavigationViewModel>(context, listen: false);
    navVM.setTab(1);
    await Future.delayed(Duration(milliseconds: 300)); // allow UI to update
    navVM.setTab(1); // switch to map tab
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.noteIndex != null
              ? "Note updated successfully!"
              : "Note saved successfully!",
        ),
      ),
    );

    Navigator.of(context).pop(); // go back

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lastNote = noteVM.notes.last;
      Provider.of<MapControllerService>(context, listen: false).moveTo(
        lastNote.locationCreated.latitude,
        lastNote.locationCreated.longitude,
      );
    });

    // if (context.mounted) {
    //   final lastNote = noteVM.notes.last;
    //   final mapController =
    //       Provider.of<MapControllerService>(context, listen: false).controller;
    //   mapController.move(lastNote.locationCreated, 13);
    // } // switch to Map tab
    // if (context.mounted) {
    //   Navigator.of(context).pop(); // back to main screen
    // } // go back to MainScreen
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder:
          (context, child) => Theme(
            data: ThemeData.light(), // Feel free to customize
            child: child!,
          ),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Note")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Note name'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  "Date: ${_selectedDate.toLocal().toString().split(' ')[0]}",
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _pickDate,
                  child: const Text("Select Date"),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: 'Note description',
                  alignLabelWithHint: true,
                ),
                maxLines: null,
                expands: true,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.withOpacity(0.3),
                  ),
                  onPressed: _saveNote,
                  child: const Text("Save"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.3),
                  ),
                  onPressed: () async {
                    if (widget.noteIndex != null) {
                      final noteVM = Provider.of<NoteViewModel>(
                        context,
                        listen: false,
                      );
                      await noteVM.deleteNote(widget.noteIndex!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("🗑️ Note deleted.")),
                      );
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text("Delete"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
