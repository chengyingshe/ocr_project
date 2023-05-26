import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:ocr_project/model_card.dart';
import 'package:toast/toast.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'save_get_from_local.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'dart:io';


class SearchPage extends StatefulWidget {
  const SearchPage({Key? key, required this.title, required this.autoFocus})
      : super(key: key);
  final String title;
  final bool autoFocus;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController numberController = TextEditingController();
  String showText = "";
  bool loading = false;
  // List<String> parts = [];
  List<String> setNumberList = [];
  List<List<String>> allPartsOfSets = [];
  bool solveImageIsFile = false;
  ImagePicker picker = ImagePicker();
  File? _userImage;
  XFile? imageXFile;
  bool bload = false;
  bool _showClearButton = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: ModalProgressHUD(
          inAsyncCall: loading,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
            child: ListView(
              children: [
                TextFormField(
                  maxLength: 15,
                  autofocus: widget.autoFocus && (!loading),
                  maxLines: 1,
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                  controller: numberController,
                  textInputAction: TextInputAction.search,
                  // keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: widget.title == "本地检索" ? "请输入积木编号" : "请输入乐高模组编号",
                    focusColor: Colors.blue[300],
                    prefixIcon: Icon(Icons.search, color: Colors.blue[300]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _showClearButton
                            ? GestureDetector(
                                onTap: _clearText,
                                child: const Icon(Icons.clear_rounded, size: 18),
                              )
                            : SizedBox(),
                        IconButton(
                            icon: const Icon(Icons.document_scanner_outlined),
                            color: Colors.blue[300],
                            onPressed: () async {
                              await selectImage();
                              submit(numberController.text);
                            }),
                      ],
                    ),
                  ),
                  onFieldSubmitted: (input) async {
                    await submit(input);
                  },
                ),
                const SizedBox(height: 20),
                Center(
                    child: Text(showText,
                        style: const TextStyle(color: Colors.red))),
                setNumberList.isEmpty
                    ? const SizedBox()
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: setNumberList.length,
                        itemBuilder: (context, index) {
                          return ModelCard(
                              setNumber: setNumberList[index],
                              partsList: allPartsOfSets[index],
                              isExpanded: widget.title == "本地检索" ? false : true,
                              canDelete: false);
                        })
              ],
            ),
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    numberController.addListener(() {
      setState(() {
        _showClearButton = numberController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    numberController.dispose();
    // FlutterMobileVision.stop();
    super.dispose();
  }

  void _clearText() {
    setState(() {
      numberController.clear();
      _showClearButton = false;
    });
  }

  Future<void> submit(String input) async {
    setNumberList = [];
    allPartsOfSets = [];
    if (input.trim() == "") {
      Toast.show('输入不能为空', gravity: Toast.bottom);
    } else {
      setState(() {
        showText = "";
        loading = true;
      });
      if (widget.title == "本地检索") {
        //search from local data
        setNumberList = await getSetsNumberByPartsNumber(input);
        if (setNumberList.isEmpty) {
          // not exists in local data
          setState(() {
            showText = "从本地未查询到相应的乐高模组";
            loading = false;
          });
        } else {
          // exists in local data
          setState(() {
            showText = "从本地查询到以下乐高模组：";
          });
          for (String set in setNumberList) {
            allPartsOfSets.add(await getListOfPartsByNumber(set));
          }
          setState(() {
            loading = false;
          });
        }
      } else {
        //search from network
        print("allPartsOfSets=" + allPartsOfSets.toString());
        print("setNumberList=" + setNumberList.toString());
        String? html = await getHtmlFromNetwork(input);
        if (html == null) {
          // network error
          Toast.show('网络出现异常', gravity: Toast.bottom);
          setState(() {
            loading = false;
          });
        } else {
          setState(() {
            allPartsOfSets = [getPartsListFromHtml(html)];
          });
          // print("allPartsOfSets.isEmpty" + allPartsOfSets.isEmpty.toString());
          if (allPartsOfSets[0].isEmpty) {
            //not found
            setState(() {
              // setNumberList = [];
              showText = "从网络中未查询到相应的乐高模组";
            });
          } else {
            setState(() {
              setNumberList = [numberController.text];
              showText = "从网络中查询到以下乐高模组：";
            });
            // print(allPartsOfSets.toString());
          }
          setState(() {
            loading = false;
          });
          // print("setNumberList=" + setNumberList.toString());
        }
      }
    }
  }

  //底部弹窗，点击选择图片的按钮后弹出
  Future<int?> _bottomChoseSheet(context) async {
    return showModalBottomSheet<int>(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          height: 180,
          child: Column(children: [
            SizedBox(
              height: 50,
              child: Stack(
                textDirection: TextDirection.rtl,
                children: [
                  const Center(
                    child: Text('选择方式',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16.0)),
                  ),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop()),
                ],
              ),
            ),
            const Divider(height: 1.0),
            Expanded(
                child: Column(
              children: [
                ListTile(
                    leading: const Icon(Icons.photo),
                    title: const Text('从相册中选择'),
                    onTap: () {
                      Navigator.of(context).pop(0);
                    }),
                const Divider(),
                ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: const Text('使用相机拍摄'),
                    onTap: () {
                      Navigator.of(context).pop(1);
                    }),
              ],
            )),
          ]),
        );
      },
    );
  }

  Future<String> extractTextFromImagePath(String imagePath) async {
    String text = await FlutterTesseractOcr.extractText(imagePath,
        language: 'eng',
        args: {
          "psm": "4",
          "preserve_interword_spaces": "1",
        });
    setState(() {});
    return text;
  }

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

    bload = true;
    setState(() {});

    String text = await FlutterTesseractOcr.extractText(imagePath,
        language: 'eng',
        args: {
          "psm": "4",
          "preserve_interword_spaces": "1",
        });
    bload = false;
    setState(() {});
    return text;
  }

  Future<void> selectImage() async {
    //点击相册返回0，点击相机返回1
    int? select = await _bottomChoseSheet(context);
    print("select=$select");
    if (select != null) {
      if (select == 0) {
        await _getImage();
      } else if (select == 1) {
        // await _getCameraImage();
        await _getCameraImage();
      }
      // print("_userImage=$_userImage");
      if (_userImage != null) {
        // String url = "https://img.buzzfeed.com/buzzfeed-static/static/2018-10/4/1/asset/buzzfeed-prod-web-05/sub-buzz-11577-1538631066-1.jpg";
        String text = await extractTextFromImagePath(_userImage!.path);
        if (text == "") {
          Toast.show('未检测到文本', gravity: Toast.bottom);
        } else {
          setState(() {
            numberController.text = text.replaceAll("\n", "").substring(
                0, text.length < 15 ? text.length : 15); //first 10 chars
          });
        }
        print("text=$text");
      }
    }
  }


  Future<void> _getCameraImage() async {
    final XFile? imagePicker =
        await picker.pickImage(source: ImageSource.camera);
    if (mounted) {
      setState(() {
        //拍摄照片不为空
        if (imagePicker != null) {
          _userImage = File(imagePicker.path);
          print('你选择的路径是：${_userImage.toString()}');
          solveImageIsFile = true;
        }
      });
    }
  }

  Future<void> _getImage() async {
    //选择相册
    final XFile? pickerImages =
        await picker.pickImage(source: ImageSource.gallery);
    if (mounted) {
      setState(() {
        if (pickerImages != null) {
          _userImage = File(pickerImages.path);
          print('你选择的本地路径是：${_userImage.toString()}');
          solveImageIsFile = true;
        }
      });
    }
  }

  Future<String?> getHtmlFromNetwork(String number) async {
    setState(() {
      loading = true;
    });
    Dio dio = Dio();
    Map<String, String> fromWhereMap = {"catType": "P", "q": number};
    var response = await dio.get('https://www.bricklink.com/catalogList.asp',
        queryParameters: fromWhereMap);
    print("status=" + response.statusCode.toString());
    if (response.statusCode == 200) {
      // print(response.data);
      return response.data;
    } else {
      return null;
    }
  }

  List<String> getPartsListFromHtml(String html) {
    List<String> partsList = [];
    // htmlText = "";
    var document = html_parser.parse(html);
    List<dom.Element> links = document.querySelectorAll('a');
    final pattern = RegExp(r'^\d+[pbc]*\d+$'); //85984pb234
    setState(() {
      for (dom.Element link in links) {
        //正则表达式
        String part = link.text;
        // htmlText += part;
        if (pattern.hasMatch(part)) {
          partsList.add(part);
        }
      }
    });
    return partsList;
  }
}
