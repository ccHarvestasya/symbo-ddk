import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logger/logger.dart';
import 'package:symbol_ddk/infra/metadata_http.dart';
import 'package:symbol_ddk/infra/metadata_search_criteria.dart';
import 'package:symbol_ddk/infra/page.dart';
import 'package:symbol_ddk/model/metadata/metadata_entry.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import '../test_data.dart';

void main() {
  /// ロガー
  final Logger logger = Logger();

  const String testDir = 'infra/metadata_http';

  test('Metadata 検索 成功', () async {
    final client = MockClient((request) async {
      if (request.url.path == '/metadata' &&
          request.url.queryParameters['targetId'] == '0F82D168E703BC51' &&
          request.url.queryParameters['pageSize'] == '20' &&
          request.url.queryParameters['pageNumber'] == '1') {
        return http.Response(
          testData('$testDir/metadata_normal.json'),
          200,
          headers: {'content-type': 'text/html; charset=utf-8'},
        );
      }
      logger.e('Not Found: ${request.url.path}');
      return http.Response('Not Found', 404, headers: {'content-type': 'text/html; charset=utf-8'});
    });

    Page<MetadataEntry> metadataEntryPage = await http.runWithClient(() async {
      MetadataHttp metadataHttp = MetadataHttp('symbol01.harvestasya.com:3001');
      return await metadataHttp.searchMetadata(
          searchCriteria: MetadataSearchCriteria(targetId: '0F82D168E703BC51'));
    }, () => client);

    // ページ確認
    expect(metadataEntryPage.pageNumber, 1);
    expect(metadataEntryPage.pageSize, 20);
    expect(metadataEntryPage.isLastPage, isTrue);

    // データ確認
    List<MetadataEntry> metadataEntry = metadataEntryPage.data;
    expect(metadataEntry, isNotEmpty);
    expect(metadataEntry, isList);
    expect(metadataEntry.length, 8);
  });
}
