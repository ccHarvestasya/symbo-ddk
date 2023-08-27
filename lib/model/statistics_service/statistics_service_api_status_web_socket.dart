class ApiStatusWebSocket {
  final bool isAvailable;
  final bool wss;
  final String? url;

  ApiStatusWebSocket({
    required this.isAvailable,
    required this.wss,
    this.url,
  });
}
