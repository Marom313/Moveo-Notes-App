import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../models/note_model.dart';
import '../../viewmodels/auth_vm.dart';
import '../../viewmodels/main_vm.dart';
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
      _titleController.text = widget.note!.title!;
      _bodyController.text = widget.note!.body!;
      _selectedDate = widget.note!.dateCreated!;
    }
  }

  Future<bool> _ensureLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permission denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permission permanently denied');
      return false;
    }

    return true;
  }

  Future<void> _saveNote() async {
    final userVM = Provider.of<AuthViewModel>(context, listen: false);
    final userId = userVM.currentUser?.uid ?? '';
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

    final newNote =
        Note()
          ..id = widget.note?.id ?? Isar.autoIncrement
          ..userId = userId
          ..lat = location.latitude
          ..long = location.longitude
          ..dateCreated = _selectedDate
          ..title = title
          ..body = body;

    final noteVM = Provider.of<NoteViewModel>(context, listen: false);
    if (widget.note != null) {
      await noteVM.updateNote(newNote);
    } else {
      await noteVM.addNote(newNote);
    }

    //SET tab to Map and pop
    final navVM = Provider.of<MainViewModel>(context, listen: false);
    navVM.setTab(1);
    await Future.delayed(Duration(milliseconds: 300)); // allow UI to update
    navVM.setTab(1); // switch to map tab
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.noteIndex != null
              ? "Note updated successfully!"
              : "Note added successfully!",
        ),
      ),
    );

    Navigator.of(context).pop(); // go back

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lastNote = noteVM.notes.last;
      context.read<MainViewModel>().moveTo(
        lastNote.lat ?? 0.0,
        lastNote.long ?? 0.0,
      );
    });
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
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Note name'),
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
                      await noteVM.deleteNote(widget.note!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Note deleted successfully!"),
                        ),
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
