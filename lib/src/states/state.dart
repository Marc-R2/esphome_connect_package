part of '../../esphome_connect.dart';

abstract class State extends EspHomeElement {
  const State({
    required super.id,
    required super.name,
    required this.state,
  });

  final String state;

  @override
  Map<String, String> asMap() => {'state': state}..addAll(super.asMap());
}
