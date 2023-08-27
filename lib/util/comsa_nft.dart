import 'dart:convert' as convert;
import 'dart:typed_data';

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
    String nftBase64 = await decoderBase64(mosaicId: mosaicId);
    // Base64デコード
    final base64Decoder = convert.base64.decoder;
    Uint8List nftData = base64Decoder.convert(nftBase64);
    return nftData;
  }

  /// # ComsaNFTデコーダ
  /// [mosaicId]に紐付いたNFTデータをデコードする
  Future<String> decoderBase64({required String mosaicId}) async {
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
          txMsgList.add(innerTxMsg);
        }
      }
    }
    // ソート
    txMsgList.sort(((a, b) => a.substring(0, 6).compareTo(b.substring(0, 6))));
    // リストを文字列に連結
    String nftBase64 = '';
    for (String txMsg in txMsgList) {
      nftBase64 += txMsg.substring(7);
    }

    return nftBase64;
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
      } else if (metadataEntry.scopedMetadataKey == ComsaMetadataType.description) {
        // NFTの説明文
        description = metadataEntry.value;
      } else if (metadataEntry.scopedMetadataKey == ComsaMetadataType.endorser) {
        // エンドーサ
        endorser = metadataEntry.value;
      } else if (metadataEntry.scopedMetadataKey == ComsaMetadataType.aggregateTxNumber) {
        // NFTデータのアグリゲートトランザクション数
        transactionNumber = int.parse(metadataEntry.value);
      } else if (metadataEntry.scopedMetadataKey == ComsaMetadataType.comsaNftInfoDetail) {
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
      } else if (metadataEntry.scopedMetadataKey == ComsaMetadataType.aggregateTxHash1 ||
          metadataEntry.scopedMetadataKey == ComsaMetadataType.aggregateTxHash2 ||
          metadataEntry.scopedMetadataKey == ComsaMetadataType.aggregateTxHash3) {
        // NFTデータのアグリゲートトランザクションハッシュ
        aggregateTransactionHashList = _convertJson(metadataEntry.value).cast<String>();
      } else {
        throw Exception('不明な Comsa NFT Metadata Key です');
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

  /// # String-JsonClass変換
  dynamic _convertJson(String jsonString) {
    dynamic jsonData = convert.jsonDecode(jsonString);
    return jsonData;
  }
}
