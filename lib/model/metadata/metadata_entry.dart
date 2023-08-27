class MetadataEntry {
  final int version;
  final String compositeHash;
  final String sourceAddress;
  final String targetAddress;
  final String scopedMetadataKey;
  final String targetId;
  final int metadataType;
  final int valueSize;
  final String value;

  MetadataEntry({
    required this.version,
    required this.compositeHash,
    required this.sourceAddress,
    required this.targetAddress,
    required this.scopedMetadataKey,
    required this.targetId,
    required this.metadataType,
    required this.valueSize,
    required this.value,
  });
}
