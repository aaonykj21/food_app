import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class DessertPage extends StatefulWidget {
  final dynamic dessertData; // รับข้อมูลร้านขนมหวานที่ส่งมาจากหน้าก่อนหน้า
  const DessertPage({Key? key, required this.dessertData}) : super(key: key);

  @override
  State<DessertPage> createState() => _DessertPageState();
}

class _DessertPageState extends State<DessertPage> {
  List<dynamic> dessert = []; // เก็บข้อมูลร้านขนมหวานจาก API
  bool isFavorite = false; // ใช้เช็คว่าร้านนี้อยู่ใน favorite แล้วหรือยัง

  Future<void> fetchData() async {
    try {
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
  // เพิ่มรายการร้านขนมหวานในรายการโปรด โดยการ POST
  Future<void> addToFavorites() async {
    final favoriteData = {
      'name': widget.dessertData['name'],
      'image': widget.dessertData['image'],
      'description': widget.dessertData['description'],
      'open': widget.dessertData['open'],
      'address': widget.dessertData['address'],
      'category': 'dessert',
    };

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/favorite'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(favoriteData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await checkIfFavorite();
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
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
  // ตรวจสอบว่าร้านนี้ถูกเพิ่มไปในรายการโปรดแล้วหรือยัง
  Future<void> checkIfFavorite() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/favorite'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> favoriteList = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        final exists = favoriteList.any(
          (item) => item['name'] == widget.dessertData['name'],
        );
        setState(() {
          isFavorite = exists;
        });
      }
    } catch (e) {
      print("Error checking favorite: $e");
    }
  }

  // ฟังก์ชันเปิดลิงก์ Google Map หรือเว็บไซต์
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'ไม่สามารถเปิดลิงก์ได้: $url';
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData(); 
    checkIfFavorite(); // เช็คว่าร้านนี้เป็นรายการโปรดมั้ย
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.dessertData['name'], //ชื่อร้านขนมหวาน
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // รูปภาพร้านขนมหวาน
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
            // รายละเอียดร้านขนมวาน
            Text(
              widget.dessertData['description'],
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            // เวลาที่ร้านเปิดทำการ
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'เวลาเปิดทำการ : ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Expanded(
                  child: Text(
                    widget.dessertData['open'],
                    style: TextStyle(fontSize: 16),
                    softWrap: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // ลิงก์ address ของร้านนั้นๆ
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'พิกัด : ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _launchURL(widget.dessertData['address']),
                    child: Text(
                      widget.dessertData['address'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      // ปุ่มเพิ่มไปในรายการโปรด(แต่ถ้าอยู่ในรายการโปรดแล้ว จะไม่ขึ้นให้กดเพิ่ม)
      bottomNavigationBar:
          isFavorite
              ? null
              : BottomAppBar(
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
