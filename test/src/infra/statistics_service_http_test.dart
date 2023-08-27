import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logger/logger.dart';
import 'package:symbol_ddk/infra/statistics_service_http.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import '../test_data.dart';

void main() {
  /// ロガー
  final Logger logger = Logger();

  const String testDir = 'infra/statistics_service_http';

  test('StatisticsService初期化成功', () async {
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
      }
      logger.e('Not Found: ${request.url.path}');
      return http.Response('Not Found', 404, headers: {'content-type': 'text/html; charset=utf-8'});
    });

    StatisticsServiceHttp ssHttp = StatisticsServiceHttp();

    await http.runWithClient(() async {
      await ssHttp.init();
    }, () => client);

    List<String> restGatewayHostList = ssHttp.getRestGatewayHostList();
    String restGatewayHost = ssHttp.getRestGatewayHost();

    expect(restGatewayHostList, isNotEmpty);
    expect(restGatewayHostList, isList);
    expect(restGatewayHostList.length, 5);

    expect(restGatewayHost, isNotEmpty);
    logger.i(restGatewayHost);
  });
}
