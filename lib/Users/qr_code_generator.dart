import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zootopia/Users/function/AppbarZootioia.dart';


class QRCodeGenerator extends StatefulWidget {
  QRCodeGenerator({super.key, required this.qrData, required this.pet_name});
  final String qrData;
  final String pet_name;


  @override
  State<QRCodeGenerator> createState() => _QRCodeGeneratorState();
}

class _QRCodeGeneratorState extends State<QRCodeGenerator> {
  final ScreenshotController _screenshotController = ScreenshotController();
  String? _savedFilePath;

  // Function to save QR Code in the Zootopia folder
  Future<void> _saveQRCode() async {
    try {
      if (await _requestStoragePermission()) {
        String zootopiaPath = await ExternalPath.getExternalStoragePublicDirectory(
            ExternalPath.DIRECTORY_PICTURES) + "/Zootopia";

        // Create folder if it doesn’t exist
        Directory(zootopiaPath).createSync(recursive: true);

        final filePath = '$zootopiaPath/qr_code_${DateTime.now().millisecondsSinceEpoch}.png';

        final imageFile = await _screenshotController.captureAndSave(
          zootopiaPath,
          fileName: 'zootopia_${widget.pet_name}_${DateTime.now().millisecondsSinceEpoch}.png',
        );

        if (imageFile != null) {
          setState(() {
            _savedFilePath = imageFile;
          });

          // Refresh gallery so image appears instantly
          await _refreshGallery(imageFile);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('QR Code saved to Zootopia folder!')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied!')),
        );
      }
    } catch (e) {
      debugPrint("Error saving QR Code: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save QR Code')),
      );
    }
  }

  // Refresh gallery so the image appears in the Photos app
  Future<void> _refreshGallery(String filePath) async {
    try {
      final path = Uri.parse(filePath).toString();
      await Future.delayed(const Duration(seconds: 1)); // Ensure file is written before scanning
      await Process.run('am', ['broadcast', '-a', 'android.intent.action.MEDIA_SCANNER_SCAN_FILE', '-d', path]);
    } catch (e) {
      debugPrint("Error refreshing gallery: $e");
    }
  }

  // Share the saved QR Code
  Future<void> _shareQRCode() async {
    try {
      final imageBytes = await _screenshotController.capture();
      if (imageBytes != null) {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/qr_code.png';
        final imageFile = File(filePath)..writeAsBytesSync(imageBytes);

        await Share.shareFiles([imageFile.path], text: "Here is my pet's QR code!");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to capture QR Code!')),
        );
      }
    } catch (e) {
      debugPrint("Error sharing QR Code: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to share QR Code')),
      );
    }
  }


  // Request storage permissions
  Future<bool> _requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      return true;
    }
    if (await Permission.manageExternalStorage.request().isGranted) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: zootopiaAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Screenshot(
              controller: _screenshotController,
              child: QrImageView(
                data: widget.qrData,
                version: QrVersions.auto,
                size: 200.0,
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20.0),
            const Text("Scan this QR code"),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _saveQRCode,
            child: const Icon(Icons.download),
            tooltip: "Save QR Code",
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _shareQRCode,
            child: const Icon(Icons.share),
            tooltip: "Share QR Code",
          ),
        ],
      ),
    );
  }
}
