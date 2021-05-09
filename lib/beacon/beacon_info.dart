import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;

class BeaconInfo {
  String beaconResult = "";
  int nrMessaggesReceived = 0;

  String uuid = DotEnv.env['BEACON_UUID'];
  int major = 0xffff;
  int minor = 0;
  int transmissionPower = -59;
  String identifier = 'iBeacon';
  AdvertiseMode advertiseMode = AdvertiseMode.lowPower;
  String layout = BeaconBroadcast.ALTBEACON_LAYOUT;
  int manufacturerId = 0x0118;
  List<int> extraData = [100];
}
