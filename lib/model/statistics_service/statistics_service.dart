import 'statistics_service_api_status.dart';
import 'statistics_service_host_detail.dart';
import 'statistics_service_peer_status.dart';

class StatisticsService {
  final int version;
  final String publicKey;
  final String networkGenerationHashSeed;
  final int roles;
  final int port;
  final int networkIdentifier;
  final String host;
  final String friendlyName;
  final DateTime lastAvailable;
  final DateTime? certificateExpiration;
  final HostDetail? hostDetail;
  final PeerStatus? peerStatus;
  final ApiStatus? apiStatus;

  StatisticsService({
    required this.version,
    required this.publicKey,
    required this.networkGenerationHashSeed,
    required this.roles,
    required this.port,
    required this.networkIdentifier,
    required this.host,
    required this.friendlyName,
    required this.lastAvailable,
    this.certificateExpiration,
    this.hostDetail,
    this.peerStatus,
    this.apiStatus,
  });
}
