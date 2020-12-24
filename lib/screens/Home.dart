import 'package:customer_app/models/hospital.dart';
import 'package:customer_app/screens/info.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import 'package:latlong/latlong.dart' as ll;
import 'package:map_launcher/map_launcher.dart';

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
  List<Hospital> hospitals;

  getAlldata() {
    final ref =
        FirebaseDatabase.instance.reference().child('AdminAccess').onValue;
    ref.listen((event) {
      final snapShot = event.snapshot.value as Map;
      if (snapShot != null) {
        hospitals = [];
        snapShot.forEach((key, value) {
          if (value['AproveStatus'])
            hospitals.add(Hospital(
                contact: value['Contact No'] ?? '',
                id: key,
                lat: value['lat'],
                long: value['long'],
                address: value['HospitalAddress'] ?? '',
                name: value['HospialName'] ?? ''));
        });
      }
    });
  }

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
    if (_permissionGranted == PermissionStatus.DENIED) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.GRANTED) {
        return;
      }
    }
    String id;
    FirebaseAuth.instance.currentUser().then((value) async {
      id = value.uid;
      _locationData = await location.getLocation();
      await FirebaseDatabase.instance
          .reference()
          .child('AdminAccess')
          .child(nearestHospital.id)
          .child('Requests')
          .child(id)
          .update(
        {
          'id': id,
          'Alert': true,
          "lat": _locationData.latitude,
          'long': _locationData.longitude,
          'Status': 'Pending',
          "Phone no": '8630598001'
        },
      );
    }).then((value) {
      final ref = FirebaseDatabase.instance
          .reference()
          .child('AdminAccess')
          .child(nearestHospital.id)
          .child('Requests')
          .child(id)
          .onValue;
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
    });
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

  getNearestHospital() {
    double min = 1000000;
    hospitals.forEach((element) {
      double dis = distanceFinder(element.lat, element.long,
          _locationData.latitude, _locationData.longitude);
      if (min > dis) {
        min = dis;
        nearestHospital = Hospital(
            name: element.name,
            address: element.address,
            contact: element.contact,
            id: element.id,
            lat: element.lat,
            long: element.long);
      }
    });
  }

  Hospital nearestHospital;

  @override
  void initState() {
    getAlldata();
    getLocation();
    Future.delayed(Duration(seconds: 3)).then((value) {
      getNearestHospital();
    });
    super.initState();
  }

  getLocation() async {
    _locationData = await location.getLocation();
  }

  double distanceFinder(var hLat, var hLong, var cLat, var cLong) {
    ll.DistanceHaversine distance = ll.DistanceHaversine();
    double distanc = distance.as(
      ll.LengthUnit.Kilometer,
      ll.LatLng(hLat, hLong),
      ll.LatLng(cLat, cLong),
    );
    return distanc;
  }

  int currIndex = 0;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currIndex,
          onTap: (x) {
            setState(() {
              currIndex = x;
            });
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.location_on), label: 'Near BY')
          ],
        ),
        appBar: AppBar(
          elevation: currIndex == 0 ? 2 : 0,
          title: currIndex == 0 ? Text('Need Help') : Text('Near by'),
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
            : currIndex == 0
                ? Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(400),
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(200),
                        ),
                        height: 200,
                        width: 200,
                        child: RaisedButton(
                          child: Text(
                            'Emergency',
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
                  )
                : ListView.builder(
                    itemCount: hospitals.length,
                    itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.all(4),
                          child: Card(
                            child: ListTile(
                              title: Text(
                                hospitals[index].name,
                                style: GoogleFonts.actor(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                  'Distance :-  ${distanceFinder(_locationData.latitude, _locationData.longitude, hospitals[index].lat, hospitals[index].long)} km'),
                              leading: CircleAvatar(
                                backgroundImage:
                                    AssetImage('assets/profile.jpg'),
                              ),
                              trailing: Container(
                                width: MediaQuery.of(context).size.width * .2,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        String id;
                                        FirebaseAuth.instance
                                            .currentUser()
                                            .then((value) async {
                                          id = value.uid;
                                          _locationData =
                                              await location.getLocation();
                                          await FirebaseDatabase.instance
                                              .reference()
                                              .child('AdminAccess')
                                              .child(hospitals[index].id)
                                              .child('Requests')
                                              .child(id)
                                              .update(
                                            {
                                              'id': id,
                                              'Alert': true,
                                              "lat": _locationData.latitude,
                                              'long': _locationData.longitude,
                                              'Status': 'Pending',
                                              "Phone no": '8630598001'
                                            },
                                          );
                                        }).then((value) {
                                          final ref = FirebaseDatabase.instance
                                              .reference()
                                              .child('AdminAccess')
                                              .child(hospitals[index].id)
                                              .child('Requests')
                                              .child(id)
                                              .onValue;
                                          ref.listen((event) {
                                            final response =
                                                event.snapshot.value;
                                            if (response == null) return;

                                            if (response['Status'] ==
                                                'Accepted') {
                                              Fluttertoast.showToast(
                                                  backgroundColor: Colors.red
                                                      .withOpacity(0.51),
                                                  msg:
                                                      'Request is  accepted  Please wait for Ambulance ');
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          Profile()));
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
                                        });
                                      },
                                      child: Icon(
                                        Icons.send_to_mobile,
                                        color: Colors.red,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        if (await MapLauncher.isMapAvailable(
                                            MapType.google)) {
                                          await MapLauncher.showMarker(
                                            mapType: MapType.google,
                                            coords: Coords(hospitals[index].lat,
                                                hospitals[index].long),
                                            title: hospitals[index].name,
                                            description:
                                                hospitals[index].contact,
                                          );
                                        }
                                      },
                                      child: Icon(
                                        Icons.directions,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )),
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
