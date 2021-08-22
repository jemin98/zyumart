import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:active_ecommerce_flutter/custom/input_decorations.dart';
import 'package:active_ecommerce_flutter/screens/login.dart';
import 'package:active_ecommerce_flutter/repositories/auth_repository.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:toast/toast.dart';

class Otp extends StatefulWidget {
  Otp({Key key, this.verify_by = "email", this.user_id}) : super(key: key);
  final String verify_by;
  final int user_id;

  @override
  _OtpState createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  //controllers
  TextEditingController _verificationCodeController = TextEditingController();

  @override
  void initState() {
    //on Splash Screen hide statusbar
    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    super.initState();
  }

  @override
  void dispose() {
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  onTapResend() async {
    var resendCodeResponse = await AuthRepository()
        .getResendCodeResponse(widget.user_id, widget.verify_by);

    if (resendCodeResponse.result == false) {
      ToastComponent.showDialog(resendCodeResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
    } else {
      ToastComponent.showDialog(resendCodeResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
    }
  }

  onPressConfirm() async {
    var code = _verificationCodeController.text.toString();

    if (code == "") {
      ToastComponent.showDialog("Enter verification code", context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    }

    var confirmCodeResponse =
        await AuthRepository().getConfirmCodeResponse(widget.user_id, code);

    if (confirmCodeResponse.result == false) {
      setState(() {
        isLoading = false;
      });
      ToastComponent.showDialog(confirmCodeResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
    } else {
      setState(() {
        isLoading = false;
      });
      ToastComponent.showDialog(confirmCodeResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return Login();
      }));
    }
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    String _verify_by = widget.verify_by; //phone or email
    final _screen_height = MediaQuery.of(context).size.height;
    final _screen_width = MediaQuery.of(context).size.width;
    Widget loadingIndicator = isLoading
        ? new Container(
            width: 70.0,
            height: 70.0,
            child: new Padding(
                padding: const EdgeInsets.all(5.0),
                child: new Center(child: new CircularProgressIndicator())),
          )
        : new Container();
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Center(
            child: Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height * 0.4,
              child: Column(
                children: [
                  Text(
                    "Verification",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Enter The Code We Sent to ",
                    style: TextStyle(fontSize: 16),
                  ),
                  //get mobile number from previouse slide
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10),
                    child: Card(
                      color: Colors.grey[100],
                      // elevation: 5,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _verificationCodeController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(10),
                          hintText: "Verification Code",
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 19),
                        ),
                        validator: (code) {


                          if (code.length != 6) {
                            return 'Please enter Valid Code';
                          }

                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _verificationCodeController.text.length == 6 ?
                        isLoading = true : isLoading = false;
                      });
                      onPressConfirm();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        color: Colors.blue[300],
                        child: Container(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width,
                            child: Center(
                              child: Text(
                                "Verify",
                                style: TextStyle(color: Colors.white, fontSize: 20),
                              ),
                            )),
                      ),
                    ),
                  ),
                  new Align(
                    child: loadingIndicator,
                    alignment: FractionalOffset.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
