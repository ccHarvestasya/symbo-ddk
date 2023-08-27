import 'transaction_info.dart';

class AggregateTransactionInfo extends TransactionInfo {
  final String aggregateHash;
  final String aggregateId;

  AggregateTransactionInfo({
    required super.height,
    super.hash,
    super.merkleComponentHash,
    required super.index,
    required super.timestamp,
    required super.feeMultiplier,
    required this.aggregateHash,
    required this.aggregateId,
  });
}
