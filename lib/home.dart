// ignore_for_file: prefer_final_fields, unused_field, avoid_print, unused_element, non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_map/consts.dart';
import 'package:google_map/location_model.dart';
import 'package:google_map/marker_data.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<MyLocationModel> myLocationModel = [];
  final MapController _mapController = MapController();
  List<MarkerData> _markerData = [];
  List<Marker> _markers = [];
  LatLng? _selectedPosition;
  LatLng? _myLocation;
  LatLng? _draggedPosition;
  bool _isDragging = false;
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  
  // get current location
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permission are denied");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error("Location permission are permanently denied");
    }
    }
    return await Geolocator.getCurrentPosition();
  }

  // show current location
  void _showCurrentLocation() async {
    try {
      Position position = await _determinePosition();
      LatLng currentLatLng = LatLng(position.latitude, position.longitude);
      _mapController.move(currentLatLng, 15.0);
      setState(() {
        _myLocation = currentLatLng;
      });
         getCurrentPositionLocation();
 
    } catch (e) {
      print(e);
    }
  }
  
  //add marker on selected location anywhere you want to!
  void _addMarker(LatLng position, String title, String description) {
    setState(() {
      final markerData = MarkerData(
          description: description, position: position, title: title);
      _markerData.add(markerData);
      _markers.add(Marker(
          point: position, 
          width: 80,
          height: 80,
          child: GestureDetector(
            onTap: () => _showMarkerInfo(markerData),
            child: Column(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ]),
                  child: Text(
                    title,
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                const Icon(
                  Icons.location_on,
                  color: Colors.redAccent,
                  size: 40,
                )
              ],
            ),
          )));
    });
  }
  
  //show marker dialog    
  void _showMarkerDialog(BuildContext context, LatLng position) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title:const Text("Add Marker"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration:const InputDecoration(labelText: 'title'),
                  ),
                  TextField(
                    controller: descController,
                    decoration:const InputDecoration(labelText: 'Description'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child:const Text("Cancel")),
                TextButton(
                    onPressed: () {
                      _addMarker(
                          position, titleController.text, descController.text);
                      Navigator.pop(context);
                    },
                    child:const Text("Save")),
              ],
            ));
  }

  // void getCurrentPositionLocation()async{
  //   String url = "$mainURL${_myLocation!.latitude},${_myLocation!.longitude}";

  //   final response =await  http.get(Uri.parse(url));
  //   final parsed = jsonDecode(response.body);
   
  //   print(parsed);
  //   log(parsed.toString());

  // }

  Future<List<MyLocationModel>> getCurrentPositionLocation() async {
   String url = "$mainURL${_myLocation!.latitude},${_myLocation!.longitude}";
   final response =await  http.get(Uri.parse(url));
   var data = jsonDecode(response.body.toString());
   

   if (response.statusCode == 200) {
     for (Map<String, dynamic> index in data) {
       myLocationModel.add(MyLocationModel.fromJson(index));
     }
     return myLocationModel;
   } else {
     return myLocationModel;
   }
 }

  //Show Marker info when tappedP
  void _showMarkerInfo(MarkerData markerData) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(markerData.title),
              content: Text(markerData.description),
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon:const Icon(Icons.close))
              ],
            ));
  }

  //Search features
  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    final url =
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5';

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data.isNotEmpty) {
      setState(() {
        _searchResults = data;
      });
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  //move to specific location
  void _moveToLocation(double lat, double lon) {
    LatLng location = LatLng(lat, lon);
    _mapController.move(location, 15.0);
    setState(() {
      _selectedPosition = location;
      _searchResults = [];
      _isSearching = false;
      _searchController.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _searchPlaces(_searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 2,
                child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                        // initialCenter: LatLng(51.509364, -0.128928), // Center the map over London
                        initialZoom: 13.0,
                        onTap: (topPosition, Latlng) {
                          setState(() {
                            _selectedPosition = Latlng;
                            _draggedPosition = _selectedPosition;
                          });
                        }),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      MarkerLayer(markers: _markers),
                      if (_isDragging && _draggedPosition != null)
                        MarkerLayer(markers: [
                          Marker(
                              point: _draggedPosition!,
                              width: 80,
                              height: 80,
                              child:const Icon(
                                Icons.location_on,
                                color: Colors.indigo,
                                size: 40,
                              ))
                        ]),
                      if (_myLocation != null)
                        MarkerLayer(markers: [
                          Marker(
                              point: _myLocation!,
                              width: 80,
                              height: 80,
                              child:const Icon(
                                Icons.location_on,
                                color: Colors.green,
                                size: 40,
                              ))
                        ])
                    ]),
              ),

              Expanded(child: Container(
                color: Colors.white54,
                // child: FutureBuilder(
                //   future: getCurrentPositionLocation(),
                  
                //   builder: (context , snapshot) {
                //     if(snapshot.hasData){
                //       return ListView.builder(
                //   itemCount: myLocationModel.length,
                //   itemBuilder: (context,index) {
                //     return Card(
                //       child: Padding(padding: EdgeInsets.all(10),
                //       child: ListTile(
                //         title: Text(myLocationModel[index].name),
                //         subtitle: Text("deep"),
                //       ),),
                //     );
                //   }) ;
                //     } else {
                //       return Center(child: SizedBox(),);
                //     }
                //   }
                // )
                
              ),),
            ],
          ),

          //Search widget
          Positioned(
              top: 40,
              left: 15,
              right: 15,
              child: Column(
                children: [
                  SizedBox(
                    height: 55,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                          hintText: "Search Location...",
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon:const Icon(Icons.search),
                          suffixIcon: _isSearching
                              ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _isSearching = false;
                                      _searchResults = [];
                                    });
                                  },
                                  icon:const Icon(Icons.clear))
                              : null),
                      onTap: () {
                        setState(() {
                          _isSearching = true;
                        });
                      },
                    ),
                  ),
                  if (_isSearching && _searchResults.isNotEmpty)
                    Container(
                      color: Colors.white,
                      child: ListView.builder( 
                          shrinkWrap: true,
                          itemCount: _searchResults.length,
                          itemBuilder: (ctx, index) {
                            final place = _searchResults[index];
                            return ListTile(
                              title: Text(
                                place['display_name'],
                              ),
                              onTap: () {
                                final lat = double.parse(place['lat']);
                                final lon = double.parse(place['lon']);
                                _moveToLocation(lat, lon);
                              },
                            );
                          }),
                    )
                ],
              )),

          // add location button
          _isDragging == false
              ? Positioned(
                  bottom: 20,
                  left: 20,
                  child: FloatingActionButton(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    onPressed: () {
                      setState(() {
                        _isDragging = true;
                      });
                    },
                    child:const Icon(Icons.add_location),
                  ))
              : Positioned(
                  bottom: 20,
                  left: 20,
                  child: FloatingActionButton(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    onPressed: () {
                      setState(() {
                        _isDragging = false;
                      });
                    },
                    child:const Icon(Icons.wrong_location),
                  )),

          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.indigo,
                  onPressed: _showCurrentLocation,
                  child:const Icon(Icons.location_searching_rounded),
                ),
                
              ],
            ),
          ),
        ],
      ),
    );
  }
}
