import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_tesseract_ocr/android_ios.dart';
import 'package:ocr_project/constant.dart';
import 'package:path_provider/path_provider.dart';

//检测本地图片
Future<String> extractTextFromImagePath(String imagePath) async {
  String text =
      await FlutterTesseractOcr.extractText(imagePath, language: 'eng', args: {
    "psm": "4",
    "preserve_interword_spaces": "1",
  });
  RegExp regExp = RegExp(r'[^a-zA-Z0-9]');
  text = text.replaceAll(regExp, "").substring(
      0, text.length < maxDetectTextSize ? text.length : maxDetectTextSize);
  return text;
}

//获取网络图片并保存到本地
Future<String> extractTextFromUrl(String url) async {
  Directory tempDir = await getTemporaryDirectory();
  Dio dio = Dio();
  var response =
      await dio.get(url, options: Options(responseType: ResponseType.bytes));
  final List<int> imageData = response.data!;
  Uint8List bytes = Uint8List.fromList(imageData);
  String dir = tempDir.path;
  print('$dir/test.jpg');
  File file = File('$dir/test.jpg');
  await file.writeAsBytes(bytes);
  String imagePath = file.path;
  String text =
      await FlutterTesseractOcr.extractText(imagePath, language: 'eng', args: {
    "psm": "4",
    "preserve_interword_spaces": "1",
  });
  RegExp regExp = RegExp(r'[^a-zA-Z0-9]');
  text = text.replaceAll(regExp, "").substring(
      0, text.length < maxDetectTextSize ? text.length : maxDetectTextSize);
  return text;
}
