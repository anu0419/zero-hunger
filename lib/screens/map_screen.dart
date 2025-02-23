import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final Set<Marker> markers = {};
  LatLng _center = const LatLng(21.7679, 78.8718); // Default to India's center
  bool _isLoading = true;
  bool _hasGooglePlayServices = true;

  @override
  void initState() {
    super.initState();
    _checkGooglePlayServices();
  }

  Future<void> _checkGooglePlayServices() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _hasGooglePlayServices = false;
          _isLoading = false;
        });
        return;
      }

      // Try to request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _hasGooglePlayServices = false;
            _isLoading = false;
          });
          return;
        }
      }

      // If we get here, we can try to initialize the map
      await _initializeMap();
    } catch (e) {
      // If we get an error about Google Play Services, handle it
      if (e.toString().contains('Google Play services')) {
        setState(() {
          _hasGooglePlayServices = false;
          _isLoading = false;
        });
      } else {
        debugPrint('Error checking Google Play Services: $e');
      }
    }
  }

  Future<void> _initializeMap() async {
    try {
      await _getCurrentLocation();
      await loadMarkers();
    } catch (e) {
      debugPrint('Error initializing map: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      if (mounted) {
        setState(() {
          _center = LatLng(position.latitude, position.longitude);
          markers.add(
            Marker(
              markerId: const MarkerId('current_location'),
              position: _center,
              infoWindow: const InfoWindow(title: 'Your Location'),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            ),
          );
        });
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  Future<void> loadMarkers() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('users').get();
      
      if (mounted) {
        setState(() {
          markers.addAll(
            snapshot.docs.where((doc) {
              final data = doc.data();
              return data['latitude'] != null && data['longitude'] != null;
            }).map((doc) {
              final data = doc.data();
              return Marker(
                markerId: MarkerId(doc.id),
                position: LatLng(data['latitude'], data['longitude']),
                infoWindow: InfoWindow(
                  title: data['name'] ?? 'User',
                  snippet: data['role'] ?? 'Unknown role',
                ),
              );
            }),
          );
        });
      }
    } catch (e) {
      debugPrint('Error loading markers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Supply Chain Map"),
        actions: _hasGooglePlayServices ? [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadMarkers,
          ),
        ] : null,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : !_hasGooglePlayServices
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Google Play Services Required',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This feature requires Google Play Services, which are not available on your device. Please try using a device with Google Play Services installed.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            )
          : GoogleMap(
              onMapCreated: (controller) => mapController = controller,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 5.0,
              ),
              markers: markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapType: MapType.normal,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              compassEnabled: true,
            ),
    );
  }
}
