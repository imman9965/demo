class Stat{
  final int id;
  final String name;
  final int countryId;

  Stat({
    required this.id,
    required this.name,
    required this.countryId,
  });

  factory Stat.fromJson(Map<String, dynamic> json) {
    return Stat(
      id: json['id'],
      name: json['name'],
      countryId: json['country_id'],
    );
  }
}