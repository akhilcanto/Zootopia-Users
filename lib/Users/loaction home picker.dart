import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:zootopia/Users/function/AppbarZootioia.dart';

class SetHomeLocationScreen extends StatefulWidget {
  final String petId;
  const SetHomeLocationScreen({required this.petId});

  @override
  State<SetHomeLocationScreen> createState() => _SetHomeLocationScreenState();
}

class _SetHomeLocationScreenState extends State<SetHomeLocationScreen> {
  Position? _currentPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          _currentPosition = position;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permission denied')),
        );
      }
    } catch (e) {
      print("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveLocationToFirebase() async {
    if (_currentPosition == null) return;

    try {
      DatabaseReference ref = FirebaseDatabase.instance
          .ref('pets/${widget.petId}/geofence_center');

      await ref.set({
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Home location saved!')),
      );
    } catch (e) {
      print("Error saving location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: zootopiaAppBar(),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : _currentPosition == null
            ? Text("Location not available")
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Latitude: ${_currentPosition!.latitude}"),
            Text("Longitude: ${_currentPosition!.longitude}"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveLocationToFirebase,
              child: Text("Set Home Location"),
            ),
          ],
        ),
      ),
    );
  }
}
