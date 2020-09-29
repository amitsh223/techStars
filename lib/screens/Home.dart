import 'dart:collection';

import 'package:customer_app/map.dart';
import 'package:customer_app/screens/info.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
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
        'Name': 'Arun',
        'Alert': true,
        "lat": _locationData.latitude,
        'long': _locationData.longitude,
        'Status': 'Pending',
        "Phone no": '8630598001'
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
            backgroundColor: Colors.red.withOpacity(0.51),
            msg: 'Request is  accepted  Please wait for Ambulance ');
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Profile()));
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

  didChangeDependencies() {
    // getLocationWithPermission();
    getProfile();
    getFeedBack();
    super.didChangeDependencies();
  }

  getFeedBack() {
    final ref =
        FirebaseDatabase.instance.reference().child('CustomerData').onValue;
    ref.listen((event) {
      final response = event.snapshot.value;
      if (response != null) {
        if (response['Complete'] == true) {
          showRating();
        }
      }
    });
  }

  getProfile() {
    final ref =
        FirebaseDatabase.instance.reference().child('CustomerData').onValue;
    ref.listen((event) {
      final response = event.snapshot.value;
      if (response == null) return;
      if (response['Status'] == 'Accepted') {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => Profile()));
      }
    });
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
                   showRating();
                 
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
                      onPressed: () {
                        getLocationWithPermission();
                      },
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  void showRating() {
    double uRating;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            actions: [
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel')),
              FlatButton(
                  onPressed: () async {
                    //  final key=  FirebaseDatabase.instance.reference().key;
                    await FirebaseDatabase.instance
                        .reference()
                        .child('Driver')
                        .push()
                        .update({'Rating': uRating});
                    Navigator.of(context).pop();
                  },
                  child: Text('Submit'))
            ],
            title: Text('Please provide your FeedBack'),
            content: RatingBar(
              initialRating: 1,
              itemCount: 5,
              minRating: 1,
              glow: true,
              unratedColor: Colors.grey,
              // ignore: missing_return
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return Icon(
                      Icons.sentiment_very_dissatisfied,
                      color: Colors.red,
                    );

                  case 1:
                    return Icon(
                      Icons.sentiment_dissatisfied,
                      color: Colors.redAccent,
                    );
                  case 2:
                    return Icon(
                      Icons.sentiment_neutral,
                      color: Colors.amber,
                    );
                  case 3:
                    return Icon(
                      Icons.sentiment_satisfied,
                      color: Colors.lightGreen,
                    );
                  case 4:
                    return Icon(
                      Icons.sentiment_very_satisfied,
                      color: Colors.green,
                    );
                  case 5:
                    return Icon(
                      Icons.sentiment_dissatisfied_outlined,
                      color: Colors.red,
                    );
                }
              },
              onRatingUpdate: (rating) {
                uRating = rating;

                print(rating);
              },
            ),
          );
        });
  }
}
