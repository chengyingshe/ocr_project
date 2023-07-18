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
      required this.colorCodeList,
      required this.setImageUrl,
      required this.partImageUrlList})
      : super(key: key);
  final String setNumber;
  final List<String> itemNoList;
  final List<String> colorCodeList;
  late bool isExpanded;
  final bool canDelete;
  final String setImageUrl;
  final List<String> partImageUrlList;

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
                  saveSetNumAndPartsToLocal(
                      widget.setNumber,
                      widget.itemNoList,
                      widget.colorCodeList,
                      widget.setImageUrl,
                      widget.partImageUrlList);
                }
              }
            },
            child: Container(
              color: Colors.grey[200],
              child: ListTile(
                onTap: () {
                  setState(() {
                    widget.isExpanded = !widget.isExpanded;
                  });
                },
                leading: ShowImage(imageUrl: widget.setImageUrl),
                title: Text("套装编号 : ${widget.setNumber}"),
                trailing:  Icon(widget.isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      size: 30),
                ),
              ),
            ),
          widget.isExpanded ?
          ListView.builder(
              physics: const ClampingScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.itemNoList.length,
              itemBuilder: (context, index) {
                return PartCard(
                  itemNo: widget.itemNoList[index],
                  colorCode: widget.colorCodeList[index],
                  partIndex: index + 1,
                  partImageUrl: widget.partImageUrlList[index]);
          }) : const SizedBox()
        ],
      ),
    );
  }
}

class ShowImage extends StatelessWidget {
  const ShowImage({Key? key, required this.imageUrl}) : super(key: key);
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: imageUrl == '' ?
            Image.asset('images/no_image.png', width: 60, height: 60) :
            Image.network('http:$imageUrl', width: 60, height: 60),
    );
  }
}
