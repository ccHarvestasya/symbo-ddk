import 'package:big_decimal/big_decimal.dart';

class Chain {
  final bool enableVerifiableState;
  final bool enableVerifiableReceipts;
  final String currencyMosaicId;
  final int currencyMosaicDivisibility;
  final String currencyMosaicTokenName;
  final String harvestingMosaicId;
  final String blockGenerationTargetTime;
  final int blockTimeSmoothingFactor;
  final int importanceGrouping;
  final int importanceActivityPercentage;
  final int maxRollbackBlocks;
  final int maxDifficultyBlocks;
  final int defaultDynamicFeeMultiplier;
  final String maxTransactionLifetime;
  final String maxBlockFutureTime;
  final BigDecimal initialCurrencyAtomicUnits;
  final BigDecimal maxMosaicAtomicUnits;
  final BigDecimal totalChainImportance;
  final BigDecimal minHarvesterBalance;
  final BigDecimal maxHarvesterBalance;
  final BigDecimal minVoterBalance;
  final int votingSetGrouping;
  final int maxVotingKeysPerAccount;
  final int minVotingKeyLifetime;
  final int maxVotingKeyLifetime;
  final int harvestBeneficiaryPercentage;
  final int harvestNetworkPercentage;
  final String harvestNetworkFeeSinkAddress;
  final int maxTransactionsPerBlock;

  Chain({
    required this.enableVerifiableState,
    required this.enableVerifiableReceipts,
    required this.currencyMosaicId,
    required this.currencyMosaicDivisibility,
    required this.currencyMosaicTokenName,
    required this.harvestingMosaicId,
    required this.blockGenerationTargetTime,
    required this.blockTimeSmoothingFactor,
    required this.importanceGrouping,
    required this.importanceActivityPercentage,
    required this.maxRollbackBlocks,
    required this.maxDifficultyBlocks,
    required this.defaultDynamicFeeMultiplier,
    required this.maxTransactionLifetime,
    required this.maxBlockFutureTime,
    required this.initialCurrencyAtomicUnits,
    required this.maxMosaicAtomicUnits,
    required this.totalChainImportance,
    required this.minHarvesterBalance,
    required this.maxHarvesterBalance,
    required this.minVoterBalance,
    required this.votingSetGrouping,
    required this.maxVotingKeysPerAccount,
    required this.minVotingKeyLifetime,
    required this.maxVotingKeyLifetime,
    required this.harvestBeneficiaryPercentage,
    required this.harvestNetworkPercentage,
    required this.harvestNetworkFeeSinkAddress,
    required this.maxTransactionsPerBlock,
  });
}
