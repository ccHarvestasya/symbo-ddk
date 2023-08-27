import 'comsa_nft_info_detail.dart';

class ComsaNftInfo {
  final String reserved;
  final String version;
  final List<String> thumbnailAggregateTransactionHash;
  final String description;
  final String endorser;
  final int transactionNumber;
  final ComsaNftInfoDetail? comsaNftInfoDetail;
  final List<String> aggregateTransactionHashes;

  ComsaNftInfo({
    required this.reserved,
    required this.version,
    required this.thumbnailAggregateTransactionHash,
    required this.description,
    required this.endorser,
    required this.transactionNumber,
    required this.comsaNftInfoDetail,
    required this.aggregateTransactionHashes,
  });
}
