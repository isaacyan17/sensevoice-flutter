import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;
export 'package:path_provider/path_provider.dart';

class AsrFlutter {
  final String _downloadPath =
      'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2024-07-17.tar.bz2';
  final String modelName = 'sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2024-07-17';
  String assetPath = '';
  sherpa_onnx.OfflineRecognizer? _recognizer;

  Future<bool> checkModelExist() async {
    Directory? d = await getDownloadsDirectory();
    if (d == null) return false;
    assetPath = d.path;
    print(d.path);
    var listSync = d.listSync();
    for (var i in listSync) {
      if (i.path.contains(modelName)) {
        return true;
      }
    }
    return false;
  }

  Future downloadModel() async {}

  void initOnnx() async {
    sherpa_onnx.initBindings();
    String modelPath = '$assetPath/$modelName/model.int8.onnx';
    String tokens = '$assetPath/$modelName/tokens.txt';
    final senseVoice = sherpa_onnx.OfflineSenseVoiceModelConfig(
        model: modelPath, useInverseTextNormalization: true);

    final modelConfig = sherpa_onnx.OfflineModelConfig(
      senseVoice: senseVoice,
      tokens: tokens,
      debug: true,
      numThreads: 1,
    );
    final config = sherpa_onnx.OfflineRecognizerConfig(model: modelConfig);
    _recognizer = sherpa_onnx.OfflineRecognizer(config);
  }

  Future<String?> AsrRecognize({required String voicePath}) async {
    if (_recognizer == null) {
      return null;
    }
    try {
      final waveData = sherpa_onnx.readWave(voicePath);
      final stream = _recognizer!.createStream();
      stream.acceptWaveform(
          samples: waveData.samples, sampleRate: waveData.sampleRate);
      _recognizer?.decode(stream);

      final result = _recognizer?.getResult(stream);
      stream.free();
      return result?.text;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
