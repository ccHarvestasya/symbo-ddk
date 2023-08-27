class TransactionType {
  /// 予約
  static const int reserved = 0;

  /// 転送トランザクション
  static const int transfer = 16724;

  static const int namespaceRegistration = 16718;
  static const int addressAlias = 16974;
  static const int mosaicAlias = 17230;
  static const int mosaicDefinition = 16717;
  static const int mosaicSupplyChange = 16973;
  static const int mosaicSupplyRevocation = 17229;
  static const int multisigAccountModification = 16725;

  /// アグリゲートトランザクション
  static const int aggregateComplete = 16705;
  static const int aggregateBonded = 16961;
  static const int hashLock = 16712;
  static const int secretLock = 16722;
  static const int secretProof = 16978;
  static const int accountAddressRestriction = 16720;
  static const int accountMosaicRestriction = 16976;
  static const int accountOperationRestriction = 17232;
  static const int accountKeyLink = 16716;
  static const int mosaicAddressRestriction = 16977;
  static const int mosaicGlobalRestriction = 16721;
  static const int accountMetadata = 16708;
  static const int mosaicMetadata = 16964;
  static const int namespaceMetadata = 17220;
  static const int vrfKeyLink = 16963;
  static const int votingKeyLink = 16707;
  static const int nodeKeyLink = 16972;
}
