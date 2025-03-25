import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tflite;
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'weed_details.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _image;
  final picker = ImagePicker();
  Map<int, String> weedLabels = {};
  tflite.Interpreter? _interpreter;

  @override
  void initState() {
    super.initState();
    loadModel();
    loadLabels();
  }

  Future<void> loadModel() async {
    try {
      _interpreter = await tflite.Interpreter.fromAsset("assets/10weed_model.tflite");
      print("Model loaded successfully");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  Future<void> loadLabels() async {
    try {
      String jsonString = await rootBundle.loadString('assets/label_maptry.json');
      Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      setState(() {
        weedLabels = jsonMap.map((key, value) => MapEntry(value as int, key));
      });
      print("Labels loaded: $weedLabels");
    } catch (e) {
      print("Error loading labels: $e");
    }
  }

  Future<Float32List> preprocessImage(File imageFile) async {
    img.Image imageInput = img.decodeImage(await imageFile.readAsBytes())!;
    img.Image resizedImage = img.copyResize(imageInput, width: 224, height: 224);

    var input = List.generate(1, (i) => List.generate(224, (y) => List.generate(224, (x) {
      var pixel = resizedImage.getPixelSafe(x, y);
      return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
    })));

    var flattenedInput = input.expand((i) => i.expand((y) => y)).expand((x) => x).toList();
    return Float32List.fromList(flattenedInput);
  }

  Future<void> classifyImage(File image) async {
    if (_interpreter == null) return;

    Float32List input = await preprocessImage(image);
    var inputTensor = input.buffer.asFloat32List().reshape([1, 224, 224, 3]);
    var outputTensor = List.filled(1 * 10, 0.0).reshape([1, 10]);

    _interpreter!.run(inputTensor, outputTensor);

    List<double> outputProbabilities = List<double>.from(outputTensor[0]);
    print("Output Probabilities: $outputProbabilities");

    int predictedIndex = outputProbabilities.indexOf(outputProbabilities.reduce((a, b) => a > b ? a : b));
    String weedName = weedLabels[predictedIndex] ?? "Unknown Weed";

    String height = "";
    String dangerLevel = "";
    String treatable = "";
    List<String> treatmentInfo = [];

    switch (weedName) {
      case "Actual Cyperus Rotundus":
        height = "1.5 ft";
        dangerLevel = "7/10";
        treatable = "Yes";
        treatmentInfo = [
          "Use selective herbicides such as Halosulfuron.",
          "Improve soil drainage to prevent spread.",
          "Regularly remove manually to control infestation.",
        ];
        break;

      case "Actual Cypherus Difformis":
        height = "2 ft";
        dangerLevel = "8/10";
        treatable = "Yes";
        treatmentInfo = [
          "Use herbicide X for effective control.",
          "Remove manually if the infestation is small.",
          "Avoid overwatering to prevent growth.",
        ];
        break;

      case "Actual Cypherus Iria":
        height = "2.5 ft";
        dangerLevel = "6/10";
        treatable = "Yes";
        treatmentInfo = [
          "Apply herbicide combinations containing Bensulfuron.",
          "Control with mulching in non-crop areas.",
          "Ensure proper field drainage to reduce growth.",
        ];
        break;

      case "Actual Echinocloa Glabrescens":
        height = "3 ft";
        dangerLevel = "8/10";
        treatable = "Yes";
        treatmentInfo = [
          "Apply post-emergence herbicides such as Fenoxaprop-P.",
          "Use water management strategies to suppress growth.",
          "Hand weeding is effective in small infestations.",
        ];
        break;

      case "Actual Pistia_Stratiotes":
        height = "1 ft";
        dangerLevel = "7/10";
        treatable = "Yes";
        treatmentInfo = [
          "Apply herbicide Y to control Pistia.",
          "Use biological control methods like weevils.",
          "Regularly clean water bodies to prevent spread.",
        ];
        break;

      case "Actual Sphecnoclea_Zeynalica":
        height = "3 ft";
        dangerLevel = "9/10";
        treatable = "No";
        treatmentInfo = [
          "This weed is highly resistant to herbicides.",
          "Manual removal is the only effective method.",
          "Prevent spread by isolating affected areas.",
        ];
        break;

      case "Actual_Echinocloa_Crusgalli":
        height = "4 ft";
        dangerLevel = "6/10";
        treatable = "Yes";
        treatmentInfo = [
          "Use herbicide Z for effective control.",
          "Rotate crops to prevent recurrence.",
          "Ensure proper drainage to reduce growth.",
        ];
        break;

      case "Actual_Fimbristylis littoralis":
        height = "1.5 ft";
        dangerLevel = "5/10";
        treatable = "Yes";
        treatmentInfo = [
          "Apply herbicide A for quick results.",
          "Use mulch to suppress growth.",
          "Regularly monitor for new infestations.",
        ];
        break;

      case "Actual_Leptochloa Chinesis":
        height = "2.5 ft";
        dangerLevel = "7/10";
        treatable = "Yes";
        treatmentInfo = [
          "Use pre-emergence herbicides for control.",
          "Maintain proper field water levels to suppress growth.",
          "Hand weeding is effective in small areas.",
        ];
        break;

      case "Actual_Ludwigia Octalvis":
        height = "3 ft";
        dangerLevel = "6/10";
        treatable = "Yes";
        treatmentInfo = [
          "Use herbicide B for targeted control.",
          "Manual removal is effective if done early.",
          "Prevent spread by cutting off flowering parts.",
        ];
        break;

      default:
        height = "Unknown";
        dangerLevel = "Unknown";
        treatable = "Unknown";
        treatmentInfo = ["No specific treatment available for this weed."];
        break;
    }



    // Navigate to WeedDetailsScreen with the weed details and image
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WeedDetailsScreen(
          weedName: weedName,
          height: height,
          dangerLevel: dangerLevel,
          treatable: treatable,
          treatmentInfo: treatmentInfo,
          image: _image, // Pass the image file to the WeedDetailsScreen
        ),
      ),
    );
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() => _image = imageFile);
      classifyImage(imageFile);
    }
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Match modern white background
      body: SafeArea(
        child: Column(
          children: [
            /// Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      print('Returning to Dashboard');
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back_ios_new, color: Colors.black),
                  ),
                  Spacer(),
                  Text("Camera", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Spacer(),
                  SizedBox(width: 24), // For balance with back icon
                ],
              ),
            ),

            /// Small Image Preview Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      )
                    : Center(
                        child: Text(
                          "No Image Selected",
                          style: TextStyle(color: Colors.black54, fontSize: 16),
                        ),
                      ),
              ),
            ),

            /// Spacer to push controls at bottom
            Spacer(),

            /// Bottom Controls
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0, left: 24.0, right: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Gallery Icon
                  GestureDetector(
                    onTap: () => pickImage(ImageSource.gallery),
                    child: Icon(Icons.photo_library_rounded, color: Colors.black, size: 35),
                  ),

                  /// Camera Button
                  GestureDetector(
                    onTap: () => pickImage(ImageSource.camera),
                    child: Container(
                      padding: EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 30),
                    ),
                  ),

                  /// Spacer / Future button (like flash)
                  SizedBox(width: 35), // Empty space or replace with flash/settings icon
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
