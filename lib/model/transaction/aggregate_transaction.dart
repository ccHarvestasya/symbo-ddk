import 'cosignature.dart';
import 'transaction.dart';

class AggregateTransaction extends Transaction {
  final List<Cosignature> cosignatures;
  final List<Transaction> innerTransaction;

  AggregateTransaction({
    required super.signerPublicKey,
    required super.version,
    required super.network,
    required super.type,
    super.size,
    super.signature,
    super.maxFee,
    super.deadline,
    super.transactionsHash,
    super.transactionInfo,
    required this.cosignatures,
    required this.innerTransaction,
  });
}
