

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

class OtpVerificationScreen extends StatefulWidget {
  final String phoneno;
  final String name;
  final String address;
  OtpVerificationScreen({this.phoneno, this.name, this.address});

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  bool isCodeSent = false;
  bool _isLoading = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String _verificationId;
  PinDecoration _pinDecoration =
      UnderlineDecoration(enteredColor: Colors.black, hintText: '123456');
  TextEditingController _pinEditingController = TextEditingController();

  void _onformsubmitted() async {
    AuthCredential _authcredential = PhoneAuthProvider.getCredential(
        verificationId: _verificationId, smsCode: _pinEditingController.text);
    _firebaseAuth
        .signInWithCredential(_authcredential)
        .then((AuthResult value) async {
      if (value.user == null) {
        setState(() {
          _isLoading = true;
        });
        print(widget.address);
        await Provider.of<UserProvider>(context, listen: false)
            .addprofile(value.user, widget.name, widget.address);
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => Home(),
          ),
        );
      } else {
        showToast('Error validating OTP,Try again', Colors.red);
      }
    }).catchError((error) {
      showToast('There is some error', Colors.red);
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
          setState(() {
            _isLoading = true;
          });
          print(widget.name);
          await Provider.of<UserProvider>(context, listen: false)
              .addprofile(value.user, widget.name, widget.address);
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
                      GoogleFonts.poppins(textStyle: TextStyle(fontSize: 25),),
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
                        _onformsubmitted();
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
                  onTap: () {
                    if (_pinEditingController.text.length == 6) {
                      _onformsubmitted();
                    } else {
                      showToast("Invalid OTP", Colors.red);
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 50),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Container(
                        color: HexColor('2c3448'),
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
