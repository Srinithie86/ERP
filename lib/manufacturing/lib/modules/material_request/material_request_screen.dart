import 'package:flutter/material.dart';
import 'pages/material_request_list_page.dart';

class MaterialRequestScreen extends StatelessWidget {
  final bool showBack;
  const MaterialRequestScreen({super.key, this.showBack = false});

  @override
  Widget build(BuildContext context) {
    return MaterialRequestListPage(showBack: showBack);
  }
}