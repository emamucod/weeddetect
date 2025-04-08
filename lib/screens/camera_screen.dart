import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tflite;
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'weed_details.dart';
import 'database_helper.dart';
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  final String userEmail; // Added

  const CameraScreen({super.key, required this.userEmail}); // Updated

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

  Future<void> _saveToDatabase(
    String weedName,
    String height,
    String dangerLevel,
    String treatable,
    List<String> treatmentInfo,
  ) async {
    try {
      final treatmentInfoString = treatmentInfo.join('; ');
      final imagePath = _image?.path;

      await DatabaseHelper.instance.insertWeed(
        {
          'name': weedName,
          'height': height,
          'danger_level': dangerLevel,
          'treatable': treatable,
          'treatment_info': treatmentInfoString,
          'image_path': imagePath,
        },
        widget.userEmail, // Pass the user email
      );

      print('Weed saved for user ${widget.userEmail}');
    } catch (e) {
      print('Database error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save data')));
    }
  }

  Future<void> _verifyDatabase() async {
    try {
      final path = await DatabaseHelper().getDatabasePath();
      debugPrint("### DATABASE PATH: $path ###");
      final file = File(path);
      debugPrint("### FILE EXISTS: ${await file.exists()} ###");
    } catch (e) {
      debugPrint("### ERROR: $e ###");
    }
  }

  // TEMPORARY DEBUG METHOD - REMOVE AFTER TESTING
  Future<void> _moveDbToExternal() async {
    try {
      // Get current database path (internal storage)
      final internalDb = await DatabaseHelper().getDatabasePath();
      final internalFile = File(internalDb);

      // Get external storage path
      final externalDir = await getExternalStorageDirectory();
      final externalDb = '${externalDir?.path}/weeds.db';

      // Copy the file
      await internalFile.copy(externalDb);

      print('### DATABASE COPIED TO EXTERNAL STORAGE ###');
      print('FROM: $internalDb');
      print('TO: $externalDb');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Database exported to Downloads/weeds.db')),
      );
    } catch (e) {
      print('### EXPORT ERROR: $e ###');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: ${e.toString()}')));
    }
  }

  Future<void> loadModel() async {
    try {
      _interpreter = await tflite.Interpreter.fromAsset(
        "assets/10weedwithpipelinetrial4.tflite",
      );
      print("Model loaded successfully");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  Future<void> loadLabels() async {
    try {
      String jsonString = await rootBundle.loadString(
        'assets/label_maptry4.json',
      );
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
    img.Image resizedImage = img.copyResize(
      imageInput,
      width: 224,
      height: 224,
    );

    var input = List.generate(
      1,
      (i) => List.generate(
        224,
        (y) => List.generate(224, (x) {
          var pixel = resizedImage.getPixelSafe(x, y);
          return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
        }),
      ),
    );

    var flattenedInput =
        input.expand((i) => i.expand((y) => y)).expand((x) => x).toList();
    return Float32List.fromList(flattenedInput);
  }

  Future<void> classifyImage(File image) async {
    if (_interpreter == null) return;

    Float32List input = await preprocessImage(image);
    var inputTensor = input.buffer.asFloat32List().reshape([1, 224, 224, 3]);
    var outputTensor = List.filled(1 * 10, 0.0).reshape([1, 10]);

    _interpreter!.run(inputTensor, outputTensor);

    List<double> outputProbabilities = List<double>.from(outputTensor[0]);
    // Add this block to print probabilities
    print("----- Model Output Probabilities -----");
    for (int i = 0; i < outputProbabilities.length; i++) {
      String label = weedLabels[i] ?? "Unknown";
      print(
        "${label.padRight(20)}: ${outputProbabilities[i].toStringAsFixed(4)}",
      );
    }
    print("-------------------------------------");

    int predictedIndex = outputProbabilities.indexOf(
      outputProbabilities.reduce((a, b) => a > b ? a : b),
    );
    String weedName = weedLabels[predictedIndex] ?? "Unknown Weed";

    String height = "";
    String dangerLevel = "";
    String treatable = "";
    List<String> treatmentInfo = [];

    switch (weedName) {
      case "Cyperus Rotundus":
        height = "1.5 ft";
        dangerLevel = "7/10";
        treatable = "Yes";
        treatmentInfo = [
          "Pre-emergence: Apply sulfentrazone (0.25-0.38 kg/ha) or oxyfluorfen (0.5-1.0 kg/ha)",
          "Post-emergence: Use halosulfuron-methyl (70 g/ha) or glyphosate (1.0-1.5 kg/ha) for non-crop areas",
          "Cultural: Deep plowing to expose tubers to sunlight, followed by repeated tillage",
          "Biological: Fusarium oxysporum fungus shows potential for biocontrol",
        ];
        break;

      case "Cyperus Difformis":
        height = "2 ft";
        dangerLevel = "8/10";
        treatable = "Yes";
        treatmentInfo = [
          "Pre-emergence: Apply pretilachlor (0.75 kg/ha) or butachlor (1.0 kg/ha) in rice fields",
          "Post-emergence: Use bispyribac-sodium (25 g/ha) or azimsulfuron (20 g/ha)",
          "Water management: Maintain 2-5 cm water depth for first 3 weeks after transplanting",
          "Rotation: Alternate rice with upland crops to disrupt life cycle",
        ];
        break;

      case "Cyperus Iria":
        height = "2.5 ft";
        dangerLevel = "6/10";
        treatable = "Yes";
        treatmentInfo = [
          "Herbicides: Apply bensulfuron-methyl (60 g/ha) or pyrazosulfuron-ethyl (20 g/ha)",
          "Mechanical: Hand weeding before flowering stage (30-40 days after emergence)",
          "Cultural: Use stale seedbed technique with shallow tillage",
          "Biological: Ducks in rice fields effectively consume young plants",
        ];
        break;

      case "Echinochloa Glabrescens":
        height = "3 ft";
        dangerLevel = "8/10";
        treatable = "Yes";
        treatmentInfo = [
          "Pre-emergence: Apply thiobencarb (1.5 kg/ha) or pendimethalin (1.0 kg/ha)",
          "Post-emergence: Use fenoxaprop-P-ethyl (120 g/ha) or cyhalofop-butyl (200 g/ha)",
          "Cultural: Use clean seeds and maintain proper water depth (5-10 cm)",
          "Rotation: Follow rice with soybean or maize to break cycle",
        ];
        break;

      case "Pistia stratiotes":
        height = "1 ft";
        dangerLevel = "7/10";
        treatable = "Yes";
        treatmentInfo = [
          "Chemical: Apply glyphosate (1.5-2.0 kg/ha) or diquat (2-4 kg/ha) to foliage",
          "Mechanical: Regular removal with nets or harvesters",
          "Biological: Neochetina weevils provide effective control (release 1000-2000 adults/ha)",
          "Prevention: Install barriers in irrigation channels",
        ];
        break;

      case "Sphenoclea zeylanica":
        height = "3 ft";
        dangerLevel = "9/10";
        treatable = "No";
        treatmentInfo = [
          "Resistant to most herbicides - requires integrated approach",
          "Mechanical: Hand pulling before seed set (wear gloves as sap may irritate)",
          "Cultural: Maintain dense crop canopy through proper spacing and fertilization",
          "Biological: Research ongoing with potential fungal pathogens",
        ];
        break;

      case "Echinochloa Crusgalli":
        height = "4 ft";
        dangerLevel = "6/10";
        treatable = "Yes";
        treatmentInfo = [
          "Pre-emergence: Apply pretilachlor (0.75 kg/ha) or oxadiazon (1.0 kg/ha)",
          "Post-emergence: Use quinclorac (0.5 kg/ha) or propanil (3.0 kg/ha)",
          "Cultural: Flood fields to 10-15 cm depth for 3-4 days after transplanting",
          "Biological: Rice-fish farming reduces infestation",
        ];
        break;

      case "Fimbristylis littoralis":
        height = "1.5 ft";
        dangerLevel = "5/10";
        treatable = "Yes";
        treatmentInfo = [
          "Herbicides: Apply 2,4-D (1.0 kg/ha) or metsulfuron-methyl (4 g/ha)",
          "Mechanical: Raking or harrowing in early growth stages",
          "Cultural: Improve drainage and avoid water stagnation",
          "Biological: No effective agents identified yet",
        ];
        break;

      case "Leptochloa chinensis":
        height = "2.5 ft";
        dangerLevel = "7/10";
        treatable = "Yes";
        treatmentInfo = [
          "Pre-emergence: Apply pendimethalin (1.0 kg/ha) or oxadiazon (1.0 kg/ha)",
          "Post-emergence: Use cyhalofop-butyl (200 g/ha) or fenoxaprop-P-ethyl (120 g/ha)",
          "Cultural: Use competitive rice varieties with early vigor",
          "Mechanical: Rogue out plants before flowering",
        ];
        break;

      case "Ludwigia octovalvis":
        height = "3 ft";
        dangerLevel = "6/10";
        treatable = "Yes";
        treatmentInfo = [
          "Chemical: Apply triclopyr (1.0 kg/ha) or glyphosate (2.0 kg/ha) to foliage",
          "Mechanical: Cutting below water surface to drown plants",
          "Cultural: Reduce nutrient runoff into water bodies",
          "Biological: Research ongoing with leaf-feeding beetles",
        ];
        break;

      default:
        height = "Unknown";
        dangerLevel = "Unknown";
        treatable = "Unknown";
        treatmentInfo = ["No specific treatment available for this weed."];
        break;
    }

    await _saveToDatabase(
      weedName,
      height,
      dangerLevel,
      treatable,
      treatmentInfo,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => WeedDetailsScreen(
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
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Camera",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins",
                    ),
                  ),
                ],
              ),
            ),

            /// Small Image Preview Card
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10,
              ),
              child: Container(
                height: 500,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child:
                    _image != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(_image!, fit: BoxFit.cover),
                        )
                        : Center(
                          child: Text(
                            "No Image Selected",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                        ),
              ),
            ),

            /// Spacer to push controls at bottom
            Spacer(),

            /// Bottom Controls
            Padding(
              padding: const EdgeInsets.only(
                bottom: 30.0,
                left: 24.0,
                right: 24.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Gallery Icon
                  GestureDetector(
                    onTap: () => pickImage(ImageSource.gallery),
                    child: Icon(
                      Icons.photo_library_rounded,
                      color: Colors.black,
                      size: 35,
                    ),
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
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),

                  /// Spacer / Future button (like flash)
                  SizedBox(
                    width: 35,
                  ), // Empty space or replace with flash/settings icon
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // Add this
        onPressed: _moveDbToExternal,
        child: Icon(Icons.file_download),
        tooltip: 'Export DB (Debug)',
      ),
    );
  }
}
