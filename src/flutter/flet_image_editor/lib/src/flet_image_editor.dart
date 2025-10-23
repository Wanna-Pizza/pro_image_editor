import 'dart:typed_data';

import 'package:flet/flet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../sticker_widget/lindi_sticker_widget.dart';
import 'dart:io';
import 'dart:math';
import 'dart:convert';
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
    
  void _sendEvent(String name, [dynamic data]) {
    widget.backend
        .triggerControlEvent(widget.control.id, name, data?.toString() ?? "");
  }

  void _debugPrintPython(String message) {
    debugPrint("🐛 Dart -> Python: $message");
    _sendEvent("debugPrint", message);
  }

  void addText({
    String? text,
    double? x,
    double? y,
    Color? color,
  }) {
    _debugPrintPython("Adding text: '$text' at position ($x, $y) with color $color");
    
    final textWidget = Text(
      text ?? "New Text",
      style: TextStyle(
        color: color ?? Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
    
    Alignment? position;
    if (x != null && y != null) {
      position = Alignment(x, y);
    }

    setState(() {
      controller.add(textWidget, position: position);
    });

    debugPrint("✅ Added text: ${text ?? 'New Text'} at position ($x, $y)");
  }

  void addImage({
    required String path,
    double? x,
    double? y,
    double? scale, 
  }) {
    _debugPrintPython("Adding image: '$path' at position ($x, $y) with scale $scale");
    
    if (path.isEmpty) {
      debugPrint("❌ Image path is empty");
      _debugPrintPython("ERROR: Image path is empty");
      return;
    }

    if (!File(path).existsSync()) {
      debugPrint("❌ Image file not found at $path");
      _debugPrintPython("ERROR: Image file not found at $path");
      return;
    }

    final imageScale = scale ?? 1.0;
    final imageWidget = Image.file(
      File(path),
      width: 150 * imageScale,
      height: 150 * imageScale,
      filterQuality: FilterQuality.high,
      isAntiAlias: true,
    );

    Alignment? position;
    if (x != null && y != null) {
      position = Alignment(x, y);
    }
    
    setState(() {
      controller.add(imageWidget, position: position);
    });

    debugPrint("✅ Added image: $path at position ($x, $y) with scale $imageScale");
    _debugPrintPython("Successfully added image: $path");
  }

  void updateTextDrawable(String? value, String? fontFamily) {
    final selected = controller.selectedWidget;
    if (selected == null) {
      debugPrint("❌ No active widget selected");
      return;
    }

    if (selected.child is! Text) {
      debugPrint("⚠️ Selected widget is not a Text widget");
      return;
    }

    final currentText = selected.child as Text;
    final currentStyle = currentText.style ?? const TextStyle();
    
    TextStyle newStyle = currentStyle.copyWith(
      fontFamily: fontFamily ?? currentStyle.fontFamily,
      color: currentStyle.color ?? Colors.white,
    );

    setState(() {
      selected.edit(
        Text(
          value ?? currentText.data ?? "",
          style: newStyle,
        ),
      );
    });

    debugPrint("✅ Updated text to: $value");
  }

  Future<Uint8List?> _saveToImage(double scale) async {
    try {
      controller.selectedWidget?.done();
      
      await Future.delayed(const Duration(milliseconds: 100));
      
      final boundary = _editorKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: scale);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      debugPrint("✅ Generated image bytes (${pngBytes.length} bytes)");
      
      return pngBytes;
    } catch (e, st) {
      debugPrint("❌ Error saving image: $e\n$st");
      return null;
    }
  }



  @override
  void initState() {
    super.initState();

    widget.backend.subscribeMethods(widget.control.id, _handleInvokeMethod);
    
    _debugPrintPython("FletImageEditor initialized");
    
    controller = LindiController(
      borderColor: Colors.white,
      icons: [
        LindiStickerIcon(
          icon: Icons.done,
          alignment: Alignment.topRight,
          onTap: () => setState(() => controller.selectedWidget?.done()),
        ),
        LindiStickerIcon(
          icon: Icons.lock_open,
          lockedIcon: Icons.lock,
          alignment: Alignment.topCenter,
          type: IconType.lock,
          onTap: () => setState(() => controller.selectedWidget?.lock()),
        ),
        LindiStickerIcon(
          icon: Icons.close,
          alignment: Alignment.topLeft,
          onTap: () => setState(() => controller.selectedWidget?.delete()),
        ),
        LindiStickerIcon(
          icon: Icons.edit,
          alignment: Alignment.centerLeft,
          onTap: () {
            final selectedWidget = controller.selectedWidget?.child;
            String widgetType = "unknown";
            
            if (selectedWidget is Text) {
              widgetType = "text";
            } else if (selectedWidget is Image) {
              widgetType = "sticker";
            }
            
            debugPrint("🎯 Edit icon tapped for widget type: $widgetType");
            _debugPrintPython("EDIT ICON TAPPED for widget type: $widgetType");
            _sendEvent("onEdit", widgetType);
          },
        ),
        LindiStickerIcon(
          icon: Icons.layers,
          alignment: Alignment.centerRight,
          onTap: () => setState(() => controller.selectedWidget?.stack()),
        ),
        LindiStickerIcon(
          icon: Icons.flip,
          alignment: Alignment.bottomLeft,
          onTap: () => setState(() => controller.selectedWidget?.flip()),
        ),
        LindiStickerIcon(
          icon: Icons.crop_free,
          alignment: Alignment.bottomRight,
          type: IconType.resize,
        ),
      ],
    );

    controller.addListener(() {
      debugPrint("🎯 Controller listener triggered");
      _debugPrintPython("Controller listener triggered - selected widget changed");
    });
  }

  @override
  void dispose() {
    controller.dispose();
    widget.backend.unsubscribeMethods(widget.control.id);
    super.dispose();
  }

  Future<String?> _handleInvokeMethod(
      String methodName, Map<String, String> args) async {
    debugPrint("FletPainter.onMethod(${widget.control.id}): $methodName");
    var theme = Theme.of(context);
    switch (methodName) {
      case "addText":
        addText(
          text: args["text"],
          x: parseDouble(args["x"]),
          y: parseDouble(args["y"]),
          color: parseColor(theme, args["color"])
        );
        break;

      case "addImage":
        addImage(
          path: args["path"] ?? "",
          x: parseDouble(args["x"]),
          y: parseDouble(args["y"]),
          scale: parseDouble(args["scale"]),
        );
        break;

      case "changeText":
        updateTextDrawable(args["text"], args["fontFamily"]);
        break;

      case "saveImage":
        var scale = parseDouble(args["scale"]) ?? 1.0;
        var bytes = await _saveToImage(scale);
        if (bytes != null) {
          _sendEvent("on_save", base64Encode(bytes));
          return "success";
        } else {
          return "failed";
        }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: SafeArea(
        child: RepaintBoundary(
          key: _editorKey,
          child: Container(
            decoration: const BoxDecoration(),
            clipBehavior: Clip.antiAlias,
            child: LindiStickerWidget(
              controller: controller,
              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),
      ),
    );
  }
}