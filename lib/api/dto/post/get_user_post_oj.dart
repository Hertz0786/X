class GetUserPort {
  final String id;

  GetUserPort({required this.id});

  factory GetUserPort.fromJson(Map<String, dynamic> json) {
    return GetUserPort(
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
