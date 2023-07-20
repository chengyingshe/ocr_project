import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:ocr_project/constant.dart';
import 'package:path_provider/path_provider.dart';
import 'api.dart';

class CameraScanPage extends StatelessWidget {
  const CameraScanPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const CameraScreen();
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _cameraController;
  late Future<void> _cameraInitializer;
  bool _isCameraInitialized = false;
  // GlobalKey _windowKey = GlobalKey();
  double windowWidth = 150;
  double windowHeight = 50;
  String detectText = detectNoText;
  Timer? _timer;
  late double windowX;
  late double windowY;
  late String croppedImagePath;
  late double screenWidth;
  late double screenHeight;


  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _timer = Timer.periodic(const Duration(milliseconds: 2000), (timer) {
      //每隔1s拍摄一次图片
      takePictureFromBox();
    });
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    // print("camera:$firstCamera");
    _cameraController = CameraController(firstCamera, ResolutionPreset.high);
    _cameraInitializer = _cameraController.initialize();
    await _cameraInitializer;
    setState(() {
      _isCameraInitialized = true;
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _timer?.cancel(); // 取消定时器
    super.dispose();
  }

  void takePictureFromBox() async {
    //获取窗口拍摄的图片，并进行实时检测
    //注：摄像头拍摄到的帧大小与手机屏幕显示的大小不一致（需要进行像素转换）
    // print("rectangle: $windowX, $windowY, $windowWidth, $windowHeight");
    try {
      final imagePath = await _cameraController.takePicture();
      final originalImage =
          img.decodeImage(File(imagePath.path).readAsBytesSync())!;
      double imageWidth = originalImage.width.toDouble();
      double imageHeight = originalImage.height.toDouble();
      // print("image size= $imageWidth, $imageWidth");
      // print("screen size= $screenWidth, $screenHeight");
      final croppedImage = img.copyCrop(
        originalImage,
        x: (windowX / screenWidth * imageWidth).toInt(),
        y: (windowY / screenHeight * imageHeight).toInt(),
        width: (windowWidth / screenWidth * imageWidth).toInt(),
        height: (windowHeight / screenHeight * imageHeight).toInt(),
      );

      final appDir = await getApplicationDocumentsDirectory();
      croppedImagePath = '${appDir.path}/cropped_image.jpg';
      File(croppedImagePath)
          .writeAsBytesSync(img.encodeJpg(croppedImage)); //把图片保存到本地
      // String text = await extractTextFromImagePath(croppedImagePath);
      String text = await extractTextFromImagePathUsingBaiduApi(croppedImagePath);
      detectText = text == "" ? detectNoText : text;
      print("detectText=$text");
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        var myContext = context;
        MediaQueryData mediaQueryData = MediaQuery.of(myContext);
        Size screenSize = mediaQueryData.size;
        screenWidth = screenSize.width;
        screenHeight = screenSize.height;
        windowX = screenWidth / 2 - windowWidth / 2; //窗口左上角点x，y
        windowY = screenHeight / 3 - windowHeight / 2;
        final textSpan = TextSpan(
          text: detectText,
          style: const TextStyle(fontSize: 18),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(maxWidth: constraints.maxWidth);
        final textWidth = textPainter.width;
        // print("screen, with:$screenWidth, height:$screenHeight");
        return Stack(
          children: [
            Positioned.fill(
              child: CameraPreview(_cameraController),
            ),
            Positioned(
              //显示检测文本
              top: windowY - 25,
              left: (screenWidth - textWidth) / 2,
              child: Text(detectText,
                  style: const TextStyle(
                      color: Colors.red,
                      fontSize: 18)),
            ),
            Positioned(
              left: windowX,
              top: windowY,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (DragUpdateDetails details) {
                  final positionDelta = details.delta;
                  final newSize = Size(
                    windowWidth + positionDelta.dx,
                    windowHeight + positionDelta.dy,
                  );
                  setState(() {
                    windowWidth = newSize.width >= minWindowSize
                        ? newSize.width
                        : minWindowSize;
                    windowHeight = newSize.height >= minWindowSize
                        ? newSize.height
                        : minWindowSize;
                  });
                },
                child: Container(
                  width: windowWidth,
                  height: windowHeight,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.yellow, width: 2.0),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        detectText = detectText == detectNoText ? "" : detectText;
                        Navigator.of(context).pop(detectText);
                      },
                      child: const Text("获取检测结果"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

}
