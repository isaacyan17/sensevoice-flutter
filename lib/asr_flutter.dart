import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa_onnx;
export 'package:path_provider/path_provider.dart';

class AsrFlutter {
  final String _downloadPath =
      'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2024-07-17.tar.bz2';
  final String modelName = 'sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2024-07-17';
  String assetPath = '';
  sherpa_onnx.OfflineRecognizerConfig? _offlineConfig;
  sherpa_onnx.OfflineRecognizer? _recognizer;
  Dio? _dio;

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

  Future downloadModel() async {
    _dio ??= Dio();
    String modelLocalPath = '$assetPath/$modelName.tar.bz2';
    File file = File(modelLocalPath);
    if (file.existsSync()) {
      file.deleteSync();
    }
    var res = await _dio!.download(
      _downloadPath,
      modelLocalPath,
      onReceiveProgress: (count, total) {
        print('下载进度：${(count / total * 100).toStringAsFixed(0)}%');
      },
    );
    print(res);
    /// 解压
    List<String> tarComd = ['tar', 'xvf', modelLocalPath,'-C',assetPath];
    print(tarComd);
    ProcessResult tarResult =  await Process.run(tarComd[0], tarComd.skip(1).toList());
    print('>>>: '+ tarResult.stdout);
    List<String> rmComd = ['rm', modelLocalPath];
    Process.runSync(rmComd[0], rmComd.skip(1).toList());
  }

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
    _offlineConfig = sherpa_onnx.OfflineRecognizerConfig(model: modelConfig);
    _recognizer ??= sherpa_onnx.OfflineRecognizer(_offlineConfig!);
   
  }

  Future<String?> AsrRecognize({required String voicePath}) async {
    _recognizer ??= sherpa_onnx.OfflineRecognizer(_offlineConfig!);
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
