import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMaps extends StatefulWidget {
  const GoogleMaps({Key? key}) : super(key: key);

  @override
  _GoogleMapsState createState() => _GoogleMapsState();
}

class _GoogleMapsState extends State<GoogleMaps> {
  final Completer<GoogleMapController> _controller = Completer();

  final CameraPosition _cameraPosition =
      CameraPosition(target: LatLng(15, 15), zoom: 15);

  final Set<Polygon> _polygons = HashSet<Polygon>();
  final Set<Polyline> _polyLines = HashSet<Polyline>();

  bool _drawPolygonEnable = false;
  List<LatLng> _userPolyLinesLatLngList = [];
  bool _clearDrawing = false;
  int? _lastXCoor = null, _lastYCoor = null;

  @override
  void initState() {
    super.initState();
  }

  _toggleDrawing() {
    _clearPolygons();
    setState(() {
      _drawPolygonEnable = !_drawPolygonEnable;
    });
  }

  _clearPolygons() {
    setState(() {
      _polyLines.clear();
      _polygons.clear();
      _userPolyLinesLatLngList.clear();
    });
  }

  _onPanUpdate(DragUpdateDetails details) async {
    if (_clearDrawing) {
      _clearDrawing = false;
      _clearPolygons();
    }

    if (_drawPolygonEnable) {
      double x, y;
      x = details.globalPosition.dx;
      y = details.globalPosition.dy;

      int xCoor = x.round();
      int yCoor = y.round();

      if (_lastXCoor != null && _lastYCoor != null) {
        var distance = Math.sqrt(Math.pow(xCoor - _lastXCoor!, 2) +
            Math.pow(yCoor - _lastYCoor!, 2));
        if (distance >= 80.0) return;
      }

      _lastXCoor = xCoor;
      _lastYCoor = yCoor;

      ScreenCoordinate scrCoor = ScreenCoordinate(x: xCoor, y: yCoor);

      final GoogleMapController controller = await _controller.future;

      LatLng latLng = await controller.getLatLng(scrCoor);

      try {
        _userPolyLinesLatLngList.add(latLng);

        _polyLines.removeWhere(
            (element) => element.polylineId.value == 'user_polyline');
        _polyLines.add(Polyline(
            polylineId: PolylineId('user_polyline'),
            points: _userPolyLinesLatLngList,
            width: 2,
            color: Colors.blue));
      } catch (e) {
        print(e.toString());
      }
      setState(() {});
    }
  }

  _onPanEnd(DragEndDetails details) async {
    // Reset last cached coordinate
    _lastXCoor = null;
    _lastYCoor = null;

    if (_drawPolygonEnable) {
      _polygons
          .removeWhere((polygon) => polygon.polygonId.value == 'user_polygon');
      _polygons.add(
        Polygon(
          polygonId: PolygonId('user_polygon'),
          points: _userPolyLinesLatLngList,
          strokeWidth: 2,
          strokeColor: Colors.blue,
          fillColor: Colors.blue.withOpacity(0.4),
        ),
      );
      setState(() {
        _clearDrawing = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (_drawPolygonEnable) ? _onPanUpdate : null,
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _cameraPosition,
          polygons: _polygons,
          polylines: _polyLines,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          // onCameraMove: (CameraPosition cameraPosition) {
          //   print(cameraPosition.target);
          // },
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: _toggleDrawing,
          tooltip: "Drawing",
          child: Icon(_drawPolygonEnable ? Icons.cancel : Icons.edit)),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
