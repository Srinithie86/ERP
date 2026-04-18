import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double horizontalPadding = screenWidth * 0.05;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [Color(0xFF26A69A), Color(0xFF26A69A)],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Terms of Service",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(screenWidth),
              const SizedBox(height: 30),
              _buildSectionTitle("1. Acceptance of Terms"),
              _buildSectionContent(
                "By accessing and using the Purchase Management System, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to these terms, please do not use this service.",
              ),
              const SizedBox(height: 20),
              _buildSectionTitle("2. Use License"),
              _buildSectionContent(
                "Permission is granted to use the Purchase Management System for business procurement purposes within your organization. This license shall automatically terminate if you violate any of these restrictions.",
              ),
              const SizedBox(height: 20),
              _buildSectionTitle("3. User Responsibilities"),
              _buildSectionContent("As a user, you agree to:"),
              _buildBulletPoint("Provide accurate and complete information"),
              _buildBulletPoint(
                "Maintain the confidentiality of your account credentials",
              ),
              _buildBulletPoint(
                "Comply with all applicable laws and regulations",
              ),
              _buildBulletPoint(
                "Use the system only for legitimate business purposes",
              ),
              _buildBulletPoint(
                "Not attempt to gain unauthorized access to the system",
              ),
              const SizedBox(height: 20),
              _buildSectionTitle("4. Prohibited Activities"),
              _buildSectionContent("You may not use this service to:"),
              _buildBulletPoint(
                "Engage in any unlawful or fraudulent activities",
              ),
              _buildBulletPoint("Upload malicious code or viruses"),
              _buildBulletPoint("Interfere with the operation of the system"),
              _buildBulletPoint("Access data not intended for you"),
              _buildBulletPoint("Share your account with unauthorized users"),
              const SizedBox(height: 20),
              _buildSectionTitle("5. Data and Privacy"),
              _buildSectionContent(
                "Your use of the service is also governed by our Privacy Policy. Please review our Privacy Policy to understand how we collect, use, and protect your information.",
              ),
              const SizedBox(height: 20),
              _buildSectionTitle("6. Service Availability"),
              _buildSectionContent(
                "We strive to provide uninterrupted service but cannot guarantee 100% uptime. We reserve the right to modify, suspend, or discontinue the service at any time with or without notice.",
              ),
              const SizedBox(height: 20),
              _buildSectionTitle("7. Intellectual Property"),
              _buildSectionContent(
                "All content, features, and functionality of the Purchase Management System are owned by us and are protected by international copyright, trademark, and other intellectual property laws.",
              ),
              const SizedBox(height: 20),
              _buildSectionTitle("8. Contact Information"),
              _buildSectionContent(
                "For questions about these Terms of Service, please contact us at:",
              ),
              const SizedBox(height: 15),
              _buildContactBox(screenWidth),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(double width) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xffF0EEFF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Color(0xFF26A69A),
              size: 40,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "Terms of Service",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Last updated: March 10, 2024",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.5),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactBox(double width) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xffF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContactItem("Email:", "privacy@purchasemanagement.com"),
          const SizedBox(height: 12),
          _buildContactItem("Phone:", "+91 1800-123-4567"),
          const SizedBox(height: 12),
          _buildContactItem(
            "Address:",
            "123 Business Park, Corporate District, Mumbai, India-400001",
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }
}

