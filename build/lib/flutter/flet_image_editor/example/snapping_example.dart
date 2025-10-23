import 'package:flutter/material.dart';
import '../lib/sticker_widget/src/lindi_controller.dart';
import '../lib/sticker_widget/src/lindi_sticker_icon.dart';
import '../lib/sticker_widget/src/lindi_sticker_widget.dart';

/// Example demonstrating the snapping functionality
/// 
/// This example shows how to use the snapping feature to automatically
/// align stickers to the center guidelines.
class SnappingExample extends StatefulWidget {
  const SnappingExample({super.key});

  @override
  State<SnappingExample> createState() => _SnappingExampleState();
}

class _SnappingExampleState extends State<SnappingExample> {
  late LindiController controller;
  bool enableSnapping = true;
  double snapThreshold = 20;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    controller = LindiController(
      enableSnapping: enableSnapping,
      snapThreshold: snapThreshold,
      icons: [
        LindiStickerIcon(
          icon: Icons.delete,
          type: IconType.other,
          alignment: Alignment.topLeft,
          onTap: () {
            controller.selectedWidget?.delete();
          },
        ),
        LindiStickerIcon(
          icon: Icons.done,
          type: IconType.other,
          alignment: Alignment.topRight,
          onTap: () {
            controller.selectedWidget?.done();
          },
        ),
        LindiStickerIcon(
          icon: Icons.open_with_rounded,
          type: IconType.resize,
          alignment: Alignment.bottomRight,
        ),
      ],
    );
  }

  void _updateSettings() {
    setState(() {
      // Recreate controller with new settings
      controller.close();
      _initController();
    });
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snapping Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add sticker',
            onPressed: () {
              controller.add(
                _buildSampleSticker('Sticker ${controller.widgets.length + 1}'),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Settings panel
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Snapping Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: enableSnapping,
                      onChanged: (value) {
                        setState(() {
                          enableSnapping = value ?? true;
                          _updateSettings();
                        });
                      },
                    ),
                    const Text('Enable Snapping'),
                  ],
                ),
                Row(
                  children: [
                    const Text('Snap Threshold: '),
                    Expanded(
                      child: Slider(
                        value: snapThreshold,
                        min: 5,
                        max: 50,
                        divisions: 9,
                        label: '${snapThreshold.round()}px',
                        onChanged: enableSnapping
                            ? (value) {
                                setState(() {
                                  snapThreshold = value;
                                  _updateSettings();
                                });
                              }
                            : null,
                      ),
                    ),
                    Text('${snapThreshold.round()}px'),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  enableSnapping
                      ? 'Try dragging a sticker close to the center!'
                      : 'Snapping is disabled',
                  style: TextStyle(
                    color: enableSnapping ? Colors.green : Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          
          // Main canvas
          Expanded(
            child: Container(
              color: Colors.white,
              child: LindiStickerWidget(
                controller: controller,
                child: Container(
                  color: Colors.grey[100],
                  child: const Center(
                    child: Text(
                      'Tap + to add stickers\nDrag them to the center to see snapping!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSampleSticker(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.primaries[
            controller.widgets.length % Colors.primaries.length],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
