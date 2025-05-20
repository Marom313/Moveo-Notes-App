import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<String?> pickImage(
    BuildContext context,
    ImageSource source,
  ) async {
    try {
      bool granted = false;

      if (source == ImageSource.camera) {
        granted = await Permission.camera.request().isGranted;
      } else {
        if (Platform.isAndroid) {
          granted =
              await Permission.photos.request().isGranted ||
              await Permission.mediaLibrary.request().isGranted ||
              await Permission.storage.request().isGranted;
        } else {
          granted = await Permission.photos.request().isGranted;
        }
      }

      if (!granted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Permission denied")));
        return null;
      }

      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (picked == null) return null;

      final saveDir = await getApplicationDocumentsDirectory();
      final savePath = '${saveDir.path}/${picked.name}';

      await picked.saveTo(savePath);
      return savePath;
    } catch (e) {
      debugPrint('Image pick/save error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      return null;
    }
  }
}
