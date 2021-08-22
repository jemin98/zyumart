
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class privacypolicy extends StatefulWidget {


  @override
  _privacypolicyState createState() => _privacypolicyState();
}

class _privacypolicyState extends State<privacypolicy> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Privacy Policy"),),
      body: WebView(
        initialUrl: 'https://upaharhouse.org/page/privacy-policy.php',
      ),
    );
  }
}
