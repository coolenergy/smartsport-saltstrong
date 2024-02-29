
import 'dart:convert';

class SavedLayer {
  final String name;
  final double opacity;
  final int? selectedOptionIndex;

  const SavedLayer({
    required this.name,
    required this.opacity,
    this.selectedOptionIndex,
  });

  factory SavedLayer.fromJson(String str) => SavedLayer.fromMap(
    json.decode(str),
  );

  String toJson() => json.encode(_toMap());

  factory SavedLayer.fromMap(Map<String, dynamic> json) => SavedLayer(
    name: json["name"],
    opacity: json["opacity"],
    selectedOptionIndex: json["selectedOptionIndex"],
  );

  Map<String, dynamic> _toMap() => {
    "name": name,
    "opacity": opacity,
    if (selectedOptionIndex != null) "selectedOptionIndex": selectedOptionIndex!,
  };
}
