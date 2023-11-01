import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../../globals/colors.dart';
import '../../globals/common.dart';
import 'home.dart';


class PhoneAuth extends StatefulWidget {
  const PhoneAuth({super.key});

  @override
  State<PhoneAuth> createState() => _PhoneAuthState();
}

class _PhoneAuthState extends State<PhoneAuth> {
  final _phoneCtrl = TextEditingController();
  String? lastVerificationId;

  void _sendOtp() async {
    try {
      final phone = '+${_phoneCtrl.text}';
      FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phone,
          verificationCompleted: (PhoneAuthCredential credentials) async {
            final firebaseCredential =
                await FirebaseAuth.instance.signInWithCredential(credentials);
            final user = firebaseCredential.user;
            if (user == null) {
              if (mounted) {
                showSnackBar(context, "Sign in error", Duration(seconds: 3));
              }
            } else {
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (cxt) => Home(user)),
                    (route) => false);
              }
            }
          },
          verificationFailed: (FirebaseAuthException error) {
            print(error);
          },
          codeSent: (String verificationId, forceResendingToken) {
            setState(() {
              lastVerificationId = verificationId;
            });
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            if (mounted) {
              setState(() {
                lastVerificationId = verificationId;
              });
            }
          });
    } catch (e) {
      print(e);
    }
  }

  void _verifyOtp(String smsCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
          verificationId: lastVerificationId!, smsCode: smsCode);
      final firebaseCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = firebaseCredential.user;
      if (user == null) {
        if (mounted) {
          showSnackBar(context, "Error", const Duration(seconds: 3));
        }
      } else {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (cxt) => Home(user)),
              (route) => false);
        }
      }
    } on FirebaseAuthException catch (e) {
      print(e.code);
      showSnackBar(context, e.code, const Duration(seconds: 3));
    } catch (e) {
      print(e);
      showSnackBar(context, e.toString(), const Duration(seconds: 3));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Auth'),
      ),
      backgroundColor: AppColors.grey,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Center(
              child: Padding(
                padding:
                    EdgeInsets.only(left: 20, right: 20, top: 80, bottom: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Sign up',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGrey1),
                    ),
                    Text(
                      "Enter your phone number",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGrey1),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white,
                    ),
                    child: TextFormField(
                      controller: _phoneCtrl,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter phone number',
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  InkWell(
                    onTap: _sendOtp,
                    child: Container(
                      padding: const EdgeInsets.only(top: 12, bottom: 12),
                      margin: const EdgeInsets.only(
                          top: 8, bottom: 8, left: 15, right: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: AppColors.blue,
                      ),
                      child: const Center(
                        child: Text(
                          'Send Otp',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
            ),
            lastVerificationId == null
                ? Container()
                : Container(
                    padding: const EdgeInsets.only(top: 30, bottom: 0),
                    child: const Text(
                      'Enter OTP',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGrey1),
                    ),
                  ),
            lastVerificationId == null
                ? Container()
                : Container(
                    padding: const EdgeInsets.only(top: 12, bottom: 12),
                    margin: const EdgeInsets.only(
                        top: 20, bottom: 20, left: 15, right: 15),
                    child: Center(
                      child: Pinput(
                        length: 6,
                        defaultPinTheme: PinTheme(
                          width: 45,
                          height: 45,
                          textStyle: const TextStyle(
                              fontSize: 20,
                              color: Color.fromRGBO(30, 60, 87, 1),
                              fontWeight: FontWeight.w600),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        focusedPinTheme: PinTheme(
                          width: 45,
                          height: 45,
                          textStyle: const TextStyle(
                              fontSize: 20,
                              color: Color.fromRGBO(30, 60, 87, 1),
                              fontWeight: FontWeight.w600),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Colors.lightBlue, width: 3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        errorPinTheme: PinTheme(
                          width: 45,
                          height: 45,
                          textStyle: const TextStyle(
                              fontSize: 20,
                              color: Color.fromRGBO(30, 60, 87, 1),
                              fontWeight: FontWeight.w600),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.blue, width: 3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                        showCursor: true,
                        onCompleted: (pin) {
                          _verifyOtp(pin);
                        },
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
