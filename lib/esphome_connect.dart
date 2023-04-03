import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// A class that handles the connection to an ESPHome device.
class EspHomeController {
  /// Creates a new instance of [EspHomeController].
  EspHomeController({required this.url, this.username, this.password})
      : assert(url.isNotEmpty, 'The URL must not be empty'),
        assert(
          username == null && password == null ||
              username != null &&
                  password != null &&
                  username.isNotEmpty &&
                  password.isNotEmpty,
          'The username and password must either '
          'both be null or both be non-empty',
        ) {
    initStream();
  }

  final String url;

  final String? username;

  final String? password;

  StreamSubscription<String>? _rawStreamSubscription;

  Future<StreamSubscription<String>> initStream() async {
    final streamUri = Uri.parse('http://192.168.178.93/events');
    final streamClient = http.Client();
    final streamRequest = http.Request('GET', streamUri);

    streamRequest.headers['Accept'] = 'text/event-stream';

    if (username != null && password != null) {
      streamRequest.headers['Authorization'] =
          'Basic ${base64Encode(utf8.encode('$username:$password'))}';
    }

    final streamResponse = await streamClient.send(streamRequest);

    return _rawStreamSubscription = streamResponse.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
          _eventHandler,
          onError: _errorHandle,
          onDone: _doneHandler,
          cancelOnError: true,
        );
  }

  void _eventHandler(String event) {
    print('Received event: $event');
  }

  void _errorHandle(error) {
    print('Error occurred while receiving events: $error');
  }

  void _doneHandler() {
    print('Done receiving events');
    _rawStreamSubscription?.cancel();
    _rawStreamSubscription = null;
  }
}
