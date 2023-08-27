import 'statistics_service_api_status_finalization.dart';
import 'statistics_service_api_status_node_status.dart';
import 'statistics_service_api_status_web_socket.dart';

class ApiStatus {
  final String restGatewayUrl;
  final bool isAvailable;
  final bool? isHttpsEnabled;
  final int lastStatusCheck;
  final String? nodePublicKey;
  final int? chainHeight;
  final int? unlockedAccountCount;
  final bool? isAvailableNetworkProperties;
  final String? restVersion;
  final ApiStatusWebSocket? webSocket;
  final ApiStatusFinalization? finalization;
  final ApiStatusNodeStatus? nodeStatus;

  ApiStatus({
    required this.restGatewayUrl,
    required this.isAvailable,
    this.isHttpsEnabled,
    required this.lastStatusCheck,
    this.nodePublicKey,
    this.chainHeight,
    this.unlockedAccountCount,
    this.isAvailableNetworkProperties,
    this.restVersion,
    this.webSocket,
    this.finalization,
    this.nodeStatus,
  });
}
