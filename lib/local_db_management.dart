import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';


Future<List<String>?> getAllSetsFromLocal(SharedPreferences prefs) async {
  return prefs.getStringList("Sets");
}

//通过设计编码查找SetNum
Future<List<String>> getSetsNumberByItemNo(String itemNo) async {
  List<String> sets = [];
  final prefs = await SharedPreferences.getInstance();
  List<String>? allSets = await getAllSetsFromLocal(prefs);

  if (allSets == null) {return [];}
  for (String set in allSets) {
    List<List<String>?> parts = await getListOfPartsBySetNum(set);
    print("parts=${parts.toString()}");
    List<String> itemNoList = parts[0]!;
    for (String i in itemNoList) {
      if (i == itemNo) {
        sets.add(set);
        break;
      }
    }
  }
  return sets;
}

//通过元素编码查找SetNum
Future<List<String>> getSetsNumberByColorCode(String colorCode) async {
  List<String> sets = [];
  final prefs = await SharedPreferences.getInstance();
  List<String>? allSets = await getAllSetsFromLocal(prefs);
  if (allSets == null) {return [];}
  for (String set in allSets) {
    List<List<String>?> parts = await getListOfPartsBySetNum(set);
    // List<String> itemNoList = parts[0];
    List<String> colorCodeList = parts[1]!;
    bool find = false;
    int i = 0;
    while (!find) {
      String cc = colorCodeList[i++];
      List<String> list = cc.split('\\');
      for (String code in list) {
        if (code == colorCode) {
          sets.add(set);
          find = true;
          break;
        }
      }
    }
  }
  return sets;
}

//通过SetNum获取设计编码和元素编码
Future<List<List<String>?>> getListOfPartsBySetNum(String number) async {
  final prefs = await SharedPreferences.getInstance();
  List<String>? itemNoList = prefs.getStringList(getItemNoListName(number));
  List<String>? colorCodeList = prefs.getStringList(getColorCodeListName(number));
  return [itemNoList, colorCodeList];
}

Future<bool> numberIsExist(String number) async {
  final prefs = await SharedPreferences.getInstance();
  List<String>? allSets = prefs.getStringList("Sets");
  if (allSets == null) {
    return false;
  } else {
    for (String set in allSets) {
      if (set == number) {return true;}
    }
    return false;
  }
}

String getItemNoListName(String number) {return "${number}ItemNo";}
String getColorCodeListName(String number) {return "${number}ColorCode";}

//存储
Future<void> saveSetNumAndPartsToLocal(String number, List<String> itemNoList, List<String> colorCodeList) async {
  final prefs = await SharedPreferences.getInstance();
  if (!await numberIsExist(number)) { // not exists
    // print("当前模型不存在");
    List<String>? allSets = prefs.getStringList("Sets");
    if (allSets == null) { //添加第一个SetNum时
      allSets = [number];
    } else {
      allSets.add(number);
    }
    prefs.setStringList("Sets", allSets);
    prefs.setStringList(getItemNoListName(number), itemNoList); //保存ItemNo
    prefs.setStringList(getColorCodeListName(number), colorCodeList); //保存ColorCode
    Toast.show('保存成功', gravity: Toast.bottom);
  } else {
    Toast.show('当前模组已存在', gravity: Toast.bottom);
  }
}

Future<void> removeSetNumAndPartsFromLocal(String number) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> allSets = prefs.getStringList("Sets")!;
  allSets.remove(number);
  prefs.remove(getItemNoListName(number));
  prefs.remove(getColorCodeListName(number));
  prefs.setStringList("Sets", allSets);
  Toast.show('删除成功', gravity: Toast.bottom);
}