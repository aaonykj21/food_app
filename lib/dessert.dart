import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DessertPage extends StatefulWidget {
  final dynamic dessertData;
  const DessertPage({Key? key, required this.dessertData}) : super(key: key);

  @override
  State<DessertPage> createState() => _DessertPageState();
}

class _DessertPageState extends State<DessertPage> {
  List<dynamic> dessert = [];

  Future<void> fetchData() async {
  try {
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
  Future<void> addToFavorites() async {
    final favoriteData = {
      'name': widget.dessertData['name'],
      'image': widget.dessertData['image'],
    };

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/favorite'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(favoriteData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
       ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'เพิ่มไปยังรายการโปรดเรียบร้อยแล้ว',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green, // สีพื้นหลังของ SnackBar
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating, // ให้ลอยจากขอบล่าง
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // เว้นขอบ SnackBar
      ),
    );
      } else {
        throw Exception('ไม่สามารถเพิ่มรายการโปรดได้');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด')));
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
        title: Text(widget.dessertData['name']),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // แสดงรูปภาพของร้าน
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: NetworkImage(widget.dessertData['image']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            // แสดงรายละเอียดของร้าน
            Text(
              widget.dessertData['description'],
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // ให้ข้อความขึ้นบรรทัดใหม่สวย ๆ
              children: [
                Text(
                  'เวลาเปิดทำการ : ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Expanded(
                  child: Text(
                    widget.dessertData['open'],
                    style: TextStyle(fontSize: 16),
                    softWrap: true, // ให้ตัดบรรทัดอัตโนมัติ
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // ให้ Text ชิดบน
              children: [
                Text(
                  'พิกัด : ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Expanded(
                  child: Text(
                    widget.dessertData['address'],
                    style: TextStyle(fontSize: 16),
                    softWrap: true, // ให้ตัดบรรทัดอัตโนมัติ
                  ),
                ),
              ],
            ),
            
            
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(255, 255, 255, 255),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: addToFavorites,
              icon: Icon(Icons.favorite, color: Colors.white),
              label: Text(
                'เพิ่มในรายการโปรด',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 12),
                
              ),
            ),
          ),
        ),
      ),
    );
  }
}