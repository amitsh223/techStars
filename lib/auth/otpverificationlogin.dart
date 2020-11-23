

import 'package:customer_app/provider/User.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';

import '../screens/Home.dart';
import 'otp.dart';

class OtpVerificationLoginScreen extends StatefulWidget {
  final String phoneno;
  OtpVerificationLoginScreen({this.phoneno});

  @override
  _OtpVerificationLoginScreenState createState() =>
      _OtpVerificationLoginScreenState();
}

class _OtpVerificationLoginScreenState
    extends State<OtpVerificationLoginScreen> {
  bool isCodeSent = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String _verificationId;
  bool _isLoading = false;
  PinDecoration _pinDecoration =
      UnderlineDecoration(enteredColor: Colors.black, hintText: '123456');
  TextEditingController _pinEditingController = TextEditingController();

  void _onFormSubmitted() async {
    AuthCredential _authCredential = PhoneAuthProvider.getCredential(
        verificationId: _verificationId, smsCode: _pinEditingController.text);

    _firebaseAuth
        .signInWithCredential(_authCredential)
        .then((AuthResult value) async {
      if (value.user != null) {
        setState(() {
          _isLoading = true;
        });
        final have = await Provider.of<UserProvider>(context, listen: false)
            .checkProfile(value.user.uid);
        if (!have) {
          FirebaseAuth.instance.signOut();
          showDialog(
            context: context,
            builder: (context) => WillPopScope(
              // ignore: missing_return
              onWillPop: () {},
              child: AlertDialog(
                title: Text("Unknown User!"),
                content: Text("Not found your profile try with signup!"),
                actions: [
                  FlatButton(
                    child: Text("Ok"),
                    onPressed: () {
                      Navigator.of(context).pop();

                      Navigator.of(context).pop();
                    },
                  )
                ],
              ),
            ),
          );

          setState(() {
            _isLoading = false;
          });
          return;
        }
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => Home(),
          ),
        );
      } else {
        showToast("Error validating OTP, try again", Colors.red);
      }
    }).catchError((error) {
      showToast("Something went wrong", Colors.red);
    });
  }

  void showToast(message, Color color) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2,
        backgroundColor: color,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void _onVerifyCode() async {
    setState(() {
      isCodeSent = true;
    });
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      _firebaseAuth
          .signInWithCredential(phoneAuthCredential)
          .then((AuthResult value) async {
        if (value.user != null) {
          // Handle loogged in state
          setState(() {
            _isLoading = true;
          });
          final have = await Provider.of<UserProvider>(context, listen: false)
              .checkProfile(value.user.uid);
          if (!have) {
            FirebaseAuth.instance.signOut();
            showDialog(
              context: context,
              builder: (context) => WillPopScope(
                // ignore: missing_return
                onWillPop: () {},
                child: AlertDialog(
                  title: Text("Unknown User!"),
                  content: Text("Not found your profile try with signup!"),
                  actions: [
                    FlatButton(
                      child: Text("Ok"),
                      onPressed: () {
                        Navigator.of(context).pop();

                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              ),
            );

            setState(() {
              _isLoading = false;
            });
            return;
          }
          setState(() {
            _isLoading = false;
          });
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => Home(),
            ),
          );
        } else {
          showToast("Error validating OTP, try again", Colors.red);
        }
      }).catchError((error) {
        showToast("Try again in sometime", Colors.red);
      });
    };
    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      showToast(authException.message, Colors.red);
      setState(() {
        isCodeSent = false;
      });
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      _verificationId = verificationId;
      setState(() {
        _verificationId = verificationId;
      });
    };
    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
      setState(() {
        _verificationId = verificationId;
      });
    };

    //Change country code

    await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: "${widget.phoneno}",
        timeout: const Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  @override
  void initState() {
    _onVerifyCode();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(top: 50, right: 30, left: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Image.asset(
                    'assets/pie.png',
                    scale: 1.3,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  'OTP Verification',
                  style:
                      GoogleFonts.poppins(textStyle: TextStyle(fontSize: 25)),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  'Please enter verification code sent to your mobile',
                  style:
                      GoogleFonts.poppins(textStyle: TextStyle(fontSize: 12)),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 40,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: PinInputTextField(
                    pinLength: 6,
                    decoration: _pinDecoration,
                    controller: _pinEditingController,
                    autoFocus: true,
                    textInputAction: TextInputAction.done,
                    onSubmit: (pin) {
                      if (pin.length == 6) {
                        _onFormSubmitted();
                      } else {
                        showToast("Invalid OTP", Colors.red);
                      }
                    },
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                InkWell(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 50),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Container(
                        color: HexColor('FA163F'),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: _isLoading
                              ? SpinKitThreeBounce(
                                  color: Colors.white,
                                  size: 20,
                                )
                              : Text(
                                  'Continue',
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
