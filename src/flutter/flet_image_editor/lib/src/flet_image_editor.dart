import 'package:flet/flet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // для RenderRepaintBoundary
import 'package:lindi_sticker_widget/lindi_sticker_widget.dart';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

class FletImageEditorControl extends StatefulWidget {
  final Control? parent;
  final Control control;
  final bool parentDisabled;
  final bool? parentAdaptive;
  final List<Control> children;
  final FletControlBackend backend;

  const FletImageEditorControl({
    super.key,
    this.parent,
    required this.control,
    required this.children,
    required this.parentDisabled,
    required this.parentAdaptive,
    required this.backend,
  });

  @override
  State<FletImageEditorControl> createState() => _FletImageEditorControlState();
}

class _FletImageEditorControlState extends State<FletImageEditorControl> {
  late final LindiController controller;
  final random = Random();
  final GlobalKey _editorKey = GlobalKey();

  final List<String> randomWords = [
    "Clay!",
    "Gay",
    "Screen!",
    "Skinz ❤️",
    "Sticker",
    "Magic",
    "Flutter",
    "🔥 Boom",
    "Edit Me!",
  ];

  final String stickerPath =
      '/Users/mf/Albert_Designer/src/assets/logos/Leagues/MLB/MLB-ATL01.png';

  @override
  void initState() {
    super.initState();
    controller = LindiController(
      borderColor: Colors.white,
      icons: [
        LindiStickerIcon(
          icon: Icons.done,
          alignment: Alignment.topRight,
          onTap: () => controller.selectedWidget?.done(),
        ),
        LindiStickerIcon(
          icon: Icons.lock_open,
          lockedIcon: Icons.lock,
          alignment: Alignment.topCenter,
          type: IconType.lock,
          onTap: () => controller.selectedWidget?.lock(),
        ),
        LindiStickerIcon(
          icon: Icons.close,
          alignment: Alignment.topLeft,
          onTap: () => controller.selectedWidget?.delete(),
        ),
        LindiStickerIcon(
          icon: Icons.edit,
          alignment: Alignment.centerLeft,
          onTap: () => controller.selectedWidget?.edit(
            const Icon(Icons.star, size: 50, color: Colors.yellow),
          ),
        ),
        LindiStickerIcon(
          icon: Icons.layers,
          alignment: Alignment.centerRight,
          onTap: () => controller.selectedWidget?.stack(),
        ),
        LindiStickerIcon(
          icon: Icons.flip,
          alignment: Alignment.bottomLeft,
          onTap: () => controller.selectedWidget?.flip(),
        ),
        LindiStickerIcon(
          icon: Icons.crop_free,
          alignment: Alignment.bottomRight,
          type: IconType.resize,
        ),
      ],
    );

    // Добавляем стикер с изображением
    if (File(stickerPath).existsSync()) {
      controller.add(
        Image.file(
          File(stickerPath),
          width: 150,
          height: 150,
          // Добавляем фильтрацию для сглаживания
          filterQuality: FilterQuality.high,
          isAntiAlias: true,
        ),
      );
    } else {
      debugPrint("❌ Sticker file not found at $stickerPath");
    }

    // Добавляем стикер с текстом
    controller.add(
      const Text(
        "Hello World!",
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: Offset(1, 1),
              blurRadius: 3,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  void _randomizeActiveText() {
    final selected = controller.selectedWidget;
    if (selected == null) {
      debugPrint("❌ No active widget selected");
      return;
    }

    if (selected.child is! Text) {
      debugPrint("⚠️ Selected widget is not a Text widget");
      return;
    }

    final newWord = randomWords[random.nextInt(randomWords.length)];
    selected.edit(
      Text(
        newWord,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: Offset(1, 1),
              blurRadius: 3,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );

    debugPrint("✅ Updated text to: $newWord");
  }

  Future<void> _saveToImage() async {
    try {
      // Снимаем выделение со всех стикеров перед сохранением
      controller.selectedWidget?.done();
      
      // Небольшая задержка для обновления UI
      await Future.delayed(const Duration(milliseconds: 100));
      
      final boundary = _editorKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 4.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final outputPath = '/Users/mf/Desktop/flet_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(outputPath);
      await file.writeAsBytes(pngBytes);
      debugPrint("✅ Saved image to: $outputPath");

      // Открываем файл на macOS
      await Process.run('open', [file.path]);
    } catch (e, st) {
      debugPrint("❌ Error saving image: $e\n$st");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: SafeArea(
        child: Stack(
          children: [
            RepaintBoundary(
              key: _editorKey,
              child: Container(
                // Добавляем антиалиасинг
                decoration: const BoxDecoration(),
                clipBehavior: Clip.antiAlias,
                child: LindiStickerWidget(
                  controller: controller,
                  child: Container(
                    color: Colors.black,
                    width: double.infinity,
                    height: double.infinity,
                    child: const Center(
                      child: Text(
                        "Flet Image Editor",
                        style: TextStyle(
                          color: Colors.white, 
                          fontSize: 20,
                          // Добавляем сглаживание текста
                          fontFeatures: [ui.FontFeature.enable('liga')],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Кнопки управления
            Positioned(
              bottom: 30,
              right: 30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    heroTag: "save",
                    backgroundColor: Colors.greenAccent,
                    onPressed: _saveToImage,
                    child: const Icon(Icons.save_alt),
                  ),
                  const SizedBox(height: 15),
                  FloatingActionButton(
                    heroTag: "random",
                    backgroundColor: Colors.blueAccent,
                    onPressed: _randomizeActiveText,
                    child: const Icon(Icons.shuffle),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}