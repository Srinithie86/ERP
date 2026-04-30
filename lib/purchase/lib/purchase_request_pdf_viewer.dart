import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

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
    
    // Initial fetch
    _prepareAndFetch();
  }

  Future<void> _prepareAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final cid = prefs.getString('cid') ?? '';
    final uid = prefs.getString('uid') ?? prefs.getString('id') ?? '';
    final lt = prefs.getString('lt') ?? '';
    final ln = prefs.getString('ln') ?? '';
    
    String requestUrl = widget.pdfUrl.trim();
    if (!requestUrl.startsWith('http')) {
      requestUrl = "https://erpsmart.in/total/api/$requestUrl";
    }

    if (!requestUrl.contains('cid=') && cid.isNotEmpty) {
      requestUrl += "${requestUrl.contains('?') ? '&' : '?'}cid=$cid";
    }
    if (!requestUrl.contains('uid=') && uid.isNotEmpty) {
      requestUrl += "&uid=$uid";
    }
    if (!requestUrl.contains('lt=') && lt.isNotEmpty) {
      requestUrl += "&lt=$lt";
    }
    if (!requestUrl.contains('ln=') && ln.isNotEmpty) {
      requestUrl += "&ln=$ln";
    }
    
    _fetchPdfBytes(requestUrl);
  }

  Future<void> _fetchPdfBytes(String requestUrl, {bool isRetry = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint("PDF Viewer [v1.0.3] => Requesting URL: $requestUrl");
      _finalPdfUrl = requestUrl;
      
      final response = await http.get(
        Uri.parse(requestUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
          'Accept': 'application/pdf,application/octet-stream,*/*',
        },
      ).timeout(const Duration(seconds: 30));

      debugPrint("PDF Viewer => Status: ${response.statusCode}");
      debugPrint("PDF Viewer => Content-Type: ${response.headers['content-type']}");
      debugPrint("PDF Viewer => Bytes received: ${response.bodyBytes.length}");

      if (response.statusCode == 200) {
        final String contentType = response.headers['content-type']?.toLowerCase() ?? '';
        final String bodyStart = String.fromCharCodes(response.bodyBytes.take(10)).toLowerCase();
        
        if (contentType.contains('text/html') || bodyStart.contains('<!doctype') || bodyStart.contains('<html')) {
          debugPrint("PDF Viewer => Received HTML instead of PDF. Body length: ${response.body.length}");
          
          // Print body in chunks for debugging
          final String fullBody = response.body;
          for (int i = 0; i < (fullBody.length > 3000 ? 3000 : fullBody.length); i += 1000) {
            int end = (i + 1000 < fullBody.length) ? i + 1000 : fullBody.length;
            debugPrint("PDF_BODY_PART: ${fullBody.substring(i, end)}");
          }

          // Try to extract a direct PDF link from the HTML if possible
          // Handle both plain and URL-encoded links
          String? foundUrl;
          final encodedPdfRegex = RegExp(r'https?(?:%3A|:)(?:%2F|/)(?:%2F|/)erpsmart\.in(?:%2F|/)uploads(?:%2F|/)[^\s"<>]+?\.pdf');
          final plainPdfRegex = RegExp(r'https://erpsmart\.in/uploads/[^\s"<>]+?\.pdf');
          
          // Use allMatches to find the best candidate (the one that is NOT a mail link)
          final allPlainMatches = plainPdfRegex.allMatches(fullBody);
          final allEncodedMatches = encodedPdfRegex.allMatches(fullBody);
          
          List<String> candidates = [];
          for (final m in allPlainMatches) candidates.add(m.group(0)!);
          for (final m in allEncodedMatches) candidates.add(m.group(0)!);

          for (String cand in candidates) {
            // Recursive decoding for multi-encoded URLs
            String decoded = cand;
            String previous;
            do {
              previous = decoded;
              decoded = Uri.decodeFull(decoded);
            } while (decoded != previous && decoded.contains('%'));

            if (!decoded.contains('google.com') && !decoded.contains('wa.me') && !decoded.contains('whatsapp.com')) {
              foundUrl = decoded;
              break;
            }
          }
          
          if (foundUrl == null) {
            // Fallback: search for any erpsmart.in link ending in .pdf but NOT containing google/whatsapp
            final fallbackRegex = RegExp(r'https?://[^\s"<>]+?erpsmart\.in[^\s"<>]+?\.pdf');
            final matches = fallbackRegex.allMatches(fullBody);
            for (final m in matches) {
              String url = m.group(0)!;
              String prev;
              do {
                prev = url;
                url = Uri.decodeFull(url);
              } while (url != prev && url.contains('%'));

              if (!url.contains('google.com') && !url.contains('wa.me') && !url.contains('whatsapp.com')) {
                foundUrl = url;
                break;
              }
            }
          }

          if (foundUrl != null && foundUrl != requestUrl) {
            debugPrint("PDF Viewer => Found valid direct PDF link: $foundUrl");
            _fetchPdfBytes(foundUrl, isRetry: true);
            return;
          }

          if (!isRetry) {
            if (!requestUrl.contains('raw=')) {
              debugPrint("PDF Viewer => Retrying with &raw=1...");
              _fetchPdfBytes("$requestUrl&raw=1", isRetry: true);
              return;
            } else if (!requestUrl.contains('stream=')) {
              debugPrint("PDF Viewer => Retrying with &stream=1...");
              _fetchPdfBytes("$requestUrl&stream=1", isRetry: true);
              return;
            } else if (!requestUrl.contains('download=')) {
              debugPrint("PDF Viewer => Retrying with &download=1...");
              _fetchPdfBytes("$requestUrl&download=1", isRetry: true);
              return;
            }
          }
          
          setState(() {
            _errorMessage = "The server returned a Web Page instead of a PDF file.\n\nThis usually happens when the session expires or the document hasn't been generated yet.\n\nTry using the 'Open in Browser' icon at the top right.";
            _isLoading = false;
          });
          return;
        }

        setState(() {
          _pdfBytes = response.bodyBytes;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Server error: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("PDF Viewer Error => $e");
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to load document: $e";
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
          IconButton(
            icon: const Icon(Icons.open_in_browser, color: Colors.white),
            onPressed: () async {
              final uri = Uri.parse(_finalPdfUrl);
              // ignore: deprecated_member_use
              if (await canLaunchUrl(uri)) {
                // ignore: deprecated_member_use
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Could not open browser")),
                  );
                }
              }
            },
            tooltip: "Open in Browser",
          ),
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
                          onPressed: () => _prepareAndFetch(),
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
