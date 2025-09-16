import 'dart:io';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

class AdapterLoadImg {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickImageAndConvertBase64() async {
    bool hasPermission = false;

    final status = await Permission.photos.request();
    print('Permission status: $status');

    if (status.isGranted) {
      hasPermission = true;
    } else if (status.isDenied) {
      hasPermission = false;
    } else if (status.isPermanentlyDenied) {
      hasPermission = false;
    }

    if (!hasPermission) {
      return null;
    }

    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile == null) return null;

    final bytes = File(pickedFile.path).readAsBytesSync();
    return base64Encode(bytes);
  }

  // / Pide permisos y devuelve el archivo seleccionado (XFile) o null
  Future<XFile?> pickImageSendFile() async {
    bool hasPermission = false;

    if (Platform.isIOS) {
      final status = await Permission.photos.request();
      hasPermission = status.isGranted || status.isLimited;
    } else if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      hasPermission = status.isGranted;
    }

    if (!hasPermission) {
      return null;
    }

    return await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
  }

  /// 🔹 Versión que devuelve solo el path
  Future<String?> pickImagePath() async {
    final file = await pickImageSendFile();
    return file?.path;
  }
}
