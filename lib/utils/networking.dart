import 'dart:io';

import 'package:connectivity/connectivity.dart';

Future<bool> checkConnection() async {
  return [ConnectivityResult.mobile, ConnectivityResult.wifi]
          .contains(await Connectivity().checkConnectivity()) &&
      await _checkLookup();
}

Future<bool> _checkLookup() async {
  try {
    final result = await InternetAddress.lookup('example.com')
        .timeout(Duration(seconds: 2));
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}
