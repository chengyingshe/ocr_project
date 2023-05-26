import 'package:flutter/material.dart';
import 'package:ocr_project/part_card.dart';
import 'package:ocr_project/save_get_from_local.dart';
import 'package:toast/toast.dart';

class ModelCard extends StatefulWidget {
  ModelCard(
      {Key? key,
      required this.setNumber,
      required this.partsList,
      required this.isExpanded,
        required this.canDelete})
      : super(key: key);
  final String setNumber;
  final List<String> partsList;
  late bool isExpanded;
  final bool canDelete;

  @override
  State<ModelCard> createState() => _ModelCardState();
}

class _ModelCardState extends State<ModelCard> {
  bool clickToChangeState = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onLongPress: () async {
              bool result = await
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(widget.canDelete ? "删除乐高模块" : "保存乐高模块"),
                      content: Text(widget.canDelete ? "确认要从本地删除当前乐高模块？" : "确认要保存当前乐高模块到本地？"),
                      actionsAlignment: MainAxisAlignment.spaceEvenly,
                      actions: [
                        ElevatedButton(onPressed: (){
                          Navigator.of(context).pop(true);
                        }, child: const Text("确认")),
                        ElevatedButton(onPressed: (){
                          Navigator.of(context).pop(false);
                        }, child: const Text("取消")),
                      ],
                    );
                  });
              if (result) {
                if (widget.canDelete) {
                  removeSetNumberAndPartsFromLocal(widget.setNumber);
                } else {
                  saveSetNumberAndPartsToLocal(widget.setNumber, widget.partsList);
                }
              }
            },
            child: Container(
              color: Colors.grey[200],
              child: ListTile(
                title: Text("LEGO Set : " + widget.setNumber),
                trailing: IconButton(
                  icon: Icon(widget.isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      size: 30),
                  onPressed: () {
                    setState(() {
                      widget.isExpanded = !widget.isExpanded;
                    });
                  },
                ),
              ),
            ),
          ),
          widget.isExpanded ?
          ListView.builder(
              physics: const ClampingScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.partsList.length,
              itemBuilder: (context, index) {
                return PartCard(partNum: widget.partsList[index]);
          }) : const SizedBox()
        ],
      ),
    );
  }
}
