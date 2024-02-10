class Checkpoint {
  final int? id;
  final String checkpoint_name;
  double latitude;
  final double longitude;

  Checkpoint({
    this.id,
    required this.checkpoint_name,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'checkpoint_name': checkpoint_name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Checkpoint.fromMap(Map<String, dynamic> map) {
    return Checkpoint(
      id: map['id'],
      checkpoint_name: map['checkpoint_name'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }
}
