import 'package:base32/base32.dart';

class AddressUtil {
  /// 16進文字列Base32([hexBase32String])を文字列に変換
  String convString(String hexBase32String) {
    return base32.encodeHexString(hexBase32String).replaceAll('=', '');
  }
}
