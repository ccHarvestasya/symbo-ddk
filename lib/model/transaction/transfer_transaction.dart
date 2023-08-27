import 'mosaic.dart';
import 'transaction.dart';

class TransferTransaction extends Transaction {
  final String recipientAddress;
  final bool? isPlainMessage;
  final String? message;
  final List<Mosaic> mosaics;

  TransferTransaction({
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
    required this.recipientAddress,
    this.isPlainMessage,
    this.message,
    required this.mosaics,
  });
}
