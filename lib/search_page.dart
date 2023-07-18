import 'dart:async';
import 'package:ocr_project/add_moduel_by_hand.dart';
import 'package:ocr_project/constant.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:ocr_project/model_card.dart';
import 'package:toast/toast.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'local_db_management.dart';
import 'dart:io';
import 'api.dart';
import 'voice_recorder.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key, required this.title, required this.autoFocus})
      : super(key: key);
  final String title;
  final bool autoFocus;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

enum Selection { fromSetNum, fromItemNo, fromColorCode }
Selection _selectedOption = Selection.fromItemNo;

class _SearchPageState extends State<SearchPage> {
  TextEditingController numberController = TextEditingController();
  String showText = "";
  bool loading = false;
  List<String> setNumberList = [];
  List<String> itemNoList = [];
  List<String> colorCodeList = [];
  ImagePicker picker = ImagePicker();
  bool bload = false;
  bool _showClearButton = false;
  bool solveImageIsFile = false;
  late File _userImage;
  String debugText = "";
  List<List<dynamic>> data = [];
  List<String> partImageUrlList = [];
  String setImageUrl = '';

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
                  maxLength: maxDetectTextSize,
                  autofocus: widget.autoFocus && (!loading),
                  maxLines: 1,
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                  controller: numberController,
                  textInputAction: TextInputAction.search,
                  // keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: widget.title == "本地检索" ? "请输入搜索编号" : "请输入乐高套装编号",
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
                            : const SizedBox(),
                        widget.title == "本地检索" ? IconButton(
                            constraints: const BoxConstraints(maxWidth: 35),
                          onPressed: () async {
                            await showSearchSetting();
                          }, icon: const Icon(Icons.settings)) : const SizedBox(),
                        IconButton(
                            constraints: const BoxConstraints(maxWidth: 35),
                            icon: const Icon(Icons.mic_none_rounded),
                            onPressed: () async {
                              await startVoiceRecorder(numberController);
                            }),
                        IconButton(
                            constraints: const BoxConstraints(maxWidth: 40),
                            icon: const Icon(Icons.document_scanner_outlined),
                            onPressed: () async {
                              await selectImage();
                              if (numberController.text.isNotEmpty) {
                                submit(numberController.text);
                              }
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
                              itemNoList: itemNoList,
                              colorCodeList: colorCodeList,
                              isExpanded: widget.title == "本地检索" ? false : true,
                              canDelete: widget.title == "本地检索" ? true : false,
                              setImageUrl: setImageUrl,
                              partImageUrlList: partImageUrlList);
                        }),
              ],
            ),
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    if (widget.title == '网络检索') {
      loadCSVData();
    }
    numberController.addListener(() {
      setState(() {
        _showClearButton = numberController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    numberController.dispose();
    super.dispose();
  }

  void _clearText() {
    setState(() {
      numberController.clear();
      _showClearButton = false;
    });
  }

  Future<void> startVoiceRecorder(TextEditingController textCtr) {
    return showDialog(context: context, builder: (context) {
      return VoiceRecorder(textCtr: textCtr);
    });
  }

  Future<void> submit(String input) async {
    setNumberList = [];
    itemNoList = [];
    if (input.trim() == "") {
      Toast.show('输入不能为空', gravity: Toast.bottom);
    } else {
      setState(() {
        showText = "";
        loading = true;
      });
      if (widget.title == "本地检索") { // search from local data
        searchFromLocalData(input);
      } else { // search from network
        // searchFromNetwork(input);
        // now is searching from csv
        searchFromCSV(input);
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
          height: 200,
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
                        title: const Text('使用相机扫描'),
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

  Future<void> getCameraScanText() async {
    String detectText = (await Navigator.of(context).pushNamed("/CameraScanPage")).toString();
    print("detectText=$detectText");
    if (detectText != "null") {
      numberController.text = detectText;
    }
  }

  //加载本地csv文件
  Future<void> loadCSVData() async {
    final csvData = await rootBundle.loadString('assets/lego_parts.csv');
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(csvData);
    print(csvTable.toString());
    setState(() {
      data = csvTable;
    });
  }

  // return [[number, setImageUrl], colorCodeList, itemNoList, partImageUrlList]
  List<List<String>>? getAllInfoFromCSVBySetNum(String number) {
    List<String> partImageUrlList = [];
    List<String> itemNoList = [];
    List<String> colorCodeList = [];
    String setImageUrl = '';
    for (var row in data) {
      // print('row=${row.toString()}');
      if (row[0].toString() == number) {
        setImageUrl = row[1].toString();
        colorCodeList.add(row[2].toString());
        itemNoList.add(row[3].toString());
        partImageUrlList.add(row[4].toString());
      }
    }
    if (itemNoList.isEmpty) {
      return null;
    }
    return [[number, setImageUrl], colorCodeList, itemNoList, partImageUrlList];
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
        await getCameraScanText();
      }
      // print("_userImage=$_userImage");
      if (select == 0) { //选择相册时
        // String url = "https://img.buzzfeed.com/buzzfeed-static/static/2018-10/4/1/asset/buzzfeed-prod-web-05/sub-buzz-11577-1538631066-1.jpg";
        String text = await extractTextFromImagePathUsingBaiduApi(_userImage.path);
        if (text == "") {
          Toast.show('未检测到文本', gravity: Toast.bottom);
        } else {
          setState(() {
            numberController.text = text;
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
    //从官网获取套件及零件编号
    //https://www.bricklink.com/catalogList.asp
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
  Future<String?> getHtmlFromNetwork2(String number) async {
    //从官网获取套件及零件编号  获取套装编号（图片）、积木块的设计编号、元素编号（图片）
    //https://www.bricklink.com/v2/catalog/catalogitem.page?S=60114-1#T=I
    setState(() {
      loading = true;
    });
    Dio dio = Dio();
    //https://www.bricklink.com/v2/catalog/catalogitem.page?S=60124
    try {
      //Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36
      var headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36"};
      var response = await dio.get('https://www.bricklink.com/v2/catalog/catalogitem.page?S=$number',
      options: Options(headers: headers));
      // print('headers=' + response.headers.toString());
      if (response.statusCode == 200) {
        return response.data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
  Future<void> searchFromNetwork(String input) async {
    //search from network
    String? html = await getHtmlFromNetwork2(input);
    if (html == null) {
      // network error
      Toast.show('网络出现异常', gravity: Toast.bottom);
      setState(() {
        loading = false;
      });
    } else {
      List<List<String>> ic = getItemNoAndColorCodeOfPartsFromHtml(html);
      itemNoList = ic[0];
      colorCodeList = ic[1];
      if (itemNoList.isEmpty || colorCodeList.isEmpty) { // not found
        setState(() {
          showText = "从网络中未查询到相应的乐高模组";
          // showText = html;
        });
      } else {
        setState(() {
          setNumberList = [numberController.text];
          showText = "从网络中查询到以下乐高模组：";
        });
      }
      setState(() {
        loading = false;
      });
    }
  }
  Future<void> searchFromLocalData(String input) async {
    switch (_selectedOption) { // 根据选择使用不同查找方式
      case Selection.fromSetNum:
        if (await numberIsExist(input)) {
          setNumberList = [input];
        } else {
          setNumberList = [];
        }
        break;
      case Selection.fromItemNo:
        setNumberList = await getSetsNumberByItemNo(input);
        break;
      case Selection.fromColorCode:
        setNumberList = await getSetsNumberByColorCode(input);
        break;
    }
    print("setNumberList=${setNumberList.toString()}");
    if (setNumberList.isEmpty) { // not exists in local data
      setState(() {
        showText = "从本地未查询到相应的乐高模组";
        loading = false;
      });
    } else { // exists in local data
      setState(() {
        showText = "从本地查询到以下乐高模组：";
      });
      for (String set in setNumberList) {
        List<List<String>?> ic = await getListOfPartsBySetNum(set);
        itemNoList = ic[0]!;
        colorCodeList = ic[1]!;
        setImageUrl = ic[2]![0];
        partImageUrlList = ic[3]!;
      }
      setState(() {
        loading = false;
      });
    }
  }
  void searchFromCSV(String input) {
    setState(() { loading = true; });
    List<List<String>>? allInfo = getAllInfoFromCSVBySetNum(input);
    // print('allInfo=${allInfo.toString()}');
    if (allInfo == null) {
      setState(() {
        showText = "从数据库中未查询到相应的乐高模组";
      });
    } else {
      setState(() {
        showText = "从数据库中查询到以下乐高模组";
        setNumberList = [numberController.text];
        setImageUrl = allInfo[0][1];
        itemNoList = allInfo[2];
        colorCodeList = allInfo[1];
        partImageUrlList = allInfo[3];
      });
    }
    setState(() { loading = false; });
  }

  List<List<String>> getItemNoAndColorCodeOfPartsFromHtml(String html) {
    //[[part1ItemNo, part2ItemNo, ...], [part1ColorCode, part2ColorCode, ...]]
    List<String> itemNoList = [];
    List<String> colorCodeList = [];
    var document = html_parser.parse(html);
    print('document=${document.outerHtml}');
    List<dom.Element> elements = document.getElementsByClassName('pciinvMainTable');
    // List<dom.Element> elements = document.getElementsByClassName('pciinvItemRow');
    print(elements.length);
    for (int i=1; i<elements.length; i++) { //i=0时为Set Item
      var element = elements[i];
      try { // 防止 Part Color Code Missing报错
        String? itemNo = element.getElementsByTagName('td')[3].text;
        RegExp re1 = RegExp(r'^[a-zA-Z0-9]+$'); // 正则表达式匹配只含有数字或字母的字符串（筛出组件）
        if (!re1.hasMatch(itemNo)) {continue;}
        String? colorCode = element.getElementsByTagName('td')[4].getElementsByClassName('pciinvPartsColorCode').first.text;
        if (colorCode.isNotEmpty) {
          colorCode = colorCode.replaceAll(' or ', '\\');
          colorCodeList.add(colorCode);
          itemNoList.add(itemNo);
        }
      } catch (e) {
        continue;
      }
    }
    print(itemNoList.toString());
    print(colorCodeList.toString());
    return [itemNoList, colorCodeList];
  }
  //点击设置后跳出对话框，显示查找类型（SetNum, itemNo, colorCode）
  Future<void> showSearchSetting() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("查询设置"),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                height: 180,
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('查询套装编号'),
                      leading: Radio(
                        value: Selection.fromSetNum,
                        groupValue: _selectedOption,
                        onChanged: (Selection? value) {
                          setState(() {
                            _selectedOption = value!;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('查询设计编号'),
                      leading: Radio(
                        value: Selection.fromItemNo,
                        groupValue: _selectedOption,
                        onChanged: (Selection? value) {
                          setState(() {
                            _selectedOption = value!;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('查询颜色编号'),
                      leading: Radio(
                        value: Selection.fromColorCode,
                        groupValue: _selectedOption,
                        onChanged: (Selection? value) {
                          setState(() {
                            _selectedOption = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
