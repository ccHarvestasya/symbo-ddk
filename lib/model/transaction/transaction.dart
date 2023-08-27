import 'transaction_info.dart';

class Transaction {
  final int? size;
  final String? signature;
  final String signerPublicKey;
  final int version;
  final int network;
  final int type;
  final String? maxFee;
  final String? deadline;
  final String? transactionsHash;
  final TransactionInfo? transactionInfo;

  Transaction({
    required this.signerPublicKey,
    required this.version,
    required this.network,
    required this.type,
    this.size,
    this.signature,
    this.maxFee,
    this.deadline,
    this.transactionsHash,
    this.transactionInfo,
  });
}
