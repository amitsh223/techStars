import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';

Location location = new Location();

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var isLoading = false;
  final spinKit = SpinKitHourGlass(
    color: Colors.red,
  );
  LocationData _locationData;
  bool _serviceEnabled;

  getLocationWithPermission() async {
    PermissionStatus _permissionGranted;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    setState(() {
      isLoading = true;
    });
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    await FirebaseDatabase.instance.reference().child('CustomerData').update(
      {
        'Name': 'Test',
        'Alert': true,
        "lat": _locationData.latitude,
        'long': _locationData.longitude,
        'Status': 'Pending'
      },
    );
    final ref =
        FirebaseDatabase.instance.reference().child('CustomerData').onValue;
    ref.listen((event) {
      final response = event.snapshot.value;
      if (response == null) return;
      print(response);
      if (response['Status'] == 'Accepted') {
        Fluttertoast.showToast(
          backgroundColor: Colors.red.withOpacity(0.5),
            msg: 'Request is  accepted  Please wait for Ambulance ');

             setState(() {
        isLoading = false;
      });

      }
      // } else if (response['Status'] == 'Pending') {
      //   Fluttertoast.showToast(msg: 'Please wait for the request to approved');
      // } else {
      //   return;
      // }
     
    });

    print(_locationData);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Need Help'),
          centerTitle: true,
          backgroundColor: Colors.red,
          actions: [
            FlatButton(
                onPressed: () {
                  getLocationWithPermission();
                },
                child: Icon(Icons.add))
          ],
        ),
        body: isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  spinKit,
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    'Please wait we are sending your request \n               to neasrest Ambulance',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 17,
                        fontWeight: FontWeight.bold),
                  )
                ],
              )
            : Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height: 50,
                    width: 200,
                    child: RaisedButton(
                      child: Text(
                        'Alert',
                        style: TextStyle(fontSize: 20),
                      ),
                      textColor: Colors.white,
                      onPressed: () {},
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
