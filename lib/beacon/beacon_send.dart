import 'dart:async';

import 'dart:io' show Platform;
import 'package:beacons_plugin/beacons_plugin.dart';
import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:flutter/material.dart';
import 'beacon_info.dart';
import 'beacon_receive.dart';

class BeaconSend extends StatefulWidget {
  String minor;
  BeaconSend({@required this.minor});
  @override
  _BeaconSendState createState() => _BeaconSendState();
}

class _BeaconSendState extends State<BeaconSend> {
  var beacon_info = new BeaconInfo();

  BeaconBroadcast beaconBroadcast = BeaconBroadcast();
  BeaconStatus _isTransmissionSupported;
  bool _isAdvertising = false;
  StreamSubscription<bool> _isAdvertisingSubscription;

  final StreamController<String> beaconEventsController =
      StreamController<String>.broadcast();

  @override
  void initState() {
    super.initState();

    beaconBroadcast
        .checkTransmissionSupported()
        .then((isTransmissionSupported) {
      setState(() {
        _isTransmissionSupported = isTransmissionSupported;
      });
    });

    _isAdvertisingSubscription =
        beaconBroadcast.getAdvertisingStateChange().listen((isAdvertising) {
      setState(() {
        _isAdvertising = isAdvertising;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_isAdvertisingSubscription != null) {
      _isAdvertisingSubscription.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      onPressed: () async {
        await BeaconsPlugin.stopMonitoring;

        print("전달받은 minor는 " + widget.minor);

        beaconBroadcast
            .setUUID(beacon_info.uuid)
            .setMajorId(beacon_info.major)
            .setMinorId(int.parse(widget.minor))
            .setTransmissionPower(beacon_info.transmissionPower)
            .setAdvertiseMode(beacon_info.advertiseMode)
            .setIdentifier(beacon_info.identifier)
            .setLayout(beacon_info.layout)
            .setManufacturerId(beacon_info.manufacturerId)
            .setExtraData(beacon_info.extraData)
            .start();
      },
      child: Text('Send BeaconMessagae'),
    );
  }
}
