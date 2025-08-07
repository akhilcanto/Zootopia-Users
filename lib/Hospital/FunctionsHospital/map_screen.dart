// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// class MapScreen extends StatefulWidget {
//   @override
//   _MapScreenState createState() => _MapScreenState();
// }
//
// class _MapScreenState extends State<MapScreen> {
//   LatLng? selectedLocation;
//   late GoogleMapController mapController;
//
//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//   }
//
//   void _onTap(LatLng position) {
//     setState(() {
//       selectedLocation = position;
//     });
//   }
//
//   void _confirmLocation() {
//     if (selectedLocation != null) {
//       Navigator.pop(context, selectedLocation);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please select a location')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Select Location')),
//       body: GoogleMap(
//         onMapCreated: _onMapCreated,
//         initialCameraPosition: CameraPosition(
//           target: LatLng(20.5937, 78.9629), // Default to India
//           zoom: 5,
//         ),
//         onTap: _onTap,
//         markers: selectedLocation != null
//             ? {Marker(markerId: MarkerId('selected'), position: selectedLocation!)}
//             : {},
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _confirmLocation,
//         child: Icon(Icons.check),
//       ),
//     );
//   }
// }
