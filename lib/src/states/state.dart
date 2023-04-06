part of '../../esphome_connect.dart';

abstract class State {
  const State({
    required this.id,
    required this.name,
    required this.state,
  });

  final String id;

  final String name;

  final String state;

  /// Create a [State] from a JSON map.
  ///
  /// The type of the state is determined by the `id` property automatically.
  ///
  /// If the type is unknown or not supported, `null` is returned.
  static State? createFromMap(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final type = id.split('-')[0];

    switch (type) {
      case 'number':
        return NumberState.fromJson(json);
      default:
        print('Unknown state type: $type');
        return null;
    }
  }

  @override
  String toString() => 'State{id: $id, name: $name, state: $state}';
}
