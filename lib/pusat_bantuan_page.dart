import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PusatBantuanPage extends StatelessWidget {
  const PusatBantuanPage({super.key});

  // Contact information
  static const String phoneNumber =
      '6281234567890'; // Update with your WhatsApp number
  static const String email = 'support@tokojual.com'; // Update with your email
  static const String whatsappMessage =
      'Halo, saya membutuhkan bantuan untuk toko saya.';

  Future<void> _openWhatsApp() async {
    final whatsappUrl =
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(whatsappMessage)}';
    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $whatsappUrl';
    }
  }

  Future<void> _openEmail() async {
    const emailUrl =
        'mailto:$email?subject=Bantuan%20Aplikasi%20Toko&body=Halo,%20saya%20membutuhkan%20bantuan.';
    if (await canLaunchUrl(Uri.parse(emailUrl))) {
      await launchUrl(Uri.parse(emailUrl));
    } else {
      throw 'Could not launch email';
    }
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Pusat Bantuan',
          style: TextStyle(
              color: Colors.red, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Support Card
            _buildSupportCard(context),
            const SizedBox(height: 30),

            // Contact Card
            _buildContactCard(),
            const SizedBox(height: 40),

            // Footer Section
            _buildFooterSection(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Masih butuh\nbantu an?',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Tim dukungan kami siap melayani Anda 24/7 untuk setiap pertanyaan atau kendala.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),

          // WhatsApp Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _openWhatsApp,
              icon: const Icon(Icons.chat, size: 20),
              label: const Text(
                'WhatsApp Kami',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Email Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _openEmail,
              icon: const Icon(Icons.email, size: 20),
              label: const Text(
                'Kirim Email',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white, width: 2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: NetworkImage(
              'https://via.placeholder.com/400x300?text=Support+Team'),
          fit: BoxFit.cover,
          opacity: 0.4,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(24),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SOVEREIGN OFFICE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Jakarta Selatan, Indonesia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterSection(BuildContext context) {
    return Column(
      children: [
        const Divider(color: Colors.grey),
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              const Text(
                'SOVEREIGN',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '© 2024 Sovereign Editorial. Hak Cipta Dilindungi.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFooterLink(
                    context,
                    'Syarat &\nKetentuan',
                    'https://example.com/terms',
                  ),
                  _buildFooterLink(
                    context,
                    'Kebijakan\nPrivasi',
                    'https://example.com/privacy',
                  ),
                  _buildFooterLink(
                    context,
                    'Panduan\nKomunitas',
                    'https://example.com/community',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooterLink(BuildContext context, String text, String url) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}
