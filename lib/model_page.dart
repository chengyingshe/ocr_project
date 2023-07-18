import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:ocr_project/model_card.dart';
import 'package:ocr_project/local_db_management.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<String>? allSets;
List<List<String>> allItemNoList = [];
List<List<String>> allColorCodeList = [];
List<String> allSetsImageUrl = [];
List<List<String>> allPartImageUrlList = [];

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
              backgroundColor: Colors.blue,
              label: '手动添加',
              onTap: () {
                Navigator.of(context).pushNamed("/AddModuleByHandPage");
              }),
          SpeedDialChild(
              backgroundColor: Colors.blue,
              label: '从数据库检索并添加',
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
                    return (allSets == null || allSets!.isEmpty) ? const SizedBox() :
                     ModelCard(
                          setNumber: allSets![index],
                          itemNoList: allItemNoList[index],
                          isExpanded: false,
                          canDelete: true,
                          colorCodeList: allColorCodeList[index],
                          setImageUrl: allSetsImageUrl[index],
                          partImageUrlList: allPartImageUrlList[index]);
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
    setState(() {});
    print('allSets=${allSets.toString()}');
    allItemNoList = [];
    allColorCodeList = [];
    allSetsImageUrl = [];
    allPartImageUrlList = [];
    if (allSets != null) {
      for (String set in allSets!) {
        List<List<String>?> parts = await getListOfPartsBySetNum(set);
        // print('parts=${parts.toString()}');
        setState(() {
          allItemNoList.add(parts[0]!);
          allColorCodeList.add(parts[1]!);
          allSetsImageUrl.add(parts[2]![0]);
          allPartImageUrlList.add(parts[3]!);
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
