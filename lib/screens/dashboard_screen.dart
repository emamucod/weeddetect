import 'package:flutter/material.dart';
import 'camera_screen.dart'; // Assuming you have a CameraScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weed Detection App',
      theme: ThemeData(
        primaryColor: const Color(0xFF5D6253), // Custom color for the app
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: const Color(0xFF5D6253)),
        fontFamily: 'Poppins', // Set Poppins as the default font
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    HomeScreen(),
    CameraScreen(),
    const PlaceholderScreen(title: 'Profile Screen Coming Soon'),
    const PlaceholderScreen(title: 'About Screen Coming Soon'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // WEED in an orange container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF26129), // Orange background
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                "WEED",
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 4), // Space between "WEED" and "DETECTION"
            // DETECTION text
            const Text(
              "DETECTION",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF5D6253), // Custom color for AppBar
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF5D6253), // Custom color for selected icons
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: "Camera"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "About"),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome to App",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins', // Apply Poppins
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for weeds...',
                hintStyle: const TextStyle(fontFamily: 'Poppins'), // Apply Poppins
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Categories",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins', // Apply Poppins
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCategoryCard("Rice Fields", Icons.grass),
                _buildCategoryCard("Weed Types", Icons.eco),
                _buildCategoryCard("Detection", Icons.camera),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Recent Detections",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins', // Apply Poppins
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _buildDetectionCard("Weed Detected in Field A", "2 hours ago"),
                  _buildDetectionCard("Weed Detected in Field B", "5 hours ago"),
                  _buildDetectionCard("Weed Detected in Field C", "1 day ago"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String label, IconData icon) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFF5D6253).withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: const Color(0xFF5D6253)),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins', // Apply Poppins
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionCard(String title, String time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.warning, color: Colors.orange),
        title: Text(
          title,
          style: const TextStyle(fontFamily: 'Poppins'), // Apply Poppins
        ),
        subtitle: Text(
          time,
          style: const TextStyle(fontFamily: 'Poppins'), // Apply Poppins
        ),
        trailing: const Icon(Icons.arrow_forward),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins', // Apply Poppins
        ),
      ),
    );
  }
}

