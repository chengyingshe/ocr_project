import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:ocr_project/model_card.dart';
import 'package:ocr_project/local_db_management.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<String>? allSets;
List<List<String>> allItemNoList = [];
List<List<String>> allColorCodeList = [];

class ModelPage extends StatefulWidget {
  const ModelPage({Key? key}) : super(key: key);

  @override
  State<ModelPage> createState() => _ModelPageState();
}

class _ModelPageState extends State<ModelPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("我的LEGO")),
      floatingActionButton: SpeedDial(
        children: [
          SpeedDialChild(
              // child: const Icon(Icons.add_circle_outline, color: Colors.white),
              backgroundColor: Colors.blue,
              label: '手动添加',
              onTap: () {
                Navigator.of(context).pushNamed("/AddModuleByHandPage");
              }),
          SpeedDialChild(
              // child: const Icon(Icons.search, color: Colors.white),
              backgroundColor: Colors.blue,
              label: '从网络检索并添加',
              onTap: () async {
                await Navigator.of(context).pushNamed("/SearchFromNetworkPage");
                await refresh();
              }),
        ],
        child: const Icon(Icons.add),
      ),
      body: PullRefreshScope(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverPullRefreshIndicator(
              refreshTriggerPullDistance: 100.0,
              refreshIndicatorExtent: 60.0,
              onRefresh: () async {
                await refresh();
              },
            ),
            // SizedBox(),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  // print("length=${allSets!.length}");
                    return (allSets == null || allSets!.isEmpty) ? const SizedBox() :
                     ModelCard(
                          setNumber: allSets![index],
                          itemNoList: allItemNoList[index],
                          isExpanded: false,
                          canDelete: true,
                          colorCodeList: allColorCodeList[index]);
                },
                childCount: allSets == null ? 0 : allSets!.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> refresh() async {
    final prefs = await SharedPreferences.getInstance();
    allSets = await getAllSetsFromLocal(prefs);
    allItemNoList = [];
    allColorCodeList = [];
    print('allSets=${allSets.toString()}');
    if (allSets != null) {
      for (String set in allSets!) {
        List<List<String>?> parts = await getListOfPartsBySetNum(set);
        setState(() {
          allItemNoList.add(parts[0]!);
          allColorCodeList.add(parts[1]!);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    refresh();
  }
}
