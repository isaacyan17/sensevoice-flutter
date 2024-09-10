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
  bool modelInitialized = false;
  RecordStatus recordStatus = RecordStatus.idle;
  Dio _dio = Dio();

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
      setState(() {
        modelInitialized = true;
      });
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
    await record.stop();
    recognize();
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
                    // Container(
                    //     height: 300.h,
                    //     margin: EdgeInsets.only(top: 100.h),
                    //     child: VoiceDialog(
                    //       startRecord: startRecord,
                    //       stopRecord: stopRecord,
                    //       recordConfirm: recognize,
                    //     )),
                    Container(
                        margin: EdgeInsets.only(top: 50.h),
                        child: Text(modelInitialized ? '模型准备完成' : '模型正在初始化')),

                    Expanded(
                      child: Column(
                        children: [],
                      ),
                    ),

                    Container(
                      width: 230.w,
                      padding: EdgeInsets.only(
                          left: 10.w, right: 10.w, top: 10.h, bottom: 10.h),
                      margin: EdgeInsets.only(bottom: 20.h),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Center(
                        child: Text(text),
                      ),
                    ),
                    Container(
                      height: 100.h,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.grey[200],
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              recordStatus == RecordStatus.recording
                                  ? const Color(0xffea7072)
                                  : Colors.white),
                          shape:
                              MaterialStateProperty.all(const CircleBorder()),
                          minimumSize: MaterialStateProperty.all(
                            Size(80.r, 80.r),
                          ),
                          iconSize: MaterialStateProperty.all(50.r),
                          animationDuration: Duration(milliseconds: 300),
                        ),
                        onPressed: () async {
                          if (recordStatus == RecordStatus.recording) {
                            setState(() {
                              recordStatus = RecordStatus.stopped;
                            });
                            stopRecord();
                          } else {
                            setState(() {
                              recordStatus = RecordStatus.recording;
                            });
                            startRecord();
                          }
                        },
                        child: Icon(
                          recordStatus == RecordStatus.recording
                              ? Icons.stop
                              : Icons.mic,
                          color: recordStatus == RecordStatus.recording
                              ? Colors.white
                              : Colors.black,
                        ),
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
