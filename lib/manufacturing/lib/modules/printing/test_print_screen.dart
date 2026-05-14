import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image/image.dart' as img;
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart' hide Barcode;
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/printer_service.dart';

class TestPrintScreen extends StatefulWidget {
  const TestPrintScreen({super.key});

  @override
  State<TestPrintScreen> createState() => _TestPrintScreenState();
}

class _TestPrintScreenState extends State<TestPrintScreen> {
  final PrinterService _printerService = PrinterService();
  final ScreenshotController _screenshotController = ScreenshotController();
  
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _connecting = false;
  bool _connected = false;
  Timer? _statusTimer;

  // Label content
  String _barcode = "BATCH-2026-001";

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _startStatusTimer();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  void _startStatusTimer() {
    _statusTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final status = await _printerService.isConnected;
      if (mounted && status != _connected) {
        setState(() => _connected = status);
      }
    });
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
    _initPrinters();
  }

  Future<void> _initPrinters() async {
    final printers = await _printerService.getPrinters();
    if (mounted) {
      setState(() {
        _devices = printers;
      });
    }
  }

  void _connect() async {
    final printer = _selectedDevice;
    if (printer == null) return;

    setState(() => _connecting = true);
    try {
      final result = await _printerService.connect(printer);
      if (mounted) {
        setState(() {
          _connecting = false;
          _connected = result;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result ? "Connected to ${printer.name}" : "Connection failed"),
            backgroundColor: result ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _connecting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _disconnect() async {
    await _printerService.disconnect();
    if (mounted) {
      setState(() {
        _connected = false;
      });
    }
  }

  void _testPrint() async {
    if (!_connected) return;
    try {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      List<int> bytes = [];
      bytes += generator.reset();
      bytes += generator.text("PRINTER TEST OK", styles: const PosStyles(align: PosAlign.center, bold: true));
      bytes += generator.feed(2);
      bytes += generator.cut();
      
      await _printerService.printBytes(Uint8List.fromList(bytes));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Test print failed: $e")),
      );
    }
  }

  Future<void> _printLabel() async {
    if (!_connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connect to a printer first")),
      );
      return;
    }

    try {
      // 1. Capture the label widget as an image
      final Uint8List? imageBytes = await _screenshotController.captureFromWidget(
        _buildLabelCanvas(),
        delay: const Duration(milliseconds: 100),
      );

      if (imageBytes == null) return;

      // 2. Process image for thermal printer (58mm = 384px)
      final img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) return;

      final img.Image resizedImage = img.copyResize(originalImage, width: 384);

      // 3. Generate ESC/POS commands
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      List<int> bytes = [];
      
      bytes += generator.reset();
      bytes += generator.imageRaster(resizedImage);
      bytes += generator.feed(1); // Reduced feed to keep it on one label

      // 4. Send to printer
      await _printerService.printBytes(Uint8List.fromList(bytes));

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Printing failed: $e")),
      );
    }
  }

  void _showPrinterPicker() {
    _initPrinters();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select Printer",
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () async {
                      final printers = await _printerService.getPrinters();
                      setModalState(() {
                        _devices = printers;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_devices.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text("No paired printers found.\nPlease pair your printer in Bluetooth settings first."),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      final device = _devices[index];
                      return ListTile(
                        leading: const Icon(Icons.print, color: Colors.blueAccent),
                        title: Text(device.name),
                        subtitle: Text(device.address),
                        onTap: () {
                          setState(() {
                            _selectedDevice = device;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text(
          "Test Printing",
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_connected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                color: _connected ? Colors.blue : Colors.grey),
            onPressed: _connected ? _disconnect : _showPrinterPicker,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Connection Status Card
            _buildConnectionCard(),
            const SizedBox(height: 24),

            // Label Preview Section
            _buildSectionTitle("Label Preview"),
            const SizedBox(height: 12),
            _buildPreviewCard(),
            const SizedBox(height: 24),

            // Editor Section
            _buildSectionTitle("Content Editor"),
            const SizedBox(height: 12),
            _buildEditorCard(),
            const SizedBox(height: 32),

            // Action Buttons
            ElevatedButton(
              onPressed: _connected ? _printLabel : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(
                "PRINT LABEL",
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
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
      style: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
    );
  }

  Widget _buildConnectionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (_connected ? Colors.green : Colors.blueAccent).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _connected ? Icons.check_circle : Icons.print,
              color: _connected ? Colors.green : Colors.blueAccent,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedDevice?.name ?? "No Printer Selected",
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  _connected ? "Status: Online" : "Status: Disconnected",
                  style: GoogleFonts.outfit(
                    color: _connected ? Colors.green : Colors.black38,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (_selectedDevice != null) ...[
            if (_connected)
              IconButton(
                icon: const Icon(Icons.flash_on, color: Colors.orange),
                onPressed: _testPrint,
                tooltip: "Test Print",
              ),
            TextButton(
              onPressed: _connecting ? null : (_connected ? _disconnect : _connect),
              child: _connecting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_connected ? "Disconnect" : "Connect"),
            ),
          ] else
            TextButton(
              onPressed: _showPrinterPicker,
              child: const Text("Select"),
            ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4),
              ],
            ),
            child: _buildLabelCanvas(),
          ),
        ),
      ),
    );
  }

  Widget _buildLabelCanvas() {
    return Container(
      width: 200, 
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BarcodeWidget(
            barcode: Barcode.code128(),
            data: _barcode,
            width: 180,
            height: 60,
            drawText: true,
            style: const TextStyle(fontSize: 12, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildTextField("Barcode Data", _barcode, (v) => setState(() => _barcode = v)),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String initialValue, Function(String) onChanged) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(color: Colors.black45),
        filled: true,
        fillColor: const Color(0xFFF8F9FE),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onChanged: onChanged,
      controller: TextEditingController(text: initialValue)..selection = TextSelection.collapsed(offset: initialValue.length),
    );
  }
}
