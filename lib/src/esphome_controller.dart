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

  final _valueStateStream = StreamController<EspHomeElement>.broadcast();

  /// Stream of value changes of states
  Stream<EspHomeElement> get valueStream => _valueStateStream.stream;

  final _stateStream = StreamController<EspHomeControllerState>.broadcast();

  /// Stream of the controller state
  Stream<EspHomeControllerState> get controllerState => _stateStream.stream;

  Timer? _keepAliveTimer;

  /// Sets the keep alive timer.
  ///
  /// Returns true if the state changed.
  bool setKeepAlive({required bool keepAlive}) {
    if (keepAlive && _keepAliveTimer == null) {
      _keepAliveTimer = Timer.periodic(
        const Duration(seconds: 4),
        (timer) => _keepAlive(),
      );
      return true;
    } else if (_keepAliveTimer != null) {
      _keepAliveTimer?.cancel();
      _keepAliveTimer = null;
      return true;
    }
    return false;
  }

  void unpause() {
    if (setKeepAlive(keepAlive: true)) initStream();
  }

  void pause() {
    setKeepAlive(keepAlive: false);
    _rawStreamSubscription?.pause();
    _setState(EspHomeControllerState.paused);
  }

  Future<void> _keepAlive() async {
    if (isConnected) return;
    await initStream();
  }

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
        .send(streamRequest);
        // .timeout(const Duration(milliseconds: 512));

    if (streamResponse.statusCode == 200) {
      _setState(EspHomeControllerState.connected);
    }

    await _rawStreamSubscription?.cancel();
    _rawStreamSubscription = null;

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

  Map<String, EspHomeElement> _elements = {};

  List<EspHomeElement> get elements => _elements.values.toList();

  void _eventHandler(String event) {
    print('Raw event: $event');
    
    if (event.contains('Rebooting...')) {
      _setState(EspHomeControllerState.disconnected);
      initStream();
    } else if (event.startsWith('event: ')) {
      _expectedNextEvent = event.substring(7);
    } else if (event.startsWith('data: ')) {
      final data = event.substring(6);
      switch (_expectedNextEvent) {
        case 'state':
          updateElementFromMap(jsonDecode(data) as Map<String, dynamic>);
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
    print('Error occurred while receiving events: $error');
    _setState(EspHomeControllerState.error);

    _rawStreamSubscription?.cancel();
    _rawStreamSubscription = null;
  }

  void _doneHandler() {
    print('Done receiving events');
    _setState(EspHomeControllerState.disconnected);
    
    _rawStreamSubscription?.cancel();
    _rawStreamSubscription = null;
  }

  /// Create a [EspState] from a JSON map.
  ///
  /// The type of the state is determined by the `id` property automatically.
  ///
  /// If the type is unknown or not supported, `null` is returned.
  EspHomeElement? updateElementFromMap(Map<String, dynamic> json) {
    final id = json['id'] as String;

    final element =
        _elements[id]?.copyWith(json) ?? createElementFromMap(json, id);

    if (element == null) return null;

    _valueStateStream.add(element);
    _elements[id] = element;

    print('State: $element');
    return element;
  }

  /// Create a [EspHomeElement] from a JSON map.
  static EspHomeElement? createElementFromMap(
    Map<String, dynamic> json,
    String id,
  ) {
    final type = id.split('-')[0];

    switch (type) {
      case NumberState.type:
        return NumberState.fromJson(json);
      case BinarySensorState.type:
        return BinarySensorState.fromJson(json);
      case SwitchState.type:
        return SwitchState.fromJson(json);
      case ButtonState.type:
        return ButtonState.fromJson(json);
      default:
        print('Unknown state type: $type => $json');
        return null;
    }
  }
}
