# ESPHome Connect

A Dart package for connecting to an ESPHome device and listening to events.

**Note: This package is not officially affiliated with ESPHome.**

## Installation

Add `esphome_connect` as a dependency in your `pubspec.yaml` file 
(for now, you have to use the git version of the package):

```yaml
dependencies:
  esphome_connect:
    git:
      url: https://github.com/Marc-R2/esphome_connect_package.git
```

## Usage

```dart
import 'package:esphome_connect/esphome_connect.dart';

void main() {
  final espHomeController = EspHomeController(
    url: '<ESP32_ADDRESS>', // required
    username: '<username>', // optional
    password: '<password>', // optional
  );

  espHomeController.initStream();
}
```

The `EspHomeController` class handles the connection to an ESPHome device and listens to events. The `url` parameter is required and should be set to the URL of the event stream of the ESPHome device. The `username` and `password` parameters are optional and should be set if a username and password are required to connect to the ESPHome device.

The `initStream` method initializes the event stream and returns a `StreamSubscription` object that can be used to listen to events. When an event is received, the `_eventHandler` method is called with the event as a string. If an error occurs while receiving events, the `_errorHandler` method is called with the error as a parameter. When the event stream is closed, the `_doneHandler` method is called.

## License

This project is licensed under the 3-Clause BSD License. See the [LICENSE](LICENSE.md) file for details.