part of '../../esphome_connect.dart';

class SwitchState extends EspState {
  const SwitchState({
    required super.id,
    required super.name,
    required super.state,
    required this.value,
  });

  factory SwitchState.fromJson(Map<String, dynamic> json) {
    return SwitchState(
      id: json['id'] as String,
      name: json['name'] as String,
      state: json['state'] as String,
      value: json['value'] as bool,
    );
  }

  static const type = 'switch';

  final bool value;

  @override
  Map<String, String> asMap() => {'value': '$value'}..addAll(super.asMap());

  @override
  SwitchState copyWith(Map<String, dynamic> json) {
    return SwitchState(
      id: id,
      name: json['name'] as String? ?? name,
      state: json['state'] as String? ?? state,
      value: json['value'] as bool? ?? value,
    );
  }
}
