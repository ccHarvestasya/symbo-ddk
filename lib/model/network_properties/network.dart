class Network {
  final String identifier;
  final String nemesisSignerPublicKey;
  final String nodeEqualityStrategy;
  final String generationHashSeed;
  final String epochAdjustment;
  final int epochAdjustmentMilliSec;
  final DateTime epochAdjustmentDt;

  Network({
    required this.identifier,
    required this.nemesisSignerPublicKey,
    required this.nodeEqualityStrategy,
    required this.generationHashSeed,
    required this.epochAdjustment,
    required this.epochAdjustmentMilliSec,
    required this.epochAdjustmentDt,
  });
}
