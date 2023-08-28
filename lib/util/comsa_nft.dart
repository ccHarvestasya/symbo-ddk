import 'dart:collection';
import 'dart:convert' as convert;
import 'dart:typed_data';

import 'package:convert/convert.dart';

import '../infra/metadata_http.dart';
import '../infra/metadata_search_criteria.dart';
import '../infra/page.dart';
import '../infra/statistics_service_http.dart';
import '../infra/transaction_http.dart';
import '../model/comsa_nft/comsa_metadata_type.dart';
import '../model/comsa_nft/comsa_nft_info.dart';
import '../model/comsa_nft/comsa_nft_info_detail.dart';
import '../model/metadata/metadata_entry.dart';
import '../model/transaction/aggregate_transaction.dart';
import '../model/transaction/transaction.dart';
import '../model/transaction/transfer_transaction.dart';

class ComsaNft {
  ComsaNftInfoDetail? _comsaNftInfoDetail;

  /// # ComsaNFTデコーダ
  /// [mosaicId]に紐付いたNFTデータをデコードする
  Future<Uint8List> decoder({required String mosaicId}) async {
    String nftStringData = await _getNftStringData(mosaicId: mosaicId);

    Uint8List nftData;
    if (_comsaNftInfoDetail!.version == 'comsa-nft-1.0') {
      // Base64デコード
      final base64Decoder = convert.base64.decoder;
      nftData = base64Decoder.convert(nftStringData);
    } else {
      // 16進文字列をUint8Listに変換
      List<int> intList = hex.decode(nftStringData);
      nftData = Uint8List.fromList(intList);
    }
    return nftData;
  }

  /// # ComsaNFTデコーダ
  /// [mosaicId]に紐付いたNFTデータをデコードする
  Future<String> _getNftStringData({required String mosaicId}) async {
    /** StatisticsService取得 **/
    StatisticsServiceHttp ssHttp = StatisticsServiceHttp();

    /** モザイクメタデータ **/
    // モザイクメタデータRest取得
    MetadataHttp metadataHttp = MetadataHttp(ssHttp.getRestGatewayHost());
    Page<MetadataEntry> metadataEntryPage = await metadataHttp.searchMetadata(
      searchCriteria: MetadataSearchCriteria(targetId: mosaicId),
    );
    // ComsaNFT情報クラス生成
    ComsaNftInfo comsaNftInfo = _createComsaNftInfo(metadataEntryPage.data);
    _comsaNftInfoDetail = comsaNftInfo.comsaNftInfoDetail;

    /** トランザクション **/
    // Restゲートウェイホストリスト取得
    List<String> hostPortList = ssHttp.getRestGatewayHostList();
    // トランザクションハッシュリストをチャンクに分割
    List<String> aggregateTransactionHashList = comsaNftInfo.aggregateTransactionHashes;
    int count = 0;
    int chunkSize = (aggregateTransactionHashList.length / hostPortList.length).ceil();
    List<List<String>> chunkedList = [];
    do {
      chunkedList.add(aggregateTransactionHashList.skip(count).take(chunkSize).toList());
      count += chunkSize;
    } while (count < aggregateTransactionHashList.length);

    print(_comsaNftInfoDetail!.version);

    // 1.0はメッセージの先頭で並び替える
    // 1.1はインナートランザクションのメタデータのインデックスで並び替える
    String nftStringData = '';
    if (_comsaNftInfoDetail!.version == 'comsa-nft-1.0') {
      /* comsa-nft-1.0 */
      // トランザクションメッセージ取得
      List<Future<List<String>>> aggTxMsgFutureList = [];
      for (int i = 0; i < chunkedList.length; i++) {
        aggTxMsgFutureList.add(_getAggregateTxMessage(hostPortList[i], chunkedList[i]));
      }
      // 完了待機
      List<List<String>> futureResultList = await Future.wait(aggTxMsgFutureList);
      // トランザクションメッセージを一つのリストに連結
      List<String> txMsgList = [];
      final regExp = RegExp(r'\d{5}#');
      for (List<String> innerTxMsgList in futureResultList) {
        for (String innerTxMsg in innerTxMsgList) {
          if (regExp.hasMatch(innerTxMsg)) {
            // データのみ取得
            txMsgList.add(innerTxMsg);
          }
        }
      }
      // ソート
      txMsgList.sort(((a, b) => a.substring(0, 6).compareTo(b.substring(0, 6))));
      // リストを文字列に連結
      for (String txMsg in txMsgList) {
        nftStringData += txMsg.substring(7);
      }
    } else {
      /* comsa-nft-1.1 */
      // インナートランザクション取得
      List<Future<Map<int, List<TransferTransaction>>>> aggInnerTxFutureListMap = [];
      for (int i = 0; i < chunkedList.length; i++) {
        aggInnerTxFutureListMap.add(_getInnerTx(hostPortList[i], chunkedList[i]));
      }
      // 完了待機
      List<Map<int, List<TransferTransaction>>> futureResultListMap =
          await Future.wait(aggInnerTxFutureListMap);
      // トランザクションを一つのマップに連結
      Map<int, List<TransferTransaction>> txListMap = {};
      for (Map<int, List<TransferTransaction>> innerTxListMap in futureResultListMap) {
        txListMap.addAll(innerTxListMap);
      }
      // ソート
      txListMap = SplayTreeMap.from(txListMap, (a, b) => a.compareTo(b));
      // トランザクションリストのメッセージを連結
      for (MapEntry<int, List<TransferTransaction>> txList in txListMap.entries) {
        txList.value.removeAt(0); // 最初は不要なので削除
        for (TransferTransaction tx in txList.value) {
          nftStringData += tx.message!;
        }
      }
    }

    return nftStringData;
  }

  ComsaNftInfoDetail? get comsaNftInfoDetail => _comsaNftInfoDetail;

  /// # ComsaNFT情報クラス生成
  ComsaNftInfo _createComsaNftInfo(List<MetadataEntry> metadataEntryList) {
    String reserved = '';
    String version = '';
    List<String> thumbnailAggregateTransactionHashList = [];
    String description = '';
    String endorser = '';
    int transactionNumber = 0;
    ComsaNftInfoDetail? comsaNftInfoDetail;
    List<String> aggregateTransactionHashList = [];

    for (MetadataEntry metadataEntry in metadataEntryList) {
      if (metadataEntry.scopedMetadataKey == ComsaMetadataType.reserved) {
        // 不明
        reserved = metadataEntry.value;
      } else if (metadataEntry.scopedMetadataKey == ComsaMetadataType.version) {
        // Comsaバージョン
        version = metadataEntry.value;
      } else if (metadataEntry.scopedMetadataKey == ComsaMetadataType.tmbAggregateTxHash) {
        // サムネイルのアグリゲートトランザクションハッシュ
        thumbnailAggregateTransactionHashList = _convertJson(metadataEntry.value).cast<String>();
      } else if (ComsaMetadataType.descriptionList.contains(metadataEntry.scopedMetadataKey)) {
        // NFTの説明文
        description = metadataEntry.value;
      } else if (metadataEntry.scopedMetadataKey == ComsaMetadataType.endorser) {
        // エンドーサ
        endorser = metadataEntry.value;
      } else if (metadataEntry.scopedMetadataKey == ComsaMetadataType.aggregateTxNumber) {
        // NFTデータのアグリゲートトランザクション数
        transactionNumber = int.parse(metadataEntry.value);
      } else if (metadataEntry.scopedMetadataKey == ComsaMetadataType.comsaNftInfoDetail ||
          metadataEntry.scopedMetadataKey == ComsaMetadataType.comsaNftInfoDetail2) {
        // NFT情報JSON
        Map<String, dynamic> nftJson = _convertJson(metadataEntry.value);
        comsaNftInfoDetail = ComsaNftInfoDetail(
          version: nftJson['version'],
          name: nftJson['name'],
          title: nftJson['title'],
          hash: nftJson['hash'],
          type: nftJson['type'],
          mimeType: nftJson['mime_type'],
          media: nftJson['media'],
          address: nftJson['address'],
          mosaic: nftJson['mosaic'],
          endorser: nftJson['endorser'],
        );
      } else if (ComsaMetadataType.aggregateTxHashList.contains(metadataEntry.scopedMetadataKey)) {
        // NFTデータのアグリゲートトランザクションハッシュ
        aggregateTransactionHashList.addAll(_convertJson(metadataEntry.value).cast<String>());
      } else {
        throw Exception('${metadataEntry.scopedMetadataKey}: 不明な Comsa NFT Metadata Key です');
      }
    }

    /* ComsaNFT情報クラス生成 */
    ComsaNftInfo comsaNftInfo = ComsaNftInfo(
      reserved: reserved,
      version: version,
      thumbnailAggregateTransactionHash: thumbnailAggregateTransactionHashList,
      description: description,
      endorser: endorser,
      transactionNumber: transactionNumber,
      comsaNftInfoDetail: comsaNftInfoDetail,
      aggregateTransactionHashes: aggregateTransactionHashList,
    );

    return comsaNftInfo;
  }

  /// # アグリゲートトランザクション内メッセージ取得
  Future<List<String>> _getAggregateTxMessage(String hostPort, List<String> txHashList) async {
    List<String> txMsgList = [];

    TransactionHttp txHttp = TransactionHttp(hostPort);
    for (String txId in txHashList) {
      AggregateTransaction aggTx = (await txHttp.getConfirmedTx(txId)) as AggregateTransaction;
      for (Transaction tx in aggTx.innerTransaction) {
        TransferTransaction trnTx = tx as TransferTransaction;
        txMsgList.add(trnTx.message!);
      }
    }

    return txMsgList;
  }

  /// # アグリゲートトランザクション内トランザクションリスト取得
  Future<Map<int, List<TransferTransaction>>> _getInnerTx(
      String hostPort, List<String> txHashList) async {
    Map<int, List<TransferTransaction>> txMapList = {};

    TransactionHttp txHttp = TransactionHttp(hostPort);
    for (String txId in txHashList) {
      AggregateTransaction aggTx = (await txHttp.getConfirmedTx(txId)) as AggregateTransaction;
      aggTx.innerTransaction
          .sort(((a, b) => a.transactionInfo!.index.compareTo(b.transactionInfo!.index)));
      // 1番目のJson解析
      String jsonString = (aggTx.innerTransaction[0] as TransferTransaction).message!;
      jsonString = jsonString.substring(1); // 1文字目のヌル文字削除
      Map<String, dynamic> jsonData = _convertJson(jsonString);
      int index = jsonData['index'];
      List<TransferTransaction> txList = [];
      for (Transaction tx in aggTx.innerTransaction) {
        TransferTransaction trnTx = tx as TransferTransaction;
        txList.add(trnTx);
      }
      txMapList[index] = txList;
    }

    return txMapList;
  }

  /// # String-JsonClass変換
  dynamic _convertJson(String jsonString) {
    dynamic jsonData = convert.jsonDecode(jsonString);
    return jsonData;
  }
}
