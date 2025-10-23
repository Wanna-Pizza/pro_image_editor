## Snapping API Reference

### LindiController

#### Constructor Parameters

```dart
LindiController({
  // ... existing parameters
  
  /// Enable automatic snapping to center guidelines
  /// Default: true
  bool enableSnapping = true,
  
  /// Distance threshold in pixels for snap activation
  /// When a widget is within this distance from center, it snaps
  /// Default: 20
  double snapThreshold = 20,
})
```

#### Public Properties

```dart
/// Controls visibility of vertical center guideline
final ValueNotifier<bool> verticalGuidelineVisible;

/// Controls visibility of horizontal center guideline
final ValueNotifier<bool> horizontalGuidelineVisible;

/// Whether snapping is enabled
final bool enableSnapping;

/// Snap activation threshold in pixels
final double snapThreshold;
```

### Usage Examples

#### Basic Usage with Default Settings

```dart
final controller = LindiController(
  icons: [...],
  // Snapping enabled by default with 20px threshold
);
```

#### Custom Snap Threshold

```dart
final controller = LindiController(
  icons: [...],
  enableSnapping: true,
  snapThreshold: 30, // Larger snap zone
);
```

#### Disable Snapping

```dart
final controller = LindiController(
  icons: [...],
  enableSnapping: false,
);
```

#### Listen to Guideline Visibility

```dart
controller.verticalGuidelineVisible.addListener(() {
  print('Vertical guideline: ${controller.verticalGuidelineVisible.value}');
});

controller.horizontalGuidelineVisible.addListener(() {
  print('Horizontal guideline: ${controller.horizontalGuidelineVisible.value}');
});
```

#### Programmatically Show/Hide Guidelines

```dart
// Show vertical guideline
controller.verticalGuidelineVisible.value = true;

// Hide horizontal guideline  
controller.horizontalGuidelineVisible.value = false;
```

### Visual Customization

The guidelines are rendered in `LindiStickerWidget` and can be customized:

**Default appearance:**
- Color: `Colors.blue.withOpacity(0.7)`
- Width: `1px` (vertical line)
- Height: `1px` (horizontal line)
- Position: Center of the canvas

**To customize, modify the guidelines in `lindi_sticker_widget.dart`:**

```dart
// Vertical guideline
Container(
  width: 1,
  color: Colors.blue.withOpacity(0.7), // Change this
)

// Horizontal guideline
Container(
  height: 1,
  color: Colors.blue.withOpacity(0.7), // Change this
)
```

### How It Works

1. **Detection Phase**: When dragging a widget, `LindiGestureDetector` calculates the distance from widget center to canvas center
2. **Snap Decision**: If distance < `snapThreshold` on X or Y axis, snapping activates
3. **Position Adjustment**: Widget position is adjusted to align perfectly with center
4. **Visual Feedback**: Guideline becomes visible for the aligned axis
5. **Cleanup**: After drag ends, guidelines fade out after 100ms

### Best Practices

✅ **DO:**
- Keep `snapThreshold` between 15-30px for good UX
- Enable snapping for precise layout tools
- Use guidelines as visual feedback

❌ **DON'T:**
- Set `snapThreshold` too high (>50px) - feels sticky
- Set `snapThreshold` too low (<10px) - hard to trigger
- Disable snapping without providing alternative alignment tools

### Performance Notes

- Snapping calculations happen only during active drag
- Guidelines use `ValueNotifier` for efficient updates
- No performance impact when `enableSnapping: false`
- Cleanup timer prevents guideline flicker

### Migration Guide

If you have existing code using `LindiController`, snapping is **automatically enabled** with default settings. No breaking changes.

**Before:**
```dart
final controller = LindiController(icons: [...]);
```

**After (same code, snapping now works!):**
```dart
final controller = LindiController(icons: [...]);
// Snapping enabled by default
```

**To disable:**
```dart
final controller = LindiController(
  icons: [...],
  enableSnapping: false,
);
```
