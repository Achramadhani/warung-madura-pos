import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'profile_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _storeNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  File? _selectedImage;
  String _currentImageUrl = 'https://via.placeholder.com/150';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final profile = await ProfileService.getProfile();
    setState(() {
      _nameController = TextEditingController(text: profile['name']);
      _storeNameController = TextEditingController(text: profile['storeName']);
      _emailController = TextEditingController(text: profile['email']);
      _phoneController = TextEditingController(text: profile['phone']);
      _currentImageUrl = profile['imagePath'] ?? 'https://via.placeholder.com/150';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _storeNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Pilih Sumber Gambar'),
          content: const Text('Dari mana Anda ingin mengambil gambar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: const Text('Kamera'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: const Text('Galeri'),
            ),
          ],
        ),
      );

      if (source == null) return;

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source, maxWidth: 1000, maxHeight: 1000);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan Email tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Simpan data ke shared preferences
      await ProfileService.saveProfile(
        name: _nameController.text,
        storeName: _storeNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        imagePath: _selectedImage?.path,
      );

      final updatedProfile = {
        'name': _nameController.text,
        'storeName': _storeNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'imagePath': _selectedImage?.path,
      };

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui!')),
      );

      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) {
        Navigator.pop(context, updatedProfile);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

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
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red.withOpacity(0.2), width: 4),
                        image: DecorationImage(
                          image: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : NetworkImage(_currentImageUrl) as ImageProvider,
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
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickImage,
              child: const Text(
                "Change Photo",
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 40),

            // Form Input
            _buildInputField("Full Name", _nameController, Icons.person_outline),
            const SizedBox(height: 20),
            _buildInputField("Store Name", _storeNameController, Icons.store_outlined),
            const SizedBox(height: 20),
            _buildInputField("Email Address", _emailController, Icons.email_outlined),
            const SizedBox(height: 20),
            _buildInputField("Phone Number", _phoneController, Icons.phone_android_outlined),
            
            const SizedBox(height: 40),
            
            // Tombol Simpan
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isSaving ? null : _saveProfile,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined, color: Colors.white),
              label: Text(
                _isSaving ? "Menyimpan..." : "Save Changes",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: !_isSaving,
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