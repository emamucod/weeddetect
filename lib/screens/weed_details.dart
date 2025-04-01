import 'dart:io';
import 'package:flutter/material.dart';

class WeedDetailsScreen extends StatelessWidget {
  final String weedName;
  final String height;
  final String dangerLevel;
  final String treatable;
  final List<String> treatmentInfo;
  final File? image;

  const WeedDetailsScreen({
    super.key,
    required this.weedName,
    required this.height,
    required this.dangerLevel,  
    required this.treatable,
    required this.treatmentInfo,
    this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weed Information',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins', color: Colors.white),
        ),
        backgroundColor: const Color(0xFF5D6253), // Custom color for AppBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(image!, height: 500, width: double.infinity, fit: BoxFit.cover),
              ),
            const SizedBox(height: 20),

            // Weed Type and Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF26129), // Orange background
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    weedName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Colors.white,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.amber, size: 20),
                    const SizedBox(width: 5),
                    Text(
                      dangerLevel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Weed Threats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoCard("Height", height),
                _buildInfoCard("Danger", dangerLevel),
                _buildInfoCard("Treatable", treatable),
              ],
            ),
            const SizedBox(height: 20),

            // Weed Description
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: treatmentInfo.map((treatment) => Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    "- $treatment",
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      color: Colors.black,
                    ),
                  ),
                )).toList(),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}