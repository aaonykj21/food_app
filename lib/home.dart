import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/favorite_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0; // ตัวแปรเก็บ index ของหน้าที่ถูกเลือก

  //เก็บหน้า Page เป็น List
  static final List<Widget> _pages = <Widget>[HomePage(), FavoritePage()];

  //ฟังก์ชันเปลี่ยนหน้า
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], //แสดงหน้าปัจจุบันตาม index ที่เลือกไว้

      // BottomNavigationBar ด้านล่างของหน้าจอ
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,

        // ปุ่มใน bottom navigation
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorite",
          ),
        ],
      ),
    );
  }
}
