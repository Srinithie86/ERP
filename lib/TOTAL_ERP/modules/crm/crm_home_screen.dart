import 'package:flutter/material.dart';
import '../../../utils/widgets/dynamic_drawer.dart';

class CRMHomeScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const CRMHomeScreen({super.key, this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: const DynamicDrawer(moduleName: 'CRM'),
      appBar: AppBar(
        title: const Text('CRM'),
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded),
          onPressed: () => scaffoldKey?.currentState?.openDrawer(),
        ),
      ),
      body: const Center(
        child: Text(
          'CRM module landing screen',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

