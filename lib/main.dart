import 'package:flutter/material.dart';
import 'package:ocr_project/add_moduel_by_hand.dart';
import 'package:ocr_project/camera_scan.dart';
import 'package:ocr_project/model_page.dart';
import 'package:ocr_project/search_page.dart';
import 'package:ocr_project/tabs.dart';
import 'package:ocr_project/voice_recorder.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: "/",
    debugShowCheckedModeBanner: false,
    routes: {
      "/SearchPage": (context) => const SearchPage(title: "本地检索", autoFocus: false),
      "/ModelPage": (context) => const ModelPage(),
      "/Tabs": (context) => const Tabs(),
      "/SearchFromNetworkPage": (context) => const SearchPage(title: "网络检索", autoFocus: true),
      "/AddModuleByHandPage": (context) => const AddModuleByHandPage(),
      "/CameraScanPage": (context) => const CameraScanPage(),
    },
    home: const MyMainPage(),
  ));
}

class MyMainPage extends StatelessWidget {
  const MyMainPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Tabs();
  }
}
