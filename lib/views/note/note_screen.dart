import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isar/isar.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../bonus/image_picker_widget.dart';
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
  String? _imagePath;

  @override
  void initState() {
    super.initState();

    if (widget.note != null) {
      _titleController.text = widget.note!.title!;
      _bodyController.text = widget.note!.body!;
      _selectedDate = widget.note!.dateCreated!;
      _imagePath = widget.note!.imagePath;
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
    final noteVM = Provider.of<NoteViewModel>(context, listen: false);

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
          ..body = body
          ..imagePath = _imagePath;

    if (widget.note != null) {
      await noteVM.updateNote(newNote);
    } else {
      await noteVM.addNote(newNote);
    }

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lastNote = noteVM.notes.last;
      context.read<MainViewModel>().moveTo(
        lastNote.lat ?? 0.0,
        lastNote.long ?? 0.0,
      );
    });
    context.go('/main');
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder:
          (context, child) => Theme(data: ThemeData.light(), child: child!),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text("Note")),
      body: Padding(
        padding: EdgeInsets.all(height * 0.02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Date: ${_selectedDate.toLocal().toString().split(' ')[0]}",
                ),
                SizedBox(width: width * 0.06),
                ElevatedButton(
                  onPressed: _pickDate,
                  child: const Text("Select Date"),
                ),
              ],
            ),
            SizedBox(height: height * 0.02),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Note name'),
            ),
            SizedBox(height: height * 0.02),
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
            SizedBox(height: height * 0.02),
            if (_imagePath != null)
              Image.file(
                File(_imagePath!),
                height: height * 0.35,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            Row(
              children: [
                SizedBox(width: width * 0.12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Camera"),
                  onPressed: () async {
                    final path = await ImagePickerHelper.pickImage(
                      context,
                      ImageSource.camera,
                    );
                    if (path != null) {
                      setState(() => _imagePath = path);
                    }
                  },
                ),
                SizedBox(width: width * 0.08),
                ElevatedButton.icon(
                  icon: const Icon(Icons.photo),
                  label: const Text("Gallery"),
                  onPressed: () async {
                    final path = await ImagePickerHelper.pickImage(
                      context,
                      ImageSource.gallery,
                    );
                    if (path != null) {
                      setState(() => _imagePath = path);
                    }
                  },
                ),
              ],
            ),

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
                    if (widget.note != null) {
                      final noteVM = Provider.of<NoteViewModel>(
                        context,
                        listen: false,
                      );
                      await noteVM.deleteNote(widget.note!);
                      context.read<MainViewModel>().setTab(0);
                      context.go('/main');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Note deleted successfully!"),
                        ),
                      );
                    }
                    // Navigator.of(context).pop();
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
