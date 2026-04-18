import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          "Privacy Policy",
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
              _buildSectionTitle("1. Introduction"),
              _buildSectionContent(
                "Welcome to Purchase Management System. We are committed to protecting your personal information and your right to privacy. This Privacy Policy explains what information we collect, how we use it, and what rights you have in relation to it.",
              ),
              const SizedBox(height: 20),
              _buildSectionTitle("2. Information We Collect"),
              _buildSectionContent(
                "We collect personal information that you provide to us such as:",
              ),
              _buildBulletPoint("Name and contact information"),
              _buildBulletPoint("Employee ID and department details"),
              _buildBulletPoint("Purchase requisition and order information"),
              _buildBulletPoint("Authentication credentials"),
              _buildBulletPoint("Device and usage information"),
              const SizedBox(height: 20),
              _buildSectionTitle("3. How We Use Your Information"),
              _buildSectionContent("We use the information we collect to:"),
              _buildBulletPoint("Facilitate purchase request and order management"),
              _buildBulletPoint("Process approvals and workflows"),
              _buildBulletPoint("Send notifications about purchase activities"),
              _buildBulletPoint("Maintain security and prevent fraud"),
              _buildBulletPoint("Improve our services and user experience"),
              _buildBulletPoint("Comply with legal obligations"),
              const SizedBox(height: 20),
              _buildSectionTitle("4. Data Retention"),
              _buildSectionContent(
                "We retain your personal information for as long as necessary to fulfill the purposes outlined in this policy, unless a longer retention period is required by law or for legitimate business purposes.",
              ),
              const SizedBox(height: 20),
              _buildSectionTitle("5. Cookies and Tracking"),
              _buildSectionContent(
                "We use cookies and similar tracking technologies to track activity on our application and store certain information. You can instruct your browser to refuse all cookies or to indicate when a cookie is being sent.",
              ),
              const SizedBox(height: 20),
              _buildSectionTitle("6. Children's Privacy"),
              _buildSectionContent(
                "Our service is not intended for use by children under the age of 18. We do not knowingly collect personal information from children under 18.",
              ),
              const SizedBox(height: 20),
              _buildSectionTitle("7. Changes to This Policy"),
              _buildSectionContent(
                "We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the \"Last updated\" date.",
              ),
              const SizedBox(height: 20),
              _buildSectionTitle("8. Contact Us"),
              _buildSectionContent(
                "If you have any questions about this Privacy Policy, please contact us at:",
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
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              color: Color(0xffF0EEFF),
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
            "Privacy Policy",
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
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade800,
        height: 1.5,
      ),
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

