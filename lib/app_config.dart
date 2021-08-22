import 'package:flutter/material.dart';

var this_year = DateTime.now().year.toString();

class AppConfig {
  static String copyright_text = "@ Upahar House Private Limited" +
      this_year; //this shows in the splash screen
  static String app_name = "Upahar House"; //this shows in the splash screen
  static String purchase_code =
      "2dd9e124-c534-4c77-9f7e-a023cb12417c"; //enter your purchase code for the app from codecanyon

  //configure this
  static const bool HTTPS = true;

  //configure this
  static const DOMAIN_PATH = "zyumart.com"; //localhost
  //static const DOMAIN_PATH = "demo.activeitzone.com/ecommerce_flutter_demo"; //inside a folder
  //static const DOMAIN_PATH = "smileturbans.com"; // directly inside the public folder

  //do not configure these below
  static const String API_ENDPATH = "api/v2";
  static const String PUBLIC_FOLDER = "public";
  static const String PROTOCOL = HTTPS ? "https://" : "http://";
  static const String RAW_BASE_URL = "${PROTOCOL}${DOMAIN_PATH}";
  static const String BASE_URL = "${RAW_BASE_URL}/${API_ENDPATH}";

  //configure this if you are using amazon s3 like services
  //give direct link to file like https://[[bucketname]].s3.ap-southeast-1.amazonaws.com/
  //otherwise do not change anythink
  // static const String BASE_PATH = "${RAW_BASE_URL}/${PUBLIC_FOLDER}/";
  static const String BASE_PATH =
      "https://upaharh.s3.ap-south-1.amazonaws.com/";
}
