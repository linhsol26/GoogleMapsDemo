import 'package:flutter/material.dart';
import 'package:location/location.dart';

import 'goomap.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Location location = new Location();
  bool? _serviceEnabled;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLocalPosition();
  }

  void checkLocalPosition() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled!) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await location.getLocation();
    print(_permissionGranted);
    print(_serviceEnabled);
    print(_locationData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[800],
        appBar: AppBar(
          title: Text("Google Maps Demo"),
          centerTitle: true,
          backgroundColor: Colors.grey[800],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _locationData != null
              ? Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GooMap(location: _locationData!)))
              : print("Failed"),
          label: Row(
            children: <Widget>[
              Text(
                'Open Maps',
                style: TextStyle(color: Colors.black87),
              ),
              Icon(
                Icons.map,
                color: Colors.black87,
              ),
            ],
          ),
        ),
        body: Container(
          padding: EdgeInsets.all(16),
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Google Maps Demo',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          )),
        ));
  }
}
