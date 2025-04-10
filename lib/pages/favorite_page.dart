import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:food/dessert.dart';
import 'package:food/restaurant.dart';
import 'package:http/http.dart' as http;

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<dynamic> favorite = []; // รายการที่ผู้ใช้เพิ่มในรายการโปรด

  Future<void> fetchData() async {
    try {
      // ดึงข้อมูล favorite
      var response = await http.get(Uri.parse('http://10.0.2.2:3000/favorite'));
      if (response.statusCode == 200) {
        String foodBody = utf8.decode(response.bodyBytes);
        List<dynamic> jsonList = jsonDecode(foodBody);
        setState(() {
          favorite = jsonList;
        });
      } else {
        throw Exception("Failed to load products");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteFromFavorites(String id) async {
    try {
      // ลบรายการโปรด
      var response = await http.delete(
        Uri.parse('http://10.0.2.2:3000/favorite/$id'),
      );
      if (response.statusCode == 200) {
        setState(() {
          favorite.removeWhere((item) => item['id'] == id);
        });
      } else {
        throw Exception('Failed to delete favorite');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
   // เมื่อคลิกที่รายการโปรด จะนำไปยังหน้ารายละเอียดตาม category
  void navigateToPage(dynamic restaurant) {
    if (restaurant['category'] == 'savoryfood') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RestaurantPage(restaurantData: restaurant),
        ),
      );
    } else if (restaurant['category'] == 'dessert') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DessertPage(dessertData: restaurant),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายการโปรด', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body:
          favorite.isEmpty
              ? Center(
                child: Text(
                  'โปรดเลือกร้านอาหารที่ชอบ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              )
              : ListView.builder(
                itemCount: favorite.length,
                itemBuilder: (context, index) {
                  var restaurant = favorite[index];
                  return Dismissible(
                    key: Key(restaurant['id'].toString()), // key สำหรับลบรายการ
                    direction: DismissDirection.endToStart, // ปัดจากขวาไปซ้าย
                    onDismissed: (direction) {
                      deleteFromFavorites(restaurant['id']); // ลบรายการเมื่อปัด
                    },
                    background: Container(
                      color: Colors.red,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        navigateToPage(restaurant); // ไปยังหน้ารายละเอียด
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 15,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              // รูปภาพร้านอาหารหรือร้านขนมหวาน
                              Container(
                                height: 80,
                                width: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: NetworkImage(restaurant['image']),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(width: 20),
                              // ชื่อร้าน
                              Expanded(
                                child: Text(
                                  restaurant['name'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
