import 'dart:io';

String testData(String name) {
  var dir = Directory.current.path;
  if (dir.endsWith('/test')) {
    dir = dir.replaceAll('/test', '');
  }
  var path = '$dir/test/data/$name';
  return File(path).readAsStringSync();
}
