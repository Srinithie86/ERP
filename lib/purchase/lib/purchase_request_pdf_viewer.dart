import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';

class PurchaseRequestPdfViewer extends StatefulWidget {
  final String pdfUrl;
  final String prNumber;

  const PurchaseRequestPdfViewer({
    super.key,
    required this.pdfUrl,
    required this.prNumber,
  });

  @override
  State<PurchaseRequestPdfViewer> createState() => _PurchaseRequestPdfViewerState();
}

class _PurchaseRequestPdfViewerState extends State<PurchaseRequestPdfViewer> {
  bool _isDownloading = false;
  String? _localFilePath;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAndLoadPdf();
  }

  Future<void> _fetchAndLoadPdf() async {
    try {
      final dio = Dio();
      final dir = await getTemporaryDirectory();
      final filePath = "${dir.path}/${widget.prNumber.replaceAll('/', '_')}_temp.pdf";
      
      await dio.download(widget.pdfUrl, filePath);
      
      if (mounted) {
        setState(() {
          _localFilePath = filePath;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to fetch PDF: $e";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _downloadPdf() async {
    setState(() => _isDownloading = true);
    try {
      final dio = Dio();
      final dir = await getApplicationDocumentsDirectory();
      final filePath = "${dir.path}/${widget.prNumber.replaceAll('/', '_')}.pdf";
      
      await dio.download(widget.pdfUrl, filePath);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Downloaded to $filePath"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download failed: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _sharePdf() async {
    if (_localFilePath == null) return;
    try {
      await Share.shareXFiles([XFile(_localFilePath!)], text: 'Document ${widget.prNumber}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Share failed: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.prNumber,
          style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _isLoading ? null : _sharePdf,
            tooltip: "Share",
          ),
          IconButton(
            icon: _isDownloading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.download, color: Colors.white),
            onPressed: _isDownloading || _isLoading ? null : _downloadPdf,
            tooltip: "Download",
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF26A69A)))
        : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(_errorMessage!, textAlign: TextAlign.center, style: GoogleFonts.outfit(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _errorMessage = null;
                        });
                        _fetchAndLoadPdf();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF26A69A)),
                      child: const Text("Retry", style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ),
            )
          : SfPdfViewer.file(
              File(_localFilePath!),
              onDocumentLoadFailed: (details) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to load PDF: ${details.description}")),
                );
              },
            ),
    );
  }
}
