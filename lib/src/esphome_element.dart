part of '../esphome_connect.dart';

abstract class EspHomeElement {
  const EspHomeElement({
    required this.id,
    required this.name,
  });

  final String id;

  final String name;

  Map<String, String> asMap() => <String, String>{'id': id, 'name': name};

  @override
  String toString() {
    final data = asMap();
    final entries = data.entries.map((e) => '${e.key}: ${e.value}');
    return 'Element(${entries.join(', ')})';
  }

  EspHomeElement copyWith(Map<String, dynamic> json);
}
