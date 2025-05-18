import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../models/note_model.dart';
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

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty || body.isEmpty) return;

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

    Navigator.of(context).pop();
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
