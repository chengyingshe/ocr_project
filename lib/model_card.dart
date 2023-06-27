import 'package:flutter/material.dart';
import 'package:ocr_project/part_card.dart';
import 'package:ocr_project/local_db_management.dart';

class ModelCard extends StatefulWidget {
  ModelCard(
      {Key? key,
      required this.setNumber,
      required this.itemNoList,
      required this.isExpanded,
      required this.canDelete,
      required this.colorCodeList})
      : super(key: key);
  final String setNumber;
  final List<String> itemNoList;
  final List<String> colorCodeList;
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
                  removeSetNumAndPartsFromLocal(widget.setNumber);
                } else {
                  saveSetNumAndPartsToLocal(widget.setNumber, widget.itemNoList, widget.colorCodeList);
                }
              }
            },
            child: Container(
              color: Colors.grey[200],
              child: ListTile(
                title: Text("套装编号 : ${widget.setNumber}"),
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
              itemCount: widget.itemNoList.length,
              itemBuilder: (context, index) {
                return PartCard(itemNo: widget.itemNoList[index],
                    colorCode: widget.colorCodeList[index], partIndex: index + 1,);
          }) : const SizedBox()
        ],
      ),
    );
  }
}
