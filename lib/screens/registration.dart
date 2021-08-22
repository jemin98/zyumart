import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:active_ecommerce_flutter/custom/input_decorations.dart';
import 'package:active_ecommerce_flutter/custom/intl_phone_input.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:active_ecommerce_flutter/addon_config.dart';
import 'package:active_ecommerce_flutter/screens/otp.dart';
import 'package:active_ecommerce_flutter/screens/login.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:active_ecommerce_flutter/repositories/auth_repository.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Registration extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration>
    with SingleTickerProviderStateMixin {
  String _register_by = "email"; //phone or email
  String initialCountry = 'US';
  PhoneNumber phoneCode = PhoneNumber(isoCode: 'US', dialCode: "+1");
  bool pass = true;
  String _phone = "";

  //controllers
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordConfirmController = TextEditingController();

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

  onPressSignUp() async {
    setState(() {
      isLoading = true;
    });
    print("yes goes inside");
    var name = _nameController.text.toString();
    var email = _emailController.text.toString();
    var password = _passwordController.text.toString();
    var password_confirm = _passwordConfirmController.text.toString();
    print(_phone);

    print(name);

    print(password);

    print(_register_by);
    if (name == "") {
      ToastComponent.showDialog("Enter your name", context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      return;
    } else if (_register_by == 'email' && email == "") {
      ToastComponent.showDialog("Enter email", context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      print("111111111111111111111111111");
      print(_register_by);
      return;
    } else if (_register_by == 'phone' && _phone == "") {
      ToastComponent.showDialog("Enter phone number", context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      print("000000000000000000000000000");
      print(_register_by);
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

    var signupResponse = await AuthRepository().getSignupResponse(
        name,
        _register_by == 'email' ? email : _phone,
        password,
        password_confirm,
        _register_by);

    if (signupResponse.result == false) {
      setState(() {
        isLoading = false;
      });
      ToastComponent.showDialog(signupResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
    } else {
      setState(() {
        isLoading = false;
      });
      ToastComponent.showDialog(signupResponse.message, context,
          gravity: Toast.CENTER, duration: Toast.LENGTH_LONG);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Otp(
          verify_by: _register_by,
          user_id: signupResponse.user_id,
        );
      }));
    }
  }

  TabController _controller;
  bool checked = false;
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
        title: Text('Registration'), // You can add title here
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back_ios, color: Colors.grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 2,
          ),
          child: SingleChildScrollView(
            child: Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Center(
                  child: Padding(
                padding: const EdgeInsets.all(22.0),
                child: ListView(
                  children: [
                    /* SizedBox(
                      height: MediaQuery.of(context).size.height * 0.015,
                    ),*/
                    Column(
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
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.65,
                          width: MediaQuery.of(context).size.width,
                          child: TabBarView(
                            controller: _controller,
                            children: [
                              ListView(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 15.0, bottom: 15),
                                    child: Column(
                                      children: [
                                        Card(
                                          color: Colors.grey[100],
                                          /* elevation: 5,*/
                                          child: TextFormField(
                                            controller: _nameController,
                                            keyboardType: TextInputType.name,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.all(10),
                                              hintText: "Name",
                                              hintStyle: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 19),
                                            ),
                                            validator: (name) {
                                              if (name.length == 0) {
                                                return 'Please enter ypur fullname';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02,
                                        ),
                                        Card(
                                          color: Colors.grey[100],
                                          /* elevation: 5,*/
                                          child: TextFormField(
                                            maxLength: 10,
                                            controller: _phoneNumberController,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              counterText: "",
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.all(10),
                                              hintText: "Phone Number",
                                              hintStyle: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 19),
                                              /* prefixIcon: CountryCodePicker(
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
                                                print(_phone);
                                              });
                                            },
                                            validator: (phone) {
                                              Pattern pattern =
                                                  r'(^(?:[+0]9)?[0-9]{10,}$)';
                                              RegExp regExp =
                                                  new RegExp(pattern);
                                              if (phone.length == 0) {
                                                return 'Please enter mobile number';
                                              } else if (!regExp
                                                  .hasMatch(phone)) {
                                                return 'Please enter mobile number';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02,
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
                                              contentPadding:
                                                  EdgeInsets.all(10),
                                              hintText: "PassWord",
                                              hintStyle: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 19),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02,
                                        ),
                                        Card(
                                          color: Colors.grey[100],
                                          // elevation: 5,
                                          child: TextFormField(
                                            controller:
                                                _passwordConfirmController,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.all(10),
                                              hintText: "Retype Password",
                                              hintStyle: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 19),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02,
                                        ),
                                        CheckboxListTile(
                                          title: Row(
                                            children: [
                                              Text(
                                                "i agree to perfee",
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      print("tap");
                                                      showDialog(
                                                        context: context,
                                                        builder: (_) =>
                                                            _TermCondiPopup(),
                                                      );
                                                    });
                                                  },
                                                  child: Text(
                                                    " Terms and Condtion",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Colors.blue[300]),
                                                  )),
                                            ],
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
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _register_by = "phone";
                                            });
                                            (checked == true)
                                                ? onPressSignUp()
                                                : ToastComponent.showDialog(
                                                    "Agree Terms & Condi.",
                                                    context,
                                                    gravity: Toast.CENTER,
                                                    duration:
                                                        Toast.LENGTH_LONG);
                                            /*Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return Otp();
                                            }));*/
                                          },
                                          child: Card(
                                            color: Colors.blue[300],
                                            child: Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.05,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Center(
                                                  child: Text(
                                                    "SignUp",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.white),
                                                  ),
                                                )),
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
                                    padding: const EdgeInsets.only(
                                        top: 15.0, bottom: 15),
                                    child: Column(
                                      children: [
                                        Card(
                                          color: Colors.grey[100],
                                          // elevation: 5,
                                          child: TextFormField(
                                            controller: _nameController,
                                            keyboardType: TextInputType.name,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.all(10),
                                              hintText: "Name",
                                              hintStyle: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 19),
                                            ),
                                            validator: (name) {
                                              if (name.length == 0) {
                                                return 'Please enter your fullname';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02,
                                        ),
                                        Card(
                                          color: Colors.grey[100],
                                          // elevation: 5,
                                          child: TextFormField(
                                            controller: _emailController,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.all(10),
                                              hintText: "Email",
                                              hintStyle: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 19),
                                            ),
                                            validator: (email) {
                                              Pattern pattern =
                                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
                                              RegExp regExp =
                                                  new RegExp(pattern);
                                              if (email.length == 0) {
                                                return 'Please enter Email id';
                                              } else if (!regExp
                                                  .hasMatch(email)) {
                                                return 'Please enter correct Email id';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02,
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
                                              contentPadding:
                                                  EdgeInsets.all(10),
                                              hintText: "PassWord",
                                              hintStyle: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 19),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02,
                                        ),
                                        Card(
                                          color: Colors.grey[100],
                                          // elevation: 5,
                                          child: TextFormField(
                                            controller:
                                                _passwordConfirmController,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.all(10),
                                              hintText: "Confirm Password",
                                              hintStyle: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 19),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.02,
                                        ),
                                        CheckboxListTile(
                                          title: Row(
                                            children: [
                                              Text(
                                                "i agree to perfee",
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      print("tap");
                                                      showDialog(
                                                        context: context,
                                                        builder: (_) =>
                                                            _TermCondiPopup(),
                                                      );
                                                      _TermCondiPopup();
                                                    });
                                                  },
                                                  child: Text(
                                                    " Terms and Condtion",
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Colors.blue[300]),
                                                  )),
                                            ],
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
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            (checked == true)
                                                ? onPressSignUp()
                                                : ToastComponent.showDialog(
                                                    "Agree Terms & Condi.",
                                                    context,
                                                    gravity: Toast.CENTER,
                                                    duration:
                                                        Toast.LENGTH_LONG);
                                            /* Navigator.push(context, MaterialPageRoute(builder: (Context){
                                              return Otp();
                                            }));*/
                                          },
                                          child: Card(
                                            color: Colors.blue[300],
                                            child: Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.05,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: Center(
                                                  child: Text(
                                                    "SignUp",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.white),
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
                      ],
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
      ),
    );
  }
}

class _TermCondiPopup extends StatefulWidget {
  @override
  __TermCondiPopupState createState() => __TermCondiPopupState();
}

class __TermCondiPopupState extends State<_TermCondiPopup>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    scaleAnimation =
        CurvedAnimation(parent: controller, curve: Curves.elasticInOut);

    controller.addListener(() {
      setState(() {});
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    print("yes");
    return ScaleTransition(
      scale: scaleAnimation,
      child: Dialog(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        // elevation: 0,
        backgroundColor: Colors.transparent,
        child: contentBox(context),
      ),
    );
  }
}

contentBox(context) {
  return Stack(
    children: [
      Positioned(
        top: 0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          height: MediaQuery.of(context).size.height * 0.7,
          width: MediaQuery.of(context).size.width * 0.8,
          child: WebView(
            initialUrl: 'https://upaharhouse.org/page/terms-of-use.php',
          ),
        ),
      ),
      Positioned(
        top: 5,
        right: 5,
        child: Container(
          height: 30,
          width: 30,
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: Color(0xffE6F0D5)),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.close),
          ),
        ),
      )
    ],
  );
}
