import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'asr_flutter_platform_interface.dart';

/// An implementation of [AsrFlutterPlatform] that uses method channels.
class MethodChannelAsrFlutter extends AsrFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('asr_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
