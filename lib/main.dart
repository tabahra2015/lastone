// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter/services.dart';
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:http_parser/http_parser.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: UploadPage(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
//
// class UploadPage extends StatefulWidget {
//   const UploadPage({super.key});
//
//   @override
//   State<UploadPage> createState() => _UploadPageState();
// }
//
// class _UploadPageState extends State<UploadPage> {
//   String status = "📄 Ready to send audio file";
//   Uint8List? waveformImageBytes;
//
//   // === Step 1: Upload WAV file ===
//   Future<String?> uploadAudio() async {
//     try {
//       setState(() {
//         status = "⏳ Preparing file...";
//         waveformImageBytes = null;
//       });
//
//       // ✅ Load WAV from assets and write to temp
//       final byteData = await rootBundle.load('assets/BLA3.wav');
//       final tempDir = await getTemporaryDirectory();
//       final file = File('${tempDir.path}/sample.wav');
//       await file.writeAsBytes(byteData.buffer.asUint8List());
//
//       if (!await file.exists()) {
//         throw Exception("Audio file not found after writing.");
//       }
//
//       print('📁 Temp file saved to: ${file.path}');
//
//       // ✅ Prepare multipart upload
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('https://child-api-dboj.onrender.com/upload-audio'),
//       );
//
//       request.headers['x-api-key'] = 'mySuperSecret123';
//       request.files.add(await http.MultipartFile.fromPath('audio', file.path));
//
//       setState(() {
//         status = "🚀 Uploading audio...";
//       });
//
//       final response = await request.send().timeout(Duration(seconds: 60));
//       final responseBody = await response.stream.bytesToString();
//
//       if (response.statusCode == 200) {
//         print('✅ Upload response: $responseBody');
//         final jsonResponse = json.decode(responseBody);
//         final url = jsonResponse['url'];
//         setState(() {
//           status = "✅ Audio uploaded. URL received.";
//         });
//         return url;
//       } else {
//         setState(() {
//           status = '❌ Upload failed with code: ${response.statusCode}';
//         });
//         return null;
//       }
//     } catch (e) {
//       print('❌ Upload Error: $e');
//       setState(() {
//         status = '❌ Upload error: $e';
//       });
//       return null;
//     }
//   }
//
//   // // === Step 2: Predict based on uploaded URL ===
//   // Future<void> predictFromUrl(String audioUrl) async {
//   //   try {
//   //     setState(() {
//   //       status = "🔍 Sending to prediction API...";
//   //     });
//   //
//   //     final response = await http
//   //         .post(
//   //           Uri.parse('https://child-api-dboj.onrender.com/predict-audio'),
//   //           headers: {'Content-Type': 'application/json'},
//   //           body: json.encode({'audio_url': audioUrl}),
//   //         )
//   //         .timeout(const Duration(seconds: 60));
//   //
//   //     if (response.statusCode == 200) {
//   //       final jsonResponse = json.decode(response.body);
//   //       final prediction = jsonResponse['prediction'];
//   //
//   //       final base64Image = jsonResponse['waveform_image_base64'];
//   //       if (base64Image != null) {
//   //         final bytes = base64Decode(base64Image.split(',').last);
//   //         setState(() {
//   //           waveformImageBytes = bytes;
//   //         });
//   //       } else {
//   //         print("⚠️ No waveform image received.");
//   //         setState(() {
//   //           waveformImageBytes = null;
//   //         });
//   //       }
//   //
//   //       setState(() {
//   //         status = "🎯 Prediction: $prediction";
//   //
//   //       });
//   //     } else {
//   //       setState(() {
//   //         status = '❌ Prediction failed with code: ${response.statusCode}';
//   //       });
//   //     }
//   //   } catch (e) {
//   //     print('❌ Prediction Error: $e');
//   //     setState(() {
//   //       status = '❌ Prediction error: $e';
//   //     });
//   //   }
//   // }
//   Future<void> predictFromFile(File wavFile) async {
//     try {
//       setState(() {
//         status = "🔍 Sending WAV file to prediction API...";
//       });
//
//       final uri = Uri.parse('https://child-api-dboj.onrender.com/predict-audio');
//       final request = http.MultipartRequest('POST', uri);
//
//       // ✅ Attach the WAV file to the request
//       request.files.add(await http.MultipartFile.fromPath(
//         'audio',
//         wavFile.path,
//         contentType: MediaType('audio', 'wav'),
//       ));
//
//       // ✅ Send and wait for response
//       final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
//       final response = await http.Response.fromStream(streamedResponse);
//
//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
//         final prediction = jsonResponse['prediction'];
//         final base64Image = jsonResponse['waveform_image_base64'];
//
//         // ✅ Decode waveform image if available
//         if (base64Image != null && base64Image.startsWith("data:image")) {
//           final bytes = base64Decode(base64Image.split(',').last);
//           setState(() {
//             waveformImageBytes = bytes;
//           });
//         } else {
//           print("⚠️ No waveform image received.");
//           setState(() {
//             waveformImageBytes = null;
//           });
//         }
//
//         setState(() {
//           status = "🎯 Prediction: $prediction";
//         });
//       } else {
//         setState(() {
//           status = '❌ Prediction failed with code: ${response.statusCode}';
//         });
//       }
//     } catch (e) {
//       print('❌ Prediction Error: $e');
//       setState(() {
//         status = '❌ Prediction error: $e';
//       });
//     }
//   }
//
//
//   Future<File?> loadAssetAsFile(String assetPath) async {
//     try {
//       final byteData = await rootBundle.load(assetPath);
//       final tempDir = await getTemporaryDirectory();
//       final file = File('${tempDir.path}/temp.wav');
//       await file.writeAsBytes(byteData.buffer.asUint8List());
//       return file;
//     } catch (e) {
//       print("❌ Failed to load asset as file: $e");
//       return null;
//     }
//   }
//
//   Future<void> sendWavAssetToServer() async {
//     final file = await loadAssetAsFile('assets/BLA3.wav');
//     if (file != null) {
//       await predictFromFile(file);
//     } else {
//       setState(() {
//         status = "❌ Failed to load WAV file.";
//       });
//     }
//   }
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Audio Uploader")),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(status, textAlign: TextAlign.center),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: sendWavAssetToServer,
//                 child: const Text("📤 Send Audio"),
//               ),
//               if (waveformImageBytes != null) ...[
//                 const SizedBox(height: 30),
//                 const Text(
//                   "🖼️ Waveform",
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 10),
//                 Image.memory(waveformImageBytes!),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: UploadPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  String status = "📄 Ready to send audio file";
  Uint8List? waveformImageBytes;

  Future<void> predictFromFile(File wavFile) async {
    try {
      setState(() {
        status = "🔍 Sending WAV file to prediction API...";
      });

      final uri = Uri.parse('https://child-api-dboj.onrender.com/predict-audio');
      final request = http.MultipartRequest('POST', uri);

      request.files.add(await http.MultipartFile.fromPath(
        'audio',
        wavFile.path,
        contentType: MediaType('audio', 'wav'),
      ));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final prediction = jsonResponse['prediction'];
        final base64Image = jsonResponse['waveform_image_base64'];

        if (base64Image != null && base64Image.startsWith("data:image")) {
          final bytes = base64Decode(base64Image.split(',').last);
          setState(() {
            waveformImageBytes = bytes;
          });
        } else {
          setState(() {
            waveformImageBytes = null;
          });
        }

        setState(() {
          status = "🎯 Prediction: $prediction";
        });
      } else {
        setState(() {
          status = '❌ Prediction failed with code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        status = '❌ Prediction error: $e';
      });
    }
  }

  Future<File?> loadAssetAsFile(String assetPath) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/temp.wav');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      return file;
    } catch (e) {
      return null;
    }
  }

  Future<void> sendWavAssetToServer() async {
    final file = await loadAssetAsFile('assets/CLA1.wav');
    if (file != null) {
      await predictFromFile(file);
    } else {
      setState(() {
        status = "❌ Failed to load WAV file.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Audio Uploader")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(status, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: sendWavAssetToServer,
                child: const Text("📤 Send Audio"),
              ),
              if (waveformImageBytes != null) ...[
                const SizedBox(height: 30),
                const Text(
                  "🖼️ Waveform",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Image.memory(waveformImageBytes!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
