import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logger/logger.dart';
import 'package:symbol_ddk/infra/statistics_service_http.dart';
import 'package:symbol_ddk/util/comsa_nft.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import '../test_data.dart';

void main() {
  /// ロガー
  final Logger logger = Logger();

  const String testDir = 'util/comsa_nft';

  test('ComsaNFTデコード', () async {
    /** テストデータ **/
    final client = MockClient((request) async {
      if (request.url.path == '/sss/nodes' && request.url.query.isEmpty) {
        return http.Response(
          testData('$testDir/statistics_service_nodes_normal.json'),
          200,
          headers: {'content-type': 'text/html; charset=utf-8'},
        );
      } else if (request.url.path == '/sss/nodes' && request.url.queryParameters['ssl'] == 'true') {
        return http.Response(
          testData('$testDir/statistics_service_nodes_ssl_normal.json'),
          200,
          headers: {'content-type': 'text/html; charset=utf-8'},
        );
      } else if (request.url.path == '/sss/nodesHeightStats') {
        return http.Response(
          testData('$testDir/statistics_service_nodes_height_stats_normal.json'),
          200,
          headers: {'content-type': 'text/html; charset=utf-8'},
        );
      } else if (request.url.path == '/network/properties') {
        return http.Response(
          testData('$testDir/network_properties_normal.json'),
          200,
          headers: {'content-type': 'text/html; charset=utf-8'},
        );
      } else if (request.url.path == '/metadata' &&
          request.url.queryParameters['targetId'] == '0F82D168E703BC51' &&
          request.url.queryParameters['pageSize'] == '20' &&
          request.url.queryParameters['pageNumber'] == '1') {
        return http.Response(
          testData('$testDir/metadata_normal.json'),
          200,
          headers: {'content-type': 'text/html; charset=utf-8'},
        );
      } else if (request.url.path.contains('/transactions/confirmed')) {
        String txId = request.url.path.substring(24);
        return http.Response(
          testData('$testDir/transactions_confirmed_$txId.json'),
          200,
          headers: {'content-type': 'text/html; charset=utf-8'},
        );
      }
      logger.e('Not Found: ${request.url.path}');
      return http.Response('Not Found', 404, headers: {'content-type': 'text/html; charset=utf-8'});
    });

    /** テスト実行 **/
    Uint8List nftData = await http.runWithClient(() async {
      // SS初期化
      StatisticsServiceHttp ssHttp = StatisticsServiceHttp();
      await ssHttp.init();
      // ComsaNft
      ComsaNft comsaNft = ComsaNft();
      return await comsaNft.decoder(mosaicId: '0F82D168E703BC51');
    }, () => client);

    expect(nftData, isNotNull);

    String path = await FileSaver.instance.saveFile(
      name: 'test',
      bytes: nftData,
      ext: 'jpg',
      mimeType: MimeType.jpeg,
    );
    logger.d('$pathに保存しました');
  });
}
