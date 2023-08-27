import 'dart:convert';

import 'package:convert/convert.dart';

class StringUtil {
  /// 16進文字列([hexString])をUTF-8文字列に変換
  String convStringUtf8(String hexString) {
    return utf8.decode(hex.decode(hexString));
  }
}
