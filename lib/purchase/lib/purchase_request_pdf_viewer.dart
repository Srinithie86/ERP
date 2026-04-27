import 'dart:io';
import 'dart:typed_data';
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
  bool _isLoading = true;
  String? _errorMessage;
  Uint8List? _pdfBytes;
  PdfViewerController? _pdfViewerController;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  late String _finalPdfUrl;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _finalPdfUrl = widget.pdfUrl.trim();
    _fetchPdfBytes();
  }

  Future<void> _fetchPdfBytes() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dio = Dio();
      final response = await dio.get<List<int>>(
        _finalPdfUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (mounted) {
          setState(() {
            _pdfBytes = Uint8List.fromList(response.data!);
            _isLoading = false;
          });
        }
      } else {
        throw "Server returned status ${response.statusCode}";
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (e.toString().contains("404")) {
            _errorMessage = "Document Not Found\n\nThis document (ID: ${widget.prNumber}) has not been generated on the server yet. Please wait a few moments or contact the administrator if this persists.";
          } else {
            _errorMessage = "Failed to load document: $e";
          }
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
      
      await dio.download(_finalPdfUrl, filePath);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("File saved: ${widget.prNumber}.pdf"),
            backgroundColor: const Color(0xFF26A69A),
          ),
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
    setState(() => _isDownloading = true);
    try {
      final dio = Dio();
      final dir = await getTemporaryDirectory();
      final filePath = "${dir.path}/temp_${widget.prNumber.replaceAll('/', '_')}.pdf";
      
      await dio.download(_finalPdfUrl, filePath);
      
      if (mounted) {
        await Share.shareXFiles([XFile(filePath)], text: 'Document ${widget.prNumber}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Share failed: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.prNumber,
              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              "Document Viewer",
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
        actions: [
          if (_pdfBytes != null) ...[
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: _sharePdf,
              tooltip: "Share",
            ),
            IconButton(
              icon: _isDownloading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.download, color: Colors.white),
              onPressed: _isDownloading ? null : _downloadPdf,
              tooltip: "Download",
            ),
          ],
          const SizedBox(width: 8),
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
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey.shade800),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _fetchPdfBytes,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF26A69A)),
                          child: const Text("Retry", style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                )
              : SfPdfViewer.memory(
                  _pdfBytes!,
                  key: _pdfViewerKey,
                  controller: _pdfViewerController,
                ),
    );
  }
}
