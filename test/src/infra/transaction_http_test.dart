import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logger/logger.dart';
import 'package:symbol_ddk/infra/transaction_http.dart';
import 'package:symbol_ddk/model/transaction/aggregate_transaction.dart';
import 'package:symbol_ddk/model/transaction/aggregate_transaction_info.dart';
import 'package:symbol_ddk/model/transaction/transaction.dart';
import 'package:symbol_ddk/model/transaction/transfer_transaction.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import '../test_data.dart';

void main() {
  /// ロガー
  final Logger logger = Logger();

  const String testDir = 'infra/transaction_http';

  test('承認済アグリゲートトランザクション検索 成功', () async {
    /** パラメータ **/
    String txId = 'EABF396F0BD8704C1582C7A15B5876F32D5B2D1938C549C00BDE3A3E18780531';
    /** テストデータ **/
    final client = MockClient((request) async {
      if (request.url.path == '/transactions/confirmed/$txId' &&
          request.url.queryParameters.isEmpty) {
        return http.Response(
          testData('$testDir/transaction_normal.json'),
          200,
          headers: {'content-type': 'text/html; charset=utf-8'},
        );
      }
      logger.e('Not Found: ${request.url.path}');
      return http.Response('Not Found', 404, headers: {'content-type': 'text/html; charset=utf-8'});
    });

    /** テスト実行 **/
    Transaction tx = await http.runWithClient(() async {
      TransactionHttp txHttp = TransactionHttp('symbol01.harvestasya.com:3001');
      return await txHttp.getConfirmedTx(txId);
    }, () => client);
    // 型変換
    AggregateTransaction aggregateTx = tx as AggregateTransaction;

    // データ確認
    expect(aggregateTx.transactionInfo!.height, '2550434');
    expect(aggregateTx.transactionInfo!.hash,
        'EABF396F0BD8704C1582C7A15B5876F32D5B2D1938C549C00BDE3A3E18780531');
    expect(aggregateTx.transactionInfo!.merkleComponentHash,
        '578A6F7DA907B3DF57745127EF473604A6AC44979113453D1DC42BCFF209F0B7');
    expect(aggregateTx.transactionInfo!.index, 0);
    expect(aggregateTx.transactionInfo!.timestamp, '76667466069');
    expect(aggregateTx.transactionInfo!.feeMultiplier, 100);

    expect(aggregateTx.size, 368);
    expect(aggregateTx.signature,
        'AD3C5AF614CE4ABE5449A868FDDDF5020FC2C4EA7C9FE42349F6BEE16EC0CA267235EF89A78EA39F82551F7FBD3EF117661FAF0BDE19452708FF509C669B490F');
    expect(aggregateTx.signerPublicKey,
        '12DF16F6DC102B9BB17C450E56315E63EEEDCC3E7E6692B37C9A0B1C22D93DCD');
    expect(aggregateTx.version, 2);
    expect(aggregateTx.network, 104);
    expect(aggregateTx.type, 16705);
    expect(aggregateTx.maxFee, '36800');
    expect(aggregateTx.deadline, '76688958369');
    expect(aggregateTx.transactionsHash,
        '85192B619E325CD2B761D1B481CE73389BFD9FCF7E8EF643DB642DEE45637285');

    expect(aggregateTx.cosignatures[0].version, '0');
    expect(aggregateTx.cosignatures[0].signerPublicKey,
        '032613603350D19639891C5D96DF55BDB7FD4CFBE03BAC367760E1C78C614EA9');
    expect(aggregateTx.cosignatures[0].signature,
        '3EF34C74DF42AE595E67C8A7FFD30F1D2FE370981817F74C06BA5649210432AC5EB7A4D16E8AEC7A1D93E16C49C279559B1CE7EE974D41DFF8EDADCD0D3ABC00');

    AggregateTransactionInfo aggregateTransactionInfo =
        aggregateTx.innerTransaction[0].transactionInfo as AggregateTransactionInfo;
    expect(aggregateTransactionInfo.height, '2550434');
    expect(aggregateTransactionInfo.aggregateHash,
        'EABF396F0BD8704C1582C7A15B5876F32D5B2D1938C549C00BDE3A3E18780531');
    expect(aggregateTransactionInfo.aggregateId, '64E1D0C9588C273D79250824');
    expect(aggregateTransactionInfo.index, 0);
    expect(aggregateTransactionInfo.timestamp, '76667466069');
    expect(aggregateTransactionInfo.feeMultiplier, 100);

    TransferTransaction transferTx = aggregateTx.innerTransaction[0] as TransferTransaction;
    expect(transferTx.signerPublicKey,
        '179DE5E32109AE013AF001934D6522DAE459A23C67981973E61CD5D1685D007D');
    expect(transferTx.version, 1);
    expect(transferTx.network, 104);
    expect(transferTx.type, 16724);
    expect(transferTx.recipientAddress, '685196962F3CB7ADD6150E2F8B40F074B46009411490B94A');

    expect(transferTx.mosaics[0].id, '6BED913FA20223F8');
    expect(transferTx.mosaics[0].amount, '160000000');
  });
}
