import 'package:flutter/material.dart';

class PartCard extends StatelessWidget {
  const PartCard(
      {Key? key,
      required this.itemNo,
      required this.colorCode,
      required this.partIndex})
      : super(key: key);
  final String itemNo;
  final String colorCode;
  final int partIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text('Part $partIndex'),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 10, 15, 5),
                  child: Text("设计编号 : $itemNo",
                      style: const TextStyle(fontSize: 15),
                      overflow: TextOverflow.ellipsis),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5, 5, 15, 10),
                  child: Text("颜色编号 : $colorCode",
                      style: const TextStyle(fontSize: 15),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
