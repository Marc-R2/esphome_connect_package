part of '../../esphome_connect.dart';

class NumberState extends State {
  const NumberState({
    required super.id,
    required super.name,
    required super.state,
    required this.value,
    required this.min_value,
    required this.max_value,
    required this.step,
    required this.mode,
  });

  factory NumberState.fromJson(Map<String, dynamic> json) {
    return NumberState(
      id: json['id'] as String,
      name: json['name'] as String,
      state: json['state'] as String,
      value: json['value'] as num,
      min_value: json['min_value'] as num,
      max_value: json['max_value'] as num,
      step: json['step'] as num,
      mode: json['mode'] as int,
    );
  }

  final num value;

  final num min_value;

  final num max_value;

  final num step;

  final int mode;
}
