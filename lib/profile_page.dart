import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Bagian Foto Profil
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red.withOpacity(0.2), width: 4),
                      image: const DecorationImage(
                        image: NetworkImage('https://via.placeholder.com/150'), // Ganti dengan image budi
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Change Photo",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 40),

            // Form Input
            _buildInputField("Full Name", "Budi Setiawan", Icons.person_outline),
            const SizedBox(height: 20),
            _buildInputField("Email Address", "budi.warung@example.com", Icons.email_outlined),
            const SizedBox(height: 20),
            _buildInputField("Phone Number", "+62 812 3456 7890", Icons.phone_android_outlined),
            
            const SizedBox(height: 40),
            
            // Tombol Simpan
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                // Logika simpan data
                Navigator.pop(context);
              },
              icon: const Icon(Icons.save_outlined, color: Colors.white),
              label: const Text(
                "Save Changes",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: value),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.red.withOpacity(0.7)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}