import 'package:beacon_broadcast/beacon_broadcast.dart';

class BeaconInfo {
  String beaconResult = "";
  int nrMessaggesReceived = 0;

  String uuid = "77707f98-a4da-451e-859f-5a29fdb8cd15";
  int major = 0xffff;
  int minor = 0;
  int transmissionPower = -59;
  String identifier = 'iBeacon';
  AdvertiseMode advertiseMode = AdvertiseMode.lowPower;
  String layout = BeaconBroadcast.ALTBEACON_LAYOUT;
  int manufacturerId = 0x0118;
  List<int> extraData = [100];
}