class PingResult {
  final String ip;
  final double ms;
  final bool success;
  final DateTime timestamp;

  PingResult({
    required this.ip,
    required this.ms,
    required this.success,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory PingResult.fromJson(Map<String, dynamic> json) {
    return PingResult(
      ip: json['ip'] as String,
      ms: (json['ms'] as num).toDouble(),
      success: json['success'] ?? (json['ms'] != null && (json['ms'] as num) > 0),
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'ip': ip,
        'ms': ms,
        'success': success,
        'timestamp': timestamp.toIso8601String(),
      };
}
