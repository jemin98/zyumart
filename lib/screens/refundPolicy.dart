import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class refundPolicy extends StatefulWidget {


  @override
  _refundPolicyState createState() => _refundPolicyState();
}

class _refundPolicyState extends State<refundPolicy> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Refund Policy"),),
      body: WebView(
        initialUrl: 'https://upaharhouse.org/page/refund.php',
      ),
    );
  }
}
