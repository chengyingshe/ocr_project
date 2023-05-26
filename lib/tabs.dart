import 'package:flutter/material.dart';
import 'package:ocr_project/model_page.dart';
import 'package:ocr_project/search_page.dart';
import 'package:toast/toast.dart';

class Tab extends StatelessWidget {
  const Tab ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tabs();
  }
}


class Tabs extends StatefulWidget {
  const Tabs({Key? key}) : super(key: key);

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  DateTime? _lastPressedAt; //记录上次点击的时间
  int _currentIndex = 0;
  final List<Widget> _pagesList = [
    SearchPage(title: "本地检索", autoFocus: false),
    ModelPage()
  ];

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return WillPopScope(
      onWillPop: () async {
        if (_lastPressedAt == null ||
            DateTime.now().difference(_lastPressedAt!) >
                const Duration(seconds: 1)) {
          _lastPressedAt = DateTime.now();
          Toast.show('再按一次退出应用', gravity: Toast.bottom);
          return false; //两次连续点击时间间隔小于1s时不退出
        }
        return true;
      },
      child: Scaffold(
        body: _pagesList[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          unselectedItemColor: Colors.blueGrey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: '搜索',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              label: '我的',
            ),
          ],
        ),
      ),
    );
  }
}
