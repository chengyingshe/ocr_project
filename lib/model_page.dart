import 'package:flukit/flukit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:ocr_project/model_card.dart';
import 'package:ocr_project/save_get_from_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<String>? allSets;
List<List<String>> allPartsOfSets = [];

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
        child: Icon(Icons.add),
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
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  // print("length=${allSets!.length}");
                  if (allSets == null) {
                    return const SizedBox();
                  } else {
                    return ModelCard(
                        setNumber: allSets![index],
                        partsList: allPartsOfSets[index],
                        isExpanded: false,
                        canDelete: true);
                  }
                },
                childCount: allPartsOfSets.length,
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
    allPartsOfSets = [];
    if (allSets != null) {
      for (String set in allSets!) {
        allPartsOfSets.add(await getListOfPartsByNumber(set));
      }
    }
    setState(() {
      allSets = allSets;
      allPartsOfSets = allPartsOfSets;
    });
  }

  @override
  void initState() {
    super.initState();
    refresh();
  }
}
