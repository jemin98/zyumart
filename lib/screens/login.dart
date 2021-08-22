import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/social_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:active_ecommerce_flutter/custom/input_decorations.dart';
import 'package:active_ecommerce_flutter/custom/intl_phone_input.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:active_ecommerce_flutter/addon_config.dart';
import 'package:active_ecommerce_flutter/screens/registration.dart';
import 'package:active_ecommerce_flutter/screens/main.dart';
import 'package:active_ecommerce_flutter/screens/password_forget.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:active_ecommerce_flutter/repositories/auth_repository.dart';
import 'package:active_ecommerce_flutter/helpers/auth_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:country_code_picker/country_code_picker.dart';
import 'dart:async';

import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  String _login_by = "email"; //phone or email
  String initialCountry = 'US';
  PhoneNumber phoneCode = PhoneNumber(isoCode: 'US', dialCode: "+1");
  String _phone = "";
  bool pass = true;
  bool isLoading = false;

  //controllers
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  // TextEditingController _passwordphoneController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TabController _controller;
  bool checked = false;

  @override
  void initState() {
    //on Splash Screen hide statusbar
    /* SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);*/
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

  onPressedLogin() async {
    var email = _emailController.text.toString();
    var password = _passwordController.text.toString();
    // var password = _passwordController.text.toString();

    if (_login_by == 'email' && email == "") {
      ToastComponent.showDialog("Enter email", context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    } else if (_login_by == 'phone' && _phone == "") {
      ToastComponent.showDialog("Enter phone number", context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    } else if (password == "") {
      ToastComponent.showDialog("Enter password", context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    }

    var loginResponse = await AuthRepository()
        .getLoginResponse(_login_by == 'email' ? email : _phone, password);

    if (loginResponse.result == false) {
      setState(() {
        isLoading = false;
      });
      ToastComponent.showDialog(loginResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
    } else {
      setState(() {
        isLoading = false;
      });

      ToastComponent.showDialog(loginResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      AuthHelper().setUserData(loginResponse);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Main();
      }));
    }
  }

  onPressedFacebookLogin() async {
    final facebookLogin = FacebookLogin();
    final facebookLoginResult = await facebookLogin.logIn(['email']);

    /*print(facebookLoginResult.accessToken);
    print(facebookLoginResult.accessToken.token);
    print(facebookLoginResult.accessToken.expires);
    print(facebookLoginResult.accessToken.permissions);
    print(facebookLoginResult.accessToken.userId);
    print(facebookLoginResult.accessToken.isValid());

    print(facebookLoginResult.errorMessage);
    print(facebookLoginResult.status);*/

    final token = facebookLoginResult.accessToken.token;

    /// for profile details also use the below code
    final graphResponse = await http.get(
        'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token');
    final profile = json.decode(graphResponse.body);
    //print(profile);
    /*from profile you will get the below params
    {
     "name": "Iiro Krankka",
     "first_name": "Iiro",
     "last_name": "Krankka",
     "email": "iiro.krankka\u0040gmail.com",
     "id": "<user id here>"
    }*/

    var loginResponse = await AuthRepository().getSocialLoginResponse(
        profile['name'], profile['email'], profile['id'].toString());

    if (loginResponse.result == false) {
      ToastComponent.showDialog(loginResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
    } else {
      ToastComponent.showDialog(loginResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      AuthHelper().setUserData(loginResponse);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Main();
      }));
    }
  }

  onPressedGoogleLogin() async {
    GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        // you can add extras if you require
      ],
    );

    _googleSignIn.signIn().then((GoogleSignInAccount acc) async {
      GoogleSignInAuthentication auth = await acc.authentication;
      print(acc.id);
      print(acc.email);
      print(acc.displayName);
      print(acc.photoUrl);

      acc.authentication.then((GoogleSignInAuthentication auth) async {
        print(auth.idToken);
        print(auth.accessToken);

        //---------------------------------------------------
        var loginResponse = await AuthRepository().getSocialLoginResponse(
            acc.displayName, acc.email, auth.accessToken);

        if (loginResponse.result == false) {
          ToastComponent.showDialog(loginResponse.message, context,
              gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
        } else {
          ToastComponent.showDialog(loginResponse.message, context,
              gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
          AuthHelper().setUserData(loginResponse);
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return Main();
          }));
        }

        //-----------------------------------
      });
    });
  }

  final _formKey = GlobalKey<FormState>();
  TextEditingController txtMobileNumber = TextEditingController();

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
        title: Text('Login'), // You can add title here
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back_ios, color: Colors.grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Container(
            color: Colors.white,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Center(
                child: Padding(
              padding: const EdgeInsets.only(
                  top: 22, bottom: 22.0, right: 22, left: 22),
              child: ListView(
                children: [
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
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    width: MediaQuery.of(context).size.width,
                    child: TabBarView(
                      controller: _controller,
                      children: [
                        ListView(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 15.0, bottom: 15),
                              child: Column(
                                children: [
                                  Card(
                                    color: Colors.grey[100],
                                    elevation: 0.5,
                                    child: TextFormField(
                                      style: TextStyle(fontSize: 19),
                                      maxLength: 10,
                                      keyboardType: TextInputType.number,
                                      controller: _phoneNumberController,
                                      decoration: InputDecoration(
                                        counterText: "",
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.all(10),
                                        hintText: "Mobile Number",
                                        hintStyle: TextStyle(
                                            color: Colors.grey, fontSize: 19),
                                        /*  prefixIcon: CountryCodePicker(

                                                initialSelection: 'NP',
                                                showCountryOnly: false,
                                                showOnlyCountryWhenClosed: false,
                                                */ /*
                                 alignLeft: true,*/ /*
                                                showFlag: true,
                                                favorite: ['+977', 'NP'],
                                              ),*/
                                      ),
                                      onChanged: (number) {
                                        print(number);
                                        setState(() {
                                          _phone = number;
                                        });
                                      },
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
                                    height: MediaQuery.of(context).size.height *
                                        0.015,
                                  ),
                                  Card(
                                    color: Colors.grey[100],
                                    // elevation: 5,
                                    child: TextFormField(
                                      style: TextStyle(fontSize: 19),
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
                                        hintText: "Password",
                                        hintStyle: TextStyle(
                                            color: Colors.grey, fontSize: 19),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02,
                                  ),
                                  /* CheckboxListTile(
                                    title: Text(
                                      "i agree to perfee Terms and Condtion",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    value: checked,
                                    activeColor: Colors.blue[300],
                                    onChanged: (value) {
                                      setState(() {
                                        checked = value;
                                      });
                                    },
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                  ),*/
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        (_phoneNumberController.text.length != 0 && _passwordController.text.length != 0) ?
                                        isLoading = true : isLoading = false;

                                        _login_by = 'phone';
                                      });
                                      onPressedLogin();
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
                                              "Login",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20),
                                            ),
                                          )),
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Don't Have Acoount Yet,",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return Registration();
                                          }));
                                        },
                                        child: Text(
                                          "SignUp",
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return PasswordForget();
                                      }));
                                    },
                                    child: Text(
                                      "Forget Password",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.048,
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 40,
                                        ),
                                        Visibility(
                                          visible:
                                              SocialConfig.allow_google_login,
                                          child: InkWell(
                                            onTap: () {
                                              onPressedGoogleLogin();
                                            },
                                            child: Container(
                                              width: 30,
                                              child: Image.asset(
                                                  "assets/google_logo.png"),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 30,
                                        ),
                                        Visibility(
                                          visible:
                                              SocialConfig.allow_facebook_login,
                                          child: InkWell(
                                            onTap: () {
                                              onPressedFacebookLogin();
                                            },
                                            child: Container(
                                              width: 30,
                                              child: Image.asset(
                                                  "assets/facebook_logo.png"),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        ListView(
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
                                            color: Colors.grey, fontSize: 17),
                                      ),
                                      validator: (email) {
                                        Pattern pattern =
                                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
                                        RegExp regExp = new RegExp(pattern);
                                        if (email.length == 0) {
                                          return 'Please enter Email id';
                                        } else if (!regExp.hasMatch(email)) {
                                          return 'Please enter correct Email id';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.015,
                                  ),
                                  Card(
                                    color: Colors.grey[100],
                                    // elevation: 5,
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
                                        hintStyle: TextStyle(
                                            color: Colors.grey, fontSize: 17),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02,
                                  ),
                                  /* CheckboxListTile(
                                    title: Text(
                                      "i agree to perfee Terms and Condtion",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    value: checked,
                                    onChanged: (value) {
                                      setState(() {
                                        checked = value;
                                      });
                                    },
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                  ),*/
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        (_emailController.text.length != 0 && _passwordController != 0) ?
                                        isLoading = true : isLoading = false;
                                      });

                                      onPressedLogin();
                                    },
                                    child: Card(
                                      color: Colors.blue[300],
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.05,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Center(
                                          child: Text(
                                            "Login",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Don't Have Acoount Yet,",
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return Registration();
                                          }));
                                        },
                                        child: Text(
                                          "SignUp",
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return PasswordForget();
                                      }));
                                    },
                                    child: Text(
                                      "Forget Password",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.048,
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 40,
                                        ),
                                        Visibility(
                                          visible:
                                              SocialConfig.allow_google_login,
                                          child: InkWell(
                                            onTap: () {
                                              onPressedGoogleLogin();
                                            },
                                            child: Container(
                                              width: 30,
                                              child: Image.asset(
                                                  "assets/google_logo.png"),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 30,
                                        ),
                                        Visibility(
                                          visible:
                                              SocialConfig.allow_facebook_login,
                                          child: InkWell(
                                            onTap: () {
                                              onPressedFacebookLogin();
                                            },
                                            child: Container(
                                              width: 30,
                                              child: Image.asset(
                                                  "assets/facebook_logo.png"),
                                            ),
                                          ),
                                        ),
                                      ],
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
            )),
          ),
        ),
      ),
    );
  }
}
