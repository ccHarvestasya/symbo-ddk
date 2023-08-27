import 'dart:developer';
import 'dart:io';

import '../model/network_properties/network_properties.dart';
import 'https.dart';

/// 【シングルトン】ネットワークプロパティを管理するクラス
class NetworkPropertiesHttp {
  /// インスタンス
  static final NetworkPropertiesHttp _instance = NetworkPropertiesHttp._internal();

  /// ネットワークプロパティ
  late NetworkProperties _networkProperties;

  /// コンストラクタ
  factory NetworkPropertiesHttp() {
    return _instance;
  }

  /// コンストラクタ(プライベート)
  NetworkPropertiesHttp._internal();

  /// # 初期処理
  void init(String hostPort) async {
    // // NetworkPropertiesRest取得
    // dynamic networkPropertiesJson = await _getNetworkPropertiesJson(hostPort);
    // // クラスに詰め込み
    // await _createNetworkProperties(networkPropertiesJson);
  }

  // /// # 日時変換
  // DateTime convertTimestamp(int networkTimestamp) {
  //   int timestamp = _networkProperties.network.epochAdjustmentMilliSec + networkTimestamp;
  //   return DateTime.fromMillisecondsSinceEpoch(timestamp);
  // }
  //
  // /// # NetworkPropertiesクラス生成
  // /// [jsonData]からNetworkPropertiesクラス作成
  // Future<void> _createNetworkProperties(dynamic jsonData) async {
  //   /** ネットワーク **/
  //   dynamic networkJson = jsonData['network'];
  //   /* epochAdjustmentミリ秒変換 */
  //   // 最後のsを外す
  //   String strEpochAdjustment = networkJson['epochAdjustment'].replaceAll('s', '');
  //   // 数値変換
  //   int epochAdjustment = int.parse(strEpochAdjustment);
  //   int epochAdjustmentMilliSec = epochAdjustment * 1000;
  //   /* ネットワーク生成 */
  //   Network network = Network(
  //     identifier: networkJson['identifier'],
  //     nemesisSignerPublicKey: networkJson['nemesisSignerPublicKey'],
  //     nodeEqualityStrategy: networkJson['nodeEqualityStrategy'],
  //     generationHashSeed: networkJson['generationHashSeed'],
  //     epochAdjustment: networkJson['epochAdjustment'],
  //     epochAdjustmentMilliSec: epochAdjustmentMilliSec,
  //     epochAdjustmentDt: DateTime.fromMillisecondsSinceEpoch(epochAdjustmentMilliSec),
  //   );
  //
  //   /** チェーン **/
  //   dynamic chainJson = jsonData['chain'];
  //   /* カレントモザイクID */
  //   String currencyMosaicId =
  //       chainJson['currencyMosaicId'].replaceAll('\'', '').replaceAll('0x', '');
  //   /* カレントモザイク可分性 */
  //   MosaicsRepo mosaicsRepo = MosaicsRepo();
  //   Mosaic mosaic = await mosaicsRepo.getMosaic(currencyMosaicId);
  //   int currencyMosaicDivisibility = mosaic.divisibility;
  //   /* カレントモザイクトークン名 */
  //   NamespaceRepo namespaceRepo = NamespaceRepo();
  //   List<MosaicName> mosaicName = await namespaceRepo.getMosaicName(currencyMosaicId);
  //   String currencyMosaicTokenName = mosaicName[0].names[0].split('.')[1];
  //   currencyMosaicTokenName = currencyMosaicTokenName.toUpperCase();
  //   /* ハーベストモザイクID */
  //   String harvestingMosaicId =
  //       chainJson['harvestingMosaicId'].replaceAll('\'', '').replaceAll('0x', '');
  //   /* チェーン生成 */
  //   Chain chain = Chain(
  //     enableVerifiableState: chainJson['enableVerifiableState'],
  //     enableVerifiableReceipts: chainJson['enableVerifiableReceipts'],
  //     currencyMosaicId: currencyMosaicId,
  //     currencyMosaicDivisibility: currencyMosaicDivisibility,
  //     currencyMosaicTokenName: currencyMosaicTokenName,
  //     harvestingMosaicId: harvestingMosaicId,
  //     blockGenerationTargetTime: chainJson['blockGenerationTargetTime'],
  //     blockTimeSmoothingFactor: int.parse(chainJson['blockTimeSmoothingFactor']),
  //     importanceGrouping: int.parse(chainJson['importanceGrouping']),
  //     importanceActivityPercentage: int.parse(chainJson['importanceActivityPercentage']),
  //     maxRollbackBlocks: int.parse(chainJson['maxRollbackBlocks']),
  //     maxDifficultyBlocks: int.parse(chainJson['maxDifficultyBlocks']),
  //     defaultDynamicFeeMultiplier: int.parse(chainJson['defaultDynamicFeeMultiplier']),
  //     maxTransactionLifetime: chainJson['maxTransactionLifetime'],
  //     maxBlockFutureTime: chainJson['maxBlockFutureTime'],
  //     initialCurrencyAtomicUnits:
  //         _convBigDecimal(chainJson['initialCurrencyAtomicUnits'], mosaic.divisibility),
  //     maxMosaicAtomicUnits: _convBigDecimal(chainJson['maxMosaicAtomicUnits'], mosaic.divisibility),
  //     totalChainImportance: _convBigDecimal(chainJson['totalChainImportance'], mosaic.divisibility),
  //     minHarvesterBalance: _convBigDecimal(chainJson['minHarvesterBalance'], mosaic.divisibility),
  //     maxHarvesterBalance: _convBigDecimal(chainJson['maxHarvesterBalance'], mosaic.divisibility),
  //     minVoterBalance: _convBigDecimal(chainJson['minVoterBalance'], mosaic.divisibility),
  //     votingSetGrouping: int.parse(chainJson['votingSetGrouping']),
  //     maxVotingKeysPerAccount: int.parse(chainJson['maxVotingKeysPerAccount']),
  //     minVotingKeyLifetime: int.parse(chainJson['minVotingKeyLifetime']),
  //     maxVotingKeyLifetime: int.parse(chainJson['maxVotingKeyLifetime']),
  //     harvestBeneficiaryPercentage: int.parse(chainJson['harvestBeneficiaryPercentage']),
  //     harvestNetworkPercentage: int.parse(chainJson['harvestNetworkPercentage']),
  //     harvestNetworkFeeSinkAddress: chainJson['harvestNetworkFeeSinkAddress'],
  //     maxTransactionsPerBlock: int.parse(chainJson['maxTransactionsPerBlock'].replaceAll('\'', '')),
  //   );
  //
  //   /** プラグイン **/
  //   // dynamic pluginsJson = jsonData['plugins'];
  //
  //   /** NetworkProperties **/
  //   _networkProperties = NetworkProperties(
  //     network: network,
  //     chain: chain,
  //     plugins: Plugins(),
  //   );
  // }

  /// # ネットワークプロパティ取得
  NetworkProperties get networkProperties => _networkProperties;

  // /// # String-BigDecimal変換
  // /// [value]値を-10の[divisibility]乗した値を返す
  // BigDecimal _convBigDecimal(String value, int divisibility) {
  //   BigDecimal valueBigDec = BigDecimal.parse(value.replaceAll('\'', ''));
  //   return valueBigDec.divide((BigDecimal.parse('10').pow(divisibility)));
  // }

  /// # ネットワークプロパティ死活
  /// ネットワークプロパティが取得出来るかチェック
  /// ホスト[host]はプロトコル不要、ポート番号付
  Future<bool> isNetworkPropertiesAvailable(String host) async {
    try {
      await _getNetworkPropertiesJson(host);
    } on HttpException catch (e) {
      log(e.message);
      return false;
    } on Exception catch (e) {
      log(e.toString());
      return false;
    }
    return true;
  }

  /// # ネットワークプロパティJson取得
  /// /network/propertiesからネットワークプロパティJsonを取得する
  dynamic _getNetworkPropertiesJson(String host) async {
    // Httpsクラス生成
    Https https = Https(
      url: host,
      path: '/network/properties',
    );
    await https.get();
  }
}
