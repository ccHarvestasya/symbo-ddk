import 'chain.dart';
import 'network.dart';
import 'plugins.dart';

class NetworkProperties {
  final Network network;
  final Chain chain;
  final Plugins plugins;

  NetworkProperties({
    required this.network,
    required this.chain,
    required this.plugins,
  });
}
