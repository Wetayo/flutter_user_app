import 'dart:async';
import 'dart:io' show Platform;
import 'package:beacons_plugin/beacons_plugin.dart';
import 'package:flutter/material.dart';
import 'package:wetayo_app/beacon/beacon_send.dart';
import 'beacon_info.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;

class BeaconReceive extends StatefulWidget {
  // int tabBarIndex;

  // BeaconReceive({@required this.tabBarIndex});
  @override
  _BeaconReceiveState createState() => _BeaconReceiveState();
}

class _BeaconReceiveState extends State<BeaconReceive> {
  var beacon_Info = new BeaconInfo();
  bool beaconRunning = true;
  final StreamController<String> beaconEventsController =
      StreamController<String>.broadcast();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    beaconEventsController.close();
    super.dispose();
  }

  Future<void> initPlatformState() async {
    if (Platform.isAndroid) {
      await BeaconsPlugin.setDisclosureDialogMessage(
          title: "Need Location Permission",
          message: "This app collects location data to work with beacons.");
    }

    BeaconsPlugin.listenToBeacons(beaconEventsController);

    await BeaconsPlugin.addRegion("iBeacon", DotEnv.env['BEACON_UUID']);

    beaconEventsController.stream.listen(
        (data) {
          if (data.isNotEmpty) {
            setState(() {
              beacon_Info.beaconResult = _setDistance(data);
              beacon_Info.nrMessaggesReceived++;
            });
            print("Beacons DataReceived: " + beacon_Info.beaconResult);
          }
        },
        onDone: () {},
        onError: (error) {
          print("Error: $error");
        });

    //Send 'true' to run in background
    await BeaconsPlugin.runInBackground(true);

    if (!mounted) return;
  }

  String _setDistance(String data) {
    Map<String, dynamic> tmp = jsonDecode(data);
    if (tmp['uuid'] == beacon_Info.uuid) {
      if (beacon_Info.beaconResult == "") {
        beacon_Info.minor = int.parse(tmp['minor']);
        return data;
      }
      Map<String, dynamic> original = jsonDecode(beacon_Info.beaconResult);
      if (tmp['minor'] != original['minor']) {
        if (double.parse(tmp['distance']) <
            double.parse(original['distance'])) {
          beacon_Info.minor = int.parse(tmp['minor']);
          return data;
        }
      }
    }
    return beacon_Info.beaconResult;
  }

  Future<int> _beaconReceive(BuildContext context) async {
    if (DefaultTabController.of(context).index == 1) {
      await BeaconsPlugin.startMonitoring;
    }
  }

  @override
  Widget build(BuildContext context) {
    _beaconReceive(context);
    return BeaconSend(
      minor: beacon_Info.minor,
    );
  }
}
