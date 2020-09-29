import 'package:customer_app/map.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => new _ProfileState();
}

class _ProfileState extends State<Profile> {
  String name = 'Ankush',
      country = 'India',
      city = 'Jaipur',
      phoneNumber = '+ 91-9876543210';
  int rating = 3, threshold;
  bool female = false;

  _launchURL() async {
    const url = 'tel: +91-986543210';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _buildAppBar(),
      body: _profile(),
    );
  }

  _buildAppBar() {
    return AppBar(
        backgroundColor: Color(0xfffbdd00),
        title: Text(
          'Driver Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        actions: <Widget>[]);
  }

  _profile() {
    return Container(
      margin: EdgeInsets.all(15.0),
      child: ListView(padding: EdgeInsets.all(10.0), children: <Widget>[
        SizedBox(height: 15.0),
        CircleAvatar(
          radius: 70.0,
          backgroundColor: Colors.redAccent,
          // child: Image.network(
          //   'https://github.com/Apeksh742/Flutter_profile_sysytem/blob/master/Assets/profile.jpg',
          //   fit: BoxFit.contain,
          // ),
        ),
        SizedBox(height: 15.0),
        Center(
            child: Text(
          '$name',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        )),
        SizedBox(height: 25.0),
        SizedBox(width: 10.0),
        _profileItems('Mobile number', '$phoneNumber'),
        Center(
            child: RaisedButton(
          onPressed: _launchURL,
          child: Text("Dial on number pad"),
          color: Colors.red,
        )),
        SizedBox(height: 15.0),
        SizedBox(width: 10.0),
        _profileItems('City', city),
        SizedBox(height: 15.0),
        SizedBox(width: 10.0),
        _profileItems('Country', country),
        Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          Text('Id: '),
          Row(children: [
            Row(
              children: [
                Text('1458913543'),
                IconButton(
                    icon: Icon(Icons.content_paste),
                    onPressed: () => _copyToClipboard('userId'))
              ],
            ),
          ]),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          Text('Rating: '),
          SizedBox(width: 10.0),
          Text(
            rating.toString(),
            style: TextStyle(color: Colors.green, fontSize: 17.0),
          )
        ]),
        SizedBox(height: 20.0),
        RaisedButton(
            color: Color(0xff75DA8B),
            child: Text('Track the driver'),
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => MapView()));
            })
      ]),
    );
  }

//for creating profile items titles and details.
  _profileItems(String title, String desc) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
      Text(title + ": "),
      Text(desc),
    ]);
  }

  _copyToClipboard(String copy) {
    Clipboard.setData(new ClipboardData(text: copy));
  }
}
