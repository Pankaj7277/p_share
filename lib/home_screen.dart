import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> savedImages = [];

  @override
  void initState() {
    super.initState();
    _loadSavedImages();
  }

  // Load all saved image paths from SharedPreferences
  Future<void> _loadSavedImages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savedImages = prefs.getStringList('saved_images') ?? [];
    });
  }

  // Clear all saved images (optional button for testing)
  Future<void> _clearSavedImages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_images');
    setState(() {
      savedImages = [];
    });
  }

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: null,
        title: const Text(
          "Home",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: ListView.builder(
          itemCount: savedImages.length,
          // reverse: true,
          itemBuilder: (context, index) {
            return Column(
              children: [
                const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.purpleAccent,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          backgroundImage: AssetImage("assets/user.png"),
                        ),
                      ),
                    ),
                    Text(
                      "John Carter",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                    )
                  ],
                ),
                Image.file(
                  File(savedImages[index]),
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: savedImages.asMap().entries.map((entry) {
                      return Container(
                        width: _currentIndex == entry.key ? 30 : 10,
                        height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: _currentIndex == entry.key
                              ? Colors.purpleAccent
                              : Colors.grey,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Text("11 hours ago", style: TextStyle(color: Colors.grey))
                    ],
                  ),
                ),
               const  SizedBox(height: 10,)
              ],
            );
          }),
    );
  }
}
