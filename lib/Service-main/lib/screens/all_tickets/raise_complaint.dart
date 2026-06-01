import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';


class RaiseComplaintScreen extends StatefulWidget {
  const RaiseComplaintScreen({super.key});

  static List<dynamic> cachedProducts = [];
  static List<dynamic> cachedComplaintTitles = [];
  static bool hasLoadedOnce = false;

  static Future<void> fetchInitialData() async {
    if (cachedProducts.isNotEmpty && cachedComplaintTitles.isNotEmpty) {
      hasLoadedOnce = true;
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final String cid = prefs.getString('cid') ?? '';
      if (cid.isEmpty) return;

      final String token = prefs.getString('token') ?? '';
      final String deviceId = prefs.getString('device_id') ?? '';
      final String lt = prefs.getString('lt') ?? '';
      final String ln = prefs.getString('ln') ?? '';

      final results = await Future.wait([
        http
            .post(
              Uri.parse("https://erpsmart.in/total/api/m_api/"),
              body: {
                "type": "7000",
                "cid": cid,
                "token": token,
                "device_id": deviceId,
                "lt": lt,
                "ln": ln,
              },
            )
            .timeout(const Duration(seconds: 10)),
        http
            .post(
              Uri.parse("https://erpsmart.in/total/api/m_api/"),
              body: {
                "type": "7002",
                "cid": cid,
                "token": token,
                "device_id": deviceId,
                "lt": lt,
                "ln": ln,
              },
            )
            .timeout(const Duration(seconds: 10)),
      ]);

      if (results[0].statusCode == 200) {
        final data = json.decode(results[0].body);
        if (data['error'] == false) {
          cachedProducts = data['data'] ?? [];
        }
      }

      if (results[1].statusCode == 200) {
        final data = json.decode(results[1].body);
        if (data['error'] == false) {
          cachedComplaintTitles = data['data'] ?? [];
        }
      }
      hasLoadedOnce = true;
    } catch (e) {
      debugPrint("Preload error: $e");
    }
  }

  @override
  State<RaiseComplaintScreen> createState() => _RaiseComplaintScreenState();
}

class _RaiseComplaintScreenState extends State<RaiseComplaintScreen> {
  DateTime? _selectedDate;
  List<File> _pickedFiles = [];
  bool _isRecording = false;
  List<String> _audioPaths = [];
  final AudioRecorder _audioRecorder = AudioRecorder();
  final ImagePicker _picker = ImagePicker();

  final AudioPlayer _audioPlayer = AudioPlayer();
  int _recordDuration = 0;
  Timer? _timer;
  String? _playingPath;

  List<dynamic> _products = RaiseComplaintScreen.cachedProducts;
  String? _selectedProductId;
  String? _selectedProductName;

  List<dynamic> _complaintTitles = RaiseComplaintScreen.cachedComplaintTitles;
  String? _selectedComplaintTitleId;
  String? _selectedComplaintTitleName;
  bool _isLoadingProducts = RaiseComplaintScreen.cachedProducts.isEmpty;
  bool _isLoadingComplaintTitles =
      RaiseComplaintScreen.cachedComplaintTitles.isEmpty;
  String? _currentAddress;
  String? _cityName;
  String? _latitude;
  String? _longitude;
  bool _isFetchingLocation = false;
  String? _cusId;

  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _alternateNumberController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCustomerName();
    _getCurrentLocation();
    if (!RaiseComplaintScreen.hasLoadedOnce ||
        _products.isEmpty ||
        _complaintTitles.isEmpty) {
      _fetchProducts();
      _fetchComplaintTitles();
      RaiseComplaintScreen.hasLoadedOnce = true;
    }
  }

  Future<void> _loadCustomerName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name') ?? '';
    _cusId = prefs.getString('cus_id') ?? '';

    if (name.isNotEmpty) {
      if (mounted) {
        setState(() {
          _customerNameController.text = name;
          _contactNumberController.text = prefs.getString('mobile') ?? '';
        });
      }
    }
  }

  Future<void> _fetchProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String cid = prefs.getString('cid') ?? '';
      final String deviceId = prefs.getString('device_id') ?? '';
      final String lt = prefs.getString('lt') ?? '';
      final String ln = prefs.getString('ln') ?? '';

      final response = await http
          .post(
            Uri.parse("https://erpsmart.in/total/api/m_api/"),
            body: {
              "type": "7000",
              "cid": cid,
              "device_id": deviceId,
              "lt": lt,
              "ln": ln,
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false) {
          if (mounted) {
            setState(() {
              _products = RaiseComplaintScreen.cachedProducts =
                  data['data'] ?? [];
              _isLoadingProducts = false;
            });
          }
        } else {
          if (mounted) setState(() => _isLoadingProducts = false);
        }
      } else {
        if (mounted) setState(() => _isLoadingProducts = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingProducts = false);
    }
  }

  Future<void> _fetchComplaintTitles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String cid = prefs.getString('cid') ?? '';
      final String deviceId = prefs.getString('device_id') ?? '';
      final String lt = prefs.getString('lt') ?? '';
      final String ln = prefs.getString('ln') ?? '';

      final response = await http
          .post(
            Uri.parse("https://erpsmart.in/total/api/m_api/"),
            body: {
              "type": "7002",
              "cid": cid,
              "device_id": deviceId,
              "lt": lt,
              "ln": ln,
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false) {
          if (mounted) {
            setState(() {
              _complaintTitles = RaiseComplaintScreen.cachedComplaintTitles =
                  data['data'] ?? [];
              _isLoadingComplaintTitles = false;
            });
          }
        } else {
          if (mounted) setState(() => _isLoadingComplaintTitles = false);
        }
      } else {
        if (mounted) setState(() => _isLoadingComplaintTitles = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingComplaintTitles = false);
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _timer?.cancel();
    _customerNameController.dispose();
    _contactNumberController.dispose();
    _alternateNumberController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _recordDuration = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Future<void> _playRecording(String path) async {
    try {
      if (_playingPath == path) {
        await _audioPlayer.pause();
        if (mounted) setState(() => _playingPath = null);
      } else {
        await _audioPlayer.play(DeviceFileSource(path));
        if (mounted) setState(() => _playingPath = path);

        _audioPlayer.onPlayerComplete.first.then((_) {
          if (mounted && _playingPath == path) {
            setState(() => _playingPath = null);
          }
        });
      }
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2CB9E5),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      if (mounted) {
        setState(() {
          _selectedDate = picked;
        });
      }
    }
  }

  Future<void> _pickFile() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text("Gallery (Select Multiple)"),
            onTap: () async {
              Navigator.pop(context);
              final List<XFile> images = await _picker.pickMultiImage(
                imageQuality: 50,
              );
              if (images.isNotEmpty) {
                setState(() {
                  _pickedFiles.addAll(images.map((i) => File(i.path)));
                });
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text("Camera"),
            onTap: () async {
              Navigator.pop(context);
              final XFile? image = await _picker.pickImage(
                source: ImageSource.camera,
                imageQuality: 50,
              );
              if (image != null) {
                setState(() {
                  _pickedFiles.add(File(image.path));
                });
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.insert_drive_file),
            title: const Text("Files"),
            onTap: () async {
              Navigator.pop(context);
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                allowMultiple: true,
              );
              if (result != null) {
                setState(() {
                  _pickedFiles.addAll(
                    result.paths.where((p) => p != null).map((p) => File(p!)),
                  );
                });
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _removeFile(int index) {
    setState(() {
      _pickedFiles.removeAt(index);
    });
  }

  Future<void> _toggleRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        if (_isRecording) {
          final path = await _audioRecorder.stop();
          _stopTimer();
          setState(() {
            _isRecording = false;
            if (path != null) _audioPaths.add(path);
          });
        } else {
          final directory = await getApplicationDocumentsDirectory();
          final path =
              '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

          const config = RecordConfig();
          await _audioRecorder.start(config, path: path);
          _startTimer();
          if (mounted) {
            setState(() {
              _isRecording = true;
            });
          }
        }
      } else {
        await Permission.microphone.request();
      }
    } catch (e) {
      debugPrint("Error recording: $e");
    }
  }

  void _deleteRecording(int index) {
    if (index < 0 || index >= _audioPaths.length) return;
    final path = _audioPaths[index];
    try {
      final file = File(path);
      if (file.existsSync()) file.deleteSync();
    } catch (e) {
      debugPrint("Error deleting file: $e");
    }
    if (mounted) {
      setState(() {
        if (_playingPath == path) {
          _audioPlayer.stop();
          _playingPath = null;
        }
        _audioPaths.removeAt(index);
      });
    }
  }

  // SUBMIT COMPLAINT
  Future<void> _submitComplaint() async {
    if (_isRecording) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please stop the audio recording before submitting"),
        ),
      );
      return;
    }
    if (_selectedProductId == null ||
        _selectedComplaintTitleId == null ||
        _customerNameController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields")),
      );
      return;
    }

    final altNum = _alternateNumberController.text.trim();
    if (altNum.isNotEmpty && altNum.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Alternate Number must be exactly 10 digits"),
        ),
      );
      return;
    }

    final contactNum = _contactNumberController.text.trim();
    if (contactNum.isNotEmpty && contactNum.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Contact Number must be exactly 10 digits"),
        ),
      );
      return;
    }

    if (_pickedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please attach at least one photo or video"),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final String token = prefs.getString('token') ?? '';
      final String cid = prefs.getString('cid') ?? '';
      final String deviceId = prefs.getString('device_id') ?? '';
      final String lt = prefs.getString('lt') ?? '';
      final String ln = prefs.getString('ln') ?? '';

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("https://erpsmart.in/total/api/m_api/"),
      );

      request.fields['type'] = '7001';
      request.fields['cid'] = cid;
      request.fields['token'] = token;
      request.fields['device_id'] = deviceId;
      request.fields['lt'] = lt;
      request.fields['ln'] = ln;
      request.fields['customer_id'] = _cusId ?? '';
      request.fields['product_id'] = _selectedProductId!;
      request.fields['complaint_title'] = _selectedComplaintTitleId ?? '';
      request.fields['complaint_desc'] = _descriptionController.text.trim();
      request.fields['address'] = _addressController.text.trim();
      request.fields['current_location'] = _currentAddress ?? '';
      request.fields['pho'] = _contactNumberController.text.trim();
      request.fields['a_pho'] = _alternateNumberController.text.trim();
      request.fields['priority'] = '2';

      request.fields['visit_date'] = _selectedDate != null
          ? DateFormat('dd-MM-yyyy').format(_selectedDate!)
          : '';
      if (_pickedFiles.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'photo',
            _pickedFiles.first.path,
            filename: _pickedFiles.first.path.split('/').last,
          ),
        );
      }
      if (_audioPaths.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'audio',
            _audioPaths.first,
            filename: _audioPaths.first.split('/').last,
          ),
        );
      }

      debugPrint("CUSTOMER ID SENT: ${_customerNameController.text.trim()}");
      debugPrint(
        "IMAGES: ${_pickedFiles.length} | AUDIO: ${_audioPaths.length}",
      );

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      var response = await http.Response.fromStream(streamedResponse);

      debugPrint("SUBMIT STATUS: ${response.statusCode}");
      debugPrint("FULL RESPONSE: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['error'] == false || data['error'] == "false") {
          _resetForm();
          if (mounted) _showSuccessPopup();
          return;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Submission failed. Please try again.")),
        );
      }
    } catch (e) {
      debugPrint("Submit Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _resetForm() {
    setState(() {
      _descriptionController.clear();
      _addressController.clear();
      _alternateNumberController.clear();
      _selectedProductId = null;
      _selectedProductName = null;
      _selectedComplaintTitleId = null;
      _selectedComplaintTitleName = null;
      _pickedFiles.clear();
      _audioPaths.clear();
      _selectedDate = null;
      _currentAddress = null;
    });
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2CB9E5).withOpacity(0.12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF2CB9E5),
                    size: 60,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                "Complaint Submitted!",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              // Subtitle
              Text(
                "Your complaint has been received.\nOur team will reach out to you shortly.",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2CB9E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "OK",
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProductSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Select Product",
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              _products.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Text(
                        "No products available",
                        style: GoogleFonts.outfit(color: Colors.grey),
                      ),
                    )
                  : Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          final bool isSelected =
                              _selectedProductId == product['id'].toString();
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 4,
                            ),
                            title: Text(
                              product['product_name'] ?? '',
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                color: isSelected
                                    ? const Color(0xFF2CB9E5)
                                    : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF2CB9E5),
                                    size: 22,
                                  )
                                : null,
                            onTap: () {
                              if (mounted) {
                                setState(() {
                                  _selectedProductId = product['id'].toString();
                                  _selectedProductName =
                                      product['product_name'];
                                });
                              }
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _isFetchingLocation = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Location services are disabled. Opening settings...',
              ),
            ),
          );
        }
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isFetchingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isFetchingLocation = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions are permanently denied.'),
            ),
          );
        }
        return;
      }

      Position? position = await Geolocator.getLastKnownPosition();

      if (position == null) {
        try {
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 5),
            ),
          );
        } catch (e) {
          debugPrint("âš ï¸ Quick location fetch failed: $e");
        }
      }

      if (position == null) {
        if (mounted) setState(() => _isFetchingLocation = false);
        return;
      }

      _latitude = position.latitude.toString();
      _longitude = position.longitude.toString();

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('lt', _latitude!);
      prefs.setString('ln', _longitude!);

      await _updateCityAndAddress(position);
    } catch (e) {
      debugPrint("Error getting location: $e");
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _updateCityAndAddress(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark p = placemarks[0];
        List<String> addressParts = [];

        if (p.street != null && p.street!.isNotEmpty) {
          addressParts.add(p.street!);
        }
        if (p.subLocality != null && p.subLocality!.isNotEmpty) {
          addressParts.add(p.subLocality!);
        }
        if (p.locality != null && p.locality!.isNotEmpty) {
          addressParts.add(p.locality!);
        }
        if (p.subAdministrativeArea != null &&
            p.subAdministrativeArea!.isNotEmpty) {
          addressParts.add(p.subAdministrativeArea!);
        }

        // Determine best name to show (City > District > Area)
        String? displayCity = (p.locality?.isNotEmpty == true)
            ? p.locality
            : (p.subAdministrativeArea?.isNotEmpty == true)
            ? p.subAdministrativeArea
            : p.subLocality;

        if (mounted) {
          setState(() {
            _cityName = displayCity;
            _currentAddress = addressParts.join(", ");
          });
        }
      }
    } catch (e) {
      debugPrint("Geocoding error: $e");
      if (mounted && _currentAddress == null) {
        setState(() {
          _currentAddress =
              "Location Set (Lat: ${position.latitude}, Lon: ${position.longitude})";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2CB9E5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Raise Complaint",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFieldLabel("Customer Name"),
            _buildTextField(
              "Enter Customer Name",
              controller: _customerNameController,
            ),
            const SizedBox(height: 15),

            _buildFieldLabel("Contact Number"),
            _buildTextField(
              "Enter Contact Number",
              controller: _contactNumberController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
            ),
            const SizedBox(height: 15),

            _buildFieldLabel("Alternate Number"),
            _buildTextField(
              "Enter Alternate Number",
              controller: _alternateNumberController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
            ),
            const SizedBox(height: 15),

            _buildFieldLabel("Product"),
            _buildProductDropdown(),
            const SizedBox(height: 15),

            _buildFieldLabel("Complaint Title"),
            _buildDropdownField("Select a Complaint Title"),
            const SizedBox(height: 15),

            _buildFieldLabel("Description"),
            _buildTextField(
              "Enter Description",
              maxLines: 4,
              controller: _descriptionController,
            ),
            const SizedBox(height: 15),

            _buildFieldLabel("Preferred Visit Date"),
            _buildDateField("Select Preferred Visit Date"),
            const SizedBox(height: 15),

            _buildFieldLabel("Address"),
            _buildTextField("Enter Address", controller: _addressController),
            const SizedBox(height: 15),

            _buildLocationSection(),
            const SizedBox(height: 20),

            _buildFieldLabel("Attach Photo / Video", required: true),
            _buildUploadSection(),
            const SizedBox(height: 25),

            _buildRecordingSection(),
            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitComplaint,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2CB9E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "Submit Complaint",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 2),
      child: RichText(
        text: TextSpan(
          text: label,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
          children: [
            if (required)
              const TextSpan(
                text: " *",
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String hint, {
    int maxLines = 1,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        maxLength: maxLength,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400),
          counterText: "",
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 12,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildProductDropdown() {
    return GestureDetector(
      onTap: _showProductSelector,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _selectedProductName ?? "Select Product",
                style: GoogleFonts.outfit(
                  color: _selectedProductName == null
                      ? Colors.grey.shade400
                      : Colors.black87,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade700),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedComplaintTitleId,
          hint: Text(
            hint,
            style: GoogleFonts.outfit(color: Colors.grey.shade400),
          ),
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade700),
          items: _complaintTitles.map((item) {
            return DropdownMenuItem<String>(
              value: item['id'].toString(),
              child: Text(
                item['name'] ?? '',
                style: GoogleFonts.outfit(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedComplaintTitleId = val;
              _selectedComplaintTitleName = _complaintTitles.firstWhere(
                (item) => item['id'].toString() == val,
                orElse: () => {'name': ''},
              )['name'];
            });
          },
        ),
      ),
    );
  }

  Widget _buildDateField(String hint) {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F4F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedDate == null
                  ? hint
                  : DateFormat('dd-MM-yyyy').format(_selectedDate!),
              style: GoogleFonts.outfit(
                color: _selectedDate == null
                    ? Colors.grey.shade400
                    : Colors.black87,
              ),
            ),
            Icon(
              Icons.calendar_month_outlined,
              color: Colors.grey.shade600,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _isFetchingLocation ? null : _getCurrentLocation,
            child: Row(
              children: [
                Icon(
                  Icons.my_location,
                  color: _isFetchingLocation ? Colors.grey : Colors.green,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  _isFetchingLocation
                      ? (_cityName != null
                            ? "Fetching near $_cityName..."
                            : "Fetching...")
                      : (_cityName != null
                            ? "Location: $_cityName"
                            : "Use Current Location"),
                  style: GoogleFonts.outfit(
                    color: _isFetchingLocation
                        ? Colors.grey
                        : Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if (_isFetchingLocation)
                  const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Text(
              _currentAddress ?? "Locating...",
              style: GoogleFonts.outfit(
                color: Colors.grey.shade800,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickFile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
            child: CustomPaint(
              painter: DashedRectPainter(color: Colors.grey.shade400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 15),
                  Image.asset('assets/camera.png', width: 40, height: 35),
                  const SizedBox(height: 12),
                  Text(
                    "Tap to add photos / videos",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "JPG/PNG , MP4 Upto 20MB",
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
        if (_pickedFiles.isNotEmpty)
          Container(
            height: 100,
            margin: const EdgeInsets.only(top: 15),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _pickedFiles.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(right: 15, top: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: _pickedFiles[index].path.endsWith('.mp4')
                            ? const Center(child: Icon(Icons.videocam))
                            : Image.file(
                                _pickedFiles[index],
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 5,
                      child: GestureDetector(
                        onTap: () => _removeFile(index),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildRecordingSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Record Your Complaint",
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _isRecording
                      ? Colors.red.shade100
                      : const Color(0xFFFFCCBC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _isRecording ? "Recording..." : "Record",
                  style: GoogleFonts.outfit(
                    color: _isRecording ? Colors.red : Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              GestureDetector(
                onTap: _toggleRecording,
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: _isRecording ? Colors.red : const Color(0xFF2CB9E5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildWaveform(),
                    _isRecording
                        ? Text(
                            _formatDuration(_recordDuration),
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.red,
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ],
          ),
          if (_audioPaths.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _audioPaths.length,
              itemBuilder: (context, index) {
                final path = _audioPaths[index];
                final bool isThisPlaying = _playingPath == path;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _playRecording(path),
                        child: Icon(
                          isThisPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          color: const Color(0xFF2CB9E5),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Voice Note ${index + 1}",
                          style: GoogleFonts.outfit(fontSize: 14),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _deleteRecording(index),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        12,
        (index) => Container(
          margin: const EdgeInsets.only(right: 3),
          width: 4,
          height: (index % 3 + 1) * 6.0,
          decoration: BoxDecoration(
            color: _isRecording ? Colors.red.shade200 : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({
    this.color = Colors.black,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    Path path = Path();
    path.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(15),
      ),
    );

    Path dashPath = Path();
    double dashWidth = 5.0;
    double dashSpace = gap;
    double distance = 0.0;

    for (final measurePath in path.computeMetrics()) {
      while (distance < measurePath.length) {
        dashPath.addPath(
          measurePath.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
      distance = 0.0;
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}