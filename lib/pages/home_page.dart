import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  List<dynamic> savoryfood = [];
  List<dynamic> dessert= [];

  Future<void> fetchData() async {
    try {
      var response = await http.get(Uri.parse('http://localhost:3000/savoryfood')); //ใช้ http.get() เพื่อเรียก API
      if (response.statusCode == 200) { //ถ้าสำเร็จ (statusCode == 200) → แปลง JSON เป็น List<dynamic>
        List<dynamic> jsonList = jsonDecode(response.body);
        setState(() { //ใช้ setState() เพื่ออัปเดต products และรีเฟรช UI
          savoryfood = jsonList;
        });
      } else {
        throw Exception("Failed to load products");
      }
    } catch (e) { //ถ้าเกิดข้อผิดพลาด → catch (e) จะจับ error และพิมพ์ออกมาใน console
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
            padding: EdgeInsets.symmetric(
              horizontal: 16.0,
            ),
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
                      Tab(text: "ของคาว 🍲"),
                      Tab(text: "ของหวาน 🍰"),
                    ],
                    indicatorColor: Colors.red,
                    labelColor: Colors.red,
                    unselectedLabelColor: Colors.black,
                  ),
                  // ListView.separated(
                  //   separatorBuilder: (BuildContext context, int index) => const Divider(),
                  //   itemCount: savoryfood.length,
                  //   itemBuilder: (context, index) {
                  //     var savory = savoryfood[index];

                  //     return ListTile(
                  //       title: Text(savory['name']),
                  //     );




                  //   },
                  // )
                  // TabBarView to show respective content
                  // Expanded(
                  //   child: TabBarView(
                  //     children: [
                  //       // Content for the first tab (อาหารคาว)
                  //       ListView.builder(
                  //         itemCount: 5,
                  //         itemBuilder: (context, index) {
                  //           return ListTile(
                  //             title: Text('ร้านอาหารคาว $index'),
                  //           );
                  //         },
                  //       ),
                  //       // Content for the second tab (ของหวาน)
                  //       ListView.builder(
                  //         itemCount: 5,
                  //         itemBuilder: (context, index) {
                  //           return ListTile(
                  //             title: Text('ร้านของหวาน $index'),
                  //           );
                  //         },
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
