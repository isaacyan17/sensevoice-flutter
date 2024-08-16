import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:asr_flutter/asr_flutter.dart';
import 'package:asr_flutter/asr_flutter_platform_interface.dart';
import 'package:asr_flutter/asr_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAsrFlutterPlatform
    with MockPlatformInterfaceMixin
    implements AsrFlutterPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final AsrFlutter asrFlutter = AsrFlutter();

  test('getModelExist', () async {
    print(await asrFlutter.checkModelExist());
  });
}
