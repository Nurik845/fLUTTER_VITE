import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../widgets/lumi_overlay.dart';
import '../widgets/lumi_widget.dart';

class ArLumiScreen extends StatefulWidget {
  const ArLumiScreen({super.key});
  @override
  State<ArLumiScreen> createState() => _ArLumiScreenState();
}

class _ArLumiScreenState extends State<ArLumiScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    _initCam();
  }

  Future<void> _initCam() async {
    _cameras = await availableCameras();
    final back = _cameras!.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => _cameras!.first);
    _controller = CameraController(back, ResolutionPreset.medium, enableAudio: false);
    await _controller!.initialize();
    if (mounted) setState(() {});
    LumiOverlay.set(emotion: LumiEmotion.curious, speech: 'Наведи камеру вокруг — я рядом!');
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lumi AR Mode')),
      body: Stack(children: [
        if (_controller?.value.isInitialized == true)
          CameraPreview(_controller!)
        else
          const Center(child: CircularProgressIndicator()),
        // Псевдо-AR: Lumi поверх камеры, можно подвигать перетаскиванием
        const SizedBox.shrink(),
      ]),
    );
  }
}
