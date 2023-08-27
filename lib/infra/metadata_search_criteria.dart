class MetadataSearchCriteria {
  String? sourceAddress;
  String? targetAddress;
  String? scopedMetadataKey;
  String? targetId;
  int? metadataType;
  int? pageSize;
  int? pageNumber;
  String? offset;
  String? order;

  MetadataSearchCriteria({
    this.sourceAddress,
    this.targetAddress,
    this.scopedMetadataKey,
    this.targetId,
    this.metadataType,
    this.pageSize,
    this.pageNumber,
    this.offset,
    this.order,
  }) {
    pageSize ??= 20;
    pageNumber ??= 1;
  }
}
