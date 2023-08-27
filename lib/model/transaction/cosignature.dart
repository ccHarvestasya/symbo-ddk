class Cosignature {
  final String version;
  final String signerPublicKey;
  final String signature;

  Cosignature({
    required this.version,
    required this.signerPublicKey,
    required this.signature,
  });
}
