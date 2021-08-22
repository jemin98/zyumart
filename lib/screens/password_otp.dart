import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:active_ecommerce_flutter/custom/input_decorations.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:active_ecommerce_flutter/repositories/auth_repository.dart';
import 'package:active_ecommerce_flutter/screens/login.dart';

class PasswordOtp extends StatefulWidget {
  PasswordOtp(
      {Key key, this.verify_by = "email", this.email_or_code, this.onSucc})
      : super(key: key);
  final String verify_by;
  final String email_or_code;
  var onSucc;

  @override
  _PasswordOtpState createState() => _PasswordOtpState();
}

class _PasswordOtpState extends State<PasswordOtp> {
  //controllers
  TextEditingController _codeController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordConfirmController = TextEditingController();

  bool pass = true;

  @override
  void initState() {
    //on Splash Screen hide statusbar
    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    super.initState();
    print(widget.verify_by);
    print("212222222222");
  }

  @override
  void dispose() {
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  onPressConfirm() async {
    var code = _codeController.text.toString();
    var password = _passwordController.text.toString();
    var password_confirm = _passwordConfirmController.text.toString();

    if (code == "") {
      ToastComponent.showDialog("Enter the code", context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    } else if (password == "") {
      ToastComponent.showDialog("Enter password", context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    } else if (password_confirm == "") {
      ToastComponent.showDialog("Confirm your password", context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    } else if (password.length < 6) {
      ToastComponent.showDialog(
          "Password must contain atleast 6 characters", context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    } else if (password != password_confirm) {
      ToastComponent.showDialog("Passwords do not match", context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    }

    var passwordConfirmResponse =
        await AuthRepository().getPasswordConfirmResponse(code, password);

    if (passwordConfirmResponse.result == false) {
      setState(() {
        isLoading = false;
      });

      ToastComponent.showDialog(passwordConfirmResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
    } else {
      setState(() {
        isLoading = false;
      });
      ToastComponent.showDialog(passwordConfirmResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return Login();
      }));
    }
  }

  onTapResend() async {
    print("1111111111111111111111111111111");
    print(widget.email_or_code);
    print(widget.verify_by);
    var passwordResendCodeResponse = await AuthRepository()
        .getPasswordResendCodeResponse(widget.email_or_code, widget.verify_by);

    if (passwordResendCodeResponse.result == false) {
      ToastComponent.showDialog(passwordResendCodeResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
    } else {
      ToastComponent.showDialog(passwordResendCodeResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
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
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.3,
        title: Text('Password Reset'), // You can add title here
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back_ios, color: Colors.grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: ListView(
            children: [
              SizedBox(
                height: 22,
              ),
              Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Text(
                        "Enter the code sent",
                        style: TextStyle(
                            color: MyTheme.accent_color,
                            fontSize: 18,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 22.0, right: 22),
                      child: Column(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          Card(
                            color: Colors.grey[100],
                            elevation: 0.5,
                            child: TextFormField(
                              controller: _codeController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(10),
                                hintText: "A X B 4 J H",
                                hintStyle:
                                    TextStyle(color: Colors.grey, fontSize: 17),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          Card(
                            color: Colors.grey[100],
                            elevation: 0.5,
                            child: TextFormField(
                              obscureText: pass,
                              controller: _passwordController,
                              decoration: InputDecoration(
                                suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        pass = !pass;
                                      });
                                    },
                                    child: Icon(
                                      Icons.remove_red_eye,
                                      color: Colors.grey,
                                    )),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(10),
                                hintText: "PassWord",
                                hintStyle:
                                    TextStyle(color: Colors.grey, fontSize: 19),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          Card(
                            color: Colors.grey[100],
                            elevation: 0.5,
                            child: TextFormField(
                              controller: _passwordConfirmController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(10),
                                hintText: "Retype Password",
                                hintStyle:
                                    TextStyle(color: Colors.grey, fontSize: 19),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isLoading = true;
                              });
                              onPressConfirm();
                            },
                            child: Card(
                              color: Colors.blue[300],
                              child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.05,
                                  width: MediaQuery.of(context).size.width,
                                  child: Center(
                                    child: Text(
                                      "Verify",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  )),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.015,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                widget.onSucc();
                              });
                            },
                            child: Text(
                              "Resend Code",
                              style: TextStyle(
                                  fontSize: 15, color: Colors.blue[300]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
    );
  }
}
