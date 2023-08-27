import 'dart:collection';

import 'package:big_decimal/big_decimal.dart';

import '../model/statistics_service/statistics_service.dart';
import '../model/statistics_service/statistics_service_api_status.dart';
import '../model/statistics_service/statistics_service_api_status_finalization.dart';
import '../model/statistics_service/statistics_service_api_status_node_status.dart';
import '../model/statistics_service/statistics_service_api_status_web_socket.dart';
import '../model/statistics_service/statistics_service_host_detail.dart';
import '../model/statistics_service/statistics_service_host_detail_coordinates.dart';
import '../model/statistics_service/statistics_service_peer_status.dart';
import '../symbol_ddk_prop.dart';
import 'https.dart';
import 'network_properties_http.dart';

/// # StatisticsServiceを管理するクラス
class StatisticsServiceHttp {
  /// インスタンス
  static final StatisticsServiceHttp _instance = StatisticsServiceHttp._internal();

  /// 全ノード一覧
  List<StatisticsService> _allStatisticsServiceList = [];

  /// 利用可能ノードリスト
  List<String> _availableNodeList = [];

  /// パブリックコンストラクタ
  factory StatisticsServiceHttp() {
    return _instance;
  }

  /// プライベートコンストラクタ
  StatisticsServiceHttp._internal();

  /// # 初期処理
  /// *必ず実行すること*
  Future<void> init({force = false}) async {
    /** 全ノード取得 **/
    // SSから取得
    List<dynamic> allNodesJsonList = await _getAllNodesJson();
    // クラスに変換
    _allStatisticsServiceList = [];
    for (Map<String, dynamic> nodeJson in allNodesJsonList) {
      StatisticsService ss = _createStatisticsService(nodeJson);
      _allStatisticsServiceList.add(ss);
    }

    /** アクセス用SSLノード取得 **/
    /* 最大ブロック取得 */
    dynamic nodesHeightStatsJson = await _getNodesHeightStatsJson();
    List<dynamic> nodesHeightJsonList = nodesHeightStatsJson['height'];
    String maxHeightStr = nodesHeightJsonList[nodesHeightJsonList.length - 1]['value'];
    int? maxHeight = int.tryParse(maxHeightStr);
    maxHeight ??= 0;
    /* ノード取得 */
    // 正常なノードを取得
    List<StatisticsService> ssSslList = [];
    List<dynamic> sslNodeJsonList = await _getSslNodeJson();
    for (Map<String, dynamic> sslNodeJson in sslNodeJsonList) {
      StatisticsService ss = _createStatisticsService(sslNodeJson);
      if (ss.apiStatus!.webSocket!.isAvailable == true &&
          (maxHeight - 60) <= ss.apiStatus!.chainHeight!) {
        // WebSocketが活きている かつ ブロック高が最大値-60以上
        ssSslList.add(ss);
      }
    }
    // ホストリスト作成
    List<String> hostList = [];
    for (StatisticsService ss in ssSslList) {
      hostList.add(ss.apiStatus!.restGatewayUrl.replaceAll('https://', ''));
    }
    // 正常なノードを応答速度順に取得
    _availableNodeList = await checkNetworkPropertiesAvailable(hostList);
    // 上位5つ残し削除
    if (_availableNodeList.isEmpty) {
      throw Exception('正常なSSLノードが存在しません');
    } else if (5 < _availableNodeList.length) {
      _availableNodeList.removeRange(5, _availableNodeList.length);
    }
  }

  /// Restゲートウェイリスト取得
  List<String> getRestGatewayHostList() {
    if (_availableNodeList.isEmpty) {
      throw Exception('StatisticsServiceクラスが初期化されていません');
    }
    _availableNodeList.shuffle();
    return _availableNodeList;
  }

  /// Restゲートウェイ取得
  String getRestGatewayHost() {
    if (_availableNodeList.isEmpty) {
      throw Exception('StatisticsServiceクラスが初期化されていません');
    }
    return getRestGatewayHostList()[0];
  }

  /// TODO ノードアカウントは publicKey を検索
  /// TODO 委任アカウントは apiStatus.nodePublicKey を検索

  StatisticsService _createStatisticsService(Map<String, dynamic> nodeJson) {
    /** Peer Status **/
    PeerStatus? peerStatus;
    if (nodeJson['peerStatus'] != null) {
      peerStatus = PeerStatus(
        isAvailable: nodeJson['peerStatus']['isAvailable'],
        lastStatusCheck: nodeJson['peerStatus']['lastStatusCheck'],
      );
    }
    /** Api Status **/
    ApiStatus? apiStatus;
    if (nodeJson['apiStatus'] != null) {
      ApiStatusWebSocket? apiStatusWebSocket;
      if (nodeJson['apiStatus']['webSocket'] != null) {
        apiStatusWebSocket = ApiStatusWebSocket(
          isAvailable: nodeJson['apiStatus']['webSocket']['isAvailable'],
          wss: nodeJson['apiStatus']['webSocket']['wss'],
          url: nodeJson['apiStatus']['webSocket']['url'],
        );
      }
      ApiStatusFinalization? apiStatusFinalization;
      if (nodeJson['apiStatus']['finalization'] != null) {
        apiStatusFinalization = ApiStatusFinalization(
          height: nodeJson['apiStatus']['finalization']['height'],
          epoch: nodeJson['apiStatus']['finalization']['epoch'],
          point: nodeJson['apiStatus']['finalization']['point'],
          hash: nodeJson['apiStatus']['finalization']['hash'],
        );
      }
      ApiStatusNodeStatus? apiStatusNodeStatus;
      if (nodeJson['apiStatus']['nodeStatus'] != null) {
        apiStatusNodeStatus = ApiStatusNodeStatus(
          apiNode: nodeJson['apiStatus']['nodeStatus']['apiNode'],
          db: nodeJson['apiStatus']['nodeStatus']['db'],
        );
      }
      apiStatus = ApiStatus(
        restGatewayUrl: nodeJson['apiStatus']['restGatewayUrl'],
        isAvailable: nodeJson['apiStatus']['isAvailable'],
        isHttpsEnabled: nodeJson['apiStatus']['isHttpsEnabled'],
        lastStatusCheck: nodeJson['apiStatus']['lastStatusCheck'],
        nodePublicKey: nodeJson['apiStatus']['nodePublicKey'],
        chainHeight: nodeJson['apiStatus']['chainHeight'],
        unlockedAccountCount: nodeJson['apiStatus']['unlockedAccountCount'],
        isAvailableNetworkProperties: nodeJson['apiStatus']['isAvailableNetworkProperties'],
        restVersion: nodeJson['apiStatus']['restVersion'],
        webSocket: apiStatusWebSocket,
        finalization: apiStatusFinalization,
        nodeStatus: apiStatusNodeStatus,
      );
    }
    /** Host Detail **/
    HostDetail? hostDetail;
    if (nodeJson.containsKey('hostDetail')) {
      HostDetailCoordinates? hostDetailCoordinates;
      if (nodeJson['hostDetail']['coordinates'] != null) {
        hostDetailCoordinates = HostDetailCoordinates(
          latitude: BigDecimal.parse(nodeJson['hostDetail']['coordinates']['latitude'].toString()),
          longitude:
              BigDecimal.parse(nodeJson['hostDetail']['coordinates']['longitude'].toString()),
        );
      }
      hostDetail = HostDetail(
        host: nodeJson['hostDetail']['host'],
        location: nodeJson['hostDetail']['location'],
        ip: nodeJson['hostDetail']['ip'],
        organization: nodeJson['hostDetail']['organization'],
        as: nodeJson['hostDetail']['as'],
        continent: nodeJson['hostDetail']['continent'],
        country: nodeJson['hostDetail']['country'],
        region: nodeJson['hostDetail']['region'],
        city: nodeJson['hostDetail']['city'],
        district: nodeJson['hostDetail']['district'],
        zip: nodeJson['hostDetail']['zip'],
        coordinates: hostDetailCoordinates,
      );
    }
    // StatisticsService生成
    return StatisticsService(
      version: nodeJson['version'],
      publicKey: nodeJson['publicKey'],
      networkGenerationHashSeed: nodeJson['networkGenerationHashSeed'],
      roles: nodeJson['roles'],
      port: nodeJson['port'],
      networkIdentifier: nodeJson['networkIdentifier'],
      host: nodeJson['host'],
      friendlyName: nodeJson['friendlyName'],
      lastAvailable: DateTime.parse(nodeJson['lastAvailable']),
      peerStatus: peerStatus,
      apiStatus: apiStatus,
      hostDetail: hostDetail,
    );
  }

  /// # ネットワークプロパティ死活チェック
  /// ホストリスト[hostList]をチャンクに分割し順にチェックする
  /// hostはプロトコル不要、ポート番号付
  Future<List<String>> checkNetworkPropertiesAvailable(List<String> hostList) async {
    // ホストリストをチャンクに分割
    int count = 0;
    int chunkSize = 3;
    List<List<String>> chunkedHostList = [];
    do {
      chunkedHostList.add(hostList.skip(count).take(chunkSize).toList());
      count += chunkSize;
    } while (count < hostList.length);
    // 並列アクセス
    List<Future<Map<String, int>>> futureList = [];
    for (List<String> hosts in chunkedHostList) {
      futureList.add(checkNetworkPropertiesAvailableSync(hosts));
    }
    // 完了待機
    List<Map<String, int>> futureResultList = await Future.wait(futureList);
    // 結果を連結
    Map<String, int> availableNodeMap = {};
    for (Map<String, int> futureResult in futureResultList) {
      availableNodeMap.addAll(futureResult);
    }
    // マップ値でソート
    SplayTreeMap.from(
        availableNodeMap, (a, b) => availableNodeMap[a]!.compareTo(availableNodeMap[b]!));
    // マップキーをリストに変換
    List<String> availableNodeList = [];
    availableNodeMap.forEach((k, v) => availableNodeList.add(k));

    return availableNodeList;
  }

  /// # ネットワークプロパティ死活チェック(同期)
  /// ホストリスト[hostList]を順にチェックする
  /// hostはプロトコル不要、ポート番号付
  Future<Map<String, int>> checkNetworkPropertiesAvailableSync(List<String> hostList) async {
    Map<String, int> availableNodeMap = {};

    Stopwatch sw = Stopwatch();
    NetworkPropertiesHttp nwHttp = NetworkPropertiesHttp();

    for (String host in hostList) {
      // ストップウォッチ開始
      sw.start();
      // ネットワークプロパティ死活チェック
      bool res = await nwHttp.isNetworkPropertiesAvailable(host);
      if (res) {
        // 活きていた場合キーにホスト、値に応答時間をセット
        availableNodeMap[host] = sw.elapsedMilliseconds;
        // _logger.d('$host: ${availableNodeMap[host]}');
      }
      // ストップウォッチ停止
      sw.stop();
      // ストップウォッチリセット
      sw.reset();
    }

    return availableNodeMap;
  }

  /// # ノードJson取得
  /// /nodes から以下の条件でノード一覧Jsonを取得する
  /// * 件数: SymbolRestProp.statisticsServiceNodesLimit の値
  /// * ソート: ランダム
  /// * SSL: True
  Future<List<dynamic>> _getSslNodeJson() async {
    // Httpsクラス生成
    Https https = Https(
      url: SymbolDDKProp.statisticsServiceHost,
      path: '${SymbolDDKProp.statisticsServicePath}/nodes',
    );
    // パラメータ作成
    Map<String, dynamic> params = {
      'limit': SymbolDDKProp.statisticsServiceNodesLimit.toString(),
      'order': 'random',
      'ssl': 'true',
    };
    // 取得
    return await https.get(params: params);
  }

  /// # ノードJson取得
  /// /nodes から全ノード一覧Jsonを取得する
  Future<List<dynamic>> _getAllNodesJson() async {
    // Httpsクラス生成
    Https https = Https(
      url: SymbolDDKProp.statisticsServiceHost,
      path: '${SymbolDDKProp.statisticsServicePath}/nodes',
    );
    // 取得
    return await https.get();
  }

  /// # ブロック高Json取得
  /// /nodesHeightStats からブロック高Jsonを取得する
  Future<dynamic> _getNodesHeightStatsJson() async {
    // Httpsクラス生成
    Https https = Https(
      url: SymbolDDKProp.statisticsServiceHost,
      path: '${SymbolDDKProp.statisticsServicePath}/nodesHeightStats',
    );
    // 取得
    return await https.get();
  }
}
