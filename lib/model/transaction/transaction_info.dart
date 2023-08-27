class TransactionInfo {
  final String height;
  final String? hash;
  final String? merkleComponentHash;
  final int index;
  final String timestamp;
  final int feeMultiplier;

  TransactionInfo({
    required this.height,
    this.hash,
    this.merkleComponentHash,
    required this.index,
    required this.timestamp,
    required this.feeMultiplier,
  });
}
