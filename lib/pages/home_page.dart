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
  final PageController _controller = PageController();
  final PageController _savoryPageController = PageController();
  final PageController _dessertPageController = PageController();
  int _currentIndex = 0;
  List<dynamic> savoryfood = [];
  List<dynamic> dessert = [];

  Future<void> fetchData() async {
    try {
      var response = await http.get(
        Uri.parse('http://10.0.2.2:3000/savoryfood'),
      ); //ใช้ http.get() เพื่อเรียก API
      if (response.statusCode == 200) {
        //ถ้าสำเร็จ (statusCode == 200) → แปลง JSON เป็น List<dynamic>
        String foodBody = utf8.decode(response.bodyBytes);
        List<dynamic> jsonList = jsonDecode(foodBody);
        setState(() {
          //ใช้ setState() เพื่ออัปเดต products และรีเฟรช UI
          savoryfood = jsonList;
        });
      } else {
        throw Exception("Failed to load products");
      }
      var dessertResponse = await http.get(
        Uri.parse('http://10.0.2.2:3000/dessert'),
      );
      if (dessertResponse.statusCode == 200) {
        // ถ้าสำเร็จ (statusCode == 200) → แปลง JSON เป็น List<dynamic>
        String dessertBody = utf8.decode(dessertResponse.bodyBytes);
        List<dynamic> dessertList = jsonDecode(dessertBody);
        setState(() {
          dessert = dessertList; // อัปเดตข้อมูล dessert
        });
      } else {
        throw Exception("Failed to load dessert");
      }
    } catch (e) {
      //ถ้าเกิดข้อผิดพลาด → catch (e) จะจับ error และพิมพ์ออกมาใน console
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    _startAutoSlider();
  }

  void _startAutoSlider() {
    Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_controller.hasClients) {
        if (_currentIndex < 2) {
          _controller.nextPage(
            duration: Duration(seconds: 1),
            curve: Curves.easeInOut,
          );
        } else {
          _controller.jumpToPage(0); // ถ้าถึงหน้าสุดท้ายจะเริ่มใหม่
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
          Expanded(
            child: DefaultTabController(
              length: 2, // We have 2 tabs
              child: Column(
                children: [
                  // TabBar at the bottom of the screen
                  TabBar(
                    tabs: const [
                      Tab(text: "อาหารคาว 🍲"),
                      Tab(text: "อาหารหวาน 🍰"),
                    ],
                    indicatorColor: Colors.red,
                    labelColor: Colors.red,
                    unselectedLabelColor: Colors.black,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // First tab content (อาหารคาว)
                        ListView.builder(
                          scrollDirection: Axis.horizontal, // เลื่อนในแนวนอน
                          itemCount: savoryfood.length,
                          itemBuilder: (context, index) {
                            var savory = savoryfood[index];
                            return GestureDetector(
                              onTap: () {
                                // เมื่อกดคอนเทนเนอร์จะไปที่หน้าร้านอาหาร
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => RestaurantPage(
                                          restaurantData:
                                              savory, // ส่งข้อมูลร้านไปที่หน้าใหม่
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                height: 200, // กำหนดขนาดให้เหมาะสม
                                width: 200, // กำหนดขนาดให้เหมาะสม
                                margin: EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: const Color.fromARGB(255,227,226,226,),
                                ),
                                child: PageView(
                                  scrollDirection:
                                      Axis.horizontal, // เลื่อนในแนวนอน
                                  controller:
                                      _savoryPageController, // ใช้ controller สำหรับ savory
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentIndex = index;
                                    });
                                  },
                                  children: [
                                    Container(
                                      height: 150, // เพิ่มความสูงของ Container
                                      width: 100, // กำหนดความกว้าง
                                      margin: EdgeInsets.all(15.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Stack(
                                        children: [
                                          // Image
                                          Container(
                                            height: 170, // ขนาดของรูปภาพ
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
                                                alignment:
                                                    Alignment
                                                        .center, // จัดข้อความให้ตรงกลาง
                                                child: Text(
                                                  savory['name'], // ชื่อของอาหาร
                                                  style: TextStyle(
                                                    color:
                                                        Colors
                                                            .black, // สีของข้อความ
                                                    fontWeight:
                                                        FontWeight
                                                            .bold, // ตัวหนา
                                                    fontSize:
                                                        18, // ขนาดตัวอักษร
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
                        ListView.builder(
                          scrollDirection: Axis.horizontal, // เลื่อนในแนวนอน
                          itemCount: dessert.length,
                          itemBuilder: (context, index) {
                            var dessertfood = dessert[index];
                            return GestureDetector(
                              onTap: () {
                                // เมื่อกดคอนเทนเนอร์จะไปที่หน้าร้านอาหาร
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => DessertPage(
                                          dessertData:
                                              dessertfood, // ส่งข้อมูลร้านไปที่หน้าใหม่
                                        ),
                                  ),
                                );
                              },
                              child: Container(
                                height: 200, // กำหนดขนาดให้เหมาะสม
                                width: 200, // กำหนดขนาดให้เหมาะสม
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
                                  scrollDirection:
                                      Axis.horizontal, // เลื่อนในแนวนอน
                                  controller:
                                      _dessertPageController, // ใช้ controller สำหรับ savory
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentIndex = index;
                                    });
                                  },
                                  children: [
                                    Container(
                                      height: 150, // เพิ่มความสูงของ Container
                                      width: 100, // กำหนดความกว้าง
                                      margin: EdgeInsets.all(15.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Stack(
                                        children: [
                                          // Image
                                          Container(
                                            height: 170, // ขนาดของรูปภาพ
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
                                                alignment:
                                                    Alignment
                                                        .center, // จัดข้อความให้ตรงกลาง
                                                child: Text(
                                                  dessertfood['name'], // ชื่อของอาหาร
                                                  style: TextStyle(
                                                    color:
                                                        Colors
                                                            .black, // สีของข้อความ
                                                    fontWeight:
                                                        FontWeight
                                                            .bold, // ตัวหนา
                                                    fontSize:
                                                        18, // ขนาดตัวอักษร
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
