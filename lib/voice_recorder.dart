import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'api.dart';

class VoiceRecorder extends StatefulWidget {
  const VoiceRecorder({Key? key, required this.textCtr}) : super(key: key);
  final TextEditingController textCtr;

  @override
  State<VoiceRecorder> createState() => _VoiceRecorderState();
}

class _VoiceRecorderState extends State<VoiceRecorder> {
  FlutterSoundRecorder recorder = FlutterSoundRecorder();
  Timer? timer;
  // 创建一个变量，用于存储录制时间
  Duration duration = Duration.zero;
  late String filePath;
  bool showDetectText = false;
  String detectText = '';

  @override
  void initState() {
    super.initState();
    // 初始化录音器
    initRecorder();
  }

  @override
  void dispose() async {
    // 关闭录音器
    closeRecorder();
    super.dispose();
  }
  // 初始化录音器的方法
  Future<void> initRecorder() async {
    // 打开音频会话
    await recorder.openRecorder();
    // 获取应用的临时目录
    Directory tempDir = await getTemporaryDirectory();
    // 拼接录制文件的路径
    filePath = '${tempDir.path}/recorded.wav';
    setState(() {});
  }

  // 关闭录音器的方法
  Future<void> closeRecorder() async {
    // 停止录音（如果正在录音）
    await recorder.stopRecorder();
    // 关闭音频会话
    await recorder.closeRecorder();
  }

  // 开始录音的方法
  Future<void> startRecording() async {
    // 开始录音，并指定文件路径
    await recorder.startRecorder(codec: Codec.pcm16WAV, toFile: filePath);
    // 启动定时器，每秒更新一次录制时间
    timer = Timer.periodic(const Duration(milliseconds: 10), (t) {
      setState(() {
        duration = Duration(milliseconds: t.tick * 10);
      });
    });
  }

  // 停止录音的方法
  Future<void> stopRecording() async {
    // 停止录音
    await recorder.stopRecorder();
    // 取消定时器
    timer?.cancel();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(child: Text('录制音频')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('录制时间：${duration.inSeconds}.${(duration.inMilliseconds % 1000 ~/ 100)}s', style: TextStyle(fontSize: 18)),
          SizedBox(height: 10),
          showDetectText ? Text(detectText == '' ? '未识别到结果' : '识别结果：$detectText', style: TextStyle(color: Colors.red)) : SizedBox(),
          SizedBox(height: 10),
          GestureDetector(
            onTapDown: (details) {
              startRecording(); // 按下时开始录音
            },
            onTapUp: (details) async {
              await stopRecording(); // 抬起时停止录音
              // Navigator.pop(context, filePath); // 返回录制文件的路径
              print('filePath=$filePath');
              detectText = await extractTextFromVoicePathUsingBaiduApi(filePath);
              showDetectText = true;
              print('detectText=$detectText');
              setState(() {});
            },
            child: const Icon(
              Icons.mic,
              size: 64,
              color: Colors.blue,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {

            Navigator.pop(context);
          },
          child: Text('取消'),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              widget.textCtr.text = detectText;

            });
            Navigator.pop(context);
          },
          child: Text('确认'),
        ),
      ],
    );
  }
}
