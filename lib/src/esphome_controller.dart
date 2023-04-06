part of '../esphome_connect.dart';

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

  bool get isConnected => _rawStreamSubscription != null;

  StreamSubscription<String>? _rawStreamSubscription;

  final _valueStateStream = StreamController<State>.broadcast();

  /// Stream of value changes of states
  Stream<State> get valueState => _valueStateStream.stream;

  final _stateStream = StreamController<EspHomeControllerState>.broadcast();

  /// Stream of the controller state
  Stream<EspHomeControllerState> get controllerState => _stateStream.stream;

  void _setState(EspHomeControllerState state) {
    _stateStream.add(state);
  }

  Future<StreamSubscription<String>> initStream() async {
    _setState(EspHomeControllerState.connecting);

    final streamUri = Uri.parse('$url/events');
    final streamClient = http.Client();
    final streamRequest = http.Request('GET', streamUri);

    streamRequest.headers['Accept'] = 'text/event-stream';

    if (username != null && password != null) {
      streamRequest.headers['Authorization'] =
          'Basic ${base64Encode(utf8.encode('$username:$password'))}';
    }

    final streamResponse = await streamClient
        .send(streamRequest)
        .timeout(const Duration(milliseconds: 512));

    if (streamResponse.statusCode == 200) {
      _setState(EspHomeControllerState.connected);
    }

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

  String _expectedNextEvent = '';

  Map<String, State> _states = {};

  List<State> get states => _states.values.toList();

  void _eventHandler(String event) {
    if (event.startsWith('event: ')) {
      _expectedNextEvent = event.substring(7);
    } else if (event.startsWith('data: ')) {
      final data = event.substring(6);
      switch (_expectedNextEvent) {
        case 'state':
          final state = State.createFromMap(jsonDecode(data) as Map<String, dynamic>);
          if (state != null) {
            _valueStateStream.add(state);
            _states[state.id] = state;
          }
          print('State: $state');
          break;
        case 'ping':
          print('Ping: $data');
          break;
        default:
          print('Unknown data: $data');
          break;
      }
    }
  }

  void _errorHandle(error) {
    _setState(EspHomeControllerState.error);
    print('Error occurred while receiving events: $error');
  }

  void _doneHandler() {
    print('Done receiving events');
    _setState(EspHomeControllerState.disconnected);
    _rawStreamSubscription?.cancel();
    _rawStreamSubscription = null;
  }
}
