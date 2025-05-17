class DevicePingResult {
  final String ip;
  final String name;
  final double ms;
  final bool online;
  
  DevicePingResult({
    required this.ip,
    required this.name,
    required this.ms,
    required this.online,
  });

  factory DevicePingResult.fromJson(Map<String, dynamic> json) {
    return DevicePingResult(
      ip: json['ip'] as String,
      name: json['name'] as String,
      ms: (json['ms'] as num).toDouble(),
      online: json['online'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
    'ip': ip,
    'name': name,
    'ms': ms,
    'online': online,
  };
}
