import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../../widgets/common_widgets.dart';

class BarcodeScreen extends StatelessWidget {
  final String barcodeData;
  final String label;

  const BarcodeScreen({
    super.key,
    required this.barcodeData,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WmsAppBar(
        title: 'Generated Barcode',
        screenType: ScreenType.viewOnly,
      ),
      body: Column(
        children: [
          const ViewOnlyBanner(),
          Expanded(
            child: Center(
              child: SectionCard(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: BarcodeWidget(
                        barcode: Barcode.code128(),
                        data: barcodeData,
                        width: 250,
                        height: 100,
                        drawText: true,
                        style: const TextStyle(fontSize: 16, letterSpacing: 2),
                      ),
                    ),
                    const SizedBox(height: 32),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.print),
                      label: const Text('Print Barcode'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Printing functionality not implemented')));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
