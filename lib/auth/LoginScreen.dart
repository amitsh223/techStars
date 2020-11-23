import 'package:customer_app/auth/otpverificationScreen.dart';
import 'package:customer_app/auth/otpverificationlogin.dart';
import 'package:customer_app/provider/User.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FocusNode focusNode = FocusNode();
  String hintText = 'Enter your mobile number';
  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        hintText = '';
      } else {
        hintText = 'Enter your mobile number';
      }
      setState(() {});
    });
  }

  final _formReg = GlobalKey<FormState>();

  final _formLog = GlobalKey<FormState>();
  String phone;
  var fullname;
  var address;
  int index = 0;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    height: 100,
                    width: 200,
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Text(
                  'Welcome To ICE',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      fontSize: 22,
                      color: HexColor('FA163F'),
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1,
                            color:
                                index == 0 ? HexColor('FA163F') : Colors.black,
                          ),
                        ),
                      ),
                      child: FlatButton(
                        onPressed: () {
                          setState(() {
                            index = 0;
                          });
                        },
                        child: Text(
                          'Login',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1,
                            color:
                                index == 1 ? HexColor('FA163F') : Colors.black,
                          ),
                        ),
                      ),
                      child: FlatButton(
                        onPressed: () {
                          setState(() {
                            index = 1;
                          });
                        },
                        child: Text(
                          'Register',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            textStyle: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 50,
                ),
                index == 0 ? logIn() : register(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget logIn() {
    return Form(
      key: _formLog,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blueGrey,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '+91',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 16,
                        color: HexColor('FA163F'),
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 200,
                    child: TextFormField(
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: HexColor('FA163F'),
                      ),
                      focusNode: focusNode,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: GoogleFonts.poppins(fontSize: 13),
                        contentPadding: EdgeInsets.all(10),
                        border: InputBorder.none,
                      ),
                      onSaved: (value) {
                        phone = value;
                      },
                      validator: (value) {
                        if (value == null) {
                          return "Enter in field";
                        }
                        if (value.length != 10) {
                          return "Enter correct phone";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
          ),
          InkWell(
            onTap: () {
              final isvalidate = _formLog.currentState.validate();
              if (!isvalidate) {
                return;
              }
              _formLog.currentState.save();
              final phoneNo = "+91" + "$phone";
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MultiProvider(
                    providers: [
                      ChangeNotifierProvider.value(
                        value: UserProvider(),
                      ),
                    ],
                    child: OtpVerificationLoginScreen(
                      phoneno: phoneNo,
                    ),
                  ),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 50),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Container(
                  color: HexColor('FA163F'),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      'Login',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  Widget register() {
    return Form(
      key: _formReg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'MOBILE NO.',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextSpan(
                    text: '*',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blueGrey,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '+91',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        fontSize: 16,
                        color: HexColor('FA163F'),
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 200,
                    child: TextFormField(
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: HexColor('FA163F'),
                      ),
                      focusNode: focusNode,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: hintText,
                        hintStyle: GoogleFonts.poppins(fontSize: 12),
                        contentPadding: EdgeInsets.all(10),
                        border: InputBorder.none,
                      ),
                      onSaved: (value) {
                        phone = value;
                      },
                      validator: (value) {
                        if (value == null) {
                          return "Enter in field";
                        }
                        if (value.length != 10) {
                          return "Enter correct phone";
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'FULL NAME',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextSpan(
                    text: '*',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blueGrey,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextFormField(
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: HexColor('FA163F'),
                ),
                validator: (value) {
                  if (value.isEmpty) {
                    return "enter in field";
                  }

                  return null;
                },
                onSaved: (val) {
                  fullname = val;
                },
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'HOME ADDRESS',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextSpan(
                    text: '*',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blueGrey,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextFormField(
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: HexColor('FA163F'),
                ),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value.isEmpty) {
                    return "enter in field";
                  }

                  return null;
                },
                onSaved: (newValue) {
                  address = newValue;
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: () async {
              final isvalidate = _formReg.currentState.validate();
              if (!isvalidate) {
                return;
              }
              _formReg.currentState.save();
              final phoneNo = "+91" + "$phone";
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => MultiProvider(
                    providers: [
                      ChangeNotifierProvider.value(
                        value: UserProvider(),
                      )
                    ],
                    child: OtpVerificationScreen(
                      address: address,
                      name: fullname,
                      phoneno: phoneNo,
                    ),
                  ),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 50),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Container(
                  color: HexColor('FA163F'),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      'Register',
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }
}
