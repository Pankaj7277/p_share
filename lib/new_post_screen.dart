import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:p_share/selected_and_preview.dart';
import 'package:photo_manager/photo_manager.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  List<String> dropdownItems = ['Recent', 'Photos', 'Videos'];

  List<AssetEntity> _mediaList = [];
  AssetEntity? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadGallery();
  }

//load gallery data
  Future<void> _loadGallery() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    print("permit ${ps.isAuth}");

    if (ps.isAuth) {
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image, // Only fetch images
      );

      if (albums.isNotEmpty) {
        List<AssetEntity> media =
            await albums[0].getAssetListPaged(page: 0, size: 50);
        setState(() {
          _mediaList = media;
          if (_mediaList.isNotEmpty) {
            _selectedImage = _mediaList.first;
          }
        });
      }
    }
  }

//pick image from camera
  void _pickFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      setState(() {
        _selectedImage = null; // Clear previous selection
      });

      File imageFile = File(photo.path);

      // Navigate to preview screen with the captured image
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SelectedAndPreview(capturedImage: imageFile),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print("taken.....${_selectedImage}");
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 35,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
            )),
        title: const Text(
          "New Post",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SelectedAndPreview(
                              selectedImage: _selectedImage,
                            )));
              },
              child: const Text(
                "Next",
                style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.purpleAccent,
                    fontSize: 16),
              ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Preview of selected image
            _selectedImage != null
                ? FutureBuilder(
                    future: _selectedImage!.file,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        return Image.file(snapshot.data!,
                            width: double.infinity,
                            height: 220,
                            fit: BoxFit.cover);
                      }
                      return const SizedBox(
                          height: 220,
                          child: Center(child: CircularProgressIndicator()));
                    },
                  )
                : Container(height: 220, color: Colors.grey[300]),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: 'Recent',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 18),
                    icon: const Icon(Icons.keyboard_arrow_down, size: 30),
                    items: dropdownItems.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            Text(value),
                            const SizedBox(
                                width: 10), // Space between text and arrow
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      print(newValue);
                    },
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                        onPressed: _loadGallery,
                        icon: const Icon(Icons.note_outlined)),
                    IconButton(
                        onPressed: _pickFromCamera,
                        icon: const Icon(Icons.camera_alt_outlined))
                  ],
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: Icon(Icons.photo_size_select_actual_outlined),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text("Recent")
                    ],
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: Icon(Icons.photo_library_outlined),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text("Photos")
                    ],
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.transparent,
                        child: Icon(Icons.camera_alt_outlined),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text("Videos")
                    ],
                  )
                ],
              ),
            ),
            // GridView for gallery images
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: _mediaList.length,
                itemBuilder: (context, index) {
                  return FutureBuilder<File?>(
                    future: _mediaList[index].file,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImage = _mediaList[index];
                            });
                          },
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Image.file(snapshot.data!, fit: BoxFit.cover),
                              if (_selectedImage == _mediaList[index])
                                Container(
                                  width: 20,
                                  height: 20,
                                  margin: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.purple,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "✔",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }
                      return Container(color: Colors.grey[300]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
