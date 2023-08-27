import 'package:symbol_ddk/util/string_util.dart';

import '../model/transaction/aggregate_transaction.dart';
import '../model/transaction/aggregate_transaction_info.dart';
import '../model/transaction/cosignature.dart';
import '../model/transaction/mosaic.dart';
import '../model/transaction/transaction.dart';
import '../model/transaction/transaction_info.dart';
import '../model/transaction/transaction_type.dart';
import '../model/transaction/transfer_transaction.dart';
import 'https.dart';

class TransactionHttp {
  /// Restゲートウェイ接続用ポート番号付ホスト
  final String _hostPort;

  /// # コンストラクタ
  TransactionHttp(this._hostPort);

  /// 承認済トランザクション取得
  Future<Transaction> getConfirmedTx(String txId) async {
    /** RESTゲートウェイからJson取得 **/
    Map<String, dynamic> jsonData = await _getConfirmedTxJson(txId);

    /** データクラス 生成 **/
    Transaction tx = _createTransactionEntity(jsonData);

    return tx;
  }

  /// トランザクションクラス生成
  Transaction _createTransactionEntity(Map<String, dynamic> jsonData, {bool isInnerTx = false}) {
    Transaction tx;
    switch (jsonData['transaction']['type']) {
      case TransactionType.aggregateComplete:
        tx = _createAggregateTransactionEntity(jsonData);
        break;
      case TransactionType.transfer:
        tx = _createTransferTransactionEntity(jsonData, isInnerTx: isInnerTx);
        break;
      default:
        throw Exception('未実装のトランザクションタイプ');
    }
    return tx;
  }

  /// 転送トランザクションクラス生成
  TransferTransaction _createTransferTransactionEntity(Map<String, dynamic> jsonData,
      {bool isInnerTx = false}) {
    /** トランザクション情報 **/
    TransactionInfo transactionInfo;
    if (isInnerTx) {
      // アグリゲート用
      transactionInfo = AggregateTransactionInfo(
        height: jsonData['meta']['height'],
        aggregateHash: jsonData['meta']['aggregateHash'],
        aggregateId: jsonData['meta']['aggregateId'],
        index: jsonData['meta']['index'],
        timestamp: jsonData['meta']['timestamp'],
        feeMultiplier: jsonData['meta']['feeMultiplier'],
      );
    } else {
      // 通常
      transactionInfo = TransactionInfo(
        height: jsonData['meta']['height'],
        hash: jsonData['meta']['hash'],
        merkleComponentHash: jsonData['meta']['merkleComponentHash'],
        index: jsonData['meta']['index'],
        timestamp: jsonData['meta']['timestamp'],
        feeMultiplier: jsonData['meta']['feeMultiplier'],
      );
    }
    /** 転送トランザクション **/
    /* モザイク */
    List<Mosaic> mosaicList = [];
    for (Map<String, dynamic> mosaic in jsonData['transaction']['mosaics']) {
      mosaicList.add(Mosaic(
        id: mosaic['id'],
        amount: mosaic['amount'],
      ));
    }
    StringUtil stringUtil = StringUtil();
    String? msg;
    if (jsonData['transaction']['message'] != null) {
      msg = stringUtil.convStringUtf8(jsonData['transaction']['message']);
    }
    /* 転送トランザクション */
    TransferTransaction transferTransaction = TransferTransaction(
      size: jsonData['transaction']['size'],
      signature: jsonData['transaction']['signature'],
      signerPublicKey: jsonData['transaction']['signerPublicKey'],
      version: jsonData['transaction']['version'],
      network: jsonData['transaction']['network'],
      type: jsonData['transaction']['type'],
      maxFee: jsonData['transaction']['maxFee'],
      deadline: jsonData['transaction']['deadline'],
      recipientAddress: jsonData['transaction']['recipientAddress'],
      transactionInfo: transactionInfo,
      message: msg,
      mosaics: mosaicList,
    );
    return transferTransaction;
  }

  /// アグリゲートトランザクションクラス生成
  AggregateTransaction _createAggregateTransactionEntity(Map<String, dynamic> jsonData) {
    /** トランザクション情報 **/
    TransactionInfo transactionInfo = TransactionInfo(
      height: jsonData['meta']['height'],
      hash: jsonData['meta']['hash'],
      merkleComponentHash: jsonData['meta']['merkleComponentHash'],
      index: jsonData['meta']['index'],
      timestamp: jsonData['meta']['timestamp'],
      feeMultiplier: jsonData['meta']['feeMultiplier'],
    );
    /** 署名者 **/
    List<Cosignature> cosignatureList = [];
    for (Map<String, dynamic> cosignature in jsonData['transaction']['cosignatures']) {
      cosignatureList.add(Cosignature(
        version: cosignature['version'],
        signerPublicKey: cosignature['signerPublicKey'],
        signature: cosignature['signature'],
      ));
    }
    /** インナートランザクション **/
    List<Transaction> innerTransactionList = [];
    for (Map<String, dynamic> innerTx in jsonData['transaction']['transactions']) {
      innerTransactionList.add(_createTransactionEntity(innerTx, isInnerTx: true));
    }
    /** アグリゲートトランザクション **/
    AggregateTransaction aggregateTransaction = AggregateTransaction(
      size: jsonData['transaction']['size'],
      signature: jsonData['transaction']['signature'],
      signerPublicKey: jsonData['transaction']['signerPublicKey'],
      version: jsonData['transaction']['version'],
      network: jsonData['transaction']['network'],
      type: jsonData['transaction']['type'],
      maxFee: jsonData['transaction']['maxFee'],
      deadline: jsonData['transaction']['deadline'],
      transactionsHash: jsonData['transaction']['transactionsHash'],
      transactionInfo: transactionInfo,
      cosignatures: cosignatureList,
      innerTransaction: innerTransactionList,
    );
    return aggregateTransaction;
  }

  /// 承認済トランザクションJson取得
  Future<Map<String, dynamic>> _getConfirmedTxJson(String txId) async {
    // Https生成
    Https https = Https(
      url: _hostPort,
      path: '/transactions/confirmed/$txId',
    );
    // 検索
    return await https.get();
  }
}
