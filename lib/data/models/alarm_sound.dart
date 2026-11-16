class AlarmSound {
  const AlarmSound({
    required this.id,
    required this.name,
    this.isCustom = false,
    this.customPath,
  });

  final String id;
  final String name;
  final bool isCustom;
  final String? customPath;
}
