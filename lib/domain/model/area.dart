class Area {
  final String code;
  final String name;
  final int id;

  const Area({
    required this.code,
    required this.name,
    required this.id,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Area &&
        other.code == code &&
        other.name == name &&
        other.id == id;
  }

  @override
  int get hashCode => code.hashCode ^ name.hashCode ^ id.hashCode;
}
