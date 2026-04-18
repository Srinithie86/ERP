import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'dart:io';

class PDFViewerScreen extends StatefulWidget {
  final String url;
  final String title;

  const PDFViewerScreen({
    super.key,
    required this.url,
    this.title = 'Invoice PDF',
  });

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  double? _downloadProgress;

  @override
  void initState() {
    super.initState();
    debugPrint("PDFViewerScreen: Initializing with URL: ${widget.url}");
  }

  Future<void> _downloadPDF() async {
    if (_downloadProgress != null) return; // Prevent multiple clicks

    try {
      debugPrint("Starting automatic download for: ${widget.url}");
      
      FileDownloader.downloadFile(
        url: widget.url,
        // Optional: you can extract a name from the URL or use a default
        name: "${widget.title.replaceAll(' ', '_')}.pdf",
        onProgress: (fileName, progress) {
          if (mounted) {
            setState(() {
              _downloadProgress = progress;
            });
          }
        },
        onDownloadCompleted: (path) async {
          debugPrint("Download Completed. Path: $path");
          String finalPath = path;
          
          // Check if it incorrectly saved as .php and rename to .pdf
          if (path.toLowerCase().endsWith('.php')) {
            try {
              final file = File(path);
              final newPath = path.substring(0, path.length - 4) + '.pdf';
              if (await file.exists()) {
                await file.rename(newPath);
                finalPath = newPath;
                debugPrint("Renamed .php to .pdf: $finalPath");
              }
            } catch (e) {
              debugPrint("Auto-rename failed: $e");
            }
          }

          if (mounted) {
            setState(() {
              _downloadProgress = null;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Download complete! Saved to: $finalPath'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
          }
        },
        onDownloadError: (errorMessage) {
          debugPrint("Download Error: $errorMessage");
          if (mounted) {
            setState(() {
              _downloadProgress = null;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Download failed: $errorMessage'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    } catch (e) {
      debugPrint("Download Exception: $e");
      if (mounted) {
        setState(() => _downloadProgress = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error triggering download: $e')),
        );
      }
    }
  }

  Future<void> _openExternally() async {
    final Uri url = Uri.parse(widget.url);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open external URL')),
          );
        }
      }
    } catch (e) {
      debugPrint("External Launch Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("PDFViewerScreen: Building Widget...");
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          _downloadProgress != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        value: _downloadProgress! / 100,
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.file_download_outlined, color: Colors.white),
                  tooltip: 'Download PDF',
                  onPressed: _downloadPDF,
                ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            tooltip: 'Open externally / Share',
            onPressed: _openExternally,
          ),
        ],
      ),
      body: SfPdfViewer.network(
        widget.url,
        key: _pdfViewerKey,
        onDocumentLoadFailed: (details) {
          debugPrint("PDF Load Failed: ${details.description}");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load PDF: ${details.description}')),
            );
          }
        },
        onDocumentLoaded: (details) {
          debugPrint("PDF Loaded Successfully");
        },
      ),
    );
  }
}
