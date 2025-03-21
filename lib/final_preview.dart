import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:p_share/home_screen.dart';

class FinalPreview extends StatelessWidget {
  final File filteredImage;

  const FinalPreview({required this.filteredImage, super.key});

  // Function to save image to local storage
  Future<String> _saveImage(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final String newPath =
          '${directory.path}/filtered_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final savedImage = await imageFile.copy(newPath);
      return savedImage.path;
    } catch (e) {
      print("Error saving image: $e");
      return "";
    }
  }

  // Function to save image path list in SharedPreferences
  Future<void> _saveImagePathToPrefs(String imagePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> imagePaths = prefs.getStringList('saved_images') ?? []; // Get existing list
    imagePaths.add(imagePath); // Add new image path
    await prefs.setStringList('saved_images', imagePaths); // Save updated list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 35,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        title: const Text(
          "New Post",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  height: 400,
                    width: MediaQuery.of(context).size.width,
                    child: Image.file(filteredImage)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                ),
                onPressed: () async {
                  String savedImagePath = await _saveImage(filteredImage);
                  if (savedImagePath.isNotEmpty) {
                    await _saveImagePathToPrefs(savedImagePath); // Save path in SharedPreferences
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                          (route) => false, // This removes all previous routes from the stack
                    );
                  }
                },
                child: const Text("Share"),
              ),
            ),
          )
        ],
      ),
    );
  }
}
