import 'dart:async';

import 'package:beacons_plugin/beacons_plugin.dart';
import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:flutter/material.dart';
import 'beacon_info.dart';
import 'beacon_receive.dart';

class BeaconSend extends StatefulWidget {
  int minor;

  BeaconSend({@required this.minor});
  @override
  _BeaconSendState createState() => _BeaconSendState();
}

class _BeaconSendState extends State<BeaconSend> {
  var beacon_Info = new BeaconInfo();
  bool ableToRun = false;
  double iconSize = 0;
  Icon buttonIcon;

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

/*
  isEnabled() {
    if (widget.minor != 0) {
      setState(() {
        buttonIcon = Icon(
          Icons.notifications,
          color: Color(0xff184C88),
          size: iconSize,
        );
        ableToRun = true;
      });
      return ableToRun;
    }

    setState(() {
      buttonIcon = Icon(
        Icons.notifications,
        color: Colors.grey,
        size: iconSize,
      );
    });
    return ableToRun;
  }
*/
  isEnabled() {
    if (widget.minor != 0) {
      ableToRun = true;
      setIconColor();
      return ableToRun;
    }

    setIconColor();
    return ableToRun;
  }

  setIconColor() {
    if (ableToRun) {
      setState(() {
        buttonIcon = Icon(
          Icons.notifications,
          color: Color(0xff184C88),
          size: iconSize,
        );
      });
    } else {
      setState(() {
        buttonIcon = Icon(
          Icons.notifications,
          color: Colors.grey,
          size: iconSize,
        );
      });
    }
    return buttonIcon;
  }

  @override
  Widget build(BuildContext context) {
    iconSize = MediaQuery.of(context).size.height * 0.4;

    return Scaffold(
        body: Center(
            child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FlatButton.icon(
            icon: setIconColor(),
            onPressed: isEnabled()
                ? () async {
                    await BeaconsPlugin.stopMonitoring;

                    print("전달받은 minor는 " + widget.minor.toString());

                    beaconBroadcast
                        .setUUID(beacon_Info.uuid)
                        .setMajorId(beacon_Info.major)
                        .setMinorId(widget.minor)
                        .setTransmissionPower(beacon_Info.transmissionPower)
                        .setAdvertiseMode(beacon_Info.advertiseMode)
                        .setIdentifier(beacon_Info.identifier)
                        .setLayout(beacon_Info.layout)
                        .setManufacturerId(beacon_Info.manufacturerId)
                        .setExtraData(beacon_Info.extraData)
                        .start();

                    Future.delayed(const Duration(seconds: 3), () {
                      setState(() {
                        print("beacon send to stop");
                        beaconBroadcast.stop();
                      });

                      ableToRun = false;
                      setIconColor();
                      widget.minor = 0;
                    });
                  }
                : null,
            label: Text("")),
      ],
    )));
  }
}
