import 'statistics_service_host_detail_coordinates.dart';

class HostDetail {
  final String host;
  final String location;
  final String ip;
  final String organization;
  final String as;
  final String continent;
  final String country;
  final String region;
  final String city;
  final String district;
  final String zip;
  final HostDetailCoordinates? coordinates;

  HostDetail({
    required this.host,
    required this.location,
    required this.ip,
    required this.organization,
    required this.as,
    required this.continent,
    required this.country,
    required this.region,
    required this.city,
    required this.district,
    required this.zip,
    required this.coordinates,
  });
}
