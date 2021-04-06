import 'dart:async';
import 'dart:io' show Platform;
import 'package:beacons_plugin/beacons_plugin.dart';
import 'package:flutter/material.dart';
import 'package:wetayo_app/beacon/beacon_send.dart';
import 'package:wetayo_app/screen/mutationTest.dart';
import 'beacon_info.dart';
import 'dart:convert';

class BeaconReceive extends StatefulWidget {
  @override
  _BeaconReceiveState createState() => _BeaconReceiveState();
}

class _BeaconReceiveState extends State<BeaconReceive> {
  var beacon_info = new BeaconInfo();

  final StreamController<String> beaconEventsController =
      StreamController<String>.broadcast();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    _beaconReceive();
    //_insertTransaction(beacon_info);
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

    await BeaconsPlugin.addRegion(
        "iBeacon", "77707f98-a4da-451e-859f-5a29fdb8cd15");

    beaconEventsController.stream.listen(
        (data) {
          if (data.isNotEmpty) {
            setState(() {
              beacon_info.beaconResult = _setDistance(data);
              beacon_info.nrMessaggesReceived++;
            });
            print("Beacons DataReceived: " + beacon_info.beaconResult);
          }
        },
        onDone: () {},
        onError: (error) {
          print("Error: $error");
        });

    //Send 'true' to run in background
    await BeaconsPlugin.runInBackground(true);

    if (Platform.isAndroid) {
      BeaconsPlugin.channel.setMethodCallHandler((call) async {
        if (call.method == 'scannerReady') {
          await BeaconsPlugin.startMonitoring;
        }
      });
    } else if (Platform.isIOS) {
      await BeaconsPlugin.startMonitoring;
    }

    if (!mounted) return;
  }

  String _setDistance(String data) {
    Map<String, dynamic> tmp = jsonDecode(data);
    if (tmp['uuid'] == beacon_info.uuid) {
      if (beacon_info.beaconResult == "") {
        beacon_info.minor = int.parse(tmp['minor']);
        _sendMinor(tmp['minor']);
        return data;
      }
      Map<String, dynamic> original = jsonDecode(beacon_info.beaconResult);
      if (tmp['minor'] != original['minor']) {
        if (double.parse(tmp['distance']) <
            double.parse(original['distance'])) {
          beacon_info.minor = int.parse(tmp['minor']);
          _sendMinor(tmp['minor']);
          return data;
        }
      }
    }
    return beacon_info.beaconResult;
  }

  Future _beaconReceive() async {
    await BeaconsPlugin.startMonitoring;
  }

  Future _sendMinor(String minor) async {
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => BeaconSend(minor: beacon_info.minor.toString())));
  }

/*
  Future<int> _insertTransaction(dynamic object) async {
    var _setBeaconMinor = new setBeaconMinor();
    //_setBeaconMinor.fromMap(<String, dynamic>{
    //   "minor": object.minor,
    //  });
    _setBeaconMinor.toMap(object);
    print("success toMap " + object.toString());
  }
*/
  @override
  Widget build(BuildContext context) {
    return MutationTest();
  }
}
