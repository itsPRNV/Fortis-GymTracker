import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/form_correction_provider.dart';
import '../services/form_checker_service.dart';

class FormCorrectionScreen extends StatefulWidget {
  final String exerciseName;

  const FormCorrectionScreen({
    super.key,
    required this.exerciseName,
  });

  @override
  State<FormCorrectionScreen> createState() => _FormCorrectionScreenState();
}

class _FormCorrectionScreenState extends State<FormCorrectionScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isDetecting = false;
  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
      model: PoseDetectionModel.accurate,
    ),
  );

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    context.read<FormCorrectionProvider>().setCurrentExercise(widget.exerciseName);
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission required')),
        );
      }
      return;
    }

    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      _cameraController = CameraController(
        _cameras!.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      _cameraController!.startImageStream(_processCameraImage);
      
      if (mounted) setState(() {});
    }
  }

  void _processCameraImage(CameraImage image) async {
    if (_isDetecting) return;
    _isDetecting = true;

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage != null) {
        final poses = await _poseDetector.processImage(inputImage);
        
        if (poses.isNotEmpty && mounted) {
          final pose = poses.first;
          String? feedback;

          switch (widget.exerciseName.toLowerCase()) {
            case 'squat':
            case 'squats':
              feedback = FormCheckerService.checkSquatForm(pose.landmarks);
              break;
            case 'push-up':
            case 'push up':
            case 'pushup':
              feedback = FormCheckerService.checkPushUpForm(pose.landmarks);
              break;
          }

          if (feedback != null) {
            context.read<FormCorrectionProvider>().provideFeedback(feedback);
          }
        }
      }
    } catch (e) {
      debugPrint('Pose detection error: $e');
    }

    _isDetecting = false;
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final camera = _cameras!.first;
    final rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.exerciseName} Form Check'),
        actions: [
          Consumer<FormCorrectionProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Icon(
                  provider.isEnabled ? Icons.volume_up : Icons.volume_off,
                ),
                onPressed: provider.toggleFormCorrection,
              );
            },
          ),
        ],
      ),
      body: _cameraController?.value.isInitialized == true
          ? Stack(
              children: [
                CameraPreview(_cameraController!),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Exercise: ${widget.exerciseName}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Consumer<FormCorrectionProvider>(
                          builder: (context, provider, child) {
                            return Text(
                              provider.isEnabled 
                                  ? 'Voice feedback: ON' 
                                  : 'Voice feedback: OFF',
                              style: TextStyle(
                                color: provider.isEnabled 
                                    ? Colors.green 
                                    : Colors.red,
                                fontSize: 14,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing camera...'),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _poseDetector.close();
    context.read<FormCorrectionProvider>().stopSpeaking();
    super.dispose();
  }
}