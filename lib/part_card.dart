import 'package:flutter/material.dart';

class PartCard extends StatelessWidget {
  const PartCard({Key? key, required this.partNum}) : super(key: key);
  final String partNum;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 0),
          ListTile(
            title: Text("Part : " + partNum),
          ),
        ],
      ),
    );
  }
}
