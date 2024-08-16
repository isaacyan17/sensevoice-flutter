import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VoiceDialog extends StatefulWidget {
  ///开始录音
  final Function? startRecord;

  ///停止录音
  final Function? stopRecord;

  ///录音结束
  final Function? recordConfirm;

  const VoiceDialog({
    super.key,
    this.recordConfirm,
    this.startRecord,
    this.stopRecord,
  });

  @override
  State<StatefulWidget> createState() {
    return _VoiceDialogState();
  }
}

class _VoiceDialogState extends State<VoiceDialog>
    with TickerProviderStateMixin {
  RecordStatus recordStatus = RecordStatus.idle;
  StreamController streamController = StreamController.broadcast();

  ///已经record的时长
  int recordCount = 0;

  ///定时器
  Timer? _timer;

  ///动画控制器
  AnimationController? _animationController;
  late Animation<double> _circleAnimation;
  late Animation<double> _iconSizeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _circleAnimation =
        Tween<double>(begin: 80.r, end: 40.r).animate(_animationController!);
    _iconSizeAnimation =
        Tween<double>(begin: 50.r, end: 25.r).animate(_animationController!);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          EdgeInsets.only(left: 30.w, right: 30.w,),
      decoration: BoxDecoration(
        color: Color(0xffe8e8e8),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          StreamBuilder(
              stream: streamController.stream,
              builder: (context, snapshot) {
                final Duration duration;
                if (snapshot.hasData) {
                  duration = Duration(seconds: snapshot.data);
                } else {
                  duration = const Duration(seconds: 0);
                }
                String twoDigits(int n) => n.toString().padLeft(2, '0');
                final twoDigitsMinute =
                    twoDigits(duration.inMinutes.remainder(60));
                final twoDigitsSeconds =
                    twoDigits(duration.inSeconds.remainder(60));
                return Container(
                    height: 100.h,
                    width: 230.w,
                    margin: EdgeInsets.only(top: 40.w),
                    decoration: BoxDecoration(
                      color: Color(0xff585858),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Center(
                      child: Text(
                        '$twoDigitsMinute:$twoDigitsSeconds',
                        style: TextStyle(
                          fontSize: 40.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ));
              }),
          AnimatedBuilder(
              animation: _animationController!,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ///开始录制，停止录制
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            recordStatus == RecordStatus.recording
                                ? const Color(0xffea7072)
                                : Colors.white),
                        shape: MaterialStateProperty.all(const CircleBorder()),
                        minimumSize: MaterialStateProperty.all(
                          Size(_circleAnimation.value, _circleAnimation.value),
                        ),
                        iconSize:
                            MaterialStateProperty.all(_iconSizeAnimation.value),
                        animationDuration: Duration(milliseconds: 300),
                      ),
                      onPressed: () async{
                        if (recordStatus == RecordStatus.recording) {
                          if (widget.stopRecord != null) {
                            widget.stopRecord!();
                          }
                          stopRecord();
                        } else {
                          if (widget.startRecord != null) {
                            await widget.startRecord!();
                          }
                          record();
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

                    Visibility(
                      visible: recordStatus == RecordStatus.stopped,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  const Color(0xff599560)),
                              shape: MaterialStateProperty.all(
                                  const CircleBorder()),
                              minimumSize:
                                  MaterialStateProperty.all(Size(80.r, 80.r)),
                            ),
                            onPressed: () {
                              ///发送
                              if (widget.recordConfirm != null) {
                                widget.recordConfirm!();
                              }
                            },
                            child: Icon(
                              Icons.check,
                              size: 50.r,
                              color: Colors.white,
                            ),
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  const Color(0xff2095f2)),
                              shape: MaterialStateProperty.all(
                                  const CircleBorder()),
                              minimumSize:
                                  MaterialStateProperty.all(Size(40.r, 40.r)),
                            ),
                            onPressed: () {
                              resetRecord();
                            },
                            child: Transform.rotate(
                              angle: 60,
                              child: Icon(
                                Icons.replay_sharp,
                                size: 25.r,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
        ],
      ),
    );
  }

  void record() {
    _animationController?.reverse().whenComplete(
      () {
        setState(() {
          recordStatus = RecordStatus.recording;
        });
        _timer?.cancel();
        streamController.sink.add(++recordCount);
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          streamController.sink.add(++recordCount);
        });
      },
    );
  }

  void stopRecord() {
    _animationController?.forward().whenComplete(() {
      setState(() {
        recordStatus = RecordStatus.stopped;
      });
      _timer?.cancel();
      _timer = null;
      recordCount = 0;
    });
  }

  void resetRecord() {
    _animationController?.reverse();
    setState(() {
      recordStatus = RecordStatus.idle;
    });
    recordCount = 0;
    streamController.sink.add(recordCount);
    _timer?.cancel();
  }

  @override
  void dispose() {
    super.dispose();
    streamController.close();
    _timer?.cancel();
  }
}

enum RecordStatus {
  idle(0, 'idle'),
  recording(1, 'recording'),
  paused(2, 'paused'),
  stopped(3, 'stopped');

  const RecordStatus(this.num, this.value);

  final int num;
  final String value;
}
