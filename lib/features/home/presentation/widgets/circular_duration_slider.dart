import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';

class CircularDurationSlider extends StatefulWidget {
  final double width;
  final int currentCheckSeconds; // For progress during focus
  final int totalSeconds; // Max duration setting
  final bool isFocusing;
  final ThemeState themeState;
  final ValueChanged<int>? onDurationChanged;

  const CircularDurationSlider({
    super.key,
    required this.width,
    required this.currentCheckSeconds,
    required this.totalSeconds,
    required this.isFocusing,
    required this.themeState,
    this.onDurationChanged,
  });

  @override
  State<CircularDurationSlider> createState() => _CircularDurationSliderState();
}

class _CircularDurationSliderState extends State<CircularDurationSlider> {
  // If we are dragging, we track the local drag value to update immediately
  // before committing? No, the requirements say "Updates the numeric timer in real time".
  // So we just call onChanged immediately.
  
  double _lastProgress = 0.0;

  void _handlePan(DragUpdateDetails details) {
    if (widget.isFocusing) return; // Inactive during focus
    
    final size = widget.width;
    final center = Offset(size / 2, size / 2);
    final localPoint = details.localPosition;
    
    // Calculate angle from center
    // atan2(y, x) -> returns radians from -pi to pi
    // 0 is right (3 o'clock).
    // We want 0 at top (12 o'clock).
    
    final dx = localPoint.dx - center.dx;
    final dy = localPoint.dy - center.dy;
    
    double angle = math.atan2(dy, dx); 
    // angle is -pi at 9 o'clock (via top?) no.
    // Right = 0
    // Down = PI/2
    // Left = PI or -PI
    // Top = -PI/2
    
    // Convert to 0 -> 2PI starting from Top (-PI/2)
    // Add PI/2 to rotate reference frame?
    // angle += math.pi / 2;
    // if (angle < 0) angle += 2 * math.pi;
    
    double adjustedAngle = angle + math.pi / 2;
    if (adjustedAngle < 0) adjustedAngle += 2 * math.pi;
    
    // adjustedAngle is now 0 at top, increasing colockwise to 2PI.
    
    // Normalize to 0.0 - 1.0
    double progress = adjustedAngle / (2 * math.pi);
    
    // CLAMPING LOGIC (Prevent Wrap-Around)
    // If wrapping from near 0 to near 1 (Left Drag at Top)
    if (_lastProgress < 0.2 && progress > 0.8) {
       progress = 0.0; // Stick to min
    }
    // If wrapping from near 1 to near 0 (Right Drag at Top)
    else if (_lastProgress > 0.8 && progress < 0.2) {
       progress = 1.0; // Stick to max
    }
    
    _lastProgress = progress;

    // Convert to minutes (1 to 120)
    int minutes = (progress * 120).round();
    if (minutes < 1) minutes = 1; // Minimum 1 min
    if (minutes > 120) minutes = 120;
    
    // SNAP LOGIC (Gentle snapping to 5 mins)
    // If close to a 5 min mark, snap?
    // User requested "Gentle snapping".
    int remainder = minutes % 5;
    if (remainder != 0) {
      if (remainder < 2) {
        minutes -= remainder;
      } else if (remainder > 3) {
        minutes += (5 - remainder);
      }
    }
    if (minutes < 1) minutes = 1; // Safety after snap
    if (minutes > 120) minutes = 120; // Safety
    
    widget.onDurationChanged?.call(minutes);
  }

  @override
  Widget build(BuildContext context) {
    // FOCUS STATE BEHAVIOR: Handled by Parent Opacity
    // if (widget.isFocusing) {
    //    return const SizedBox.shrink(); 
    // }

    return GestureDetector(
      onPanUpdate: _handlePan,
      onPanStart: (details) {
         // handle tap/start behavior if needed
         _handlePan(DragUpdateDetails(globalPosition: details.globalPosition, localPosition: details.localPosition));
      },
      child: CustomPaint(
        size: Size(widget.width, widget.width),
        painter: _CircularSliderPainter(
          themeState: widget.themeState,
          isFocusing: widget.isFocusing, // Will always be false here effectively
          progress: (widget.currentCheckSeconds / 60) / 120.0, // Setting fraction
        ),
      ),
    );
  }
}

class _CircularSliderPainter extends CustomPainter {
  final ThemeState themeState;
  final bool isFocusing; // Retained for painter logic if needed later, but effective false
  final double progress;

  _CircularSliderPainter({
    required this.themeState,
    required this.isFocusing,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Radius: Fit within size, minus padding
    final radius = (size.width / 2) - 8; 
    
    final isNight = themeState.mode == AppThemeMode.night;
    
    // GLASS MATERIAL COLORS (Pre-Focus Only)
    // Track: Very subtle glass
    final Color trackColor = isNight 
        ? Colors.white.withOpacity(0.08) 
        : Colors.black.withOpacity(0.04);
        
    // Progress: Visible Glass Control
    final Color progressColor = isNight
        ? Colors.white.withOpacity(0.5) 
        : Colors.white.withOpacity(0.65); // Soft white glass
        
    // Knob: Tactile Handle
    final Color knobColor = isNight 
        ? Colors.white.withOpacity(0.95) 
        : Colors.white;

    // Paint Track (Full Circle)
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6 // Thicker for tactile feel
      ..strokeCap = StrokeCap.round;
      
    canvas.drawCircle(center, radius, trackPaint);
    
    // Paint Progress Arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6 // Match thickness
      ..strokeCap = StrokeCap.round;

    double sweepAngle = 2 * math.pi * progress;
    if (sweepAngle > 2 * math.pi) sweepAngle = 2 * math.pi;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
    
    // Knob (Only when setting)
    final knobAngle = -math.pi / 2 + sweepAngle;
    final knobOffset = Offset(
      center.dx + radius * math.cos(knobAngle),
      center.dy + radius * math.sin(knobAngle),
    );
    
    // Knob Shadow for Lift
    canvas.drawCircle(knobOffset, 8, Paint()..color = Colors.black.withOpacity(0.1)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));
    canvas.drawCircle(knobOffset, 8, Paint()..color = knobColor); // Larger knob
  }

  @override
  bool shouldRepaint(covariant _CircularSliderPainter oldDelegate) {
     return oldDelegate.progress != progress ||
            oldDelegate.isFocusing != isFocusing ||
            oldDelegate.themeState != themeState;
  }
}
