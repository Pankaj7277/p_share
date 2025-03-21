import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:p_share/final_preview.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:path_provider/path_provider.dart';

class SelectedAndPreview extends StatefulWidget {
  final AssetEntity? selectedImage;
  final File? capturedImage;

  const SelectedAndPreview({this.selectedImage, this.capturedImage, super.key});

  @override
  State<SelectedAndPreview> createState() => _SelectedAndPreviewState();
}

class _SelectedAndPreviewState extends State<SelectedAndPreview> {
  Color selectedFilter = Colors.transparent;
  bool isSelected = false;
  List<Color> colorsList = [
    Colors.purpleAccent.withOpacity(0.25),
    Colors.purple.withOpacity(0.75),
    Colors.blue.withOpacity(0.35),
    Colors.green.withOpacity(0.35),
  ];

  final GlobalKey _globalKey = GlobalKey(); // Key to capture the widget

  // Function to capture and save the widget as an image
  Future<File?> _captureFilteredImage() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save image to temporary directory
      final directory = await getTemporaryDirectory();
      File imgFile = File('${directory.path}/filtered_image.png');
      await imgFile.writeAsBytes(pngBytes);

      return imgFile;
    } catch (e) {
      print("Error capturing image: $e");
      return null;
    }
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
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
            )),
        title: const Text(
          "New Post",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      RepaintBoundary(
                        // Wrap with RepaintBoundary
                        key: _globalKey,
                        child: Stack(
                          children: [
                            Container(
                              height: 500,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20)),
                              child: widget.capturedImage != null
                                  ? Image.file(
                                      widget.capturedImage!,
                                      width: double.infinity,
                                      height: 220,
                                      fit: BoxFit.cover,
                                    )
                                  : widget.selectedImage != null
                                      ? FutureBuilder(
                                          future: widget.selectedImage!.file,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                    ConnectionState.done &&
                                                snapshot.hasData) {
                                              return Image.file(snapshot.data!,
                                                  width: double.infinity,
                                                  height: 220,
                                                  fit: BoxFit.cover);
                                            }
                                            return const SizedBox(
                                                height: 220,
                                                child: Center(
                                                    child:
                                                        CircularProgressIndicator()));
                                          },
                                        )
                                      : Container(
                                          height: 220, color: Colors.grey[300]),
                            ),
                            Container(
                              height: 500,
                              color: selectedFilter, // Apply filter overlay
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      SizedBox(
                        height: 150,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount:
                              colorsList.length + 1, // +1 for the profile icon
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Colors
                                              .purpleAccent, // Change as needed
                                          child: Icon(Icons.music_video_rounded,
                                              size: 30, color: Colors.white),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text("Browse")
                                      ],
                                    )),
                              );
                            } else {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedFilter = colorsList[index - 1];
                                    isSelected = true;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: selectedFilter ==
                                                    colorsList[index - 1]
                                                ? colorsList[index - 1]
                                                    .withOpacity(.50)
                                                : Colors.transparent,
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 30,
                                          backgroundColor:
                                              colorsList[index - 1],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text("Filter ${index}")
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                  ),
                  onPressed: () async {
                    File? filteredImage = await _captureFilteredImage();
                    if (filteredImage != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FinalPreview(filteredImage: filteredImage),
                        ),
                      );
                    }
                  },
                  child: const Text("Start"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
