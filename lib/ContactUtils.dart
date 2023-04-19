import 'dart:io';

class ContactUtils {
  static String appName = "TraitZ";

  static String screenTitle = "Share TraitZ";

  static String shareTitle = "Don't miss to check the TraitZ App!";

  static String getSharableText() {
    String msg = "";

    if (Platform.isAndroid) {
      msg = "Download TraitZ App and Enjoy! Link: https://shorturl.at/FHLN4";
    } else if (Platform.isIOS) {
      msg =
          "Download TraitZ App from TestFlight. Link: https://testflight.apple.com/join/LOXtw5WI";
    } else {
      msg = "Checkout our website: https://traitz.me";
    }

    return msg;
  }
}
