import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

// --- CALM VISUAL CONSTANTS ---
class CalmPalette {
  // Atmospheric Gradient Colors
  // KEY: All colors must share a hue family (Blue-Grey) to blend perfectly.
  static const Color skyTop = Color(0xFFCFD8DC);    // Light Blue-Grey (Sky)
  static const Color skyMist = Color(0xFFB0BEC5);   // Mid Blue-Grey (Horizon) - NO CREAM
  static const Color deepWater = Color(0xFF78909C); // Darker Blue-Grey (Depth)
  
  // Nature
  static const Color grassBase = Color(0xFF8DA399); // Sage Green
  static const Color grassHighlight = Color(0xFF9FB5AB); // Restored
  
  // Cliff now has a gradient, these are the stops
  static const Color cliffTop = Color(0xFF6D6466);  // Warm Grey
  static const Color cliffBottom = Color(0xFF78909C); // Matches deepWater exactly!
  static const Color cliffShadow = Color(0xFF585052); // Restored
  
  static const Color sandBase = Color(0xFFE0D8CC);  
  
  // Structures
  static const Color houseWall = Color(0xFFD7CCC8); 
  static const Color houseRoof = Color(0xFF8D6E63); 
  static const Color houseDoor = Color(0xFF8D6E63); 
  
  // Character
  static const Color charSkin = Color(0xFFFFCCBC); 
  static const Color charCloth = Color(0xFF5D4037); 
}

class IslandBaseLayer extends StatefulWidget {
  final bool isFocusing;
  final double width;

  const IslandBaseLayer({
    super.key,
    required this.isFocusing,
    required this.width,
  });

  @override
  State<IslandBaseLayer> createState() => _IslandBaseLayerState();
}

class _IslandBaseLayerState extends State<IslandBaseLayer> with TickerProviderStateMixin {
  late AnimationController _patrolController;
  late AnimationController _walkCycleController;
  
  Timer? _behaviorTimer;
  bool _isCharacterWalking = true;

  @override
  void initState() {
    super.initState();
    _patrolController = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 14), 
    );
    
    _walkCycleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    if (widget.isFocusing) {
      _startAnimations(); 
    }
  }

  @override
  void didUpdateWidget(IslandBaseLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFocusing && !oldWidget.isFocusing) {
      _startAnimations();
    } else if (!widget.isFocusing && oldWidget.isFocusing) {
      _stopAnimations();
    }
  }
  
  void _startAnimations() {
    _scheduleBehavior();
  }
  
  void _stopAnimations() {
    _behaviorTimer?.cancel();
    _patrolController.stop();
    _walkCycleController.stop();
    _walkCycleController.animateTo(0, duration: const Duration(milliseconds: 200));
  }
  
  void _scheduleBehavior() {
    if (!mounted || !widget.isFocusing) return;

    final isWalking = _isCharacterWalking;
    final duration = Duration(seconds: 4 + math.Random().nextInt(4));
        
    setState(() {
      _isCharacterWalking = !isWalking; 
      
      if (_isCharacterWalking) {
        _patrolController.repeat(reverse: true);
        _walkCycleController.repeat();
      } else {
        _patrolController.stop();
        _walkCycleController.animateTo(0, duration: const Duration(milliseconds: 200)); 
      }
    });

    _behaviorTimer = Timer(duration, _scheduleBehavior);
  }

  @override
  void dispose() {
    _behaviorTimer?.cancel();
    _patrolController.dispose();
    _walkCycleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.width;
    
    return Container(
      width: w,
      height: w, 
      // TRANSPARENT BACKGROUND - World Context provided by Parent
      decoration: const BoxDecoration(
        color: Colors.transparent, 
      ),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 0. SOFT FLOATING SHADOW (Atmospheric Grounding)
          Positioned(
             bottom: w * 0.05, // Moved lower to detach slightly
             child: Container(
               width: w * 0.9,
               height: w * 0.3,
               decoration: BoxDecoration(
                 gradient: RadialGradient(
                   colors: [
                     CalmPalette.deepWater.withOpacity(0.12), // Subtle Blue-Grey tint
                     Colors.transparent,
                   ],
                   radius: 1.0, // Very soft spread
                 ),
               ),
             ),
          ),
          
          // 1. ISLAND GEO (Gradient Blend)
          Positioned(
             bottom: w * 0.15,
             child: SizedBox(
               width: w * 0.95, 
               height: w * 0.55, 
               child: CustomPaint(painter: CalmIslandPainter()),
             ),
          ),
          
          // 2. HOUSE
          Positioned(
            bottom: w * 0.48, 
            left: w * 0.05,  
            child: CalmHouseWidget(size: w * 0.50), 
          ),

          // 3. TREES
          Positioned(
             bottom: w * 0.48,
             right: w * 0.15, 
             child: CalmTreeWidget(size: w * 0.45, isFocusing: widget.isFocusing, delay: 0),
          ),
          Positioned(
             bottom: w * 0.50,
             right: w * 0.05, 
             child: CalmTreeWidget(size: w * 0.35, isFocusing: widget.isFocusing, delay: 1),
          ),

          // 4. CHARACTER
          AnimatedBuilder(
            animation: Listenable.merge([_patrolController, _walkCycleController]),
            builder: (context, child) {
              final t = _patrolController.value;
              final minX = w * 0.35;
              final maxX = w * 0.60;
              final currentLeft = minX + ((maxX - minX) * t); 
              
              final isMovingRight = _patrolController.status == AnimationStatus.forward;
              final walkVal = _walkCycleController.value;
              final useSideView = _isCharacterWalking; 
              
              final bob = useSideView 
                  ? -2.0 * math.sin(walkVal * math.pi * 2).abs() 
                  : 0.0;

              return Positioned(
                bottom: (w * 0.48) + bob, 
                left: currentLeft,
                child: CalmCharacterWidget(
                  isFocusing: widget.isFocusing, 
                  walkProgress: walkVal,
                  isFacingLeft: !isMovingRight,
                  size: w * 0.09, 
                  isWalking: useSideView,
                ),
              );
            }
          ),
        ],
      ),
    );
  }
}

// --- PAINTERS ---

class CalmIslandPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    // 1. CLIFF BODY (Gradient Fill for blending)
    final cliffPath = Path();
    cliffPath.moveTo(-w * 0.05, h * 0.4);
    cliffPath.quadraticBezierTo(w * 0.5, h * 0.9, w * 1.05, h * 0.4);
    cliffPath.lineTo(w * 1.05, h * 0.35);
    cliffPath.quadraticBezierTo(w * 0.5, h * 0.15, -w * 0.05, h * 0.35);
    cliffPath.close();
    
    // Gradient: Top (Color) -> Bottom (Water)
    final cliffPaint = Paint()
      ..shader = LinearGradient(
         begin: Alignment.topCenter,
         end: Alignment.bottomCenter,
         colors: [
           CalmPalette.cliffTop,
           CalmPalette.cliffBottom, // Blends into water
         ],
         stops: [0.3, 1.0]
      ).createShader(Rect.fromLTWH(0, 0, w, h));
      
    canvas.drawPath(cliffPath, cliffPaint);
    
    // 2. GRASS SURFACE
    final grassPath = Path();
    grassPath.moveTo(-w * 0.05, h * 0.35);
    grassPath.cubicTo(w*0.3, h*0.1, w*0.7, h*0.1, w*1.05, h*0.35);
    grassPath.quadraticBezierTo(w*0.5, h*0.55, -w*0.05, h*0.35);
    canvas.drawPath(grassPath, Paint()..color = CalmPalette.grassBase);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CalmHouseWidget extends StatelessWidget {
  final double size;
  const CalmHouseWidget({super.key, required this.size});
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: size, height: size * 0.7, child: CustomPaint(painter: _CalmHousePainter()));
  }
}

class _CalmHousePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Main Block
    paint.color = CalmPalette.houseWall;
    final wallRect = Rect.fromLTWH(w * 0.1, h * 0.4, w * 0.8, h * 0.6);
    canvas.drawRRect(RRect.fromRectAndRadius(wallRect, const Radius.circular(4)), paint);
    
    // Roof
    final roofPath = Path();
    roofPath.moveTo(-w*0.05, h * 0.45);
    roofPath.quadraticBezierTo(w * 0.5, h * 0.1, w * 1.05, h * 0.45);
    roofPath.close();
    paint.color = CalmPalette.houseRoof;
    canvas.drawPath(roofPath, paint);
    
    // Door
    paint.color = CalmPalette.houseDoor.withOpacity(0.8);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.45, h * 0.65, w * 0.15, h * 0.35), const Radius.circular(2)), paint);
    
    // Windows
    paint.color = Colors.white.withOpacity(0.3);
    canvas.drawCircle(Offset(w * 0.25, h * 0.65), w * 0.06, paint);
    canvas.drawCircle(Offset(w * 0.75, h * 0.65), w * 0.06, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CalmTreeWidget extends StatefulWidget {
  final double size;
  final bool isFocusing;
  final int delay;
  const CalmTreeWidget({super.key, required this.size, required this.isFocusing, this.delay = 0});
  @override
  State<CalmTreeWidget> createState() => _CalmTreeWidgetState();
}

class _CalmTreeWidgetState extends State<CalmTreeWidget> with SingleTickerProviderStateMixin {
  late AnimationController _swayController;
  @override
  void initState() {
    super.initState();
    _swayController = AnimationController(vsync: this, duration: Duration(seconds: 5 + widget.delay));
    if(widget.isFocusing) _swayController.repeat(reverse: true);
  }
  @override
  void didUpdateWidget(CalmTreeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFocusing && !oldWidget.isFocusing) {
       _swayController.repeat(reverse: true);
    } else if (!widget.isFocusing && oldWidget.isFocusing) {
       _swayController.stop(); 
       _swayController.animateTo(0.5, curve: Curves.easeOut);
    }
  }
  @override
  void dispose() {
    _swayController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _swayController,
      builder: (context, child) {
        double sway = 0;
        if (widget.isFocusing) {
           sway = math.sin(_swayController.value * math.pi * 2) * 0.03; // Even subtler
        }
        return CustomPaint(
          size: Size(widget.size, widget.size), 
          painter: _CalmTreePainter(swayValue: sway)
        );
      }
    );
  }
}

class _CalmTreePainter extends CustomPainter {
  final double swayValue;
  _CalmTreePainter({required this.swayValue});
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final trunkPaint = Paint()..color = CalmPalette.cliffShadow;
    final foliagePaint = Paint()..color = CalmPalette.grassHighlight;

    // 1. TRUNK
    final trunkRect = Rect.fromLTWH(w * 0.48, h * 0.6, w * 0.04, h * 0.4);
    canvas.drawRect(trunkRect, trunkPaint);
    
    // 2. FOLIAGE
    canvas.save();
    canvas.translate(w * 0.5, h * 0.6); 
    canvas.rotate(swayValue * 0.08); 
    canvas.drawCircle(Offset(0, -h * 0.15), w * 0.25, foliagePaint);
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant _CalmTreePainter oldDelegate) => swayValue != oldDelegate.swayValue;
}

class CalmCharacterWidget extends StatelessWidget {
  final bool isFocusing; // Unused for color now, but kept for interface consistency
  final double size;
  final double walkProgress;
  final bool isFacingLeft;
  final bool isWalking;

  const CalmCharacterWidget({
    super.key, 
    required this.isFocusing, 
    required this.size,
    required this.walkProgress,
    required this.isFacingLeft,
    required this.isWalking,
  });

  @override
  Widget build(BuildContext context) {
    // If NOT walking, we ignore isFacingLeft horizontal flip to keep the "Front" view not mirrored weirdly?
    // Actually Front view is symmetric mostly, but flipping might move the blush/hair if not perfectly centered.
    // Let's keep flip logic ONLY for side view.
    
    if (!isWalking) {
       return SizedBox(
         width: size, height: size * 2.2, 
         child: CustomPaint(
           painter: _CalmCharacterPainter(
             walkProgress: 0,
             isMoving: false,
             viewMode: CharacterViewMode.front,
           )
         ),
       );
    }

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..scale(isFacingLeft ? -1.0 : 1.0, 1.0),
      child: SizedBox(
         width: size, height: size * 2.2, 
         child: CustomPaint(
           painter: _CalmCharacterPainter(
             walkProgress: walkProgress,
             isMoving: true,
             viewMode: CharacterViewMode.side,
           )
         ),
      ),
    );
  }
}

enum CharacterViewMode { front, side }

class _CalmCharacterPainter extends CustomPainter {
  final double walkProgress;
  final bool isMoving;
  final CharacterViewMode viewMode;
  
  _CalmCharacterPainter({
    required this.walkProgress, 
    required this.isMoving,
    required this.viewMode,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double centerX = w / 2;
    
    // Missing Paint definition re-added
    final Paint p = Paint()..style = PaintingStyle.fill;
    
    // --- PALETTE (Earth Tones & Softness) ---
    // Skin: Warm gentle peach
    final skinGradient = RadialGradient(
      colors: [Color(0xFFFFCCBC), Color(0xFFFFAB91)], 
      center: Alignment(0.0, -0.2),
      radius: 0.5,
    );
    
    // Hair: Soft dark brown (Natural)
    final hairGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF4E342E), Color(0xFF3E2723)], 
    );
    
    // Cloth: Muted Sage/Brown Tunic (Organic)
    final clothGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF8D6E63), Color(0xFF6D4C41)], 
    );

    // --- FRONT VIEW (Stopped/Idle) ---
    if (viewMode == CharacterViewMode.front) {
       // 0. BACK HAIR (Simple Soft Drape - Zen)
       p.shader = hairGradient.createShader(Rect.fromLTWH(0, 0, w, h));
       final backHairPath = Path();
       backHairPath.moveTo(centerX, h * 0.3); 
       // Left Drape (Smooth flow down)
       backHairPath.cubicTo(centerX - w*0.35, h * 0.4, centerX - w*0.3, h * 0.7, centerX - w*0.2, h * 0.75);
       // Bottom Hem (Soft curve)
       backHairPath.quadraticBezierTo(centerX, h * 0.8, centerX + w*0.2, h * 0.75); 
       // Right Drape
       backHairPath.cubicTo(centerX + w*0.3, h * 0.7, centerX + w*0.35, h * 0.4, centerX, h * 0.3);
       backHairPath.close();
       canvas.drawPath(backHairPath, p);

       // 1. BODY (Tunica with Visible Arms)
       p.shader = clothGradient.createShader(Rect.fromLTWH(0, 0, w, h));
       final bodyPath = Path();
       // Neck
       bodyPath.moveTo(centerX - w*0.1, h * 0.44); 
       // Left Shoulder
       bodyPath.quadraticBezierTo(centerX - w*0.25, h * 0.46, centerX - w*0.28, h * 0.55); 
       // Left Arm Down
       bodyPath.lineTo(centerX - w*0.26, h * 0.75); 
       // Tunic Hem Check
       bodyPath.quadraticBezierTo(centerX, h * 0.94, centerX + w*0.26, h * 0.75); // Bottom hem connection
       // Right Arm Up
       bodyPath.lineTo(centerX + w*0.28, h * 0.55);
       // Right Shoulder
       bodyPath.quadraticBezierTo(centerX + w*0.25, h * 0.46, centerX + w*0.1, h * 0.44);
       bodyPath.close();
       canvas.drawPath(bodyPath, p);

       // LEGS (Under)
       p.shader = null;
       p.color = const Color(0xFF3E2723); 
       canvas.drawRect(Rect.fromLTWH(centerX - w*0.07, h*0.88, w*0.05, h*0.12), p);
       canvas.drawRect(Rect.fromLTWH(centerX + w*0.02, h*0.88, w*0.05, h*0.12), p);

       // ARMS & HANDS (Front View - Visible)
       p.shader = clothGradient.createShader(Rect.fromLTWH(0,0,w,h));
       // Left Sleeve
       final leftArm = Path();
       leftArm.moveTo(centerX - w*0.28, h*0.55);
       leftArm.quadraticBezierTo(centerX - w*0.32, h*0.65, centerX - w*0.28, h*0.75); // Outer
       leftArm.lineTo(centerX - w*0.22, h*0.75); // Cuff
       leftArm.lineTo(centerX - w*0.22, h*0.58); // Inner
       leftArm.close();
       canvas.drawPath(leftArm, p);
       
       // Right Sleeve
       final rightArm = Path();
       rightArm.moveTo(centerX + w*0.28, h*0.55);
       rightArm.quadraticBezierTo(centerX + w*0.32, h*0.65, centerX + w*0.28, h*0.75);
       rightArm.lineTo(centerX + w*0.22, h*0.75);
       rightArm.lineTo(centerX + w*0.22, h*0.58);
       rightArm.close();
       canvas.drawPath(rightArm, p);

       // HANDS (Skin Tone - Simple Ovals)
       p.shader = null;
       p.color = const Color(0xFFFFCCBC); 
       canvas.drawOval(Rect.fromCenter(center: Offset(centerX - w*0.25, h*0.78), width: w*0.06, height: w*0.06), p);
       canvas.drawOval(Rect.fromCenter(center: Offset(centerX + w*0.25, h*0.78), width: w*0.06, height: w*0.06), p);

       // NECK
       p.shader = null;
       p.color = const Color(0xFFFFAB91); 
       canvas.drawRect(Rect.fromCenter(center: Offset(centerX, h * 0.42), width: w*0.11, height: h*0.08), p);

       // 3. HEAD (Soft Round Oval)
       p.shader = skinGradient.createShader(Rect.fromLTWH(0, 0, w, h));
       final headRect = Rect.fromCenter(center: Offset(centerX, h * 0.29), width: w * 0.36, height: h * 0.27);
       canvas.drawOval(headRect, p);
       
       // 4. FACE DETAILS
       p.shader = null;
       
       // Blush
       p.color = const Color(0xFFFF8A65).withOpacity(0.15); 
       p.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0); 
       canvas.drawOval(Rect.fromCenter(center: Offset(centerX - w*0.1, h*0.33), width: w*0.08, height: w*0.05), p);
       canvas.drawOval(Rect.fromCenter(center: Offset(centerX + w*0.1, h*0.33), width: w*0.08, height: w*0.05), p);
       p.maskFilter = null;
       
       // EYES
       p.color = const Color(0xFFF5F5F5); 
       canvas.drawOval(Rect.fromCenter(center: Offset(centerX - w*0.08, h*0.29), width: w*0.07, height: w*0.045), p);
       canvas.drawOval(Rect.fromCenter(center: Offset(centerX + w*0.08, h*0.29), width: w*0.07, height: w*0.045), p);
       
       // Iris
       p.color = const Color(0xFF5D4037); 
       canvas.drawCircle(Offset(centerX - w*0.08, h*0.29), w*0.022, p);
       canvas.drawCircle(Offset(centerX + w*0.08, h*0.29), w*0.022, p);
       
       // Highlight
       p.color = Colors.white.withOpacity(0.6);
       canvas.drawCircle(Offset(centerX - w*0.09, h*0.285), w*0.006, p);
       canvas.drawCircle(Offset(centerX + w*0.07, h*0.285), w*0.006, p);

       // MOUTH
       p.color = const Color(0xFF8D6E63);
       p.style = PaintingStyle.stroke;
       p.strokeWidth = 0.7;
       canvas.drawArc(Rect.fromCenter(center: Offset(centerX, h*0.34), width: w*0.035, height: w*0.015), 0, math.pi, false, p);

       // GLASSES (Significant Size Increase)
       p.color = const Color(0xFF455A64);
       p.strokeWidth = 0.9;
       // Larger + Framing Face
       canvas.drawOval(Rect.fromCenter(center: Offset(centerX - w*0.08, h*0.29), width: w*0.12, height: w*0.09), p);
       canvas.drawOval(Rect.fromCenter(center: Offset(centerX + w*0.08, h*0.29), width: w*0.12, height: w*0.09), p);
       canvas.drawLine(Offset(centerX - w*0.02, h*0.29), Offset(centerX + w*0.02, h*0.29), p);

       // 5. FRONT HAIR CAP (Smooth Helmet)
       p.style = PaintingStyle.fill;
       p.shader = hairGradient.createShader(Rect.fromLTWH(0, 0, w, h));
       final hairCap = Path();
       hairCap.moveTo(centerX, h * 0.12); // High Crown
       // Wrap Left Full
       hairCap.cubicTo(centerX - w*0.3, h * 0.12, centerX - w*0.28, h * 0.35, centerX - w*0.2, h * 0.45);
       // Forehead Sweep
       hairCap.quadraticBezierTo(centerX - w*0.1, h * 0.22, centerX, h * 0.24); 
       hairCap.quadraticBezierTo(centerX + w*0.1, h * 0.22, centerX + w*0.2, h * 0.45);
       // Wrap Right Full
       hairCap.cubicTo(centerX + w*0.28, h * 0.35, centerX + w*0.3, h * 0.12, centerX, h * 0.12);
       hairCap.close();
       canvas.drawPath(hairCap, p);

       return;
    }

    // --- SIDE VIEW (Walking) - Clean Minimalist Silhouette ---
    // Animation Math
    double legOffset = 0;
    double armAngle = 0;
    double bob = 0;
    
    if (isMoving) {
      final t = walkProgress * math.pi * 2;
      legOffset = math.sin(t) * (w * 0.12);
      armAngle = math.cos(t) * 0.4; 
      bob = -0.5 * math.sin(t * 2).abs(); 
    }

    canvas.save();
    canvas.translate(0, bob); 

    // 0. HAIR HELMET (Single "Zen" Shape - No Ponytail)
    p.shader = hairGradient.createShader(Rect.fromLTWH(0,0,w,h));
    final hairHelmet = Path();
    // Start at Forehead Top
    hairHelmet.moveTo(centerX + w*0.12, h * 0.22); 
    // Smooth Arc over Cranium (Big Volume)
    hairHelmet.cubicTo(centerX - w*0.1, h * 0.1, centerX - w*0.35, h * 0.15, centerX - w*0.35, h * 0.45); 
    // Curve down smoothly to Nape (No ponytail bump)
    hairHelmet.quadraticBezierTo(centerX - w*0.25, h * 0.65, centerX - w*0.15, h * 0.7);
    // Connection to Jaw/Ear
    hairHelmet.quadraticBezierTo(centerX - w*0.05, h * 0.6, centerX + w*0.05, h * 0.45);
    // Sideburn/Cheek Sweep
    hairHelmet.quadraticBezierTo(centerX + w*0.15, h * 0.35, centerX + w*0.12, h * 0.22);
    hairHelmet.close();
    canvas.drawPath(hairHelmet, p);

    // LEGS 
    p.shader = null;
    p.color = const Color(0xFF3E2723);
    canvas.drawRect(Rect.fromLTWH(centerX - w*0.05 + legOffset, h*0.85, w*0.08, h*0.15), p);

    // BODY (Profile)
    p.shader = clothGradient.createShader(Rect.fromLTWH(0,0,w,h));
    final sidePath = Path();
    sidePath.moveTo(centerX, h * 0.42); 
    sidePath.cubicTo(centerX - w*0.15, h * 0.5, centerX - w*0.2, h * 0.8, centerX - w*0.05, h * 0.92); 
    sidePath.lineTo(centerX + w*0.15, h * 0.9); 
    sidePath.quadraticBezierTo(centerX + w*0.18, h * 0.6, centerX + w*0.05, h * 0.45); 
    sidePath.close();
    canvas.drawPath(sidePath, p);

    // HEAD (Profile - Nested inside Hair)
    p.shader = skinGradient.createShader(Rect.fromLTWH(0,0,w,h));
    final headProfile = Path();
    headProfile.moveTo(centerX + w*0.1, h*0.25); // Hairline start
    headProfile.cubicTo(centerX + w*0.25, h*0.3, centerX + w*0.2, h*0.4, centerX + w*0.1, h*0.45); // Face
    headProfile.lineTo(centerX, h*0.45); // Jaw
    headProfile.lineTo(centerX, h*0.25); // Back (hidden)
    headProfile.close();
    canvas.drawPath(headProfile, p);
    
    // ARM
    canvas.save();
    canvas.translate(centerX, h * 0.48); 
    canvas.rotate(armAngle);
    p.shader = clothGradient.createShader(Rect.fromLTWH(0,0,w,h));
    final armPath = Path();
    armPath.moveTo(0, 0);
    armPath.quadraticBezierTo(w*0.08, h*0.1, 0, h*0.2);
    armPath.lineTo(-w*0.08, h*0.2);
    armPath.quadraticBezierTo(-w*0.12, h*0.1, 0, 0);
    canvas.drawPath(armPath, p);
    // Hand
    p.shader = null;
    p.color = const Color(0xFFFFCCBC);
    canvas.drawCircle(Offset(-w*0.04, h*0.22), w*0.045, p);
    canvas.restore();
    
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
