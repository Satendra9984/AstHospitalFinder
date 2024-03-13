import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:nearby_hospital_locator/screens/authentication/auth_cubit/auth_cubit_cubit.dart';

class LocatorHomeScreen extends StatefulWidget {
  LocatorHomeScreen({super.key});

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  State<LocatorHomeScreen> createState() => _LocatorHomeScreenState();
}

class _LocatorHomeScreenState extends State<LocatorHomeScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final Location location = Location();
  LoadingStatus _loadingStatus = LoadingStatus.initial;
  LatLng? _currentUserPosition;

  Set<Marker>? markers;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Builder(builder: (context) {
        if (_currentUserPosition != null) {
          return  GoogleMap(
            mapType: MapType.hybrid,
            initialCameraPosition: CameraPosition(
              target: _currentUserPosition!,
              zoom: 14.4746,
            ),
            markers: markers ?? <Marker>{},
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          );
        }

        return SizedBox(
          // color: Colors.amber,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_location_alt_rounded,
                color: Colors.green,
                size: 64.0,
              ),
              TextButton(
                onPressed: () async {
                  await getUserLocation();
                  // await fetchNearbyRestaurants(26.7377647, 80.856979);
                  // debugPrint(
                  //     '${_currentUserPosition}, ${markers?.length}, ${_loadingStatus}');
                },
                child: const Text(
                  'Add Current Location',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (_loadingStatus == LoadingStatus.loading)
                const Text(
                  'Locating...',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> getUserLocation() async {
    bool serviceEnabled = false;
    PermissionStatus permissionGranted = PermissionStatus.denied;

    // serviceEnabled = await location.serviceEnabled();
    // if (!serviceEnabled) {
    // serviceEnabled = await location.requestService();
    // if (!serviceEnabled) {
    // return;
    // }
    // }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _loadingStatus = LoadingStatus.loading;
    });
    await location.getLocation().then(
      (LocationData currentLocation) async {
        _currentUserPosition = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );

        await fetchNearbyRestaurants(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );

        setState(() {
          _currentUserPosition;
          _loadingStatus = LoadingStatus.loaded;
        });
        return;
      },
    );
  }

  Future<void> fetchNearbyRestaurants(
    double lat,
    double lng,
  ) async {
    Set<Marker> lmarkers = <Marker>{};
    Marker usermarker = Marker(
      markerId: const MarkerId('user_default_location'),
      position: LatLng(lat, lng),
    );

    lmarkers.add(usermarker);
    try {
      // const String baseUrl =
      //     'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
      final String location = '$lat,$lng';
      const int radius = 5000; // Define your desired radius in meters
      const String type = 'hospitals'; // Search for restaurants
      // final String url =
      //     '$baseUrl?location=$location&radius=$radius&type=$type&key=AIzaSyD3A9eyljjrwvGIle9HpKuB63vhLPuixww';

      final String url =
          'https://overpass-api.de/api/interpreter?data=[out:json];(node(around:20000,$lat,$lng)["amenity"="hospital"];);out;';

      final response = await http.get(Uri.parse(url));
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200) {
        List results = jsonData['elements'];
        // var enc = const JsonEncoder.withIndent("  ");
        // debugPrint(enc.convert(results));

        // Process the results here
        for (var place in results) {
          LatLng position = LatLng(place["lat"], place["lon"]);
          Marker newm = Marker(
            markerId: MarkerId(place["id"].toString()),
            position: position,
          );

          lmarkers.add(newm);
        }
      } else {
        // Handle errors
        debugPrint('Error fetching nearby restaurants');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    setState(() {
      markers = lmarkers;
    });
    // debugPrint('[markers]:  $markers.toString()');
  }
}

enum LoadingStatus {
  initial,
  loading,
  loaded,
  errorLoading,
}
