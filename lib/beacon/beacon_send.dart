import 'dart:async';

import 'package:wetayo_app/screen/home_screen.dart';
import 'package:beacons_plugin/beacons_plugin.dart';
import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:flutter/material.dart';
import 'beacon_info.dart';
import 'beacon_receive.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

class BeaconSend extends StatefulWidget {
  int minor;

  BeaconSend({@required this.minor});
  @override
  _BeaconSendState createState() => _BeaconSendState();
}

class _BeaconSendState extends State<BeaconSend> {
  var beacon_Info = new BeaconInfo();
  bool ableToRun = false;
  String message = "파란색이 되면 눌러주세요!";
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
        // message = "하차벨 가능";
      });
    } else {
      setState(() {
        buttonIcon = Icon(
          Icons.notifications,
          color: Colors.white,
          size: iconSize,
        );
      });
    }
    return buttonIcon;
  }

  void _showDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          Future.delayed(const Duration(seconds: 3), () {
            Navigator.of(context).pop();
          });
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              content: SizedBox(
                  height: 180,
                  child: Column(
                    children: [
                      Center(
                        child: new Text(
                          "하차벨 정상 울림",
                          style: TextStyle(
                              fontSize: 30.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 40),
                      CircularCountDownTimer(
                          width: 80,
                          height: 80,
                          duration: 3,
                          fillColor: Color(0xff184C88),
                          color: Colors.white,
                          isReverse: true,
                          isTimerTextShown: false,
                          //isReverseAnimation: true,
                          textStyle: TextStyle(
                              fontSize: 30.0, fontWeight: FontWeight.bold))
                    ],
                  )));
        });
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
                    if (DefaultTabController.of(context).index == 1) {
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

                      _showDialog();

                      Future.delayed(const Duration(seconds: 3), () {
                        setState(() {
                          print("beacon send to stop");
                          beaconBroadcast.stop();
                          //  message = "하차벨 불가";
                        });

                        ableToRun = false;
                        setIconColor();
                        widget.minor = 0;
                      });
                    }
                  }
                : null,
            label: Text("")),
        Text('$message',
            style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center)
      ],
    )));
  }
}
