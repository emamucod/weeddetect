import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Logo/Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF5D6253).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.eco,
                size: 60,
                color: Color(0xFF5D6253),
              ),
            ),
            const SizedBox(height: 20),
            
            // App Name
            const Text(
              "Weed Detection App",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Color(0xFF5D6253),
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Version
            const Text(
              "Version 1.0.0",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // About Description
            const Text(
              "The Weed Detection App helps farmers and agricultural professionals identify and manage weeds in their fields using advanced image recognition technology.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Features Section
            _buildSectionTitle("Key Features"),
            const SizedBox(height: 15),
            _buildFeatureItem(Icons.camera_alt, "Real-time Weed Detection"),
            _buildFeatureItem(Icons.agriculture, "Crop-Specific Weed Identification"),
            _buildFeatureItem(Icons.lightbulb, "Management Tips"),
            
            const SizedBox(height: 30),
            
            // Developer Info
            _buildSectionTitle("Development Team"),
            const SizedBox(height: 15),
            _buildTeamMember("assets/images/dev3.png", "Edrian Josef Mamucod", "Back End Developer"),
            _buildTeamMember("assets/images/dev2.png", "Jermaine Pau Malveda", "AI Specialist"),
            _buildTeamMember("assets/images/dev1.png", "Phillippe James Catubig", "Front End Developer"),
            
            const SizedBox(height: 30),
            
            // Contact Info
            _buildSectionTitle("Contact Us"),
            const SizedBox(height: 15),
            _buildContactItem(Icons.email, "cpc0103@dlsud.edu.ph"),
            _buildContactItem(Icons.phone, "+93 960 253 6855"),
            _buildContactItem(Icons.location_on, "De La Salle University - Dasmarinas"),
            
            const SizedBox(height: 30),
            
            // Copyright
            const Text(
              "© 2023 Weed Detection App. All rights reserved.",
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
        color: Color(0xFF5D6253),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF5D6253)),
          const SizedBox(width: 15),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMember(String imagePath, String name, String role) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFF5D6253).withOpacity(0.1),
            // You would typically use an image here
            child: Text(
              name.split(' ').map((n) => n[0]).join(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5D6253),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            role,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF5D6253)),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}