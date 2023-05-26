import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';


Future<List<String>?> getAllSetsFromLocal(SharedPreferences prefs) async {
  return prefs.getStringList("Sets");
}

Future<List<String>> getSetsNumberByPartsNumber(String partNum) async {
  List<String> sets = [];
  final prefs = await SharedPreferences.getInstance();
  List<String>? allSets = await getAllSetsFromLocal(prefs);
  if (allSets == null) {return [];}
  for (String set in allSets) {
    List<String> parts = await getListOfPartsByNumber(set);
    for (String part in parts) {
      if (part == partNum) {
        sets.add(set);
      }
    }
  }
  return sets;
}

Future<List<String>> getListOfPartsByNumber(String number) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList(number)!;
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

Future<void> saveSetNumberAndPartsToLocal(String number, List<String> parts) async {
  final prefs = await SharedPreferences.getInstance();
  if (!await numberIsExist(number)) { // not exists
    // print("当前模型不存在");
    List<String>? allSets = prefs.getStringList("Sets");
    if (allSets == null) {
      allSets = [number];
    } else {
      allSets.add(number);
    }
    prefs.setStringList("Sets", allSets);
    prefs.setStringList(number, parts);
    Toast.show('保存成功', gravity: Toast.bottom);
  } else {
    Toast.show('当前模组已存在', gravity: Toast.bottom);
  }
}

Future<void> removeSetNumberAndPartsFromLocal(String number) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.remove(number);
  List<String> allSets = prefs.getStringList("Sets")!;
  allSets.remove(number);
  if (allSets.isNotEmpty) {
    prefs.setStringList("Sets", allSets);
  } else {
    prefs.remove("Sets");
  }
  Toast.show('删除成功', gravity: Toast.bottom);
}