
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class aboutUs extends StatefulWidget {


  @override
  _aboutUsState createState() => _aboutUsState();
}

class _aboutUsState extends State<aboutUs> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("About Us"),),
      body: WebView(
        initialUrl: 'https://upaharhouse.org/page/about.php',
      ),
    );
  }
}
