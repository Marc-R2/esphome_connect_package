part of '../../esphome_connect.dart';

class ButtonState extends EspHomeElement {
  const ButtonState({
    required super.id,
    required super.name,
  });

  factory ButtonState.fromJson(Map<String, dynamic> json) {
    return ButtonState(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  static const type = 'button';

  @override
  Map<String, String> asMap() => super.asMap();

  @override
  ButtonState copyWith(Map<String, dynamic> json) {
    return ButtonState(
      id: id,
      name: json['name'] as String? ?? name,
    );
  }
}
