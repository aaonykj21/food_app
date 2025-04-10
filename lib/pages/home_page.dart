import 'dart:async';
import 'dart:convert';
import 'package:food/dessert.dart';
import 'package:food/restaurant.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _controller = PageController();  // ควบคุม PageView(รูปภาพด้านบน)
  final PageController _savoryPageController = PageController(); // ควบคุม PageView ของร้านอาหาร
  final PageController _dessertPageController = PageController(); // ควบคุม PageView ของร้านขนมหวาน
  int _currentIndex = 0; // เก็บ index ของ Page ปัจจุบัน
  List<dynamic> savoryfood = []; // เก็บข้อมูลร้านอาหารจาก API
  List<dynamic> dessert = []; // เก็บข้อมูลร้านขนมหวานจาก API

  Future<void> fetchData() async {
    try {
      // ดึงข้อมูลร้านอาหาร
      var response = await http.get(
        Uri.parse('http://10.0.2.2:3000/savoryfood'),
      );
      if (response.statusCode == 200) {
        String foodBody = utf8.decode(response.bodyBytes);
        List<dynamic> jsonList = jsonDecode(foodBody);
        setState(() {
          savoryfood = jsonList;
        });
      } else {
        throw Exception("Failed to load products");
      }
      // ดึงข้อมูลร้านขนมหวาน
      var dessertResponse = await http.get(
        Uri.parse('http://10.0.2.2:3000/dessert'),
      );
      if (dessertResponse.statusCode == 200) {
        String dessertBody = utf8.decode(dessertResponse.bodyBytes);
        List<dynamic> dessertList = jsonDecode(dessertBody);
        setState(() {
          dessert = dessertList;
        });
      } else {
        throw Exception("Failed to load dessert");
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData(); // ดึงข้อมูลเมื่อเปิดหน้า
    _startAutoSlider(); // เริ่มสไลด์รูปภาพอัตโนมัติ
  }
  // ฟังก์ชันเปลี่ยนรูปภาพใน PageView(ด้านบน)
  void _startAutoSlider() {
    Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_controller.hasClients) {
        if (_currentIndex < 2) {
          _controller.nextPage(
            duration: Duration(seconds: 1),
            curve: Curves.easeInOut,
          );
        } else {
          _controller.jumpToPage(0);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("บรรทัดทอง", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          // รูปภาพถนนบรรทัดทองที่สามารถเลื่อนอัตโนมัติได้
          Align(
            child: Container(
              height: 250,
              width: 400,
              margin: EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: PageView(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage('assets/bun1.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage('assets/bun2.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage('assets/bun3.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Restaurant',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // TabBar เปลี่ยนหน้า(อาหาร กับ ขนมหวาน)
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: const [Tab(text: "อาหาร"), Tab(text: "ขนมหวาน")],
                    indicatorColor: Colors.red,
                    labelColor: Colors.red,
                    unselectedLabelColor: Colors.black,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // รายการร้านอาหารแต่ละร้าน
                        ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: savoryfood.length,
                          itemBuilder: (context, index) {
                            var savory = savoryfood[index];
                            return GestureDetector(
                              onTap: () { //เมื่อกดที่ร้านอาหารร้านไหนก็ตาม จะนำไปที่หน้ารายละเอียดของร้านอาหารนั้นๆ
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => RestaurantPage(
                                          restaurantData: savory,
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                height: 200,
                                width: 200,
                                margin: EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: const Color.fromARGB(
                                    255,
                                    227,
                                    226,
                                    226,
                                  ),
                                ),
                                child: PageView(
                                  scrollDirection: Axis.horizontal,
                                  controller: _savoryPageController,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentIndex = index;
                                    });
                                  },
                                  children: [
                                    Container(
                                      height: 150,
                                      width: 100,
                                      margin: EdgeInsets.all(15.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Stack(
                                        children: [
                                          // Image
                                          Container(
                                            height: 170,
                                            width: 200,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                  savory['image'],
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          // Text at the bottom
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 5.0,
                                              ),
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  savory['name'],
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        // รายการร้านขนมหวานแต่ละร้าน
                        ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: dessert.length,
                          itemBuilder: (context, index) {
                            var dessertfood = dessert[index];
                            return GestureDetector(
                              onTap: () { //เมื่อกดที่ร้านอาหารร้านไหนก็ตาม จะนำไปที่หน้ารายละเอียดของร้านอาหารนั้นๆ
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => DessertPage(
                                          dessertData: dessertfood,
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                height: 200,
                                width: 200,
                                margin: EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: const Color.fromARGB(
                                    255,
                                    227,
                                    226,
                                    226,
                                  ),
                                ),
                                child: PageView(
                                  scrollDirection: Axis.horizontal,
                                  controller: _dessertPageController,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentIndex = index;
                                    });
                                  },
                                  children: [
                                    Container(
                                      height: 150,
                                      width: 100,
                                      margin: EdgeInsets.all(15.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Stack(
                                        children: [
                                          // Image
                                          Container(
                                            height: 170,
                                            width: 200,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                  dessertfood['image'],
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          // Text at the bottom
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 5.0,
                                              ),
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  dessertfood['name'],
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
