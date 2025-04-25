import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;


class SportCourtFinder extends StatefulWidget {
  @override
  _SportCourtFinderState createState() => _SportCourtFinderState();
}

class _SportCourtFinderState extends State<SportCourtFinder> {
  GoogleMapController? _mapController; //Controls the Google Map 
  late LatLng _currentPosition; //	Stores the user's current GPS location
  String _selectedSport = 'Football';// 	Current selected sport
  Set<Marker> _markers = {}; // Map markers for nearby courts
  Set<Polyline> _polylines = {}; // Added for routes
  final List<String> _sports = ['Football', 'Basketball', 'Tennis'];
  bool _isLoading = false;  // Whether data is loading (not used in current UI)
  TextEditingController _searchController = TextEditingController(); //Controls the text in the search bar
  FocusNode _searchFocusNode = FocusNode(); // Used to detect focus on the search field
  bool _showSportsList = false; // Whether the dropdown list is shown
  LatLng? _selectedDestination; // Added to track selected court
  String? _travelTime; // Added to store travel time

  final String googleApiKey = 'AIzaSyBsxe_cvisFPpMaddsoyjO0z99FuIzuE9A';

  @override
  void initState() {
    super.initState();
    _currentPosition = LatLng(34.4511,35.8107);
    // Get actual position immediately
    _determinePosition();
    _searchController.text = _selectedSport;
    // Close dropdown when focus is lost
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        setState(() {
          _showSportsList = false;
        });
      }
    });
  }
  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
  Future<void> _determinePosition() async {
    // We removed the loading state here
    
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError('Location services are disabled');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError('Location permissions are denied');
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      _showError('Location permissions are permanently denied');
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );
      
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        // Clear previous routes when location is updated
        _polylines = {};
        _travelTime = null;
      });
      
      _moveCamera(_currentPosition);
      _fetchNearbyCourts(_selectedSport);
    } catch (e) {
      _showError('Failed to get current location: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red)
    );
  }

  Future<void> _fetchNearbyCourts(String sport) async {
    setState(() {
      // Clear previous routes when fetching new courts
      _polylines = {};
      _travelTime = null;
      _selectedDestination = null;
    });
    
    final keyword = "$sport court";
    final url =
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${_currentPosition.latitude},${_currentPosition.longitude}&radius=5000&keyword=$keyword&key=$googleApiKey";

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final List results = data['results'];
        Set<Marker> newMarkers = {};
        
        for (var result in results) {
          final location = result['geometry']['location'];
          final name = result['name'];
          final latLng = LatLng(location['lat'], location['lng']);
          final address = result['vicinity'] ?? 'No address available';
          final rating = result['rating']?.toString() ?? 'No rating';

          final BitmapDescriptor markerIcon;
          if (sport == 'Football') {
            markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
          } else if (sport == 'Basketball') {
            markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
          } else {
            markerIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
          }

          newMarkers.add(
            Marker(
              markerId: MarkerId(name),
              position: latLng,
              infoWindow: InfoWindow(
                title: name,
                snippet: "$address • Rating: $rating",
              ),
              icon: markerIcon,
              onTap: () {
                _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
                // Get directions when marker is tapped
                _getDirections(latLng, name);
              },
            ),
          );
        }
        
        setState(() {
          _markers = newMarkers;
        });
        
        if (newMarkers.isEmpty) {
          _showMessage('No ${sport.toLowerCase()} courts found nearby');
        } else {
          _showMessage('Found ${newMarkers.length} ${sport.toLowerCase()} courts nearby');
        }
      } else {
        _showError('Failed to fetch places: ${data['status']}');
      }
    } catch (e) {
      _showError('Network error: $e');
    }
  }

  // New method to get directions between two points
  Future<void> _getDirections(LatLng destination, String destinationName) async {
    setState(() {
      _selectedDestination = destination;
    });

    final String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${_currentPosition.latitude},${_currentPosition.longitude}&destination=${destination.latitude},${destination.longitude}&mode=driving&key=$googleApiKey";

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        // Get route points
        List<LatLng> points = [];
        List<dynamic> steps = data['routes'][0]['legs'][0]['steps'];
        for (int i = 0; i < steps.length; i++) {
          String polyline = steps[i]['polyline']['points'];
          points.addAll(_decodePolyline(polyline));
        }

        // Get estimated duration
        final duration = data['routes'][0]['legs'][0]['duration']['text'];
        final distance = data['routes'][0]['legs'][0]['distance']['text'];

        // Create polyline
        final Polyline route = Polyline(
          polylineId: PolylineId('route'),
          points: points,
          color: Colors.blue,
          width: 5,
        );

        setState(() {
          _polylines = {route};
          _travelTime = 'To $destinationName: $distance ($duration)';
        });

        // Adjust camera to show the whole route
        _fitPolylineInMap(points);
      } else {
        _showError('Failed to get directions: ${data['status']}');
      }
    } catch (e) {
      _showError('Failed to get directions: $e');
    }
  }

  // Helper method to decode the polyline string
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      final p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  }

  // Adjust map bounds to show the entire route
  void _fitPolylineInMap(List<LatLng> points) {
    if (points.isEmpty) return;
    
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        70, // padding
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message))
    );
  }
  void _moveCamera(LatLng position) {
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(position, 14));
  }
  void _selectSport(String sport) {
    setState(() {
      _selectedSport = sport;
      _searchController.text = sport;
      _showSportsList = false;
      // Clear previous routes when changing sport
      _polylines = {};
      _travelTime = null;
      _selectedDestination = null;
    });
    _fetchNearbyCourts(sport);
  }
  // Clear directions and reset view
  void _clearDirections() {
    setState(() {
      _polylines = {};
      _travelTime = null;
      _selectedDestination = null;
    });
    _moveCamera(_currentPosition);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
    icon: Icon(Icons.arrow_back),
    onPressed: () => Navigator.of(context).pop(), // Pops the current screen
  ),
        title: Text('Sport Court Finder'),
        elevation: 0,
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _currentPosition, zoom: 14),
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: _markers,
            polylines: _polylines, // Added polylines to the map
            mapType: MapType.normal,
          ),
          
          // Search bar with dropdown
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Material(
                        borderRadius: BorderRadius.circular(8),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Search for sports courts...',
                            prefixIcon: Icon(Icons.search),
                            suffixIcon: Icon(Icons.arrow_drop_down),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          readOnly: true,
                          onTap: () {
                            setState(() {
                              _showSportsList = !_showSportsList;
                            });
                          },
                        ),
                      ),
                      
                      // Dropdown list
                      if (_showSportsList)
                        Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                          child: Container(
                            width: double.infinity,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: _sports.map((sport) {
                                return InkWell(
                                  onTap: () => _selectSport(sport),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: sport != _sports.last ? Colors.grey.shade300 : Colors.transparent,
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          sport == 'Football' ? Icons.sports_soccer :
                                          sport == 'Basketball' ? Icons.sports_basketball : Icons.sports_tennis,
                                          color: Colors.grey.shade700,
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          sport,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: _selectedSport == sport ? FontWeight.bold : FontWeight.normal,
                                            color: _selectedSport == sport ? Colors.blue : Colors.black87,
                                          ),
                                        ),
                                        Spacer(),
                                        if (_selectedSport == sport)
                                          Icon(Icons.check, color: Colors.blue),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Travel time info panel (when a route is displayed)
          if (_travelTime != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.directions_car, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _travelTime!,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.grey),
                      onPressed: _clearDirections,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          
          // Removed the loading indicator container
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_selectedDestination != null)
            FloatingActionButton(
              heroTag: 'clear',
              onPressed: _clearDirections,
              mini: true,
              child: Icon(Icons.clear),
              tooltip: 'Clear route',
            ),
          SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'refresh',
            onPressed: () => _fetchNearbyCourts(_selectedSport),
            mini: true,
            child: Icon(Icons.refresh),
            tooltip: 'Refresh courts',
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'location',
            onPressed: () {
              _determinePosition();
            },
            child: Icon(Icons.my_location),
            tooltip: 'My location',
          ),
        ],
      ),
    );
  }
}