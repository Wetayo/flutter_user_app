import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;

String _urlPrefix = DotEnv.env['ARRIVAL_URL'];
String _serviceKey = DotEnv.env['ARRIVAL_KEY'];
const String _idPrefix = '&stationId=';
// const String _defaultid = '123456789';

const String STATUS_OK = '0';

String buildUrl(String id) {
  StringBuffer sb = StringBuffer();
  sb.write(_urlPrefix);
  sb.write(_serviceKey);
  sb.write(_idPrefix);
  sb.write(id);

  return sb.toString();
}
