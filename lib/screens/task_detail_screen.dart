import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../helpers/backend.dart';
import 'my_tasks_screen.dart';
import 'full_scree.dart';
import 'chat_page.dart';
import '../helpers/colors.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher_string.dart';

class TaskDetailPage extends StatefulWidget {
  final int currentUserId;
  final int providerId;
  final bool readOnly;
  final Map<String, dynamic>? taskData;
  final Map<String, dynamic>? serviceData;
  final List<Map<String, dynamic>>? providerServices;

  const TaskDetailPage({
    Key? key,
    required this.currentUserId,
    required this.providerId,
    this.readOnly = false,
    this.taskData,
    this.serviceData,
    this.providerServices,
  }) : assert(
         (readOnly && taskData != null) ||
             (!readOnly && (serviceData != null || providerServices != null)),
         "Provide serviceData/providerServices for user, or taskData for provider view",
       ),
       super(key: key);

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  DateTime? selectedDate;
  final TextEditingController notesController = TextEditingController();
  final TextEditingController headingController = TextEditingController();
  final TextEditingController imageDetailsController = TextEditingController();
  final List<File> _attachments = [];
  final List<String> providerAttachments = [];
  Map<String, dynamic> service = {};
  bool loadingServices = false;
  late List<Map<String, dynamic>> _providerServices;
  int? selectedServiceId;
TextEditingController addressController = TextEditingController();
double? selectedLat;
double? selectedLng;
  @override
  void initState() {
    super.initState();

    _providerServices = widget.providerServices != null
        ? List<Map<String, dynamic>>.from(widget.providerServices!)
        : [];

    headingController.text = widget.taskData?['title'] ?? "Enter task title";

    // Provider view (readOnly)
    // Provider view (readOnly)
    if (widget.readOnly && widget.taskData != null) {
      final t = widget.taskData!;
      headingController.text = t['title'] ?? t['service_title'];
      notesController.text = t['notes'] ?? t['description'] ?? '';
      imageDetailsController.text = t['attachment_details'] ?? '';
      try {
        selectedDate = DateTime.parse(t['scheduled_date']);
      } catch (_) {}

// 🆕 Address and location
  addressController.text = t['address'] ?? '';
  selectedLat = t['latitude'] is double
      ? t['latitude']
      : double.tryParse(t['latitude']?.toString() ?? '');
  selectedLng = t['longitude'] is double
      ? t['longitude']
      : double.tryParse(t['longitude']?.toString() ?? '');

      // ✅ Fix for attachments
      if (t['attachments'] != null) {
        providerAttachments.clear();
        for (var a in t['attachments']) {
          final path = a['file_path']?.toString() ?? "";
          if (path.isNotEmpty) {
            final fullUrl = path.startsWith("http")
                ? path
                : "${Backend.baseUrl}/$path";
            providerAttachments.add(fullUrl);
          }
        }
      }

      _setService({
        'id': t['service_id'],
        'title': t['service_title'] ?? 'Unknown Service',
        'price': t['price']?.toString() ?? '0',
        'description': t['description'] ?? '',
      });
    }

    // User view: set serviceData if available
    if (!widget.readOnly && widget.serviceData != null) {
      _setService(widget.serviceData!);
    }

    // If provider services exist but no service selected, pick first
    if (!widget.readOnly && _providerServices.isNotEmpty && service.isEmpty) {
      _setService(_providerServices.first);
    }

    // If no services → fetch
    if (!widget.readOnly && _providerServices.isEmpty) {
      fetchProviderServices();
    }
  }

  void _setService(Map<String, dynamic> s) {
    setState(() {
      service = {
        'id': s['id'],
        'title': s['title'] ?? '',
        'price': s['price']?.toString() ?? '',
        'description': s['description'] ?? '',
      };
      selectedServiceId = s['id'] is int
          ? s['id']
          : int.tryParse(s['id'].toString());
    });
  }

  Future<void> fetchProviderServices() async {
    setState(() => loadingServices = true);
    try {
      final url = Uri.parse(
        '${Backend.baseUrl}/provider/${widget.providerId}/services',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> servicesRaw = data['services'] is List
            ? data['services']
            : [];

        _providerServices = servicesRaw
            .map<Map<String, dynamic>>((s) => Map<String, dynamic>.from(s))
            .toList();

        if (_providerServices.isNotEmpty &&
            (service.isEmpty || selectedServiceId == null)) {
          _setService(_providerServices.first);
        }

        if (_providerServices.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No services available for this provider."),
            ),
          );
        }
      } else {
        String msg = "";
        try {
          msg = jsonDecode(response.body)['error'] ?? "";
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to fetch services ❌ $msg")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error fetching services: $e")));
    } finally {
      setState(() => loadingServices = false);
    }
  }

Future<void> createTaskWithAttachments({
  required int userId,
  required int providerId,
  required int serviceId,
  required DateTime scheduledDate,
  required String notes,
  String? attachmentDetails,
  required List<File> attachments,
  required BuildContext context,
  String? address,           // 🆕 new param
  double? latitude,          // 🆕 new param
  double? longitude,         // 🆕 new param
}) async {
  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${Backend.baseUrl}/tasks'),
    );

    String sanitize(String input) {
      return input.replaceAll(RegExp(r'[^\u0000-\uFFFF]'), '');
    }

    // ⚡ Task fields
    request.fields['user_id'] = userId.toString();
    request.fields['provider_id'] = providerId.toString();
    request.fields['service_id'] = serviceId.toString();
    request.fields['scheduled_date'] = scheduledDate.toIso8601String();
    request.fields['notes'] = sanitize(notes);
    request.fields['attachment_details'] = sanitize(attachmentDetails ?? '');
    request.fields['title'] = sanitize(headingController.text);

    // 🆕 Address & Location fields
    if (address != null && address.isNotEmpty) {
      request.fields['address'] = sanitize(address);
    }
    if (latitude != null && longitude != null) {
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
    }

    // ⚡ Add attachments
    for (var file in attachments) {
      request.files.add(
        await http.MultipartFile.fromPath('attachments', file.path),
      );
    }

    // ⚡ Send request
    var response = await request.send();

    if (response.statusCode == 201) {
      final resBody = await response.stream.bytesToString();
      final data = jsonDecode(resBody);

      ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text(
      "🎉 Task created successfully!",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: Colors.white,
      ),
    ),
    backgroundColor: Colors.green.shade600,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    duration: const Duration(seconds: 3),
  ),
);

      print("Task created: ${data['task']}");
      // 🔔 Send notification to provider
      await NotificationsApi.sendNotification(
        userId: providerId, // receiver
        title: "📢 New Task Assigned",
        body:
          "You have a new task 📢 ,Go and check your Tasks Page... ",
        senderId: userId, // sender
      );
    } else {
      final resBody = await response.stream.bytesToString();
      print("Failed to create task: $resBody");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to create task ❌")));
    }
  } catch (e) {
    print("Error: $e");
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Error: $e")));
  }
}

Future<void> _pickDate() async {
  if (widget.readOnly) return;

  final pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now().add(const Duration(days: 1)),
    firstDate: DateTime.now(),
    lastDate: DateTime.now().add(const Duration(days: 365)),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.darkBlue,   // Header background
            onPrimary: Colors.white,       // Header text (month/year/day)
            onSurface: AppColors.textDark, // Dates text
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.darkBlue, // Action button text
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        child: child!,
      );
    },
  );

  if (pickedDate != null) {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.darkBlue,   // Time picker dial color
              onPrimary: Colors.white,       // Selected text
              onSurface: AppColors.textDark, // Normal text
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.darkBlue,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        selectedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }
}

  Future<void> _pickImage() async {
    if (widget.readOnly) return;
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null)
      setState(() => _attachments.add(File(pickedFile.path)));
  }

  Future<void> _confirmBooking() async {
    FocusScope.of(context).unfocus();

    if (selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a date 📅")));
      return;
    }

    if (selectedServiceId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid service ❌")));
      return;
    }

    try {
      // ⚡ Call helper function to create task with attachments
      await createTaskWithAttachments(
        userId: widget.currentUserId,
        providerId: widget.providerId,
        serviceId: selectedServiceId!,
        scheduledDate: selectedDate!,
        notes: notesController.text,
        attachmentDetails: imageDetailsController.text,
        attachments: _attachments,
        context: context,
         address: addressController.text,
  latitude: selectedLat,
  longitude: selectedLng,
      );

      ScaffoldMessenger.of(
  context,
).showSnackBar(const SnackBar(
  content: Text("✅ Your task has been successfully sent. Please wait for provider approval."),
  backgroundColor: Colors.blue,
));

      // Navigate to MyTasksScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              MyTasksScreen(currentUserId: widget.currentUserId, role: "user"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  void dispose() {
    notesController.dispose();
    headingController.dispose();
    imageDetailsController.dispose();
    super.dispose();
  }

  Widget buildImagePreview(File file) {
    if (kIsWeb) {
      return FutureBuilder(
        future: file.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Image.memory(
              snapshot.data as Uint8List,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            );
          }
          return Container(
            width: 100,
            height: 100,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      );
    } else {
      return Image.file(file, width: 100, height: 100, fit: BoxFit.cover);
    }
  }

  Widget buildProviderAttachment(String url) {
    final lower = url.toLowerCase();
    Widget content;

    if (lower.endsWith(".jpg") ||
        lower.endsWith(".jpeg") ||
        lower.endsWith(".png") ||
        lower.endsWith(".gif")) {
      content = Image.network(url, width: 100, height: 100, fit: BoxFit.cover);
    } else {
      content = Container(
        width: 100,
        height: 100,
        color: Colors.grey[300],
        child: const Icon(
          Icons.insert_drive_file,
          size: 40,
          color: Colors.black54,
        ),
      );
    }

    return GestureDetector(
      onTap:
          lower.endsWith(".jpg") ||
              lower.endsWith(".jpeg") ||
              lower.endsWith(".png") ||
              lower.endsWith(".gif")
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FullScreenImage(url: url)),
              );
            }
          : null,
      child: ClipRRect(borderRadius: BorderRadius.circular(8), child: content),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
     appBar: AppBar(
  title: const Text(
    "Task Details",
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 22,
    ),
  ),
  backgroundColor: AppColors.darkBlue,
  elevation: 0,
  centerTitle: true,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
  ),
  iconTheme: const IconThemeData(color: Colors.white), // <-- icons bhi white
),

      body: loadingServices && !widget.readOnly
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: headingController,
                     readOnly: widget.readOnly,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A3A69),
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Task",
                    ),
                  ),
                  const SizedBox(height: 20),
               Container(
  alignment: Alignment.centerLeft,
  padding: const EdgeInsets.symmetric(vertical: 8),
  child: Text(
    "Choose the service You need",
    style: TextStyle(
      fontSize: 22, // slightly bigger
      fontWeight: FontWeight.bold,
      foreground: Paint()
        ..shader = const LinearGradient(
          colors: <Color>[
            Color(0xFF2A3A69), // dark blue
            Color(0xFF4B6CB7), // lighter blue
          ],
        ).createShader(const Rect.fromLTWH(0.0, 0.0, 250.0, 50.0)),
      shadows: const [
        Shadow(
          offset: Offset(0, 3),
          blurRadius: 6,
          color: Colors.black26,
        ),
      ],
      letterSpacing: 0.5,
      height: 1.3,
    ),
  ),
),

                  const SizedBox(height: 8),
                  if (!widget.readOnly)
                    (_providerServices.isEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _infoBox(
                                service.isNotEmpty
                                    ? "${service['title']} • PKR ${service['price']}"
                                    : "No services available",
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: fetchProviderServices,
                                icon: const Icon(Icons.refresh),
                                label: const Text("Refresh services",style: TextStyle(color: AppColors.darkBlue),),
                              ),
                            ],
                          )
                        : DropdownButtonFormField<int?>(
                            value: selectedServiceId,
                            items: _providerServices.map((s) {
                              final id = s['id'] is int
                                  ? s['id']
                                  : int.tryParse(s['id'].toString()) ?? 0;
                              return DropdownMenuItem<int>(
                                value: id,
                                child: Text(
                                  "${s['title']} • PKR ${s['price']}",
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val == null) return;
                              final sel = _providerServices.firstWhere(
                                (s) =>
                                    (s['id'] is int
                                        ? s['id']
                                        : int.tryParse(s['id'].toString())) ==
                                    val,
                                orElse: () => {},
                              );
                              if (sel.isEmpty) return;
                              _setService(sel);
                            },
                            decoration: _dropdownDecoration(),
                          ))
                  else
                    _infoBox(
                      "${service['title'] ?? ''} • PKR ${service['price'] ?? ''}",
                    ),

                  const SizedBox(height: 40),
                Container(
  alignment: Alignment.centerLeft,
  padding: const EdgeInsets.symmetric(vertical: 6),
  child: Text(
    "Set Expiry Date For Task",
    style: TextStyle(
      fontSize: 20, // slightly bigger than original
      fontWeight: FontWeight.bold,
      foreground: Paint()
        ..shader = const LinearGradient(
          colors: <Color>[
            Color(0xFF2A3A69), // dark blue
            Color(0xFF4B6CB7), // lighter blue
          ],
        ).createShader(const Rect.fromLTWH(0.0, 0.0, 250.0, 40.0)),
      shadows: const [
        Shadow(
          offset: Offset(0, 2),
          blurRadius: 5,
          color: Colors.black26,
        ),
      ],
      letterSpacing: 0.4,
      height: 1.3,
    ),
  ),
),

                  const SizedBox(height: 8),
                  ListTile(
                    leading: const Icon(
                      Icons.calendar_today,
                      color: AppColors.textDark,
                    ),
                    title: Text(
                      selectedDate != null
                          ? "${selectedDate!.toLocal()}".split(
                              '.',
                            )[0] // yyyy-mm-dd hh:mm:ss
                          : "No date & time selected",

                      style: const TextStyle(color: AppColors.textDark),
                    ),
                    onTap: widget.readOnly ? null : _pickDate,

                    contentPadding: EdgeInsets.zero,
                  ),

                  SizedBox(height: 20,),

 SizedBox(height: 20,),

Container(
  alignment: Alignment.centerLeft,
  padding: const EdgeInsets.symmetric(vertical: 6),
  child: Text(
    "Share Your Location ",
    style: TextStyle(
      fontSize: 20, // slightly bigger than original
      fontWeight: FontWeight.bold,
      foreground: Paint()
        ..shader = const LinearGradient(
          colors: <Color>[
            Color(0xFF2A3A69), // dark blue
            Color(0xFF4B6CB7), // lighter blue
          ],
        ).createShader(const Rect.fromLTWH(0.0, 0.0, 250.0, 40.0)),
      shadows: const [
        Shadow(
          offset: Offset(0, 2),
          blurRadius: 5,
          color: Colors.black26,
        ),
      ],
      letterSpacing: 0.4,
      height: 1.3,
    ),
  ),
),

 // Address Section
if (!widget.readOnly) ...[
  TextField(
  controller: addressController,
  style: const TextStyle(
    fontSize: 16,
    color: Color(0xFF2A3A69),
    fontWeight: FontWeight.w500,
  ),
  decoration: InputDecoration(
    labelText: "Type your address",
    labelStyle: const TextStyle(
      color: Color(0xFF4B6CB7), // subtle bluish label
      fontWeight: FontWeight.bold,
    ),
    filled: true,
    fillColor: const Color(0xFFE6F0FA), // soft bluish background
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(
        color: Colors.black.withOpacity(0.3), // subtle black border
        width: 1.2,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(
        color: Colors.black.withOpacity(0.3),
        width: 1.2,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(
        color: Color(0xFF2A3A69), // dark blue focus glow
        width: 2,
      ),
    ),
    // subtle shadow inside
    floatingLabelBehavior: FloatingLabelBehavior.always,
  ),
)
,

  const SizedBox(height: 10),
  ElevatedButton.icon(
  onPressed: () async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        selectedLat = pos.latitude;
        selectedLng = pos.longitude;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location set: $selectedLat, $selectedLng")),
      );
    }
  },
  icon: const Icon(
    Icons.my_location,
    color: Colors.white,
  ),
  label: const Text(
    "Share my location",
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF2A3A69), // premium dark blue
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 6,
    shadowColor: Colors.black.withOpacity(0.3),
  ),
),

] else ...[
  const Text(
    "Address",
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: AppColors.textDark,
    ),
  ),

  const SizedBox(height: 6),
  _infoBox(addressController.text.isNotEmpty
      ? addressController.text
      : "No address provided"),
  const SizedBox(height: 10),
 if (selectedLat != null && selectedLng != null)
  GestureDetector(
    onTap: () {
      final url = "https://www.google.com/maps/search/?api=1&query=$selectedLat,$selectedLng";
      launchUrlString(url); // url_launcher package se
    },
    child: _infoBox("📍 View location on map"),
  ),

],

                  const SizedBox(height: 35),
                  Container(
  alignment: Alignment.centerLeft,
  padding: const EdgeInsets.symmetric(vertical: 6),
  child: Text(
    "Notes/Requirments ",
    style: TextStyle(
      fontSize: 20, // slightly bigger than original
      fontWeight: FontWeight.bold,
      foreground: Paint()
        ..shader = const LinearGradient(
          colors: <Color>[
            Color(0xFF2A3A69), // dark blue
            Color(0xFF4B6CB7), // lighter blue
          ],
        ).createShader(const Rect.fromLTWH(0.0, 0.0, 250.0, 40.0)),
      shadows: const [
        Shadow(
          offset: Offset(0, 2),
          blurRadius: 5,
          color: Colors.black26,
        ),
      ],
      letterSpacing: 0.4,
      height: 1.3,
    ),
  ),
),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    maxLines: 6,
                    readOnly: widget.readOnly,
                    decoration: _inputDecoration(
                      "Write any additional notes...",
                    ),
                  ),
                  const SizedBox(height: 20),
                 Container(
  alignment: Alignment.centerLeft,
  padding: const EdgeInsets.symmetric(vertical: 6),
  child: Text(
    "Attachments",
    style: TextStyle(
      fontSize: 20, // slightly bigger than original
      fontWeight: FontWeight.bold,
      foreground: Paint()
        ..shader = const LinearGradient(
          colors: <Color>[
            Color(0xFF2A3A69), // dark blue
            Color(0xFF4B6CB7), // lighter blue
          ],
        ).createShader(const Rect.fromLTWH(0.0, 0.0, 250.0, 40.0)),
      shadows: const [
        Shadow(
          offset: Offset(0, 2),
          blurRadius: 5,
          color: Colors.black26,
        ),
      ],
      letterSpacing: 0.4,
      height: 1.3,
    ),
  ),
),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // ✅ Local attachments (user added)
                      if (!widget.readOnly)
                        ..._attachments.map(
                          (file) => Stack(
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FullScreenImage(file: file),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: buildImagePreview(file),
                                ),
                              ),
                              Positioned(
                                top: 2,
                                right: 2,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _attachments.remove(file)),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE6F0FA),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color:AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      // ➕ Add new attachment button
                      if (!widget.readOnly)
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.textDark,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.textLight.withOpacity(0.1),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Color(0xFF2A3A69),
                              size: 30,
                            ),
                          ),
                        ),
                      // ✅ Provider attachments
                      if (widget.readOnly)
                        ...providerAttachments.map(
                          (url) => GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullScreenImage(url: url),
                              ),
                            ),
                            child: buildProviderAttachment(url),
                          ),
                        ),
                    ],
                  ),

                  // ✅ Show attachment details only for provider view
                  if (widget.readOnly &&
                      imageDetailsController.text.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      "Attachment Details",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _infoBox(imageDetailsController.text),
                  ],

                  const SizedBox(height: 12),
                  if (!widget.readOnly)
                   TextField(
  controller: imageDetailsController,
  minLines: 1,        // start with 1 line
  maxLines: 7,        // expand up to 7 lines only
  decoration: _inputDecoration(
    "You can add details about images...",
  ),
),

                  const SizedBox(height: 30),
                  if (!widget.readOnly)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                (_providerServices.isEmpty ||
                                    selectedServiceId == null)
                                ? null
                                : _confirmBooking,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  (_providerServices.isEmpty ||
                                      selectedServiceId == null)
                                  ? Colors.grey
                                  : AppColors.darkBlue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Confirm Booking",
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textLight,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(color: AppColors.textDark),
                            ),
                            child: const Text(
                              "Cancel Booking",
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.darkBlue,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _messageUser(context);
                        },
                        icon: const Icon(Icons.message, color: Colors.white),
                        label: const Text("Message User",style: TextStyle(color: Colors.white),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkBlue,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
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

Widget _infoBox(String text) => Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEFF4FB), // Softer bluish shade
            Color(0xFFD9E1F0), // Original tone
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20), // slightly rounder
        border: Border.all(
          color: AppColors.darkBlue.withOpacity(0.3), // subtle blue border
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 6),
            blurRadius: 20,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.5), // soft top highlight
            offset: const Offset(-2, -2),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF2A3A69),
          fontWeight: FontWeight.w600,
          fontSize: 16,
          height: 1.5,
          letterSpacing: 0.2,
        ),
      ),
    );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: AppColors.darkBlue, // subtle bluish-grey
        fontSize: 15,
      ),
      filled: true,
      fillColor: const Color(0xFFE6F0FA), // soft bluish fill
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF2A3A69), // dark blue focus glow
          width: 1.5,
        ),
      ),
    );

  InputDecoration _dropdownDecoration() => InputDecoration(
      filled: true,
      fillColor: const Color(0xFFE8EEF9), // softer premium bluish fill
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFF2A3A69), // dark blue accent for focus
          width: 1.5,
        ),
      ),
    );

  // ----- msg btn logic function ----
 Future<void> _messageUser(BuildContext context) async {
  try {
    int? receiverId;

    // --- Determine receiver safely ---
    if (widget.readOnly) {
      // Provider view → receiver is task's user
      receiverId = widget.taskData?['user_id'] as int?;
    } else {
      // User view → receiver is provider
      receiverId = widget.providerId;
    }

    // ❌ Null check
    if (receiverId == null || receiverId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot determine recipient ❌")),
      );
      debugPrint("❌ _messageUser: receiverId is invalid, taskData: ${widget.taskData}");
      return;
    }

    // ✅ Use `receiverId!` here to tell Dart it's non-null
    final response = await http.post(
      Uri.parse("${Backend.baseUrl}/conversations"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": widget.currentUserId,
        "provider_id": receiverId!,  // <-- force non-null
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final conversationId = data['conversation_id'] ?? data['id'];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatPage(
            conversationId: conversationId,
            currentUserId: widget.currentUserId,
            otherUserId: receiverId!,  // <-- force non-null
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to start chat ❌")),
      );
      debugPrint("❌ _messageUser: Backend returned ${response.statusCode} - ${response.body}");
    }
  } catch (e, stack) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error starting chat: $e")),
    );
    debugPrint("❌ _messageUser exception: $e\n$stack");
  }
}

}









// import 'dart:io';
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import '../helpers/backend.dart';
// //import 'my_tasks_screen.dart';
// import 'full_scree.dart';
// import 'chat_page.dart';
// import '../helpers/colors.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:url_launcher/url_launcher_string.dart';
// //import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'PaymentScreen.dart';
// class TaskDetailPage extends StatefulWidget {
//   final int currentUserId;
//   final int providerId;
//   final bool readOnly;
//   final Map<String, dynamic>? taskData;
//   final Map<String, dynamic>? serviceData;
//   final List<Map<String, dynamic>>? providerServices;
// final Map<String, dynamic> currentUser; // add this
//   const TaskDetailPage({
//     Key? key,
//     required this.currentUserId,
//     required this.providerId,
//     this.readOnly = false,
//     this.taskData,
//     this.serviceData,
//     this.providerServices,
//     required this.currentUser, // add this
//   }) : assert(
//          (readOnly && taskData != null) ||
//              (!readOnly && (serviceData != null || providerServices != null)),
//          "Provide serviceData/providerServices for user, or taskData for provider view",
//        ),
//        super(key: key);

//   @override
//   State<TaskDetailPage> createState() => _TaskDetailPageState();
// }

// class _TaskDetailPageState extends State<TaskDetailPage> {
//   DateTime? selectedDate;
//   final TextEditingController notesController = TextEditingController();
//   final TextEditingController headingController = TextEditingController();
//   final TextEditingController imageDetailsController = TextEditingController();
//   final List<File> _attachments = [];
//   final List<String> providerAttachments = [];
//   Map<String, dynamic> service = {};
//   bool loadingServices = false;
//   late List<Map<String, dynamic>> _providerServices;
//   int? selectedServiceId;
//   TextEditingController addressController = TextEditingController();
//   double? selectedLat;
//   double? selectedLng;
//   @override
//   void initState() {
//     super.initState();

//     _providerServices = widget.providerServices != null
//         ? List<Map<String, dynamic>>.from(widget.providerServices!)
//         : [];

//     headingController.text = widget.taskData?['title'] ?? "Enter task title";

//     // Provider view (readOnly)
//     // Provider view (readOnly)
//     if (widget.readOnly && widget.taskData != null) {
//       final t = widget.taskData!;
//       headingController.text = t['title'] ?? t['service_title'];
//       notesController.text = t['notes'] ?? t['description'] ?? '';
//       imageDetailsController.text = t['attachment_details'] ?? '';
//       try {
//         selectedDate = DateTime.parse(t['scheduled_date']);
//       } catch (_) {}

//       // 🆕 Address and location
//       addressController.text = t['address'] ?? '';
//       selectedLat = t['latitude'] is double
//           ? t['latitude']
//           : double.tryParse(t['latitude']?.toString() ?? '');
//       selectedLng = t['longitude'] is double
//           ? t['longitude']
//           : double.tryParse(t['longitude']?.toString() ?? '');

//       // ✅ Fix for attachments
//       if (t['attachments'] != null) {
//         providerAttachments.clear();
//         for (var a in t['attachments']) {
//           final path = a['file_path']?.toString() ?? "";
//           if (path.isNotEmpty) {
//             final fullUrl = path.startsWith("http")
//                 ? path
//                 : "${Backend.baseUrl}/$path";
//             providerAttachments.add(fullUrl);
//           }
//         }
//       }

//       _setService({
//         'id': t['service_id'],
//         'title': t['service_title'] ?? 'Unknown Service',
//         'price': t['price']?.toString() ?? '0',
//         'description': t['description'] ?? '',
//       });
//     }

//     // User view: set serviceData if available
//     if (!widget.readOnly && widget.serviceData != null) {
//       _setService(widget.serviceData!);
//     }

//     // If provider services exist but no service selected, pick first
//     if (!widget.readOnly && _providerServices.isNotEmpty && service.isEmpty) {
//       _setService(_providerServices.first);
//     }

//     // If no services → fetch
//     if (!widget.readOnly && _providerServices.isEmpty) {
//       fetchProviderServices();
//     }
//   }
// //---------------------payments---------------------






//   void _setService(Map<String, dynamic> s) {
//     setState(() {
//       service = {
//         'id': s['id'],
//         'title': s['title'] ?? '',
//         'price': s['price']?.toString() ?? '',
//         'description': s['description'] ?? '',
//       };
//       selectedServiceId = s['id'] is int
//           ? s['id']
//           : int.tryParse(s['id'].toString());
//     });
//   }

//   Future<void> fetchProviderServices() async {
//     setState(() => loadingServices = true);
//     try {
//       final url = Uri.parse(
//         '${Backend.baseUrl}/provider/${widget.providerId}/services',
//       );
//       final response = await http.get(url);

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final List<dynamic> servicesRaw = data['services'] is List
//             ? data['services']
//             : [];

//         _providerServices = servicesRaw
//             .map<Map<String, dynamic>>((s) => Map<String, dynamic>.from(s))
//             .toList();

//         if (_providerServices.isNotEmpty &&
//             (service.isEmpty || selectedServiceId == null)) {
//           _setService(_providerServices.first);
//         }

//         if (_providerServices.isEmpty) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("No services available for this provider."),
//             ),
//           );
//         }
//       } else {
//         String msg = "";
//         try {
//           msg = jsonDecode(response.body)['error'] ?? "";
//         } catch (_) {}
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to fetch services ❌ $msg")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error fetching services: $e")));
//     } finally {
//       setState(() => loadingServices = false);
//     }
//   }
// Future<Map<String, dynamic>> createTaskWithAttachments({
//   required int userId,
//   required int providerId,
//   required int serviceId,
//   required DateTime scheduledDate,
//   required String notes,
//   String? attachmentDetails,
//   required List<File> attachments,
//   required BuildContext context,
//   String? address,
//   double? latitude,
//   double? longitude,
// }) async {
//   try {
//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse('${Backend.baseUrl}/tasks'),
//     );

//     String sanitize(String input) {
//       return input.replaceAll(RegExp(r'[^\u0000-\uFFFF]'), '');
//     }

//     // ⚡ Task fields
//     request.fields['user_id'] = userId.toString();
//     request.fields['provider_id'] = providerId.toString();
//     request.fields['service_id'] = serviceId.toString();
//     request.fields['scheduled_date'] = scheduledDate.toIso8601String();
//     request.fields['notes'] = sanitize(notes);
//     request.fields['attachment_details'] = sanitize(attachmentDetails ?? '');
//     request.fields['title'] = sanitize(headingController.text);

//     if (address != null && address.isNotEmpty) {
//       request.fields['address'] = sanitize(address);
//     }
//     if (latitude != null && longitude != null) {
//       request.fields['latitude'] = latitude.toString();
//       request.fields['longitude'] = longitude.toString();
//     }

//     // ⚡ Add attachments
//     for (var file in attachments) {
//       request.files.add(
//         await http.MultipartFile.fromPath('attachments', file.path),
//       );
//     }

//     // ⚡ Send request
//     var response = await request.send();
//     final resBody = await response.stream.bytesToString();
//     final data = jsonDecode(resBody);

//     if (response.statusCode == 201) {
//       // ✅ Success snackbar
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: const Text(
//             "🎉 Task created successfully!",
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
//           ),
//           backgroundColor: Colors.green.shade600,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           duration: const Duration(seconds: 3),
//         ),
//       );

//       print("Task created: ${data['task']}");

//       // 🔔 Send notification to provider
//       await NotificationsApi.sendNotification(
//         userId: providerId,
//         title: "📢 New Task Assigned",
//         body: "You have a new task 📢 ,Go and check your Tasks Page...",
//         senderId: userId,
//       );

//       return data; // 👈 ye return zaroori hai
//     } else {
//       print("Failed to create task: $resBody");
//       throw Exception("Failed to create task ❌");
//     }
//   } catch (e) {
//     print("Error: $e");
//     throw Exception("Error: $e");
//   }
// }






//   Future<void> _pickDate() async {
//     if (widget.readOnly) return;

//     final pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now().add(const Duration(days: 1)),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 365)),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: AppColors.darkBlue, // Header background
//               onPrimary: Colors.white, // Header text (month/year/day)
//               onSurface: AppColors.textDark, // Dates text
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: AppColors.darkBlue, // Action button text
//                 textStyle: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (pickedDate != null) {
//       final pickedTime = await showTimePicker(
//         context: context,
//         initialTime: TimeOfDay.now(),
//         builder: (context, child) {
//           return Theme(
//             data: Theme.of(context).copyWith(
//               colorScheme: const ColorScheme.light(
//                 primary: AppColors.darkBlue, // Time picker dial color
//                 onPrimary: Colors.white, // Selected text
//                 onSurface: AppColors.textDark, // Normal text
//               ),
//               textButtonTheme: TextButtonThemeData(
//                 style: TextButton.styleFrom(
//                   foregroundColor: AppColors.darkBlue,
//                   textStyle: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//             child: child!,
//           );
//         },
//       );

//       if (pickedTime != null) {
//         setState(() {
//           selectedDate = DateTime(
//             pickedDate.year,
//             pickedDate.month,
//             pickedDate.day,
//             pickedTime.hour,
//             pickedTime.minute,
//           );
//         });
//       }
//     }
//   }

//   Future<void> _pickImage() async {
//     if (widget.readOnly) return;
//     final pickedFile = await ImagePicker().pickImage(
//       source: ImageSource.gallery,
//     );
//     if (pickedFile != null)
//       setState(() => _attachments.add(File(pickedFile.path)));
//   }





// Future<void> _confirmBooking() async {
//   FocusScope.of(context).unfocus();

//   if (selectedDate == null) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Please select a date 📅")),
//     );
//     return;
//   }

//   if (selectedServiceId == null) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Invalid service ❌")),
//     );
//     return;
//   }

//   try {
//     // ⚡ Call helper function to create task with attachments
//     final taskData = await createTaskWithAttachments(
//   userId: widget.currentUserId,
//   providerId: widget.providerId,
//   serviceId: selectedServiceId!,
//   scheduledDate: selectedDate!,
//   notes: notesController.text,
//   attachmentDetails: imageDetailsController.text,
//   attachments: _attachments,
//   context: context,
//   address: addressController.text,
//   latitude: selectedLat,
//   longitude: selectedLng,
// );

//     // ✅ Success snackbar
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text(
//           "✅ Your task has been successfully sent. Please wait for provider approval.",
//         ),
//         backgroundColor: Colors.blue,
//       ),
//     );

//     // 🔔 Get taskId & amount for payment
//     final taskId = taskData['task']['id'];
//     final amount =
//         double.tryParse(taskData['task']['price'].toString()) ?? 0; // ya service['price'] use karo
//    final userId = widget.currentUserId;
// final providerId = widget.providerId;
// final userPhone = widget.currentUser?['phoneNumber'] ?? '';
// final userEmail = widget.currentUser?['email'] ?? '';

// showPaymentOptionDialog(
//   context,
//   taskId,
//   amount,
//   userId,      // now using the variable
//   providerId,  // now using the variable
//   userPhone,   // now using the variable
//   userEmail,   // now using the variable
// );




//     // 👉 Optionally, popup ke andar "Pay Later" press karne par aap navigate kara sakte ho MyTasksScreen me
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Error: $e")),
//     );
//   }
// }

















//   @override
//   void dispose() {
//     notesController.dispose();
//     headingController.dispose();
//     imageDetailsController.dispose();
//     super.dispose();
//   }

//   Widget buildImagePreview(File file) {
//     if (kIsWeb) {
//       return FutureBuilder(
//         future: file.readAsBytes(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done &&
//               snapshot.hasData) {
//             return Image.memory(
//               snapshot.data as Uint8List,
//               width: 100,
//               height: 100,
//               fit: BoxFit.cover,
//             );
//           }
//           return Container(
//             width: 100,
//             height: 100,
//             color: Colors.grey[200],
//             child: const Center(child: CircularProgressIndicator()),
//           );
//         },
//       );
//     } else {
//       return Image.file(file, width: 100, height: 100, fit: BoxFit.cover);
//     }
//   }

//   Widget buildProviderAttachment(String url) {
//     final lower = url.toLowerCase();
//     Widget content;

//     if (lower.endsWith(".jpg") ||
//         lower.endsWith(".jpeg") ||
//         lower.endsWith(".png") ||
//         lower.endsWith(".gif")) {
//       content = Image.network(url, width: 100, height: 100, fit: BoxFit.cover);
//     } else {
//       content = Container(
//         width: 100,
//         height: 100,
//         color: Colors.grey[300],
//         child: const Icon(
//           Icons.insert_drive_file,
//           size: 40,
//           color: Colors.black54,
//         ),
//       );
//     }

//     return GestureDetector(
//       onTap:
//           lower.endsWith(".jpg") ||
//               lower.endsWith(".jpeg") ||
//               lower.endsWith(".png") ||
//               lower.endsWith(".gif")
//           ? () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => FullScreenImage(url: url)),
//               );
//             }
//           : null,
//       child: ClipRRect(borderRadius: BorderRadius.circular(8), child: content),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text(
//           "Task Details",
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: 22,
//           ),
//         ),
//         backgroundColor: AppColors.darkBlue,
//         elevation: 0,
//         centerTitle: true,
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
//         ),
//         iconTheme: const IconThemeData(
//           color: Colors.white,
//         ), // <-- icons bhi white
//       ),

//       body: loadingServices && !widget.readOnly
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   TextField(
//                     controller: headingController,
//                     readOnly: widget.readOnly,
//                     style: const TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF2A3A69),
//                     ),
//                     decoration: const InputDecoration(
//                       border: InputBorder.none,
//                       hintText: "Task",
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Container(
//                     alignment: Alignment.centerLeft,
//                     padding: const EdgeInsets.symmetric(vertical: 8),
//                     child: Text(
//                       "Choose the service You need",
//                       style: TextStyle(
//                         fontSize: 22, // slightly bigger
//                         fontWeight: FontWeight.bold,
//                         foreground: Paint()
//                           ..shader =
//                               const LinearGradient(
//                                 colors: <Color>[
//                                   Color(0xFF2A3A69), // dark blue
//                                   Color(0xFF4B6CB7), // lighter blue
//                                 ],
//                               ).createShader(
//                                 const Rect.fromLTWH(0.0, 0.0, 250.0, 50.0),
//                               ),
//                         shadows: const [
//                           Shadow(
//                             offset: Offset(0, 3),
//                             blurRadius: 6,
//                             color: Colors.black26,
//                           ),
//                         ],
//                         letterSpacing: 0.5,
//                         height: 1.3,
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 8),
//                   if (!widget.readOnly)
//                     (_providerServices.isEmpty
//                         ? Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               _infoBox(
//                                 service.isNotEmpty
//                                     ? "${service['title']} • PKR ${service['price']}"
//                                     : "No services available",
//                               ),
//                               const SizedBox(height: 8),
//                               TextButton.icon(
//                                 onPressed: fetchProviderServices,
//                                 icon: const Icon(Icons.refresh),
//                                 label: const Text(
//                                   "Refresh services",
//                                   style: TextStyle(color: AppColors.darkBlue),
//                                 ),
//                               ),
//                             ],
//                           )
//                         : DropdownButtonFormField<int?>(
//                             value: selectedServiceId,
//                             items: _providerServices.map((s) {
//                               final id = s['id'] is int
//                                   ? s['id']
//                                   : int.tryParse(s['id'].toString()) ?? 0;
//                               return DropdownMenuItem<int>(
//                                 value: id,
//                                 child: Text(
//                                   "${s['title']} • PKR ${s['price']}",
//                                 ),
//                               );
//                             }).toList(),
//                             onChanged: (val) {
//                               if (val == null) return;
//                               final sel = _providerServices.firstWhere(
//                                 (s) =>
//                                     (s['id'] is int
//                                         ? s['id']
//                                         : int.tryParse(s['id'].toString())) ==
//                                     val,
//                                 orElse: () => {},
//                               );
//                               if (sel.isEmpty) return;
//                               _setService(sel);
//                             },
//                             decoration: _dropdownDecoration(),
//                           ))
//                   else
//                     _infoBox(
//                       "${service['title'] ?? ''} • PKR ${service['price'] ?? ''}",
//                     ),

//                   const SizedBox(height: 40),
//                   Container(
//                     alignment: Alignment.centerLeft,
//                     padding: const EdgeInsets.symmetric(vertical: 6),
//                     child: Text(
//                       "Set Expiry Date For Task",
//                       style: TextStyle(
//                         fontSize: 20, // slightly bigger than original
//                         fontWeight: FontWeight.bold,
//                         foreground: Paint()
//                           ..shader =
//                               const LinearGradient(
//                                 colors: <Color>[
//                                   Color(0xFF2A3A69), // dark blue
//                                   Color(0xFF4B6CB7), // lighter blue
//                                 ],
//                               ).createShader(
//                                 const Rect.fromLTWH(0.0, 0.0, 250.0, 40.0),
//                               ),
//                         shadows: const [
//                           Shadow(
//                             offset: Offset(0, 2),
//                             blurRadius: 5,
//                             color: Colors.black26,
//                           ),
//                         ],
//                         letterSpacing: 0.4,
//                         height: 1.3,
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 8),
//                   ListTile(
//                     leading: const Icon(
//                       Icons.calendar_today,
//                       color: AppColors.textDark,
//                     ),
//                     title: Text(
//                       selectedDate != null
//                           ? "${selectedDate!.toLocal()}".split(
//                               '.',
//                             )[0] // yyyy-mm-dd hh:mm:ss
//                           : "No date & time selected",

//                       style: const TextStyle(color: AppColors.textDark),
//                     ),
//                     onTap: widget.readOnly ? null : _pickDate,

//                     contentPadding: EdgeInsets.zero,
//                   ),

//                   SizedBox(height: 20),

//                   SizedBox(height: 20),

//                   Container(
//                     alignment: Alignment.centerLeft,
//                     padding: const EdgeInsets.symmetric(vertical: 6),
//                     child: Text(
//                       "Share Your Location ",
//                       style: TextStyle(
//                         fontSize: 20, // slightly bigger than original
//                         fontWeight: FontWeight.bold,
//                         foreground: Paint()
//                           ..shader =
//                               const LinearGradient(
//                                 colors: <Color>[
//                                   Color(0xFF2A3A69), // dark blue
//                                   Color(0xFF4B6CB7), // lighter blue
//                                 ],
//                               ).createShader(
//                                 const Rect.fromLTWH(0.0, 0.0, 250.0, 40.0),
//                               ),
//                         shadows: const [
//                           Shadow(
//                             offset: Offset(0, 2),
//                             blurRadius: 5,
//                             color: Colors.black26,
//                           ),
//                         ],
//                         letterSpacing: 0.4,
//                         height: 1.3,
//                       ),
//                     ),
//                   ),

//                   // Address Section
//                   if (!widget.readOnly) ...[
//                     TextField(
//                       controller: addressController,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         color: Color(0xFF2A3A69),
//                         fontWeight: FontWeight.w500,
//                       ),
//                       decoration: InputDecoration(
//                         labelText: "Type your address",
//                         labelStyle: const TextStyle(
//                           color: Color(0xFF4B6CB7), // subtle bluish label
//                           fontWeight: FontWeight.bold,
//                         ),
//                         filled: true,
//                         fillColor: const Color(
//                           0xFFE6F0FA,
//                         ), // soft bluish background
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 20,
//                           vertical: 16,
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(18),
//                           borderSide: BorderSide(
//                             color: Colors.black.withOpacity(
//                               0.3,
//                             ), // subtle black border
//                             width: 1.2,
//                           ),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(18),
//                           borderSide: BorderSide(
//                             color: Colors.black.withOpacity(0.3),
//                             width: 1.2,
//                           ),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(18),
//                           borderSide: const BorderSide(
//                             color: Color(0xFF2A3A69), // dark blue focus glow
//                             width: 2,
//                           ),
//                         ),
//                         // subtle shadow inside
//                         floatingLabelBehavior: FloatingLabelBehavior.always,
//                       ),
//                     ),

//                     const SizedBox(height: 10),
//                     ElevatedButton.icon(
//                       onPressed: () async {
//                         LocationPermission permission =
//                             await Geolocator.requestPermission();
//                         if (permission == LocationPermission.always ||
//                             permission == LocationPermission.whileInUse) {
//                           Position pos = await Geolocator.getCurrentPosition(
//                             desiredAccuracy: LocationAccuracy.high,
//                           );
//                           setState(() {
//                             selectedLat = pos.latitude;
//                             selectedLng = pos.longitude;
//                           });
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text(
//                                 "Location set: $selectedLat, $selectedLng",
//                               ),
//                             ),
//                           );
//                         }
//                       },
//                       icon: const Icon(Icons.my_location, color: Colors.white),
//                       label: const Text(
//                         "Share my location",
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(
//                           0xFF2A3A69,
//                         ), // premium dark blue
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 14,
//                           horizontal: 20,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         elevation: 6,
//                         shadowColor: Colors.black.withOpacity(0.3),
//                       ),
//                     ),
//                   ] else ...[
//                     const Text(
//                       "Address",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.textDark,
//                       ),
//                     ),

//                     const SizedBox(height: 6),
//                     _infoBox(
//                       addressController.text.isNotEmpty
//                           ? addressController.text
//                           : "No address provided",
//                     ),
//                     const SizedBox(height: 10),
//                     if (selectedLat != null && selectedLng != null)
//                       GestureDetector(
//                         onTap: () {
//                           final url =
//                               "https://www.google.com/maps/search/?api=1&query=$selectedLat,$selectedLng";
//                           launchUrlString(url); // url_launcher package se
//                         },
//                         child: _infoBox("📍 View location on map"),
//                       ),
//                   ],

//                   const SizedBox(height: 35),
//                   Container(
//                     alignment: Alignment.centerLeft,
//                     padding: const EdgeInsets.symmetric(vertical: 6),
//                     child: Text(
//                       "Notes/Requirments ",
//                       style: TextStyle(
//                         fontSize: 20, // slightly bigger than original
//                         fontWeight: FontWeight.bold,
//                         foreground: Paint()
//                           ..shader =
//                               const LinearGradient(
//                                 colors: <Color>[
//                                   Color(0xFF2A3A69), // dark blue
//                                   Color(0xFF4B6CB7), // lighter blue
//                                 ],
//                               ).createShader(
//                                 const Rect.fromLTWH(0.0, 0.0, 250.0, 40.0),
//                               ),
//                         shadows: const [
//                           Shadow(
//                             offset: Offset(0, 2),
//                             blurRadius: 5,
//                             color: Colors.black26,
//                           ),
//                         ],
//                         letterSpacing: 0.4,
//                         height: 1.3,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   TextField(
//                     controller: notesController,
//                     maxLines: 6,
//                     readOnly: widget.readOnly,
//                     decoration: _inputDecoration(
//                       "Write any additional notes...",
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Container(
//                     alignment: Alignment.centerLeft,
//                     padding: const EdgeInsets.symmetric(vertical: 6),
//                     child: Text(
//                       "Attachments",
//                       style: TextStyle(
//                         fontSize: 20, // slightly bigger than original
//                         fontWeight: FontWeight.bold,
//                         foreground: Paint()
//                           ..shader =
//                               const LinearGradient(
//                                 colors: <Color>[
//                                   Color(0xFF2A3A69), // dark blue
//                                   Color(0xFF4B6CB7), // lighter blue
//                                 ],
//                               ).createShader(
//                                 const Rect.fromLTWH(0.0, 0.0, 250.0, 40.0),
//                               ),
//                         shadows: const [
//                           Shadow(
//                             offset: Offset(0, 2),
//                             blurRadius: 5,
//                             color: Colors.black26,
//                           ),
//                         ],
//                         letterSpacing: 0.4,
//                         height: 1.3,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),

//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: [
//                       // ✅ Local attachments (user added)
//                       if (!widget.readOnly)
//                         ..._attachments.map(
//                           (file) => Stack(
//                             children: [
//                               GestureDetector(
//                                 onTap: () => Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (_) => FullScreenImage(file: file),
//                                   ),
//                                 ),
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(8),
//                                   child: buildImagePreview(file),
//                                 ),
//                               ),
//                               Positioned(
//                                 top: 2,
//                                 right: 2,
//                                 child: GestureDetector(
//                                   onTap: () =>
//                                       setState(() => _attachments.remove(file)),
//                                   child: Container(
//                                     decoration: const BoxDecoration(
//                                       color: Color(0xFFE6F0FA),
//                                       shape: BoxShape.circle,
//                                     ),
//                                     padding: const EdgeInsets.all(4),
//                                     child: const Icon(
//                                       Icons.close,
//                                       size: 16,
//                                       color: AppColors.textDark,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       // ➕ Add new attachment button
//                       if (!widget.readOnly)
//                         GestureDetector(
//                           onTap: _pickImage,
//                           child: Container(
//                             width: 100,
//                             height: 100,
//                             decoration: BoxDecoration(
//                               border: Border.all(color: AppColors.textDark),
//                               borderRadius: BorderRadius.circular(8),
//                               color: AppColors.textLight.withOpacity(0.1),
//                             ),
//                             child: const Icon(
//                               Icons.add,
//                               color: Color(0xFF2A3A69),
//                               size: 30,
//                             ),
//                           ),
//                         ),
//                       // ✅ Provider attachments
//                       if (widget.readOnly)
//                         ...providerAttachments.map(
//                           (url) => GestureDetector(
//                             onTap: () => Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => FullScreenImage(url: url),
//                               ),
//                             ),
//                             child: buildProviderAttachment(url),
//                           ),
//                         ),
//                     ],
//                   ),

//                   // ✅ Show attachment details only for provider view
//                   if (widget.readOnly &&
//                       imageDetailsController.text.isNotEmpty) ...[
//                     const SizedBox(height: 20),
//                     const Text(
//                       "Attachment Details",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.textDark,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     _infoBox(imageDetailsController.text),
//                   ],

//                   const SizedBox(height: 12),
//                   if (!widget.readOnly)
//                     TextField(
//                       controller: imageDetailsController,
//                       minLines: 1, // start with 1 line
//                       maxLines: 7, // expand up to 7 lines only
//                       decoration: _inputDecoration(
//                         "You can add details about images...",
//                       ),
//                     ),

//                   const SizedBox(height: 30),
//                   if (!widget.readOnly)
//                     Row(
//                       children: [
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed:
//                                 (_providerServices.isEmpty ||
//                                     selectedServiceId == null)
//                                 ? null
//                                 : _confirmBooking,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor:
//                                   (_providerServices.isEmpty ||
//                                       selectedServiceId == null)
//                                   ? Colors.grey
//                                   : AppColors.darkBlue,
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             child: const Text(
//                               "Confirm Booking",
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: AppColors.textLight,
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed: () => Navigator.pop(context),
//                             style: OutlinedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(vertical: 14),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               side: const BorderSide(color: AppColors.textDark),
//                             ),
//                             child: const Text(
//                               "Cancel Booking",
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 color: AppColors.darkBlue,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     )
//                   else
//                     Center(
//                       child: ElevatedButton.icon(
//                         onPressed: () {
//                           _messageUser(context);
//                         },
//                         icon: const Icon(Icons.message, color: Colors.white),
//                         label: const Text(
//                           "Message User",
//                           style: TextStyle(color: Colors.white),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppColors.darkBlue,
//                           padding: const EdgeInsets.symmetric(
//                             vertical: 14,
//                             horizontal: 20,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ),
//                   const SizedBox(height: 30),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _infoBox(String text) => Container(
//     width: double.infinity,
//     padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
//     decoration: BoxDecoration(
//       gradient: const LinearGradient(
//         colors: [
//           Color(0xFFEFF4FB), // Softer bluish shade
//           Color(0xFFD9E1F0), // Original tone
//         ],
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//       ),
//       borderRadius: BorderRadius.circular(20), // slightly rounder
//       border: Border.all(
//         color: AppColors.darkBlue.withOpacity(0.3), // subtle blue border
//         width: 1.2,
//       ),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.08),
//           offset: const Offset(0, 6),
//           blurRadius: 20,
//           spreadRadius: 1,
//         ),
//         BoxShadow(
//           color: Colors.white.withOpacity(0.5), // soft top highlight
//           offset: const Offset(-2, -2),
//           blurRadius: 10,
//           spreadRadius: 0,
//         ),
//       ],
//     ),
//     child: Text(
//       text,
//       style: const TextStyle(
//         color: Color(0xFF2A3A69),
//         fontWeight: FontWeight.w600,
//         fontSize: 16,
//         height: 1.5,
//         letterSpacing: 0.2,
//       ),
//     ),
//   );

//   InputDecoration _inputDecoration(String hint) => InputDecoration(
//     hintText: hint,
//     hintStyle: const TextStyle(
//       color: AppColors.darkBlue, // subtle bluish-grey
//       fontSize: 15,
//     ),
//     filled: true,
//     fillColor: const Color(0xFFE6F0FA), // soft bluish fill
//     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//     border: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(16),
//       borderSide: BorderSide.none,
//     ),
//     enabledBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(16),
//       borderSide: BorderSide.none,
//     ),
//     focusedBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(16),
//       borderSide: const BorderSide(
//         color: Color(0xFF2A3A69), // dark blue focus glow
//         width: 1.5,
//       ),
//     ),
//   );

//   InputDecoration _dropdownDecoration() => InputDecoration(
//     filled: true,
//     fillColor: const Color(0xFFE8EEF9), // softer premium bluish fill
//     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//     border: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(16),
//       borderSide: BorderSide.none,
//     ),
//     enabledBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(16),
//       borderSide: BorderSide.none,
//     ),
//     focusedBorder: OutlineInputBorder(
//       borderRadius: BorderRadius.circular(16),
//       borderSide: const BorderSide(
//         color: Color(0xFF2A3A69), // dark blue accent for focus
//         width: 1.5,
//       ),
//     ),
//   );

//   // ----- msg btn logic function ----
//   Future<void> _messageUser(BuildContext context) async {
//     try {
//       int? receiverId;

//       // --- Determine receiver safely ---
//       if (widget.readOnly) {
//         // Provider view → receiver is task's user
//         receiverId = widget.taskData?['user_id'] as int?;
//       } else {
//         // User view → receiver is provider
//         receiverId = widget.providerId;
//       }

//       // ❌ Null check
//       if (receiverId == null || receiverId <= 0) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Cannot determine recipient ❌")),
//         );
//         debugPrint(
//           "❌ _messageUser: receiverId is invalid, taskData: ${widget.taskData}",
//         );
//         return;
//       }

//       // ✅ Use `receiverId!` here to tell Dart it's non-null
//       final response = await http.post(
//         Uri.parse("${Backend.baseUrl}/conversations"),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "user_id": widget.currentUserId,
//           "provider_id": receiverId!, // <-- force non-null
//         }),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final data = jsonDecode(response.body);
//         final conversationId = data['conversation_id'] ?? data['id'];

//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => ChatPage(
//               conversationId: conversationId,
//               currentUserId: widget.currentUserId,
//               otherUserId: receiverId!, // <-- force non-null
//             ),
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("Failed to start chat ❌")));
//         debugPrint(
//           "❌ _messageUser: Backend returned ${response.statusCode} - ${response.body}",
//         );
//       }
//     } catch (e, stack) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error starting chat: $e")));
//       debugPrint("❌ _messageUser exception: $e\n$stack");
//     }
//   }
// }





