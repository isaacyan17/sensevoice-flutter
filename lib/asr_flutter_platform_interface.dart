import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'asr_flutter_method_channel.dart';

abstract class AsrFlutterPlatform extends PlatformInterface {
  /// Constructs a AsrFlutterPlatform.
  AsrFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static AsrFlutterPlatform _instance = MethodChannelAsrFlutter();

  /// The default instance of [AsrFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelAsrFlutter].
  static AsrFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AsrFlutterPlatform] when
  /// they register themselves.
  static set instance(AsrFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
