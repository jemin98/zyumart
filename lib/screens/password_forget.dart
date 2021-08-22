import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:active_ecommerce_flutter/custom/input_decorations.dart';
import 'package:active_ecommerce_flutter/custom/intl_phone_input.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:active_ecommerce_flutter/addon_config.dart';
import 'package:active_ecommerce_flutter/screens/password_otp.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:active_ecommerce_flutter/repositories/auth_repository.dart';

class PasswordForget extends StatefulWidget {
  @override
  _PasswordForgetState createState() => _PasswordForgetState();
}

class _PasswordForgetState extends State<PasswordForget>
    with SingleTickerProviderStateMixin {
  String _send_code_by = "email"; //phone or email
  String initialCountry = 'US';
  PhoneNumber phoneCode = PhoneNumber(isoCode: 'US');
  String _phone = "";
  TabController _controller;
  bool checked = false;

  //controllers
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();

  @override
  void initState() {
    //on Splash Screen hide statusbar
    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    super.initState();
    setState(() {
      _controller = TabController(vsync: this, length: 2);
      _controller.addListener(_handleTabSelection);
      print(_controller.index);
    });
  }

  void _handleTabSelection() {
    setState(() {});
  }

  @override
  void dispose() {
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  onPressSendCode() async {
    setState(() {
      isLoading = true;
      print("onsendwork");
      print(_emailController.text);
    });
    var email = _emailController.text.toString();

    if (_send_code_by == 'email' && email == "") {
      setState(() {
        isLoading = false;
      });
      ToastComponent.showDialog("Enter email", context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    } else if (_send_code_by == 'phone' && _phone == "") {
      setState(() {
        isLoading = false;
      });
      ToastComponent.showDialog("Enter phone number", context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    }
    print(_send_code_by);
    print("000000000000000");

    var passwordForgetResponse = await AuthRepository()
        .getPasswordForgetResponse(
            _send_code_by == 'email' ? email : _phone, _send_code_by);

    if (passwordForgetResponse.result == false) {
      setState(() {
        isLoading = false;
      });
      ToastComponent.showDialog(passwordForgetResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
    } else {
      setState(() {
        isLoading = false;
      });
      ToastComponent.showDialog(passwordForgetResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return PasswordOtp(
            verify_by: _send_code_by,
            email_or_code:
                _send_code_by == "email" ? _emailController.text : _phone,
            onSucc: () {
              onPressSendCode();
            });
      }));
    }
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
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
        title: Text('Forget Password'), // You can add title here
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back_ios, color: Colors.grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(22.0),
              child: Center(
                  child: ListView(
                children: [
                  /* SizedBox(
                        height: 50,
                      ), */ // use container for logo
                  DefaultTabController(
                    initialIndex: 0,
                    length: 2,
                    child: Container(
                      color: Colors.white,
                      height: MediaQuery.of(context).size.height * 0.06,
                      width: MediaQuery.of(context).size.width,
                      child: TabBar(
                        controller: _controller,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.transparent,
                        tabs: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              color: _controller.index == 0
                                  ? Color(0xffF9F9F9)
                                  : Colors.white,
                            ),
                            height: 40,
                            width: 200,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.phone,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Phone No.",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                              color: _controller.index == 1
                                  ? Color(0xffF9F9F9)
                                  : Colors.white,
                            ),
                            height: 40,
                            width: 200,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.email,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Email",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.30,
                    width: MediaQuery.of(context).size.width,
                    child: TabBarView(
                      controller: _controller,
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 15.0, bottom: 15),
                              child: Column(
                                children: [
                                  Card(
                                    color: Colors.grey[100],
                                    // elevation: 5,
                                    child: TextFormField(
                                      maxLength: 10,
                                      controller: _phoneNumberController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        counterText: "",
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(10),
                                        hintText: "Mobile Number",
                                        hintStyle: TextStyle(
                                            color: Colors.grey, fontSize: 19),
                                      ),
                                      validator: (phone) {
                                        Pattern pattern =
                                            r'(^(?:[+0]9)?[0-9]{10,}$)';
                                        RegExp regExp = new RegExp(pattern);
                                        if (phone.length == 0) {
                                          return 'Please enter mobile number';
                                        } else if (!regExp.hasMatch(phone)) {
                                          return 'Please enter mobile number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _send_code_by = "phone";
                                        _phone = _phoneNumberController.text;

                                        onPressSendCode();
                                      });
                                    },
                                    child: Card(
                                      color: Colors.blue[300],
                                      child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.05,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Center(
                                            child: Text(
                                              "Send Code",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20),
                                            ),
                                          )),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 15.0, bottom: 15),
                              child: Column(
                                children: [
                                  Card(
                                    color: Colors.grey[100],
                                    // elevation: 5,
                                    child: TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(10),
                                        hintText: "Email",
                                        hintStyle: TextStyle(
                                            color: Colors.grey, fontSize: 19),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _send_code_by = "email";
                                        _phone = _emailController.text;
                                        onPressSendCode();
                                      });
                                    },
                                    child: Card(
                                      color: Colors.blue[300],
                                      child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.05,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Center(
                                            child: Text(
                                              "Send Code",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20),
                                            ),
                                          )),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
          ),
        ),
      ),
    );


  }
}
