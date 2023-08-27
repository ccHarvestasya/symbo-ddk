class PeerStatus {
  final bool isAvailable;
  final int lastStatusCheck;

  PeerStatus({
    required this.isAvailable,
    required this.lastStatusCheck,
  });
}
