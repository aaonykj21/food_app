import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class RestaurantPage extends StatefulWidget {
  final dynamic restaurantData;

  const RestaurantPage({Key? key, required this.restaurantData})
    : super(key: key);

  @override
  _RestaurantPageState createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  List<dynamic> savoryfood = [];
  bool isFavorite = false;

  Future<void> fetchData() async {
    try {
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
        throw Exception("Failed to load savoryfood");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> addToFavorites() async {
    final favoriteData = {
      'name': widget.restaurantData['name'],
      'image': widget.restaurantData['image'],
      'description': widget.restaurantData['description'],
      'open': widget.restaurantData['open'],
      'address': widget.restaurantData['address'],
      'category': 'savoryfood',
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
          (item) => item['name'] == widget.restaurantData['name'],
        );
        setState(() {
          isFavorite = exists;
        });
      }
    } catch (e) {
      print("Error checking favorite: $e");
    }
  }

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
    checkIfFavorite();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.restaurantData['name'],
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
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: NetworkImage(widget.restaurantData['image']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              widget.restaurantData['description'],
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'เวลาเปิดทำการ : ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Expanded(
                  child: Text(
                    widget.restaurantData['open'],
                    style: TextStyle(fontSize: 16),
                    softWrap: true,
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),
             Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'พิกัด : ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _launchURL(widget.restaurantData['address']),
                    child: Text(
                      widget.restaurantData['address'],
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
