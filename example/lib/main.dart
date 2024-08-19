import 'dart:io';

import 'package:asr_flutter_example/widget/voice_dialog.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:asr_flutter/asr_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:record/record.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final record = AudioRecorder();

  final _asrFlutterPlugin = AsrFlutter();
  String text = '';

  @override
  void initState() {
    super.initState();
    initAsrModel();
  }

  Future<void> initAsrModel() async {
    bool b = await _asrFlutterPlugin.checkModelExist();
    print(b);
    if (b) {
      _asrFlutterPlugin.initOnnx();
    }
  }

  Future startRecord() async {
    var p = await getDownloadsDirectory();
    String filePath = '${p?.path}/audio.wav';
    print(filePath);
    File file = File(filePath);
    if (file.existsSync()) {
      print('删除已经存在的文件');
      file.deleteSync();
    }
    if (await record.hasPermission()) {
      await record.start(
        const RecordConfig(
            encoder: AudioEncoder.wav, sampleRate: 16000, numChannels: 1),
        path: filePath,
      );
    } else {
      print('没有录音权限');
    }
  }

  Future stopRecord() async {
    record.stop();
  }

  Future recognize() async {
    var p = await getDownloadsDirectory();
    String filePath = '${p?.path}/audio.wav';
    // String testPath = '${p?.path}/zh_prompt.wav';
    String? r = await _asrFlutterPlugin.AsrRecognize(voicePath: filePath);
    print('>>>>: $r');
    setState(() {
      text = r ?? 'null';
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return Scaffold(
              body: SafeArea(
                child: Column(
                  children: [
                    Container(
                        height: 300.h,
                        margin: EdgeInsets.only(top: 100.h),
                        child: VoiceDialog(
                          startRecord: startRecord,
                          stopRecord: stopRecord,
                          recordConfirm: recognize,
                        )),
                    Container(
                      width: 230.w,
                      padding: EdgeInsets.only(
                          left: 10.w, right: 10.w, top: 10.h, bottom: 10.h),
                      margin: EdgeInsets.only(top: 50.h),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Center(
                        child: Text(text),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
