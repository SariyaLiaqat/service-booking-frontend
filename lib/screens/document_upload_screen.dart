// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import '../helpers/my_colors.dart';
// import '../helpers/backend.dart';

// class DocumentUploadScreen extends StatefulWidget {
//   final int userId;
//   final bool alreadySubmitted; // 🔹 New flag

//   const DocumentUploadScreen({super.key, required this.userId, this.alreadySubmitted = false});

//   @override
//   State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
// }

// class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
//   final ImagePicker _picker = ImagePicker();
//   final storage = const FlutterSecureStorage(); // 🔹 Secure Storage

//   List<XFile> selectedFiles = [];
//   bool isUploading = false;
//   bool submitted = false; // 🔹 Tracks if documents are submitted

//   final List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];
//   final int maxFileSizeMB = 5;

//   @override
//   void initState() {
//     super.initState();
//     submitted = widget.alreadySubmitted;
//   }

//   Future<void> pickFile(ImageSource source) async {
//     if (submitted) return;

//     try {
//       final pickedFile = await _picker.pickImage(source: source);
//       if (pickedFile == null) return;

//       final extension = pickedFile.name.split('.').last.toLowerCase();
//       final fileSizeMB = await pickedFile.length() / (1024 * 1024);

//       if (!allowedExtensions.contains(extension)) {
//         Fluttertoast.showToast(
//             msg: "❌ File type not allowed. Use jpg, png, pdf.");
//         return;
//       }

//       if (fileSizeMB > maxFileSizeMB) {
//         Fluttertoast.showToast(
//             msg: "❌ File too large. Max size ${maxFileSizeMB}MB.");
//         return;
//       }

//       setState(() {
//         selectedFiles.add(pickedFile);
//       });
//     } catch (e) {
//       Fluttertoast.showToast(msg: "Error picking file: $e");
//     }
//   }

//  Future<void> uploadDocuments() async {
//   if (submitted) return;
//   if (selectedFiles.isEmpty) {
//     Fluttertoast.showToast(msg: "Select at least one document.");
//     return;
//   }

//   setState(() => isUploading = true);

//   try {
//     final token = await storage.read(key: 'jwt');
//     if (token == null) {
//       Fluttertoast.showToast(msg: "❌ Not authenticated. Login first.");
//       setState(() => isUploading = false);
//       return;
//     }

//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse('${Backend.baseUrl}/provider/upload-documents'),
//     );

//     request.headers['Authorization'] = 'Bearer $token';
//     request.fields['userId'] = widget.userId.toString();

//     for (var file in selectedFiles) {
//       request.files.add(await http.MultipartFile.fromPath(
//         'documents',
//         file.path,
//         filename: file.name,
//       ));
//     }

//     var response = await request.send();
//     var respStr = await response.stream.bytesToString();

//     print("Status: ${response.statusCode}");
//     print("Body: $respStr");

//     setState(() => isUploading = false);

//     if (response.statusCode == 201) {
//       Fluttertoast.showToast(msg: "✅ Documents submitted — under review!");
//       setState(() {
//         selectedFiles.clear();
//         submitted = true;
//       });
//     } else {
//       Fluttertoast.showToast(msg: "❌ Upload failed. Please try again later.");
//     }
//   } catch (e) {
//     setState(() => isUploading = false);
//     Fluttertoast.showToast(msg: "❌ Error uploading files: $e");
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Upload Documents")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Text(
//               submitted
//                   ? "Documents submitted — under review"
//                   : "Upload your verification documents",
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),
//             Wrap(
//               spacing: 10,
//               runSpacing: 10,
//               children: selectedFiles
//                   .map((file) => Stack(
//                         children: [
//                           Container(
//                             width: 100,
//                             height: 100,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(color: MyColors.primary),
//                               image: file.name.endsWith('.pdf')
//                                   ? null
//                                   : DecorationImage(
//                                       image: FileImage(File(file.path)),
//                                       fit: BoxFit.cover,
//                                     ),
//                             ),
//                             child: file.name.endsWith('.pdf')
//                                 ? const Center(child: Icon(Icons.picture_as_pdf))
//                                 : null,
//                           ),
//                           if (!submitted)
//                             Positioned(
//                               right: -10,
//                               top: -10,
//                               child: IconButton(
//                                 icon: const Icon(Icons.close, color: Colors.red),
//                                 onPressed: () {
//                                   setState(() => selectedFiles.remove(file));
//                                 },
//                               ),
//                             ),
//                         ],
//                       ))
//                   .toList(),
//             ),
//             const SizedBox(height: 20),
//             if (!submitted)
//               Row(
//                 children: [
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       icon: const Icon(Icons.photo_camera),
//                       label: const Text("Camera"),
//                       onPressed: () => pickFile(ImageSource.camera),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       icon: const Icon(Icons.photo_library),
//                       label: const Text("Gallery"),
//                       onPressed: () => pickFile(ImageSource.gallery),
//                     ),
//                   ),
//                 ],
//               ),
//             const SizedBox(height: 20),
//             submitted
//                 ? Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.yellow[100],
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: const Text(
//                       "Your documents are under review. You cannot upload new files unless requested by admin.",
//                       style: TextStyle(fontSize: 16),
//                     ),
//                   )
//                 : isUploading
//                     ? const CircularProgressIndicator()
//                     : SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: uploadDocuments,
//                           child: const Text(
//                             "Submit Documents",
//                             style: TextStyle(fontSize: 18),
//                           ),
//                         ),
//                       ),
//           ],
//         ),
//       ),
//     );
//   }
// }










import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../helpers/coolors.dart';
import '../helpers/backend.dart';

class DocumentUploadScreen extends StatefulWidget {
  final int userId;
  final bool alreadySubmitted;

  const DocumentUploadScreen({
    super.key,
    required this.userId,
    this.alreadySubmitted = false,
  });

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  final storage = const FlutterSecureStorage();

  List<XFile> selectedFiles = [];
  bool isUploading = false;
  bool submitted = false;

  final List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];
  final int maxFileSizeMB = 5;
  final int maxFiles = 5;

  @override
  void initState() {
    super.initState();
    _checkSubmissionStatus();
  }

  /// ✅ Check if submission is already done from local storage
  Future<void> _checkSubmissionStatus() async {
    String? savedStatus = await storage.read(key: 'submitted_${widget.userId}');
    setState(() {
      submitted = savedStatus == 'true' || widget.alreadySubmitted;
    });
  }

  /// ✅ Pick file from camera/gallery
  Future<void> pickFile(ImageSource source) async {
    if (submitted) return;
    if (selectedFiles.length >= maxFiles) {
      Fluttertoast.showToast(msg: "❌ Maximum $maxFiles files allowed.");
      return;
    }

    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return;

      final extension = pickedFile.name.split('.').last.toLowerCase();
      final fileSizeMB = await pickedFile.length() / (1024 * 1024);

      if (!allowedExtensions.contains(extension)) {
        Fluttertoast.showToast(msg: "❌ Invalid file type. Use jpg, png, pdf.");
        return;
      }

      if (fileSizeMB > maxFileSizeMB) {
        Fluttertoast.showToast(msg: "❌ File too large. Max size ${maxFileSizeMB}MB.");
        return;
      }

      setState(() {
        selectedFiles.add(pickedFile);
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "❌ Error picking file: $e");
    }
  }

  /// ✅ Upload documents logic
  Future<void> uploadDocuments() async {
    if (submitted) return;
    if (selectedFiles.isEmpty) {
      Fluttertoast.showToast(msg: "Select at least one document.");
      return;
    }

    setState(() => isUploading = true);

    try {
      final token = await storage.read(key: 'jwt');
      if (token == null) {
        Fluttertoast.showToast(msg: "❌ Not authenticated. Login first.");
        setState(() => isUploading = false);
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Backend.baseUrl}/provider/upload-documents'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['userId'] = widget.userId.toString();

      for (var file in selectedFiles) {
        request.files.add(await http.MultipartFile.fromPath(
          'documents',
          file.path,
          filename: file.name,
        ));
      }

      var response = await request.send();
      var respStr = await response.stream.bytesToString();

      print("Status: ${response.statusCode}");
      print("Body: $respStr");

      setState(() => isUploading = false);

      if (response.statusCode == 201) {
        Fluttertoast.showToast(msg: "✅ Documents submitted — under review!");
        await storage.write(key: 'submitted_${widget.userId}', value: 'true'); // ✅ save state
        setState(() {
          selectedFiles.clear();
          submitted = true;
        });
      } else {
        Fluttertoast.showToast(msg: "❌ Upload failed. Please try again later.");
      }
    } catch (e) {
      setState(() => isUploading = false);
      Fluttertoast.showToast(msg: "❌ Error uploading files: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Upload Documents",
          style: TextStyle(color: kTextPrimary),
        ),
        backgroundColor: kCardColor,
        elevation: 1,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔹 Heading
              Text(
                submitted
                    ? "✅ Documents Submitted"
                    : "Upload Your Verification Documents",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              Text(
                submitted
                    ? "Your documents are under review. You cannot upload new files unless requested by admin."
                    : "Please upload CNIC, service license or any verification document. Maximum 5 files, each max 5MB.",
                style: const TextStyle(
                  fontSize: 16,
                  color: kTextPrimary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // 🔹 Selected Files Preview
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: selectedFiles
                    .map(
                      (file) => Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: kPrimaryColor),
                              image: file.name.endsWith('.pdf')
                                  ? null
                                  : DecorationImage(
                                      image: FileImage(File(file.path)),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            child: file.name.endsWith('.pdf')
                                ? const Center(
                                    child: Icon(Icons.picture_as_pdf,
                                        size: 40, color: Colors.red),
                                  )
                                : null,
                          ),
                          if (!submitted)
                            Positioned(
                              right: -10,
                              top: -10,
                              child: IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.red),
                                onPressed: () {
                                  setState(() => selectedFiles.remove(file));
                                },
                              ),
                            ),
                        ],
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),

              // 🔹 Upload Buttons
              if (!submitted)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.photo_camera, color: Colors.white),
                        label: const Text(
                          "Camera",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () => pickFile(ImageSource.camera),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.photo_library, color: Colors.white),
                        label: const Text(
                          "Gallery",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () => pickFile(ImageSource.gallery),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 20),

              // 🔹 Submit / Submitted Message
              submitted
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.yellow[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Documents uploaded successfully. Waiting for admin review.",
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : isUploading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: uploadDocuments,
                            child: const Text(
                              "Submit Documents",
                              style: TextStyle(
                                  fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
