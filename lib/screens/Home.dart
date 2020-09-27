import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Need Help'),
          centerTitle: true,
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Text('help'),
        ),
      ),
    );
  }
}
