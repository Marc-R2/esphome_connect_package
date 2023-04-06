import 'package:esphome_connect/esphome_connect.dart';

void main() async {
  final esp = EspHomeController(
    url: 'http://192.168.178.93',
    username: 'admin',
    password: 'admin',
  );
}
