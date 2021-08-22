import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class termAndCondi extends StatefulWidget {

  @override
  _termAndCondiState createState() => _termAndCondiState();
}

class _termAndCondiState extends State<termAndCondi> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Terms & Condition"),),
      body: WebView(
        initialUrl: 'https://upaharhouse.org/page/terms-of-use.php',
      ),
    );
  }
}
