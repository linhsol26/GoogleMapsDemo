import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as Math;
import 'dart:async';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;

class GooMap extends StatefulWidget {
  // const GooMap({Key? key}) : super(key: key);
  final LocationData location;
  GooMap({required this.location});

  @override
  _GooMapState createState() => _GooMapState();
}

class _GooMapState extends State<GooMap> {
  LocationData? _locationData;

  Set<Marker> _markers = HashSet<Marker>();
  Set<Polygon> _polygons = HashSet<Polygon>();
  Set<Circle> _circles = HashSet<Circle>();
  Completer<GoogleMapController> _googleMapController = Completer();

  List<LatLng> polygonLatLngs = <LatLng>[];
  double? radius;

  int _polygonIdCounter = 1;
  int _markerIdCounter = 1;

  // Type controllers
  bool _isPolygon = true; // Default
  bool _isMarker = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _locationData = widget.location;
  }

  // Draw Polygon to the map
  void _setPolygon() {
    final String polygonIdVal = 'polygon_id_$_polygonIdCounter';
    _polygons.add(Polygon(
      polygonId: PolygonId(polygonIdVal),
      points: polygonLatLngs,
      strokeWidth: 2,
      strokeColor: Colors.yellow,
      fillColor: Colors.yellow.withOpacity(0.15),
    ));
  }

  // Set Markers to the map
  void _setMarkers(LatLng point) {
    final String markerIdVal = 'marker_id_$_markerIdCounter';
    _markerIdCounter++;
    setState(() {
      print(
          'Marker | Latitude: ${point.latitude}  Longitude: ${point.longitude}');
      _markers.add(
        Marker(
          markerId: MarkerId(markerIdVal),
          position: point,
        ),
      );
    });
  }

  // Start the map with this marker setted up
  void _onMapCreated(GoogleMapController controller) {
    _googleMapController.complete(controller);

    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('0'),
          position: LatLng(-20.131886, -47.484488),
          //icon: _markerIcon,
        ),
      );
    });
  }

  String _calculateArea() {
    List<mp.LatLng> fromMp = [];
    polygonLatLngs.forEach((element) {
      fromMp.add(mp.LatLng(element.latitude, element.longitude));
    });
    return mp.SphericalUtil.computeArea(fromMp).toString();
  }

  // undo
  Widget _fabPolygon() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FloatingActionButton.extended(
          onPressed: () {
            setState(() {
              _polygons.clear();
              polygonLatLngs.clear();
              _polygonIdCounter = 1;
            });
          },
          icon: Icon(Icons.delete),
          label: Text('Erase All'),
          backgroundColor: Colors.blueGrey,
        ),
        FloatingActionButton.extended(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: new Text("AREA!!"),
                  content: new Text(_calculateArea()),
                  actions: <Widget>[
                    new TextButton(
                      child: new Text("Close"),
                      onPressed: () {
                        setState(() {
                          _polygons.clear();
                          polygonLatLngs.clear();
                          _polygonIdCounter = 1;
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
          icon: Icon(Icons.calculate),
          label: Text('Calc'),
          backgroundColor: Colors.blueGrey,
        ),
        FloatingActionButton.extended(
          onPressed: () {
            //Remove the last point setted at the polygon
            setState(() {
              polygonLatLngs.removeLast();
            });
          },
          icon: Icon(Icons.undo),
          label: Text('Undo'),
          backgroundColor: Colors.blueGrey,
        ),
      ],
    );
  }

  // static double calculatePolygonArea(List coordinates) {
  //   double area = 0;

  //   if (coordinates.length > 2) {
  //     for (var i = 0; i < coordinates.length - 1; i++) {
  //       var p1 = coordinates[i];
  //       var p2 = coordinates[i + 1];
  //       area += convertToRadian(p2.longitude - p1.longitude) *
  //           (2 +
  //               Math.sin(convertToRadian(p1.latitude)) +
  //               Math.sin(convertToRadian(p2.latitude)));
  //     }

  //     area = area * 6378137 * 6378137 / 2;
  //   }

  //   return area.abs() * 0.000247105; //sq meters to Acres
  // }

  // static double convertToRadian(double input) {
  //   return input * Math.pi / 180;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Google Maps Demo'),
      //   centerTitle: true,
      //   backgroundColor: Colors.grey[900],
      // ),
      floatingActionButton:
          polygonLatLngs.length > 0 && _isPolygon ? _fabPolygon() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterTop,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target:
                  LatLng(_locationData!.latitude!, _locationData!.longitude!),
              zoom: 16,
            ),
            mapType: MapType.hybrid,
            markers: _markers,
            polygons: _polygons,
            myLocationEnabled: true,
            onTap: (point) {
              if (_isPolygon) {
                setState(() {
                  polygonLatLngs.add(point);
                  _setPolygon();
                });
              } else if (_isMarker) {
                setState(() {
                  _markers.clear();
                  _setMarkers(point);
                });
              }
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _isPolygon = true;
                    _isMarker = false;
                  },
                  child: Text(
                    'Polygon',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _isPolygon = false;
                    _isMarker = true;
                  },
                  child: Text(
                    'Marker',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
