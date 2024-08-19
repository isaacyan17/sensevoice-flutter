# ASR Flutter 本地语音识别

Asr Flutter是基于阿里开源的语音大模型[SenseVoice](https://github.com/FunAudioLLM/SenseVoice/blob/main/README_zh.md)开发的Flutter版本地离线语音识别插件

目前实现的功能:

- ASR (Automatic Speech Recognition)  Offline , 离线版语音识别*(非流式, .wav格式)* 

## 选用框架

- `SenseVoice-small` 234M参数, 支持中、粤、英、日、韩语的多语言语音识别
- [sherpa-onnx](https://github.com/k2-fsa/sherpa-onnx): 手机端神经网络训练框架, 支持多种语言及端平台



## 编译环境

```
Flutter: 3.24.0
sherpa-onnx: 1.10.21
Android SDK version 34.0.0

```



## 测试指南

尽量先参照https://k2-fsa.github.io/sherpa/onnx/sense-voice/dart-api.html#id1 进行本地编译测试运行, 如果正常识别demo音频表示开发环境正常.

**注意**,示例中:

```
cd /tmp

git clone http://github.com/k2-fsa/sherpa-onnx

cd sherpa-onnx
cd dart-api-examples
cd non-streaming-asr
dart pub get
./run-sense-voice.sh
```

`dart pub get`我本地测试跑不通, 用`flutter pub get`运行亦可. 同时需要修改脚本文件`run-sense-voice.sh`: 

```

#!/usr/bin/env bash

set -ex

dart pub get  // !! --> change to: flutter pub get

if [ ! -f ./sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2024-07-17/tokens.txt ]; then
  curl -SL -O https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2024-07-17.tar.bz2
  tar xvf sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2024-07-17.tar.bz2
  rm sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2024-07-17.tar.bz2
fi

dart run \
  ./bin/sense-voice.dart \
  --model ./sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2024-07-17/model.int8.onnx \
  --tokens ./sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2024-07-17/tokens.txt \
  --use-itn true \
  --input-wav ./sherpa-onnx-sense-voice-zh-en-ja-ko-yue-2024-07-17/test_wavs/zh.wav
```



