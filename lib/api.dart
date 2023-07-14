import 'dart:convert';
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

//使用百度api进行图片ocr识别
Future<String> extractTextFromImagePathUsingBaiduApi(String imagePath) async {
  String detectText = '';
  Dio dio = Dio();
  var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
  var response = await dio.post(
      'https://aip.baidubce.com/rest/2.0/ocr/v1/accurate_basic',
      data: {
        'access_token': accessToken,
        'image': cvtFile2Base64(imagePath)
      },
      options: Options(headers: headers));
  var text = response.data['words_result'];
  // print('text=${text.toString()}');
  if (text.isNotEmpty) {
    detectText = text[0]['words'].toString();
    RegExp regExp = RegExp(r'[^a-zA-Z0-9]');
    detectText = detectText.replaceAll(regExp, '');
    detectText.substring(  //去掉特殊字符（并进行字符串截断）
        0, detectText.length <= maxDetectTextSize ? detectText.length : maxDetectTextSize);
    // print('detectText=$detectText');
    return detectText;
  }
  return '';
}

String? cvtFile2Base64(String filePath) {
  File file = File(filePath);
  if (file.existsSync()) {
    List<int> fileBytes = file.readAsBytesSync();
    return base64Encode(fileBytes);
  } else {
    return null;
  }
}

//使用百度api进行语音识别
Future<String> extractTextFromVoicePathUsingBaiduApi(String voicePath) async {
  String detectText = '';
  Dio dio = Dio();
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };
  var response = await dio.post(
      'https://vop.baidu.com/server_api',
      data: {
        "format": "wav",
        "rate": 16000,
        "channel": 1,
        "cuid": "1QdCGq4ifQ7eLlZS3qDJTgSElXBS8zUk",
        "token": accessToken,
        "speech": cvtFile2Base64(voicePath),
        "len": File(voicePath).lengthSync(),
      },
      options: Options(headers: headers));
  var text = response.data['result'];
  // print('text=${text.toString()}');
  if (text.isNotEmpty) {
    detectText = text[0];
    // print('detectText=$detectText');
    RegExp regExp = RegExp(r'[^a-zA-Z0-9]');
    detectText = detectText.replaceAll(regExp, '');
    detectText.substring(  //去掉特殊字符（并进行字符串截断）
        0, detectText.length <= maxDetectTextSize ? detectText.length : maxDetectTextSize);
    return detectText;
  }
  return '';
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
