import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';

// --- CALM VISUAL CONSTANTS ---
class CalmPalette {
  // Atmospheric Gradient Colors
  // KEY: All colors must share a hue family (Blue-Grey) to blend perfectly.
  // UPDATE: Muted Overcast Day Theme (Per visual comfort request)
  static const Color skyTop = Color(0xFFD8E1E6);    // Muted grey-blue (Overcast, not bright white)
  static const Color skyMist = Color(0xFFCED6DA);   // Soft neutral grey
  static const Color deepWater = Color(0xFFB0BBC2); // Grounded slate blue-grey
  
  // Night Theme (Focus State)
  static const Color nightSkyTop = Color(0xFF37474F);    // Deep Calm Blue-Grey
  static const Color nightSkyMist = Color(0xFF546E7A);   // Muted Slate
  static const Color nightDeepWater = Color(0xFF263238); // Abyss
  
  // Lighting
  static const Color lightWarm = Color(0xFFFFE082);      // Soft Amber/Yellow Glow (Low Intensity)

  // Nature
  static const Color grassBase = Color(0xFF8DA399); // Sage Green
  static const Color grassHighlight = Color(0xFF9FB5AB); // Restored
  
  // Cliff now has a gradient, these are the stops
  static const Color cliffTop = Color(0xFF6D6466);  // Warm Grey
  static const Color cliffBottom = Color(0xFFB0BBC2); // Matches deepWater exactly!
  static const Color cliffShadow = Color(0xFF585052); // Restored
  
  // ... (Other colors unchanged) 
  static const Color sandBase = Color(0xFFE0D8CC);  
  
  static const Color houseWall = Color(0xFFD7CCC8); 
  static const Color houseRoof = Color(0xFF8D6E63); 
  static const Color houseDoor = Color(0xFF8D6E63); 
  
  static const Color charSkin = Color(0xFFFFCCBC); 
  static const Color charCloth = Color(0xFF5D4037); 
  
  // Seasons...
  static const Color sakuraLight = Color(0xFFE6C9C9); 
  static const Color sakuraDark = Color(0xFFD7A7A7);  
  
  static const Color autumnSky = Color(0xFFE0E5E8); 
  static const Color autumnMist = Color(0xFFD7D3CE); 
  static const Color autumnGround = Color(0xFF9E9D89); 
  static const Color autumnLeafLight = Color(0xFFD4A373); 
  static const Color autumnLeafDark = Color(0xFFA67C52); 
  
  static const Color winterSky = Color(0xFFE8ECEF); 
  static const Color winterDayMist = Color(0xFFDEE4E8); 
  static const Color winterNightTop = Color(0xFF2C3E50); 
  static const Color winterNightBot = Color(0xFF34495E); 
  static const Color snowWhite = Color(0xFFFDFDFD); 
  static const Color snowShadow = Color(0xFFECF0F1); 
  static const Color pineGreen = Color(0xFF4A6B5D); 
}

class IslandBaseLayer extends StatefulWidget {
  final bool isFocusing; // ACTION
  final ThemeState themeState; // WORLD STATE (Mode + Season)
  final double width;

  const IslandBaseLayer({
    super.key,
    required this.isFocusing,
    required this.themeState,
    required this.width,
  });

  @override
  State<IslandBaseLayer> createState() => _IslandBaseLayerState();
}

class _IslandBaseLayerState extends State<IslandBaseLayer> with TickerProviderStateMixin {
  // ... (Animation Controllers)
  late AnimationController _patrolController;
  late AnimationController _walkCycleController;
  late AnimationController _petalController; 
  
  Timer? _behaviorTimer;
  Timer? _petalTimer;
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

    _petalController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), 
    );

    if (widget.isFocusing) {
      _startAnimations(); 
      _checkPetalStart(); 
    }
  }

  @override
  void didUpdateWidget(IslandBaseLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFocusing != oldWidget.isFocusing) {
      if (widget.isFocusing) {
        _startAnimations();
        _checkPetalStart();
      } else {
        _stopAnimations();
        _stopPetalLoop();
      }
    }
    if (widget.isFocusing && widget.themeState.season != oldWidget.themeState.season) {
      _checkPetalStart(); 
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
  
  void _checkPetalStart() {
    final season = widget.themeState.season;
    if (widget.isFocusing && (season == AppSeason.sakura || season == AppSeason.autumn || season == AppSeason.winter)) {
      _stopPetalLoop();
      _schedulePetalWave(initialDelay: Duration.zero);
    } else {
      _stopPetalLoop();
    }
  }
  
  void _stopPetalLoop() {
    _petalTimer?.cancel();
    _petalController.stop();
    _petalController.reset();
  }

  void _schedulePetalWave({Duration? initialDelay}) {
    if (!mounted || !widget.isFocusing) return;
    final season = widget.themeState.season;
    if (season != AppSeason.sakura && season != AppSeason.autumn && season != AppSeason.winter) return;
    
    int baseDelay = 3;
    if (season == AppSeason.autumn) baseDelay = 4;
    if (season == AppSeason.winter) baseDelay = 5;
    
    final delay = initialDelay ?? Duration(seconds: baseDelay + math.Random().nextInt(3));
    
    _petalTimer = Timer(delay, () {
      if (!mounted) return;
      _petalController.forward(from: 0.0).then((_) {
         _schedulePetalWave();
      });
    });
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
    _petalTimer?.cancel();
    _patrolController.dispose();
    _walkCycleController.dispose();
    _petalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.width;
    final isNight = widget.themeState.mode == AppThemeMode.night;
    
    // LIGHTING LOGIC
    double lightIntensity = 0.0;
    if (isNight) {
       lightIntensity = widget.isFocusing ? 0.8 : 0.3;
    }

    final bool isSakura = widget.themeState.season == AppSeason.sakura;
    final bool isAutumn = widget.themeState.season == AppSeason.autumn;
    final bool isWinter = widget.themeState.season == AppSeason.winter;

    // SHADOW LOGIC
    // Day: Neutral grounding shadow (Grey-Brown)
    // Night: Deep ambient darkness (Blue-Grey)
    final Color shadowColor = isNight 
         ? CalmPalette.nightDeepWater.withOpacity(0.3) 
         : const Color(0xFF6B645D).withOpacity(0.18); // Neutral grounding shadow

    return Container(
      width: w,
      height: w, 
      decoration: const BoxDecoration(
        color: Colors.transparent, 
      ),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
              // 0. SOFT FLOATING SHADOW (Atmospheric Grounding)
          Positioned(
             bottom: w * 0.08, 
             child: Container(
               width: w * 0.85,
               height: w * 0.25,
               decoration: BoxDecoration(
                 borderRadius: BorderRadius.circular(w), 
                 boxShadow: [
                   BoxShadow(
                     color: shadowColor, 
                     blurRadius: isNight ? 50 : 30, // Tighter for day
                     spreadRadius: isNight ? -5 : -8, 
                     offset: const Offset(0, 10),
                   ),
                 ],
               ),
             ),
          ),
          
          // 1. ISLAND GEO (Gradient Blend + Sakura Accents)
          Positioned(
             bottom: w * 0.15,
             child: SizedBox(
               width: w * 0.95, 
               height: w * 0.55, 
               child: CustomPaint(
                 painter: CalmIslandPainter(
                   isSakura: isSakura, 
                   isAutumn: isAutumn, 
                   isWinter: isWinter,
                   isNight: widget.themeState.mode == AppThemeMode.night,
                 )
               ),
             ),
          ),
          
          // 2. HOUSE
          Positioned(
            bottom: w * 0.48, 
            left: w * 0.05,  
            child: CalmHouseWidget(
              size: w * 0.50, 
              lightIntensity: lightIntensity,
              isSakura: isSakura,
              isAutumn: isAutumn,
              isWinter: isWinter,
            ), 
          ),

          // 2.5 GARDEN LAMP (New)
          Positioned(
             bottom: w * 0.49,
             right: w * 0.28, // Near tree
             child: CalmGardenLamp(size: w * 0.08, lightIntensity: lightIntensity),
          ),

          // 3. TREES (Sakura or Green)
          Positioned(
             bottom: w * 0.48,
             right: w * 0.15, 
             child: CalmTreeWidget(
               size: w * 0.45, 
               isFocusing: widget.isFocusing, 
               delay: 0,
               isSakura: isSakura,
               isAutumn: isAutumn,
               isWinter: isWinter,
             ),
          ),
          Positioned(
             bottom: w * 0.50,
             right: w * 0.05, 
             child: CalmTreeWidget(
               size: w * 0.35, 
               isFocusing: widget.isFocusing, 
               delay: 1,
               isSakura: isSakura,
               isAutumn: isAutumn,
               isWinter: isWinter,
             ),
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

          // 5. SAKURA PETALS (Overlay - Only triggered once)
          // Drawn on top of everything
          AnimatedBuilder(
            animation: _petalController,
            builder: (context, child) {
              if ((isSakura || isAutumn || isWinter) && _petalController.isAnimating) {
                return Positioned.fill(
                  child: CustomPaint(
                    painter: isSakura 
                      ? _SakuraPetalPainter(progress: _petalController.value)
                      : isWinter 
                        ? _SnowFlakePainter(progress: _petalController.value)
                        : _AutumnLeafPainter(progress: _petalController.value),
                  ),
                );
              }
              return const SizedBox.shrink();
            }
          ),
        ],
      ),
    );
  }
}

// --- PAINTERS ---

class CalmIslandPainter extends CustomPainter {
  final bool isSakura;
  final bool isAutumn;
  final bool isWinter;
  final bool isNight;
  CalmIslandPainter({this.isSakura = false, this.isAutumn = false, this.isWinter = false, this.isNight = false});

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
    
    // 2.5 NIGHT AMBIENT SHADOW (Non-Winter)
    // Grounds the island in the dark water
    if (isNight && !isWinter) {
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
      
      canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.5, h * 0.85), width: w * 0.8, height: h * 0.15),
        shadowPaint
      );
    }

    // 2. GRASS SURFACE
    final grassPath = Path();
    grassPath.moveTo(-w * 0.05, h * 0.35);
    grassPath.cubicTo(w*0.3, h*0.1, w*0.7, h*0.1, w*1.05, h*0.35);
    grassPath.quadraticBezierTo(w*0.5, h*0.55, -w*0.05, h*0.35);
    grassPath.quadraticBezierTo(w*0.5, h*0.55, -w*0.05, h*0.35);
    canvas.drawPath(grassPath, Paint()..color = isAutumn ? CalmPalette.autumnGround : CalmPalette.grassBase);

    // 3. SAKURA GROUND PETALS (Static)
    // Increased density and natural range
    if (isSakura) {
      final petalPaint = Paint()..color = CalmPalette.sakuraLight.withOpacity(0.9);
      
      // Far Left
      canvas.drawOval(Rect.fromLTWH(w * 0.1, h * 0.36, w * 0.02, w * 0.015), petalPaint);
      canvas.drawOval(Rect.fromLTWH(w * 0.15, h * 0.39, w * 0.015, w * 0.01), petalPaint);
      
      // Near House
      canvas.drawOval(Rect.fromLTWH(w * 0.45, h * 0.40, w * 0.025, w * 0.018), petalPaint);
      canvas.drawOval(Rect.fromLTWH(w * 0.52, h * 0.42, w * 0.02, w * 0.015), petalPaint);
      
      // Right Side (under tree)
      canvas.drawOval(Rect.fromLTWH(w * 0.8, h * 0.37, w * 0.022, w * 0.016), petalPaint);
      canvas.drawOval(Rect.fromLTWH(w * 0.85, h * 0.35, w * 0.018, w * 0.012), petalPaint);
      canvas.drawOval(Rect.fromLTWH(w * 0.75, h * 0.41, w * 0.02, w * 0.015), petalPaint);
    }
    
    // 4. AUTUMN GROUND LEAVES (Static)
    // Increased density and varied colors
    if (isAutumn) {
       final leafPaint = Paint();
       
       // Saturated Amber
       leafPaint.color = CalmPalette.autumnLeafLight.withOpacity(0.85);
       canvas.drawOval(Rect.fromLTWH(w * 0.6, h * 0.42, w * 0.025, w * 0.015), leafPaint);
       canvas.drawOval(Rect.fromLTWH(w * 0.3, h * 0.38, w * 0.02, w * 0.012), leafPaint);
       canvas.drawOval(Rect.fromLTWH(w * 0.15, h * 0.35, w * 0.022, w * 0.014), leafPaint);

       // Darker Brown
       leafPaint.color = CalmPalette.autumnLeafDark.withOpacity(0.8);
       canvas.drawOval(Rect.fromLTWH(w * 0.8, h * 0.36, w * 0.02, w * 0.012), leafPaint);
       canvas.drawOval(Rect.fromLTWH(w * 0.45, h * 0.41, w * 0.025, w * 0.015), leafPaint);
       canvas.drawOval(Rect.fromLTWH(w * 0.9, h * 0.39, w * 0.018, w * 0.010), leafPaint);
    }

    // 5. WINTER SNOW LAYERS (Static)
    if (isWinter) {
      final snowPaint = Paint()..color = CalmPalette.snowWhite.withOpacity(0.9);
      
      // Base layer (Thin & Even)
      canvas.drawOval(Rect.fromLTWH(w * 0.05, h * 0.32, w * 0.9, w * 0.25), snowPaint..color = CalmPalette.snowWhite.withOpacity(0.6));
      
      // Accents (Softer)
      canvas.drawOval(Rect.fromLTWH(w * 0.15, h * 0.38, w * 0.15, w * 0.08), snowPaint..color = CalmPalette.snowWhite.withOpacity(0.8));
      canvas.drawOval(Rect.fromLTWH(w * 0.7, h * 0.4, w * 0.2, w * 0.06), snowPaint);
    }
  }
  @override
  bool shouldRepaint(covariant CalmIslandPainter oldDelegate) => 
    isSakura != oldDelegate.isSakura || isAutumn != oldDelegate.isAutumn || isWinter != oldDelegate.isWinter;
}

class CalmHouseWidget extends StatelessWidget {
  final double size;
  final double lightIntensity; 
  final bool isSakura;
  final bool isAutumn;
  final bool isWinter;
  
  const CalmHouseWidget({
    super.key, 
    required this.size,
    required this.lightIntensity,
    this.isSakura = false,
    this.isAutumn = false,
    this.isWinter = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size, 
      height: size * 0.7, 
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: 0.0, 
          end: lightIntensity // Animate to target intensity
        ),
        duration: const Duration(milliseconds: 1200),
        builder: (context, lightOpacity, child) {
          return CustomPaint(
            painter: _CalmHousePainter(
              lightOpacity: lightOpacity,
              isSakura: isSakura,
              isAutumn: isAutumn,
              isWinter: isWinter,
            )
          );
        }
      )
    );
  }
}

class _CalmHousePainter extends CustomPainter {
  final double lightOpacity;
  final bool isSakura;
  final bool isAutumn;
  final bool isWinter;
  
  _CalmHousePainter({required this.lightOpacity, required this.isSakura, required this.isAutumn, required this.isWinter});
  
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
    
    // Door Light (Bottom)
    if (lightOpacity > 0) {
       paint.color = CalmPalette.lightWarm.withOpacity(lightOpacity * 0.8); 
       // Soft spill on ground/door
       canvas.drawOval(Rect.fromLTWH(w * 0.45, h * 0.9, w * 0.15, h * 0.05), paint);
    }
    
    // Windows
    // Day Mode: Reflection (White/Blue)
    // Night Mode: Warm Light
    final Color windowColor = Color.lerp(
      Colors.white.withOpacity(0.3), 
      CalmPalette.lightWarm, 
      lightOpacity
    )!;
    
    paint.color = windowColor.withOpacity(0.3 + (lightOpacity * 0.4)); // Brighter at night
    
    canvas.drawCircle(Offset(w * 0.25, h * 0.65), w * 0.06, paint);
    canvas.drawCircle(Offset(w * 0.75, h * 0.65), w * 0.06, paint);
    
    // Window Light Bloom (Subtle)
    if (lightOpacity > 0) {
       paint.color = CalmPalette.lightWarm.withOpacity(lightOpacity * 0.5);
       paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
       canvas.drawCircle(Offset(w * 0.25, h * 0.65), w * 0.08, paint);
       canvas.drawCircle(Offset(w * 0.75, h * 0.65), w * 0.08, paint);
       paint.maskFilter = null;
    }

    // ROOF PETALS (Static Sakura)
    if (isSakura) {
       paint.color = CalmPalette.sakuraDark.withOpacity(0.7);
       // 1. On left slope
       canvas.drawOval(Rect.fromLTWH(w * 0.3, h * 0.32, w * 0.03, w * 0.02), paint);
       // 2. Near Peak
       canvas.drawOval(Rect.fromLTWH(w * 0.55, h * 0.28, w * 0.03, w * 0.02), paint);
    }
    
    // ROOF PETALS (Static Sakura)
    if (isSakura) {
       paint.color = CalmPalette.sakuraLight.withOpacity(0.8);
       canvas.drawOval(Rect.fromLTWH(w * 0.25, h * 0.35, w * 0.025, w * 0.015), paint);
       canvas.drawOval(Rect.fromLTWH(w * 0.6, h * 0.32, w * 0.02, w * 0.012), paint);
       canvas.drawOval(Rect.fromLTWH(w * 0.4, h * 0.30, w * 0.022, w * 0.014), paint);
    }
    
    // ROOF LEAVES (Static Autumn)
    if (isAutumn) {
       paint.color = CalmPalette.autumnLeafLight.withOpacity(0.85);
       canvas.drawOval(Rect.fromLTWH(w * 0.2, h * 0.35, w * 0.03, w * 0.015), paint);
       canvas.drawOval(Rect.fromLTWH(w * 0.55, h * 0.32, w * 0.025, w * 0.012), paint);
       
       paint.color = CalmPalette.autumnLeafDark.withOpacity(0.8);
       canvas.drawOval(Rect.fromLTWH(w * 0.35, h * 0.29, w * 0.022, w * 0.014), paint);
    }
  }
  @override
  bool shouldRepaint(covariant _CalmHousePainter oldDelegate) => 
    lightOpacity != oldDelegate.lightOpacity || 
    isSakura != oldDelegate.isSakura || 
    isAutumn != oldDelegate.isAutumn || 
    isWinter != oldDelegate.isWinter;
}

// 2.5 GARDEN LAMP
class CalmGardenLamp extends StatelessWidget {
  final double size;
  final double lightIntensity;
  
  const CalmGardenLamp({super.key, required this.size, required this.lightIntensity});
  
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: lightIntensity), 
      duration: const Duration(milliseconds: 1200),
      builder: (context, opacity, child) {
         return CustomPaint(
           size: Size(size, size * 2), // Tall thin lamp
           painter: _CalmGardenLampPainter(lightOpacity: opacity)
         );
      }
    );
  }
}

class _CalmGardenLampPainter extends CustomPainter {
  final double lightOpacity;
  const _CalmGardenLampPainter({required this.lightOpacity});
  
  @override 
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Post (Always visible but subtle)
    paint.color = CalmPalette.cliffShadow;
    canvas.drawRect(Rect.fromLTWH(w * 0.4, h * 0.2, w * 0.2, h * 0.8), paint);
    
    // Lamp Head
    paint.color = CalmPalette.houseRoof;
    canvas.drawOval(Rect.fromLTWH(w * 0.2, h * 0.1, w * 0.6, h * 0.2), paint);
    
    // Light Source (Only when Opacity > 0)
    if (lightOpacity > 0) {
      paint.color = CalmPalette.lightWarm.withOpacity(lightOpacity);
      
      // 1. Bulb (Small bright center)
      canvas.drawCircle(Offset(w * 0.5, h * 0.25), w * 0.15, paint);
      
      // 2. Glow (Soft Blur)
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);
      paint.color = CalmPalette.lightWarm.withOpacity(lightOpacity * 0.6);
      canvas.drawCircle(Offset(w * 0.5, h * 0.25), w * 1.5, paint); // Wide soft glow
      
      // 3. Ground Reflection
      canvas.drawOval(Rect.fromCenter(center: Offset(w*0.5, h*0.95), width: w*2.0, height: w*0.5), paint);
      
      paint.maskFilter = null;
    }
  }
  @override
  bool shouldRepaint(covariant _CalmGardenLampPainter oldDelegate) => lightOpacity != oldDelegate.lightOpacity;
}

class CalmTreeWidget extends StatefulWidget {
  final double size;
  final bool isFocusing;
  final bool isSakura;
  final bool isAutumn;
  final bool isWinter;
  final int delay;
  const CalmTreeWidget({
    super.key, 
    required this.size, 
    required this.isFocusing, 
    this.isSakura = false,
    this.isAutumn = false,
    this.isWinter = false,
    this.delay = 0
  });
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
          painter: _CalmTreePainter(
            swayValue: sway,
            isSakura: widget.isSakura,
            isAutumn: widget.isAutumn,
            isWinter: widget.isWinter,
          )
        );
      }
    );
  }
}

class _CalmTreePainter extends CustomPainter {
  final double swayValue;
  final bool isSakura;
  final bool isAutumn;
  final bool isWinter;
  
  _CalmTreePainter({required this.swayValue, required this.isSakura, required this.isAutumn, required this.isWinter});
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final trunkPaint = Paint()..color = CalmPalette.cliffShadow;
    Color foliageColor = CalmPalette.grassHighlight;
    if (isSakura) foliageColor = CalmPalette.sakuraLight;
    if (isAutumn) foliageColor = CalmPalette.autumnLeafLight;
    if (isWinter) foliageColor = CalmPalette.pineGreen;
    
    final foliagePaint = Paint()..color = foliageColor;

    // 1. TRUNK
    // Extended upwards (h*0.5) to ensure connection with foliage
    final trunkRect = Rect.fromLTWH(w * 0.48, h * 0.5, w * 0.04, h * 0.5); 
    canvas.drawRect(trunkRect, trunkPaint);
    
    // SNOW BASE (Winter Only) - Covers trunk bottom
    if (isWinter) {
      final baseSnowPaint = Paint()..color = CalmPalette.snowWhite.withOpacity(0.9);
      canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.95), width: w * 0.15, height: w * 0.06), baseSnowPaint);
    }
    
    // 2. FOLIAGE
    canvas.save();
    canvas.translate(w * 0.5, h * 0.6); 
    canvas.rotate(swayValue * 0.08); 
    
    if (isSakura) {
      // SAKURA SHAPE: Soft Cloud
      // 3 overlapping circles for fluffiness
      foliagePaint.color = CalmPalette.sakuraLight;
      canvas.drawCircle(Offset(0, -h * 0.2), w * 0.22, foliagePaint);
      canvas.drawCircle(Offset(-w * 0.15, -h * 0.15), w * 0.18, foliagePaint);
      canvas.drawCircle(Offset(w * 0.15, -h * 0.15), w * 0.18, foliagePaint);
      
      // Depth
      foliagePaint.color = CalmPalette.sakuraDark.withOpacity(0.3);
      canvas.drawCircle(Offset(0, -h * 0.15), w * 0.15, foliagePaint);
      
    } else if (isAutumn) {
      // AUTUMN SHAPE: Maple (Wider, Flatter)
      
      // Main Crown (Wide)
      foliagePaint.color = CalmPalette.autumnLeafLight;
      canvas.drawOval(Rect.fromCenter(center: Offset(0, -h * 0.18), width: w * 0.55, height: w * 0.35), foliagePaint);
      
      // Top Bit
      foliagePaint.color = CalmPalette.autumnLeafDark.withOpacity(0.8);
      canvas.drawOval(Rect.fromCenter(center: Offset(0, -h * 0.28), width: w * 0.3, height: w * 0.25), foliagePaint);
      
    } else if (isWinter) {
      // WINTER SHAPE: Minimal Pine (Triangle/Cone stack)
      // Dark Muted Green with Snow Caps
      
      // Bottom Tier
      final path = Path();
      path.moveTo(-w*0.25, -h*0.1);
      path.lineTo(w*0.25, -h*0.1);
      path.lineTo(0, -h*0.35);
      path.close();
      canvas.drawPath(path, foliagePaint);
      
      // Top Tier
      final pathTop = Path();
      pathTop.moveTo(-w*0.15, -h*0.25);
      pathTop.lineTo(w*0.15, -h*0.25);
      pathTop.lineTo(0, -h*0.45);
      pathTop.close();
      canvas.drawPath(pathTop, foliagePaint);
      
      // Snow Caps (Simple white triangles at top of tiers)
      final snowPaint = Paint()..color = CalmPalette.snowWhite;
      
      // Top Cap
      final snowTop = Path();
      snowTop.moveTo(-w*0.05, -h*0.4);
      snowTop.lineTo(w*0.05, -h*0.4);
      snowTop.lineTo(0, -h*0.45);
      snowTop.close();
      canvas.drawPath(snowTop, snowPaint);

      // Bottom Cap
      final snowBot = Path();
      snowBot.moveTo(-w*0.08, -h*0.3);
      snowBot.lineTo(w*0.08, -h*0.3);
      snowBot.lineTo(0, -h*0.35); // Overlap
      snowBot.close();
      canvas.drawPath(snowBot, snowPaint);

    } else {
      // NORMAL SHAPE: Simple Sphere
      canvas.drawCircle(Offset(0, -h * 0.15), w * 0.25, foliagePaint);
    }

    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant _CalmTreePainter oldDelegate) => 
    swayValue != oldDelegate.swayValue || isSakura != oldDelegate.isSakura || isAutumn != oldDelegate.isAutumn || isWinter != oldDelegate.isWinter;
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

class _SakuraPetalPainter extends CustomPainter {
  final double progress; // 0.0 -> 1.0 (4 seconds)
  
  _SakuraPetalPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    // Draw 4 Petals
    _drawPetal(canvas, w * 0.2, h * 0.2, w, h, 1.0, 0.0);
    _drawPetal(canvas, w * 0.5, h * 0.1, w, h, -1.0, 0.15);
    _drawPetal(canvas, w * 0.8, h * 0.3, w, h, 1.0, 0.3);
    _drawPetal(canvas, w * 0.4, h * 0.05, w, h, 0.5, 0.4);
  }

  void _drawPetal(Canvas canvas, double startX, double startY, double w, double h, double driftDir, double timeOffset) {
    // Current Time for this petal
    double t = (progress + timeOffset).clamp(0.0, 1.0);
    if (t <= 0 || t >= 1) return;

    // Position Y: Falls down 20% of screen height
    double y = startY + (h * 0.25 * t);
    
    // Position X: Drifts with Sine
    double x = startX + (math.sin(t * math.pi * 3) * (w * 0.05) * driftDir);

    // Rotation
    double rotation = t * math.pi * 2 * driftDir;
    
    // Opacity Fade In/Out
    double opacity = 1.0;
    if (t < 0.2) opacity = t / 0.2;
    else if (t > 0.8) opacity = (1.0 - t) / 0.2;
    
    final paint = Paint()..color = CalmPalette.sakuraLight.withOpacity(opacity * 0.8);

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(rotation);
    
    // Draw Petal (Small Oval)
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: w * 0.02, height: w * 0.015), paint);
    
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SakuraPetalPainter oldDelegate) => progress != oldDelegate.progress;
}

class _AutumnLeafPainter extends CustomPainter {
  final double progress; 
  _AutumnLeafPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    // Draw 4 Leaves (Varied colors)
    _drawLeaf(canvas, w * 0.4, h * 0.2, w, h, -1.0, 0.0, CalmPalette.autumnLeafLight);
    _drawLeaf(canvas, w * 0.7, h * 0.1, w, h, 1.0, 0.2, CalmPalette.autumnLeafDark);
    _drawLeaf(canvas, w * 0.2, h * 0.3, w, h, 0.8, 0.4, CalmPalette.autumnLeafLight);
    _drawLeaf(canvas, w * 0.55, h * 0.05, w, h, -0.5, 0.5, CalmPalette.autumnLeafDark);
  }
  
  void _drawLeaf(Canvas canvas, double startX, double startY, double w, double h, double driftDir, double timeOffset, Color color) {
    double t = (progress + timeOffset).clamp(0.0, 1.0);
    if (t <= 0 || t >= 1) return;
    
    // Falls further/slower feeling
    double y = startY + (h * 0.4 * t);
    double x = startX + (math.sin(t * math.pi * 2) * (w * 0.1) * driftDir);
    
    // Slow rotation
    double rotation = t * math.pi * driftDir;
    
    // Fade
    double opacity = 1.0;
    if (t < 0.1) opacity = t / 0.1;
    else if (t > 0.9) opacity = (1.0 - t) / 0.1;
    
    final paint = Paint()..color = color.withOpacity(opacity);
    
    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(rotation);
    
    // Leaf Shape (Diamond-ish)
    final path = Path();
    path.moveTo(0, -w * 0.015);
    path.lineTo(w * 0.01, 0);
    path.lineTo(0, w * 0.015);
    path.lineTo(-w * 0.01, 0);
    path.close();
    
    canvas.drawPath(path, paint);
    canvas.restore();
  }
  
  @override
  bool shouldRepaint(covariant _AutumnLeafPainter oldDelegate) => progress != oldDelegate.progress;
}

class _SnowFlakePainter extends CustomPainter {
  final double progress; 
  _SnowFlakePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    // Draw 4 Snowflakes (Small, Slow)
    _drawFlake(canvas, w * 0.2, h * 0.1, w, h, 0.0);
    _drawFlake(canvas, w * 0.5, h * 0.05, w, h, 0.3);
    _drawFlake(canvas, w * 0.8, h * 0.15, w, h, 0.6);
    _drawFlake(canvas, w * 0.35, h * 0.0, w, h, 0.8);
  }
  
  void _drawFlake(Canvas canvas, double startX, double startY, double w, double h, double timeOffset) {
    double t = (progress + timeOffset).clamp(0.0, 1.0);
    if (t <= 0 || t >= 1) return;
    
    // Fall Vertical mostly
    double y = startY + (h * 0.5 * t); // Falls halfway down screen
    double x = startX + (math.sin(t * math.pi * 4) * (w * 0.02)); // Very slight wobble
    
    // Fade
    double opacity = 1.0;
    if (t < 0.1) opacity = t / 0.1;
    else if (t > 0.8) opacity = (1.0 - t) / 0.2;
    
    final paint = Paint()..color = CalmPalette.snowWhite.withOpacity(opacity);
    
    canvas.drawCircle(Offset(x, y), w * 0.008, paint); // Tiny circle
  }
  
  @override
  bool shouldRepaint(covariant _SnowFlakePainter oldDelegate) => progress != oldDelegate.progress;
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
