import 'package:flutter/material.dart';
import 'package:ocr_project/save_get_from_local.dart';
import 'package:toast/toast.dart';

class AddModuleByHandPage extends StatefulWidget {
  const AddModuleByHandPage({Key? key}) : super(key: key);

  @override
  State<AddModuleByHandPage> createState() => _AddModuleByHandPageState();
}

TextEditingController textCtr = TextEditingController();

class _AddModuleByHandPageState extends State<AddModuleByHandPage> {
  String setNo = "";
  List<String> partNum = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("手动添加")),
      body: Padding(
          padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
          child: Column(children: [
            SizedBox(
              height: 300,
              //"请手动输入LEGO模组编号及积木编号（格式为 [Set No]:[Part No1],[Part No2],...）"
              child: TextFormField(
                  maxLines: 10,
                  maxLength: 500,
                  autofocus: true,
                  style: const TextStyle(color: Colors.black, fontSize: 15),
                  controller: textCtr,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText:
                        "请手动输入LEGO模组编号及积木编号\n格式为 [Set No]:[Part No1],[Part No2],...\n(如 20:1,2,3,4)",
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
                    if (setNo != "" && partNum.isNotEmpty) {
                      saveSetNumberAndPartsToLocal(setNo, partNum);
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
    setNo = "";
    partNum = [];
    List<String> list = text.split(":");
    if (list.isEmpty || list.length != 2) {
      Toast.show('输入格式错误', gravity: Toast.bottom);
    } else {
      String set = list[0].trim();
      String parts = list[1].trim();
      if (set == "" || parts == "") {
        Toast.show('输入格式错误', gravity: Toast.bottom);
      } else {
        List<String> partList = parts.split(",");
        for (String p in partList) {
          partNum.add(p.trim());
        }
        setState(() {
          setNo = set;
          partNum = partNum;
        });
      }
    }
  }
}
