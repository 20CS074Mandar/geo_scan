class ScanData {
  final int? id;
  final int checkpoint_id;
  final String timestamp;
  final String data;

  ScanData({
    this.id,
    required this.checkpoint_id,
    required this.timestamp,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'checkpoint_id': checkpoint_id,
      'timestamp': timestamp,
      'data': data,
    };
  }

  factory ScanData.fromMap(Map<String, dynamic> map) {
    return ScanData(
      id: map['id'],
      checkpoint_id: map['checkpoint_id'],
      timestamp: map['timestamp'],
      data: map['data'],
    );
  }
}
