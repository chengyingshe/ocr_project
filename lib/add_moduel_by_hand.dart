import 'package:flutter/material.dart';
import 'package:ocr_project/local_db_management.dart';
import 'package:toast/toast.dart';

class AddModuleByHandPage extends StatefulWidget {
  const AddModuleByHandPage({Key? key}) : super(key: key);

  @override
  State<AddModuleByHandPage> createState() => _AddModuleByHandPageState();
}

TextEditingController textCtr = TextEditingController();

class _AddModuleByHandPageState extends State<AddModuleByHandPage> {
  String setNum = "";
  List<String> itemNoList = [];
  List<String> colorCodeList = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("手动添加")),
      body: Padding(
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
          child: Column(children: [
            SizedBox(
              height: 350,
              //"请手动输入LEGO模组编号及积木编号（格式为 [Set No]:[Part No1],[Part No2],...）"
              child: TextFormField(
                  maxLines: 15,
                  autofocus: true,
                  style: const TextStyle(color: Colors.black, fontSize: 15),
                  controller: textCtr,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText:
                        "请手动输入LEGO模组编号及积木编号\n格式为：[套装编码]:[设计编码1],[颜色编码1];[设计编码2],[颜色编码2];...\n(如 20:1,2;3,4;5,6)",
                    focusColor: Colors.blue[300],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  )),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton(onPressed: () {
                    getSetNoAndPartNumFromText(textCtr.text);
                    // print("setNo=$setNum");
                    if (setNum != "" && itemNoList.isNotEmpty && colorCodeList.isNotEmpty) {
                      saveSetNumAndPartsToLocal(setNum, itemNoList, colorCodeList, "", List<String>.filled(itemNoList.length, ""));
                    }
                  }, child: const Text('添加模组')),
                  const SizedBox(width: 10),
                  ElevatedButton(
                      onPressed: () {
                        textCtr.text = "";
                      },
                      child: const Text('清空文本')),
                ],
              ),
            ),
          ])),
    );
  }

  void getSetNoAndPartNumFromText(String text) {
    setNum = "";
    itemNoList = [];
    colorCodeList = [];
    String str = text.replaceAll(' ', ''); //删除文本中的空格
    List<String> list = str.split(":");
    if (list.isEmpty || list.length != 2) {
      Toast.show('输入格式错误', gravity: Toast.bottom);
    } else {
      setNum = list[0];
      String parts = list[1];
      if (setNum == "" || parts == "") {
        Toast.show('输入格式错误', gravity: Toast.bottom);
      } else {
        List<String> allParts = parts.split(';');
        for (String p in allParts) {
          List<String> ic = p.split(',');
          itemNoList.add(ic[0]);
          colorCodeList.add(ic[1]);
        }
        setState(() {});
      }
    }
  }
}
