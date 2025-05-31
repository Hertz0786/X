class ReportRequestDto {
  final String reason;

  ReportRequestDto({required this.reason});

  Map<String, dynamic> toJson() => {
    'reason': reason,
  };
}
