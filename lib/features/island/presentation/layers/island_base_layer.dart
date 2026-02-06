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
  // Nature
  // Day Mode (Fresh)
  static const Color grassBase = Color(0xFFA7C995); // Fresh Sage (Vibrant)
  static const Color grassHighlight = Color(0xFFC4DBC2); // Soft highlight
  static const Color cliffTop = Color(0xFF8D7F75);  // Warm Taupe
  static const Color cliffBottom = Color(0xFF7A6C62); // Darker Clay
  
  // Night Mode (Physically Adapted: Dimmed + Desaturated + Cool Tint + Warm Bias)
  static const Color nightGrassBase = Color(0xFF909A85); // Muted Sage (Warmer)
  static const Color nightCliffTop = Color(0xFF7F726B);  // Muted Taupe (Warmer)
  static const Color nightCliffBottom = Color(0xFF695E58); // Muted Clay (Warmer)
  static const Color cliffShadow = Color(0xFF585052); // Keep for props
  
  // ... (Other colors unchanged) 
  static const Color sandBase = Color(0xFFE0D8CC);  
  
  static const Color houseWall = Color(0xFFD7CCC8); 
  static const Color houseRoof = Color(0xFF8D6E63); 
  static const Color houseDoor = Color(0xFF8D6E63); 
  
  // House (Night) - Dimmed ~15% + Cool Tint + Warm Bias
  static const Color nightHouseWall = Color(0xFFC0AAA4); // Dimmed Mauve/Beige (Warmer)
  static const Color nightHouseRoof = Color(0xFF70544C); // Darker Brown (Warmer)
  static const Color nightHouseDoor = Color(0xFF70544C); // Darker Brown (Warmer)

  // Adventure House (Day)
  static const Color adventureCanopy = Color(0xFFA6C3A1); 
  static const Color adventureCanopyShade = Color(0xFF8FB08B); 
  static const Color adventureTrunk = Color(0xFFC3A286); 
  static const Color adventurePlatform = Color(0xFFB58C6E); 
  static const Color adventureDoor = Color(0xFF9B7760); 
  static const Color adventureWindow = Color(0xFFEADCCB); 

  // Adventure House (Night)
  static const Color nightAdventureCanopy = Color(0xFF7F977B); 
  static const Color nightAdventureCanopyShade = Color(0xFF6F886D); 
  static const Color nightAdventureTrunk = Color(0xFF9C7E69); 
  static const Color nightAdventurePlatform = Color(0xFF8E6E5B); 
  static const Color nightAdventureDoor = Color(0xFF7B5E4D); 
  static const Color nightAdventureWindow = Color(0xFFD2C1B1); 

  // Stargazer Hut (Day)
  static const Color stargazerDome = Color(0xFFC8D3DD);
  static const Color stargazerDomeShade = Color(0xFFAEBBC6);
  static const Color stargazerRoofTint = Color(0xFFB6C6D2);
  static const Color stargazerBase = Color(0xFFC1B6A8);
  static const Color stargazerScope = Color(0xFF8FA0AF);
  static const Color stargazerTripod = Color(0xFFA38A73);

  // Stargazer Hut (Night)
  static const Color nightStargazerDome = Color(0xFF9FAEBB);
  static const Color nightStargazerDomeShade = Color(0xFF8B98A5);
  static const Color nightStargazerRoofTint = Color(0xFF94A5B3);
  static const Color nightStargazerBase = Color(0xFF9A8F82);
  static const Color nightStargazerScope = Color(0xFF7E8C9A);
  static const Color nightStargazerTripod = Color(0xFF8B7461);

  // Forest Cabin (Day)
  static const Color cabinWall = Color(0xFF8D6E63);
  static const Color cabinRoof = Color(0xFF5D4037);
  static const Color cabinDoor = Color(0xFF4E342E);
  static const Color cabinWindow = Color(0xFF6D4C41);
  static const Color cabinWoodDark = Color(0xFF3E2723);

  // Forest Cabin (Night)
  static const Color nightCabinWall = Color(0xFF6D4C41);
  static const Color nightCabinRoof = Color(0xFF4E342E);
  static const Color nightCabinDoor = Color(0xFF3E2723);
  static const Color nightCabinWindow = Color(0xFF5D4037);
  static const Color nightCabinWoodDark = Color(0xFF2D1B18);

  // Nature Details (Night)
  static const Color nightFoliage = Color(0xFF909A85); // Matches nightGrassBase
  static const Color nightFoliageSakura = Color(0xFFCDB1B1); // Dimmed Pink 
  
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
  final bool enableCharacterIdleMotion;

  const IslandBaseLayer({
    super.key,
    required this.isFocusing,
    required this.themeState,
    required this.width,
    this.enableCharacterIdleMotion = false,
  });

  @override
  State<IslandBaseLayer> createState() => _IslandBaseLayerState();
}

class _IslandBaseLayerState extends State<IslandBaseLayer> with TickerProviderStateMixin {
  // ... (Animation Controllers)
  late AnimationController _patrolController;
  late AnimationController _walkCycleController;
  late AnimationController _petalController; 
  late AnimationController _idleController;
  late Animation<double> _idleCurve;
  
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

    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    _idleCurve = CurvedAnimation(parent: _idleController, curve: Curves.easeInOut);

    if (widget.isFocusing) {
      _startAnimations(); 
      _checkPetalStart(); 
    }

    _updateIdleMotion();
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
    if (widget.enableCharacterIdleMotion != oldWidget.enableCharacterIdleMotion ||
        widget.isFocusing != oldWidget.isFocusing) {
      _updateIdleMotion();
    }
    if (widget.isFocusing && widget.themeState.season != oldWidget.themeState.season) {
      _checkPetalStart(); 
    }
  }

  void _updateIdleMotion() {
    final shouldIdle = widget.enableCharacterIdleMotion && !widget.isFocusing;
    if (shouldIdle) {
      if (!_idleController.isAnimating) {
        _idleController.repeat(reverse: true);
      }
    } else {
      _idleController.stop();
      _idleController.reset();
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
    _idleController.dispose();
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
    final bool isAdventureHouse = widget.themeState.house == AppHouse.adventureHouse;
    final bool isStargazerHut = widget.themeState.house == AppHouse.stargazerHut;
    final bool isForestCabin = widget.themeState.house == AppHouse.forestCabin;

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
             child: isAdventureHouse
                 ? AdventureHouseWidget(
                     size: w * 0.55,
                     lightIntensity: lightIntensity,
                     isNight: isNight,
                     isSakura: isSakura,
                     isAutumn: isAutumn,
                     isWinter: isWinter,
                   )
                 : isStargazerHut
                     ? StargazerHutWidget(
                         size: w * 0.52,
                         lightIntensity: lightIntensity,
                         isNight: isNight,
                         isSakura: isSakura,
                         isAutumn: isAutumn,
                         isWinter: isWinter,
                       )
                 : isForestCabin
                     ? ForestCabinWidget(
                         size: w * 0.54,
                         lightIntensity: lightIntensity,
                         isNight: isNight,
                         isFocusing: widget.isFocusing,
                         isSakura: isSakura,
                         isAutumn: isAutumn,
                         isWinter: isWinter,
                       )
                     : CalmHouseWidget(
                         size: w * 0.50, 
                         lightIntensity: lightIntensity,
                         isSakura: isSakura,
                         isAutumn: isAutumn,
                         isWinter: isWinter,
                         isNight: isNight,
                       ), 
           ),

          // 2.5 GARDEN LAMP (New)
          Positioned(
             bottom: w * 0.49,
             right: w * 0.28, // Near tree
             child: CalmGardenLamp(size: w * 0.08, lightIntensity: lightIntensity, isNight: isNight),
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
               isNight: isNight,
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
               isNight: isNight,
             ),
          ),

          if (isStargazerHut)
            Positioned(
              bottom: w * 0.48,
              left: w * 0.05,
              child: StargazerTelescopeWidget(
                size: w * 0.52,
                isNight: isNight,
                isWinter: isWinter,
              ),
            ),

          // 4. CHARACTER
           AnimatedBuilder(
             animation: Listenable.merge([
               _patrolController,
               _walkCycleController,
               _idleController,
             ]),
             builder: (context, child) {
               final bool useIdleMotion = widget.enableCharacterIdleMotion && !widget.isFocusing;
               final t = _patrolController.value;
               final minX = w * 0.35;
               final maxX = w * 0.60;
               final walkLeft = minX + ((maxX - minX) * t);
               final idleT = _idleCurve.value * math.pi * 2;
               final idleX = useIdleMotion ? math.sin(idleT) * (w * 0.012) : 0.0;
               final idleY = useIdleMotion ? math.cos(idleT * 2) * (w * 0.004) : 0.0;
               final idleScale = useIdleMotion ? 1.0075 + (math.sin(idleT) * 0.0075) : 1.0;
               final baseLeft = useIdleMotion ? w * 0.48 : walkLeft;
               final currentLeft = baseLeft + idleX;

               final isMovingRight = _patrolController.status == AnimationStatus.forward;
               final walkVal = _walkCycleController.value;
               final useSideView = useIdleMotion ? false : _isCharacterWalking; 
               
               final bob = useSideView
                   ? -2.0 * math.sin(walkVal * math.pi * 2).abs()
                   : 0.0;

               return Positioned(
                 bottom: (w * 0.48) + bob + idleY,
                 left: currentLeft,
                 child: Transform.scale(
                   scale: idleScale,
                    child: isAdventureHouse
                        ? AdventureCharacterWidget(
                            isFocusing: widget.isFocusing,
                            walkProgress: walkVal,
                            isFacingLeft: !isMovingRight,
                            size: w * 0.09,
                            isWalking: useSideView,
                          )
                        : CalmCharacterWidget(
                            isFocusing: widget.isFocusing, 
                            walkProgress: walkVal,
                            isFacingLeft: !isMovingRight,
                            size: w * 0.09, 
                            isWalking: useSideView,
                          ),
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
    // Gradient: Top (Color) -> Bottom (Water)
    // Select colors based on mode
    final topColor = isNight ? CalmPalette.nightCliffTop : CalmPalette.cliffTop;
    final botColor = isNight ? CalmPalette.nightCliffBottom : CalmPalette.cliffBottom;

    final cliffPaint = Paint()
      ..shader = LinearGradient(
         begin: Alignment.topCenter,
         end: Alignment.bottomCenter,
         colors: [
           topColor,
           botColor, 
         ],
         stops: [0.3, 1.0]
      ).createShader(Rect.fromLTWH(0, 0, w, h));
      
    canvas.drawPath(cliffPath, cliffPaint);
    
    // 2.5 NIGHT AMBIENT SHADOW (Non-Winter)
    // Grounds the island in the dark water
    if (isNight && !isWinter) {
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
      
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
    
    Color grassColor = CalmPalette.grassBase;
    if (isNight) grassColor = CalmPalette.nightGrassBase;
    if (isAutumn) grassColor = CalmPalette.autumnGround;

    canvas.drawPath(grassPath, Paint()..color = grassColor);

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
  final bool isNight;
  
  const CalmHouseWidget({
    super.key, 
    required this.size,
    required this.lightIntensity,
    this.isSakura = false,
    this.isAutumn = false,
    this.isWinter = false,
    required this.isNight,
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
              isNight: isNight,
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
  final bool isNight;
  
  _CalmHousePainter({required this.lightOpacity, required this.isSakura, required this.isAutumn, required this.isWinter, required this.isNight});
  
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Main Block
    paint.color = isNight ? CalmPalette.nightHouseWall : CalmPalette.houseWall;
    final wallRect = Rect.fromLTWH(w * 0.1, h * 0.4, w * 0.8, h * 0.6);
    canvas.drawRRect(RRect.fromRectAndRadius(wallRect, const Radius.circular(4)), paint);
    
    // Roof
    final roofPath = Path();
    roofPath.moveTo(-w*0.05, h * 0.45);
    roofPath.quadraticBezierTo(w * 0.5, h * 0.1, w * 1.05, h * 0.45);
    roofPath.close();
    paint.color = isNight ? CalmPalette.nightHouseRoof : CalmPalette.houseRoof;
    canvas.drawPath(roofPath, paint);
    
    // Door
    paint.color = (isNight ? CalmPalette.nightHouseDoor : CalmPalette.houseDoor).withOpacity(0.8);
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
  bool shouldRepaint(covariant _CalmHousePainter oldDelegate) {
    return lightOpacity != oldDelegate.lightOpacity || 
           isSakura != oldDelegate.isSakura || 
           isAutumn != oldDelegate.isAutumn || 
           isWinter != oldDelegate.isWinter ||
           isNight != oldDelegate.isNight;
  }
}

class AdventureHouseWidget extends StatelessWidget {
  final double size;
  final double lightIntensity;
  final bool isNight;
  final bool isSakura;
  final bool isAutumn;
  final bool isWinter;

  const AdventureHouseWidget({
    super.key,
    required this.size,
    required this.lightIntensity,
    required this.isNight,
    this.isSakura = false,
    this.isAutumn = false,
    this.isWinter = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.85,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: lightIntensity),
        duration: const Duration(milliseconds: 1200),
        builder: (context, lightOpacity, child) {
          return CustomPaint(
            painter: _AdventureHousePainter(
              lightOpacity: lightOpacity,
              isNight: isNight,
              isSakura: isSakura,
              isAutumn: isAutumn,
              isWinter: isWinter,
            ),
          );
        },
      ),
    );
  }
}

class _AdventureHousePainter extends CustomPainter {
  final double lightOpacity;
  final bool isNight;
  final bool isSakura;
  final bool isAutumn;
  final bool isWinter;

  _AdventureHousePainter({
    required this.lightOpacity,
    required this.isNight,
    required this.isSakura,
    required this.isAutumn,
    required this.isWinter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..style = PaintingStyle.fill;

    Color canopyBase = isNight ? CalmPalette.nightAdventureCanopy : CalmPalette.adventureCanopy;
    Color canopyShade = isNight ? CalmPalette.nightAdventureCanopyShade : CalmPalette.adventureCanopyShade;
    double canopyOpacity = 1.0;
    double shadeOpacity = 0.7;

    if (isSakura) {
      canopyBase = isNight ? CalmPalette.nightFoliageSakura : CalmPalette.sakuraLight;
      canopyShade = CalmPalette.sakuraDark;
      canopyOpacity = 0.85;
      shadeOpacity = 0.55;
    } else if (isAutumn) {
      canopyBase = isNight
          ? CalmPalette.autumnLeafLight.withOpacity(0.7)
          : CalmPalette.autumnLeafLight;
      canopyShade = CalmPalette.autumnLeafDark;
      canopyOpacity = 0.8;
      shadeOpacity = 0.5;
    } else if (isWinter) {
      canopyBase = isNight ? CalmPalette.pineGreen.withOpacity(0.7) : CalmPalette.pineGreen;
      canopyShade = isNight ? CalmPalette.pineGreen.withOpacity(0.55) : CalmPalette.pineGreen.withOpacity(0.6);
      canopyOpacity = 0.55;
      shadeOpacity = 0.35;
    }
    final trunkColor = isNight ? CalmPalette.nightAdventureTrunk : CalmPalette.adventureTrunk;
    final platformColor = isNight ? CalmPalette.nightAdventurePlatform : CalmPalette.adventurePlatform;
    final doorColor = isNight ? CalmPalette.nightAdventureDoor : CalmPalette.adventureDoor;
    final windowBase = isNight ? CalmPalette.nightAdventureWindow : CalmPalette.adventureWindow;

    // Canopy
    paint.color = canopyBase.withOpacity(canopyOpacity);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.58, h * 0.23), width: w * 0.92, height: h * 0.5),
      paint,
    );
    paint.color = canopyShade.withOpacity(shadeOpacity);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.45, h * 0.3), width: w * 0.62, height: h * 0.34),
      paint,
    );
    if (!isWinter) {
      paint.color = canopyBase.withOpacity(canopyOpacity * 0.9);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(w * 0.62, h * 0.34), width: w * 0.48, height: h * 0.22),
        paint,
      );
    }
    if (isWinter) {
      paint.color = CalmPalette.snowWhite.withOpacity(0.6);
      canvas.drawOval(Rect.fromLTWH(w * 0.3, h * 0.14, w * 0.22, h * 0.08), paint);
      canvas.drawOval(Rect.fromLTWH(w * 0.55, h * 0.16, w * 0.18, h * 0.07), paint);
      paint.color = CalmPalette.snowWhite.withOpacity(0.35);
      canvas.drawCircle(Offset(w * 0.25, h * 0.12), w * 0.012, paint);
      canvas.drawCircle(Offset(w * 0.75, h * 0.2), w * 0.01, paint);
    }
    if (isSakura) {
      paint.color = CalmPalette.sakuraLight.withOpacity(0.5);
      canvas.drawOval(Rect.fromLTWH(w * 0.7, h * 0.18, w * 0.04, w * 0.025), paint);
      canvas.drawOval(Rect.fromLTWH(w * 0.2, h * 0.22, w * 0.03, w * 0.02), paint);
    }

    // Trunk
    paint.color = trunkColor;
    final trunkRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.45, h * 0.36, w * 0.18, h * 0.46),
      Radius.circular(w * 0.08),
    );
    canvas.drawRRect(trunkRect, paint);

    // Platform
    paint.color = platformColor;
    final platformRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.12, h * 0.63, w * 0.76, h * 0.1),
      Radius.circular(w * 0.05),
    );
    canvas.drawRRect(platformRect, paint);

    // Ladder
    final ladderHeight = h * 0.26;
    final ladderWidth = w * 0.14;
    final railWidth = w * 0.02;
    canvas.save();
    canvas.translate(w * 0.33, h * 0.62);
    canvas.rotate(-0.12);
    paint.color = platformColor.withOpacity(0.95);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, railWidth, ladderHeight),
        Radius.circular(railWidth),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(ladderWidth - railWidth, 0, railWidth, ladderHeight),
        Radius.circular(railWidth),
      ),
      paint,
    );
    paint.color = platformColor.withOpacity(0.85);
    final rungHeight = w * 0.012;
    final rungInset = railWidth * 0.9;
    final rungOffsets = [0.08, 0.26, 0.44, 0.62, 0.8];
    for (var i = 0; i < rungOffsets.length; i++) {
      final y = ladderHeight * rungOffsets[i];
      final jitter = i.isEven ? -w * 0.004 : w * 0.003;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(rungInset + jitter, y, ladderWidth - (rungInset * 2), rungHeight),
          Radius.circular(rungHeight),
        ),
        paint,
      );
    }
    canvas.restore();

    // House Pod
    paint.color = trunkColor.withOpacity(0.95);
    final podRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.24, h * 0.48, w * 0.34, h * 0.22),
      Radius.circular(w * 0.08),
    );
    canvas.drawRRect(podRect, paint);

    // Door
    paint.color = doorColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.37, h * 0.6, w * 0.1, h * 0.12),
        Radius.circular(w * 0.03),
      ),
      paint,
    );

    // Windows
    paint.color = windowBase.withOpacity(0.7 + (lightOpacity * 0.2));
    canvas.drawCircle(Offset(w * 0.5, h * 0.57), w * 0.04, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.28, h * 0.54, w * 0.08, h * 0.06),
        Radius.circular(w * 0.02),
      ),
      paint,
    );

    // Warm glow
    if (lightOpacity > 0) {
      paint.color = CalmPalette.lightWarm.withOpacity(lightOpacity * 0.6);
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
      canvas.drawCircle(Offset(w * 0.5, h * 0.57), w * 0.07, paint);
      canvas.drawOval(Rect.fromLTWH(w * 0.28, h * 0.54, w * 0.08, h * 0.06), paint);
      paint.maskFilter = null;

      paint.color = CalmPalette.lightWarm.withOpacity(lightOpacity * 0.5);
      canvas.drawOval(Rect.fromLTWH(w * 0.34, h * 0.72, w * 0.18, h * 0.05), paint);
    }

    if (isWinter) {
      paint.color = CalmPalette.snowWhite.withOpacity(0.7);
      canvas.drawOval(Rect.fromLTWH(w * 0.26, h * 0.81, w * 0.16, h * 0.05), paint);
      canvas.drawOval(Rect.fromLTWH(w * 0.48, h * 0.83, w * 0.2, h * 0.06), paint);
      canvas.drawOval(Rect.fromLTWH(w * 0.18, h * 0.86, w * 0.12, h * 0.04), paint);
    } else if (isAutumn) {
      paint.color = CalmPalette.autumnLeafLight.withOpacity(0.7);
      canvas.drawOval(Rect.fromLTWH(w * 0.22, h * 0.82, w * 0.03, w * 0.018), paint);
      canvas.drawOval(Rect.fromLTWH(w * 0.36, h * 0.86, w * 0.028, w * 0.016), paint);
      paint.color = CalmPalette.autumnLeafDark.withOpacity(0.7);
      canvas.drawOval(Rect.fromLTWH(w * 0.3, h * 0.84, w * 0.03, w * 0.018), paint);
      canvas.drawOval(Rect.fromLTWH(w * 0.46, h * 0.82, w * 0.028, w * 0.016), paint);
    } else if (isSakura) {
      paint.color = CalmPalette.sakuraLight.withOpacity(0.75);
      canvas.drawOval(Rect.fromLTWH(w * 0.22, h * 0.83, w * 0.03, w * 0.02), paint);
      canvas.drawOval(Rect.fromLTWH(w * 0.34, h * 0.86, w * 0.028, w * 0.018), paint);
      paint.color = CalmPalette.sakuraDark.withOpacity(0.6);
      canvas.drawOval(Rect.fromLTWH(w * 0.4, h * 0.82, w * 0.026, w * 0.016), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AdventureHousePainter oldDelegate) {
    return lightOpacity != oldDelegate.lightOpacity ||
        isNight != oldDelegate.isNight ||
        isSakura != oldDelegate.isSakura ||
        isAutumn != oldDelegate.isAutumn ||
        isWinter != oldDelegate.isWinter;
  }
}

class StargazerHutWidget extends StatelessWidget {
  final double size;
  final double lightIntensity;
  final bool isNight;
  final bool isSakura;
  final bool isAutumn;
  final bool isWinter;

  const StargazerHutWidget({
    super.key,
    required this.size,
    required this.lightIntensity,
    required this.isNight,
    this.isSakura = false,
    this.isAutumn = false,
    this.isWinter = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.8,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: lightIntensity),
        duration: const Duration(milliseconds: 1200),
        builder: (context, lightOpacity, child) {
          return CustomPaint(
            painter: _StargazerHutPainter(
              lightOpacity: lightOpacity,
              isNight: isNight,
              isSakura: isSakura,
              isAutumn: isAutumn,
              isWinter: isWinter,
            ),
          );
        },
      ),
    );
  }
}

class _StargazerHutPainter extends CustomPainter {
  final double lightOpacity;
  final bool isNight;
  final bool isSakura;
  final bool isAutumn;
  final bool isWinter;

  _StargazerHutPainter({
    required this.lightOpacity,
    required this.isNight,
    required this.isSakura,
    required this.isAutumn,
    required this.isWinter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..style = PaintingStyle.fill;

    final domeColor = isNight ? CalmPalette.nightStargazerDome : CalmPalette.stargazerDome;
    final domeShade = isNight ? CalmPalette.nightStargazerDomeShade : CalmPalette.stargazerDomeShade;
    final roofTint = isNight ? CalmPalette.nightStargazerRoofTint : CalmPalette.stargazerRoofTint;
    final baseColor = isNight ? CalmPalette.nightStargazerBase : CalmPalette.stargazerBase;
    final scopeColor = isNight ? CalmPalette.nightStargazerScope : CalmPalette.stargazerScope;
    final tripodColor = isNight ? CalmPalette.nightStargazerTripod : CalmPalette.stargazerTripod;

    // Dome
    final domeRect = Rect.fromCenter(
      center: Offset(w * 0.45, h * 0.52),
      width: w * 0.62,
      height: h * 0.62,
    );
    paint.color = domeColor;
    canvas.drawOval(domeRect, paint);
    paint.color = domeShade.withOpacity(0.7);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.4, h * 0.58), width: w * 0.48, height: h * 0.44),
      paint,
    );

    // Roof tint (suggestive transparency)
    paint.color = roofTint.withOpacity(isNight ? 0.35 : 0.45);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.48, h * 0.4), width: w * 0.5, height: h * 0.38),
      paint,
    );

    // Dome structural lines (curved)
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.003
      ..strokeCap = StrokeCap.round
      ..color = (isNight ? CalmPalette.nightDeepWater : CalmPalette.cliffShadow).withOpacity(0.22);
    final topY = domeRect.top + domeRect.height * 0.1;
    final bottomY = domeRect.bottom - domeRect.height * 0.08;
    const lineCount = 7;
    for (var i = 0; i < lineCount; i++) {
      final t = i / (lineCount - 1);
      final x = domeRect.left + domeRect.width * (0.16 + (0.68 * t));
      final curve = (x - domeRect.center.dx) * 0.32;
      final path = Path()
        ..moveTo(x, bottomY)
        ..cubicTo(
          x + curve,
          domeRect.center.dy + domeRect.height * 0.15,
          x + curve * 0.6,
          domeRect.center.dy - domeRect.height * 0.1,
          x,
          topY,
        );
      canvas.drawPath(path, linePaint);
    }
    final horizontalYs = [0.32, 0.45, 0.58];
    for (final t in horizontalYs) {
      final y = domeRect.top + domeRect.height * t;
      final arcRect = Rect.fromCenter(
        center: Offset(domeRect.center.dx, y),
        width: domeRect.width * 0.92,
        height: domeRect.height * 0.48,
      );
      final arcPath = Path()..addArc(arcRect, math.pi, math.pi);
      canvas.drawPath(arcPath, linePaint);
    }

    // Base
    paint.color = baseColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.22, h * 0.67, w * 0.46, h * 0.16),
        Radius.circular(w * 0.08),
      ),
      paint,
    );

    // Door
    final doorRect = Rect.fromCenter(center: Offset(w * 0.45, h * 0.68), width: w * 0.16, height: h * 0.2);
    final doorPath = Path()
      ..moveTo(doorRect.left, doorRect.top)
      ..lineTo(doorRect.right, doorRect.top)
      ..arcTo(doorRect, 0, math.pi, false)
      ..close();
    paint.color = roofTint.withOpacity(0.22);
    canvas.drawPath(doorPath, paint);
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.003
      ..color = (isNight ? CalmPalette.nightDeepWater : CalmPalette.cliffShadow).withOpacity(0.28);
    canvas.drawPath(doorPath, paint);
    paint.style = PaintingStyle.fill;

    // Soft interior glow (night)
    if (isNight) {
      paint.color = CalmPalette.lightWarm.withOpacity(0.12 + (lightOpacity * 0.18));
      canvas.drawOval(Rect.fromLTWH(w * 0.34, h * 0.62, w * 0.22, h * 0.12), paint);
    }

    // String lights (exterior)
    final wirePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.003
      ..strokeCap = StrokeCap.round
      ..color = (isNight ? CalmPalette.nightDeepWater : CalmPalette.cliffShadow).withOpacity(0.22);
    paint.color = tripodColor.withOpacity(0.7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.18, h * 0.68, w * 0.015, h * 0.22),
        Radius.circular(w * 0.02),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.38, h * 0.68, w * 0.015, h * 0.22),
        Radius.circular(w * 0.02),
      ),
      paint,
    );
    final wirePath = Path()
      ..moveTo(w * 0.19, h * 0.68)
      ..quadraticBezierTo(w * 0.28, h * 0.72, w * 0.39, h * 0.68);
    canvas.drawPath(wirePath, wirePaint);
    final bulbColor = isNight
        ? CalmPalette.lightWarm.withOpacity(0.6)
        : roofTint.withOpacity(0.2);
    paint.color = bulbColor;
    final bulbPoints = [
      Offset(w * 0.21, h * 0.69),
      Offset(w * 0.26, h * 0.71),
      Offset(w * 0.31, h * 0.72),
      Offset(w * 0.36, h * 0.7),
    ];
    for (final point in bulbPoints) {
      canvas.drawCircle(point, w * 0.012, paint);
      if (isNight) {
        paint.color = CalmPalette.lightWarm.withOpacity(0.22);
        canvas.drawCircle(point, w * 0.028, paint);
        paint.color = bulbColor;
      }
    }

    // Seasonal scatter
    if (isWinter) {
      paint.color = CalmPalette.snowWhite.withOpacity(0.7);
      canvas.drawOval(Rect.fromLTWH(w * 0.44, h * 0.84, w * 0.2, h * 0.06), paint);
      canvas.drawOval(Rect.fromLTWH(w * 0.5, h * 0.86, w * 0.14, h * 0.04), paint);
      paint.color = CalmPalette.snowWhite.withOpacity(0.25);
      canvas.drawCircle(Offset(w * 0.36, h * 0.18), w * 0.008, paint);
      canvas.drawCircle(Offset(w * 0.55, h * 0.22), w * 0.01, paint);
      canvas.drawCircle(Offset(w * 0.68, h * 0.26), w * 0.007, paint);
    } else if (isAutumn) {
      paint.color = CalmPalette.autumnLeafLight.withOpacity(0.7);
      canvas.drawOval(Rect.fromLTWH(w * 0.22, h * 0.84, w * 0.03, w * 0.018), paint);
      canvas.drawOval(Rect.fromLTWH(w * 0.38, h * 0.86, w * 0.028, w * 0.016), paint);
      paint.color = CalmPalette.autumnLeafDark.withOpacity(0.7);
      canvas.drawOval(Rect.fromLTWH(w * 0.3, h * 0.88, w * 0.03, w * 0.018), paint);
      canvas.drawOval(Rect.fromLTWH(w * 0.62, h * 0.84, w * 0.028, w * 0.016), paint);
    } else if (isSakura) {
      paint.color = CalmPalette.sakuraLight.withOpacity(0.75);
      canvas.drawOval(Rect.fromLTWH(w * 0.24, h * 0.85, w * 0.03, w * 0.02), paint);
      canvas.drawOval(Rect.fromLTWH(w * 0.44, h * 0.87, w * 0.028, w * 0.018), paint);
      paint.color = CalmPalette.sakuraDark.withOpacity(0.6);
      canvas.drawOval(Rect.fromLTWH(w * 0.52, h * 0.84, w * 0.026, w * 0.016), paint);
      paint.color = CalmPalette.sakuraLight.withOpacity(0.3);
      canvas.drawOval(Rect.fromLTWH(w * 0.62, h * 0.24, w * 0.02, w * 0.014), paint);
      canvas.drawOval(Rect.fromLTWH(w * 0.3, h * 0.2, w * 0.018, w * 0.012), paint);
    }

    // Campfire (exterior)
    paint.color = CalmPalette.cliffShadow.withOpacity(0.35);
    final fireCenter = Offset(w * 0.28, h * 0.9);
    paint.color = CalmPalette.cliffShadow.withOpacity(0.35);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: fireCenter.translate(-w * 0.02, 0), width: w * 0.06, height: w * 0.015),
        Radius.circular(w * 0.02),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: fireCenter.translate(w * 0.02, w * 0.005), width: w * 0.055, height: w * 0.014),
        Radius.circular(w * 0.02),
      ),
      paint,
    );
    paint.color = CalmPalette.cliffShadow.withOpacity(0.2);
    canvas.drawOval(Rect.fromCenter(center: fireCenter, width: w * 0.05, height: w * 0.02), paint);
    if (isNight) {
      paint.color = CalmPalette.lightWarm.withOpacity(0.55);
      canvas.drawOval(Rect.fromCenter(center: fireCenter, width: w * 0.07, height: w * 0.04), paint);
      paint.color = CalmPalette.lightWarm.withOpacity(0.3);
      canvas.drawOval(Rect.fromCenter(center: fireCenter.translate(0, -w * 0.012), width: w * 0.1, height: w * 0.05), paint);
    } else if (isWinter) {
      paint.color = CalmPalette.snowWhite.withOpacity(0.6);
      canvas.drawOval(Rect.fromCenter(center: fireCenter, width: w * 0.06, height: w * 0.025), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StargazerHutPainter oldDelegate) {
    return lightOpacity != oldDelegate.lightOpacity ||
        isNight != oldDelegate.isNight ||
        isSakura != oldDelegate.isSakura ||
        isAutumn != oldDelegate.isAutumn ||
        isWinter != oldDelegate.isWinter;
  }
}

// Forest Cabin Widget
class ForestCabinWidget extends StatelessWidget {
  final double size;
  final double lightIntensity;
  final bool isNight;
  final bool isFocusing;
  final bool isSakura;
  final bool isAutumn;
  final bool isWinter;

  const ForestCabinWidget({
    super.key,
    required this.size,
    required this.lightIntensity,
    required this.isNight,
    required this.isFocusing,
    this.isSakura = false,
    this.isAutumn = false,
    this.isWinter = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.75,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: lightIntensity),
        duration: const Duration(milliseconds: 1200),
        builder: (context, lightOpacity, child) {
          return CustomPaint(
            painter: _ForestCabinPainter(
              lightOpacity: lightOpacity,
              isNight: isNight,
              isFocusing: isFocusing,
              isSakura: isSakura,
              isAutumn: isAutumn,
              isWinter: isWinter,
            ),
          );
        },
      ),
    );
  }
}

class _ForestCabinPainter extends CustomPainter {
  final double lightOpacity;
  final bool isNight;
  final bool isFocusing;
  final bool isSakura;
  final bool isAutumn;
  final bool isWinter;

  _ForestCabinPainter({
    required this.lightOpacity,
    required this.isNight,
    required this.isFocusing,
    required this.isSakura,
    required this.isAutumn,
    required this.isWinter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..style = PaintingStyle.fill;

    // Colors
    final wallColor = isNight ? CalmPalette.nightCabinWall : CalmPalette.cabinWall;
    final roofColor = isNight ? CalmPalette.nightCabinRoof : CalmPalette.cabinRoof;
    final doorColor = isNight ? CalmPalette.nightCabinDoor : CalmPalette.cabinDoor;
    final woodDark = isNight ? CalmPalette.nightCabinWoodDark : CalmPalette.cabinWoodDark;

    // === 1. BACK TREES (Behind cabin) ===
    _drawPineTree(canvas, w * 0.15, h * 0.85, w * 0.25, h * 0.55, true);
    _drawPineTree(canvas, w * 0.82, h * 0.88, w * 0.22, h * 0.50, true);

    // === 2. CABIN BODY (A-frame) ===
    // Main A-frame structure
    final cabinPath = Path();
    cabinPath.moveTo(w * 0.25, h * 0.85); // Bottom left
    cabinPath.lineTo(w * 0.50, h * 0.25); // Peak
    cabinPath.lineTo(w * 0.75, h * 0.85); // Bottom right
    cabinPath.close();
    paint.color = wallColor;
    canvas.drawPath(cabinPath, paint);

    // Roof overhang (darker triangle on top)
    final roofPath = Path();
    roofPath.moveTo(w * 0.20, h * 0.50); // Left overhang
    roofPath.lineTo(w * 0.50, h * 0.18); // Peak
    roofPath.lineTo(w * 0.80, h * 0.50); // Right overhang
    roofPath.lineTo(w * 0.75, h * 0.55); // Right inner
    roofPath.lineTo(w * 0.50, h * 0.25); // Peak inner
    roofPath.lineTo(w * 0.25, h * 0.55); // Left inner
    roofPath.close();
    paint.color = roofColor;
    canvas.drawPath(roofPath, paint);

    // Wood texture lines (subtle)
    paint.color = woodDark.withOpacity(0.3);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = w * 0.002;
    for (var i = 0; i < 6; i++) {
      final t = (i + 1) / 7;
      final leftX = w * 0.25 + (w * 0.25 * t);
      final rightX = w * 0.75 - (w * 0.25 * t);
      final y = h * 0.85 - (h * 0.60 * t);
      canvas.drawLine(Offset(leftX, y), Offset(rightX, y), paint);
    }
    paint.style = PaintingStyle.fill;

    // === 3. DOOR (Centered, front-facing) ===
    final doorRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.44, h * 0.58, w * 0.12, h * 0.27),
      Radius.circular(w * 0.01),
    );
    paint.color = doorColor;
    canvas.drawRRect(doorRect, paint);

    // Door frame
    paint.color = woodDark;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = w * 0.003;
    canvas.drawRRect(doorRect, paint);
    paint.style = PaintingStyle.fill;

    // Door knob
    paint.color = CalmPalette.lightWarm.withOpacity(0.6);
    canvas.drawCircle(Offset(w * 0.535, h * 0.72), w * 0.008, paint);

    // Door ground spill light (night)
    if (lightOpacity > 0) {
      paint.color = CalmPalette.lightWarm.withOpacity(lightOpacity * 0.4);
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 15.0);
      canvas.drawOval(Rect.fromLTWH(w * 0.42, h * 0.82, w * 0.16, h * 0.06), paint);
      paint.maskFilter = null;
    }

    // === 4. WINDOW (Small, beside door) ===
    final windowRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.58, h * 0.52, w * 0.10, h * 0.12),
      Radius.circular(w * 0.02),
    );
    
    // Window color based on time
    final Color windowColor = Color.lerp(
      Colors.white.withOpacity(0.25),
      CalmPalette.lightWarm,
      lightOpacity,
    )!;
    
    paint.color = windowColor.withOpacity(0.4 + (lightOpacity * 0.4));
    canvas.drawRRect(windowRect, paint);

    // Window frame
    paint.color = woodDark;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = w * 0.003;
    canvas.drawRRect(windowRect, paint);
    
    // Window cross
    paint.style = PaintingStyle.fill;
    paint.strokeWidth = w * 0.002;
    canvas.drawLine(Offset(w * 0.63, h * 0.52), Offset(w * 0.63, h * 0.64), paint);
    canvas.drawLine(Offset(w * 0.58, h * 0.58), Offset(w * 0.68, h * 0.58), paint);

    // Window glow (night)
    if (lightOpacity > 0) {
      paint.color = CalmPalette.lightWarm.withOpacity(lightOpacity * 0.5);
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
      canvas.drawRRect(windowRect.inflate(w * 0.02), paint);
      paint.maskFilter = null;
    }

    // === 5. FRONT TREES (Beside cabin) ===
    _drawPineTree(canvas, w * 0.05, h * 0.90, w * 0.20, h * 0.45, false);
    _drawPineTree(canvas, w * 0.90, h * 0.92, w * 0.18, h * 0.40, false);

    // === 6. SNOW PILES (Winter only, at base) ===
    if (isWinter) {
      final snowPaint = Paint()..color = CalmPalette.snowWhite.withOpacity(0.85);
      // Snow at cabin base
      canvas.drawOval(Rect.fromLTWH(w * 0.22, h * 0.82, w * 0.18, h * 0.08), snowPaint);
      canvas.drawOval(Rect.fromLTWH(w * 0.52, h * 0.83, w * 0.28, h * 0.07), snowPaint);
      // Snow piles around
      canvas.drawOval(Rect.fromLTWH(w * 0.08, h * 0.85, w * 0.12, h * 0.06), snowPaint..color = CalmPalette.snowWhite.withOpacity(0.7));
      canvas.drawOval(Rect.fromLTWH(w * 0.78, h * 0.86, w * 0.15, h * 0.05), snowPaint);
    }

    // === 7. CAMPFIRE (Must be after snow - on top!) ===
    final fireCenter = Offset(w * 0.22, h * 0.88);
    
    // Logs
    paint.color = woodDark.withOpacity(0.6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: fireCenter.translate(-w * 0.015, h * 0.01), width: w * 0.06, height: w * 0.012),
        Radius.circular(w * 0.01),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: fireCenter.translate(w * 0.015, h * 0.015), width: w * 0.055, height: w * 0.011),
        Radius.circular(w * 0.01),
      ),
      paint,
    );

    // Fire glow (night + focusing)
    if (isNight && isFocusing) {
      // Outer glow
      paint.color = CalmPalette.lightWarm.withOpacity(0.35 + (lightOpacity * 0.15));
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 20.0);
      canvas.drawOval(Rect.fromCenter(center: fireCenter.translate(0, -h * 0.02), width: w * 0.12, height: w * 0.08), paint);
      
      // Inner glow
      paint.color = CalmPalette.lightWarm.withOpacity(0.55 + (lightOpacity * 0.2));
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
      canvas.drawOval(Rect.fromCenter(center: fireCenter, width: w * 0.07, height: w * 0.04), paint);
      paint.maskFilter = null;
      
      // Fire core
      paint.color = const Color(0xFFFF6F00).withOpacity(0.8);
      canvas.drawOval(Rect.fromCenter(center: fireCenter.translate(0, -h * 0.005), width: w * 0.035, height: w * 0.025), paint);
    } else if (isWinter && !isNight) {
      // Snow on fire pit during winter day
      paint.color = CalmPalette.snowWhite.withOpacity(0.5);
      canvas.drawOval(Rect.fromCenter(center: fireCenter, width: w * 0.05, height: w * 0.025), paint);
    }

    // === 8. STRING LIGHTS (Last - above everything) ===
    // Wire from cabin roof to front tree
    final wirePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.002
      ..strokeCap = StrokeCap.round
      ..color = (isNight ? CalmPalette.nightDeepWater : CalmPalette.cliffShadow).withOpacity(0.35);
    
    // Wire path (cabin to left front tree)
    final wirePath = Path()
      ..moveTo(w * 0.25, h * 0.55) // Cabin roof left edge
      ..quadraticBezierTo(w * 0.15, h * 0.62, w * 0.08, h * 0.50); // To left front tree
    canvas.drawPath(wirePath, wirePaint);

    // Bulbs along wire
    final bulbColor = isNight
        ? CalmPalette.lightWarm.withOpacity(0.8)
        : CalmPalette.cabinWindow.withOpacity(0.25);
    
    paint.color = bulbColor;
    final bulbPoints = [
      Offset(w * 0.22, h * 0.56),
      Offset(w * 0.18, h * 0.58),
      Offset(w * 0.14, h * 0.56),
      Offset(w * 0.10, h * 0.53),
    ];
    
    for (final point in bulbPoints) {
      canvas.drawCircle(point, w * 0.01, paint);
      if (isNight) {
        // Glow around bulb
        paint.color = CalmPalette.lightWarm.withOpacity(0.25);
        canvas.drawCircle(point, w * 0.025, paint);
        paint.color = bulbColor;
      }
    }

    // Seasonal scatter on ground
    if (isSakura) {
      paint.color = CalmPalette.sakuraLight.withOpacity(0.75);
      canvas.drawOval(Rect.fromLTWH(w * 0.30, h * 0.88, w * 0.03, w * 0.02), paint);
      canvas.drawOval(Rect.fromLTWH(w * 0.55, h * 0.90, w * 0.028, w * 0.018), paint);
      paint.color = CalmPalette.sakuraDark.withOpacity(0.6);
      canvas.drawOval(Rect.fromLTWH(w * 0.42, h * 0.87, w * 0.026, w * 0.016), paint);
    } else if (isAutumn) {
      paint.color = CalmPalette.autumnLeafLight.withOpacity(0.7);
      canvas.drawOval(Rect.fromLTWH(w * 0.28, h * 0.89, w * 0.03, w * 0.018), paint);
      canvas.drawOval(Rect.fromLTWH(w * 0.48, h * 0.91, w * 0.028, w * 0.016), paint);
      paint.color = CalmPalette.autumnLeafDark.withOpacity(0.7);
      canvas.drawOval(Rect.fromLTWH(w * 0.38, h * 0.88, w * 0.03, w * 0.018), paint);
    }
  }

  void _drawPineTree(Canvas canvas, double x, double y, double width, double height, bool isBack) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Trunk
    final trunkHeight = height * 0.25;
    final trunkWidth = width * 0.12;
    paint.color = isNight 
        ? CalmPalette.cliffShadow.withOpacity(isBack ? 0.6 : 1.0)
        : CalmPalette.cliffShadow.withOpacity(isBack ? 0.7 : 1.0);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(x, y - trunkHeight * 0.5), width: trunkWidth, height: trunkHeight),
      paint,
    );

    // Foliage color based on season
    // NOTE: Pine trees stay green in Sakura season (only deciduous trees turn pink)
    Color foliageColor;
    if (isAutumn) {
      foliageColor = isNight 
          ? CalmPalette.autumnLeafLight.withOpacity(0.7) 
          : CalmPalette.autumnLeafLight;
    } else if (isWinter) {
      foliageColor = isNight 
          ? CalmPalette.pineGreen.withOpacity(0.8) 
          : CalmPalette.pineGreen;
    } else {
      foliageColor = isNight 
          ? CalmPalette.nightFoliage 
          : CalmPalette.grassHighlight;
    }

    // Apply darkness for back trees
    if (isBack) {
      foliageColor = foliageColor.withOpacity(0.7);
    }

    paint.color = foliageColor;

    // Pine tree tiers (3 triangles)
    // Bottom tier
    final bottomPath = Path();
    bottomPath.moveTo(x - width * 0.4, y - trunkHeight * 0.8);
    bottomPath.lineTo(x + width * 0.4, y - trunkHeight * 0.8);
    bottomPath.lineTo(x, y - height * 0.55);
    bottomPath.close();
    canvas.drawPath(bottomPath, paint);

    // Middle tier
    final middlePath = Path();
    middlePath.moveTo(x - width * 0.32, y - height * 0.45);
    middlePath.lineTo(x + width * 0.32, y - height * 0.45);
    middlePath.lineTo(x, y - height * 0.75);
    middlePath.close();
    canvas.drawPath(middlePath, paint);

    // Top tier
    final topPath = Path();
    topPath.moveTo(x - width * 0.22, y - height * 0.65);
    topPath.lineTo(x + width * 0.22, y - height * 0.65);
    topPath.lineTo(x, y - height);
    topPath.close();
    canvas.drawPath(topPath, paint);

    // Snow caps for winter
    if (isWinter) {
      final snowPaint = Paint()..color = CalmPalette.snowWhite;
      
      // Top cap
      final topSnow = Path();
      topSnow.moveTo(x - width * 0.08, y - height * 0.82);
      topSnow.lineTo(x + width * 0.08, y - height * 0.82);
      topSnow.lineTo(x, y - height);
      topSnow.close();
      canvas.drawPath(topSnow, snowPaint);

      // Middle cap
      final midSnow = Path();
      midSnow.moveTo(x - width * 0.12, y - height * 0.62);
      midSnow.lineTo(x + width * 0.12, y - height * 0.62);
      midSnow.lineTo(x, y - height * 0.75);
      midSnow.close();
      canvas.drawPath(midSnow, snowPaint);

      // Snow at base
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y - trunkHeight * 0.2), width: width * 0.2, height: width * 0.08),
        snowPaint..color = CalmPalette.snowWhite.withOpacity(0.9),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ForestCabinPainter oldDelegate) {
    return lightOpacity != oldDelegate.lightOpacity ||
        isNight != oldDelegate.isNight ||
        isFocusing != oldDelegate.isFocusing ||
        isSakura != oldDelegate.isSakura ||
        isAutumn != oldDelegate.isAutumn ||
        isWinter != oldDelegate.isWinter;
  }
}

class StargazerTelescopeWidget extends StatelessWidget {
  final double size;
  final bool isNight;
  final bool isWinter;

  const StargazerTelescopeWidget({
    super.key,
    required this.size,
    required this.isNight,
    required this.isWinter,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.8,
      child: CustomPaint(
        painter: _StargazerTelescopePainter(
          isNight: isNight,
          isWinter: isWinter,
        ),
      ),
    );
  }
}

class _StargazerTelescopePainter extends CustomPainter {
  final bool isNight;
  final bool isWinter;

  const _StargazerTelescopePainter({
    required this.isNight,
    required this.isWinter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..style = PaintingStyle.fill;

    final scopeColor = isNight ? CalmPalette.nightStargazerScope : CalmPalette.stargazerScope;
    final tripodColor = isNight ? CalmPalette.nightStargazerTripod : CalmPalette.stargazerTripod;
    final roofTint = isNight ? CalmPalette.nightStargazerRoofTint : CalmPalette.stargazerRoofTint;

    const telescopeAngle = -0.48;
    final telescopeOrigin = Offset(w * 0.74, h * 0.76);
    canvas.save();
    canvas.translate(telescopeOrigin.dx, telescopeOrigin.dy);
    canvas.rotate(telescopeAngle);
    paint.color = scopeColor;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, h * 0.012, w * 0.24, h * 0.046),
      Radius.circular(w * 0.03),
    );
    canvas.drawRRect(bodyRect, paint);
    paint.color = scopeColor.withOpacity(0.9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.22, 0, w * 0.08, h * 0.07),
        Radius.circular(w * 0.035),
      ),
      paint,
    );
    paint.color = scopeColor.withOpacity(0.75);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.17, h * 0.02, w * 0.035, h * 0.03),
        Radius.circular(w * 0.02),
      ),
      paint,
    );
    paint.color = scopeColor.withOpacity(0.7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, h * 0.02, w * 0.045, h * 0.03),
        Radius.circular(w * 0.02),
      ),
      paint,
    );
    paint.color = roofTint.withOpacity(isNight ? 0.35 : 0.45);
    canvas.drawCircle(Offset(w * 0.3, h * 0.035), w * 0.03, paint);
    if (isWinter) {
      paint.color = CalmPalette.snowWhite.withOpacity(0.18);
      canvas.drawOval(Rect.fromLTWH(w * 0.06, -h * 0.002, w * 0.16, h * 0.015), paint);
    }
    canvas.restore();

    paint.color = tripodColor;
    final jointLocal = Offset(w * 0.12, h * 0.07);
    final joint = Offset(
      telescopeOrigin.dx + (jointLocal.dx * math.cos(telescopeAngle)) - (jointLocal.dy * math.sin(telescopeAngle)),
      telescopeOrigin.dy + (jointLocal.dx * math.sin(telescopeAngle)) + (jointLocal.dy * math.cos(telescopeAngle)),
    );
    final legPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.008
      ..strokeCap = StrokeCap.round
      ..color = tripodColor;
    canvas.drawCircle(joint, w * 0.01, paint);
    canvas.drawLine(joint, joint.translate(-w * 0.035, h * 0.08), legPaint);
    canvas.drawLine(joint, joint.translate(w * 0.02, h * 0.085), legPaint);
    canvas.drawLine(joint, joint.translate(-w * 0.005, h * 0.095), legPaint);
  }

  @override
  bool shouldRepaint(covariant _StargazerTelescopePainter oldDelegate) {
    return isNight != oldDelegate.isNight || isWinter != oldDelegate.isWinter;
  }
}

// 2.5 GARDEN LAMP
class CalmGardenLamp extends StatelessWidget {
  final double size;
  final double lightIntensity;
  
  final bool isNight;
  
  const CalmGardenLamp({super.key, required this.size, required this.lightIntensity, required this.isNight});
  
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: lightIntensity), 
      duration: const Duration(milliseconds: 1200),
      builder: (context, opacity, child) {
         return CustomPaint(
           size: Size(size, size * 2), // Tall thin lamp
           painter: _CalmGardenLampPainter(lightOpacity: opacity, isNight: isNight)
         );
      }
    );
  }
}

class _CalmGardenLampPainter extends CustomPainter {
  final double lightOpacity;
  final bool isNight;
  const _CalmGardenLampPainter({required this.lightOpacity, required this.isNight});
  
  @override 
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Post (Always visible but subtle)
    paint.color = CalmPalette.cliffShadow;
    canvas.drawRect(Rect.fromLTWH(w * 0.4, h * 0.2, w * 0.2, h * 0.8), paint);
    
    // Lamp Head
    paint.color = isNight ? CalmPalette.nightHouseRoof : CalmPalette.houseRoof;
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
  bool shouldRepaint(covariant _CalmGardenLampPainter oldDelegate) {
    return lightOpacity != oldDelegate.lightOpacity || isNight != oldDelegate.isNight;
  }
}

class CalmTreeWidget extends StatefulWidget {
  final double size;
  final bool isFocusing;
  final bool isSakura;
  final bool isAutumn;
  final bool isWinter;
  final bool isNight;
  final int delay;
  const CalmTreeWidget({
    super.key, 
    required this.size, 
    required this.isFocusing, 
    this.isSakura = false,
    this.isAutumn = false,
    this.isWinter = false,
    this.delay = 0,
    required this.isNight,
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
            isNight: widget.isNight,
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
  final bool isNight;
  
  _CalmTreePainter({required this.swayValue, required this.isSakura, required this.isAutumn, required this.isWinter, required this.isNight});
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final trunkPaint = Paint()..color = CalmPalette.cliffShadow;
    Color foliageColor = CalmPalette.grassHighlight;
    if (isNight) foliageColor = CalmPalette.nightFoliage;
    
    if (isSakura) foliageColor = isNight ? CalmPalette.nightFoliageSakura : CalmPalette.sakuraLight;
    if (isAutumn) foliageColor = isNight ? CalmPalette.autumnLeafLight.withOpacity(0.7) : CalmPalette.autumnLeafLight; // Manual dim for Autumn
    if (isWinter) foliageColor = isNight ? CalmPalette.pineGreen.withOpacity(0.8) : CalmPalette.pineGreen; // Manual dim for Winter
    
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
      foliagePaint.color = isNight ? CalmPalette.nightFoliageSakura : CalmPalette.sakuraLight;
      canvas.drawCircle(Offset(0, -h * 0.2), w * 0.22, foliagePaint);
      canvas.drawCircle(Offset(-w * 0.15, -h * 0.15), w * 0.18, foliagePaint);
      canvas.drawCircle(Offset(w * 0.15, -h * 0.15), w * 0.18, foliagePaint);
      
      // Depth
      foliagePaint.color = CalmPalette.sakuraDark.withOpacity(0.3);
      canvas.drawCircle(Offset(0, -h * 0.15), w * 0.15, foliagePaint);
      
    } else if (isAutumn) {
      // AUTUMN SHAPE: Maple (Wider, Flatter)
      
      // Main Crown (Wide)
      foliagePaint.color = isNight ? CalmPalette.autumnLeafLight.withOpacity(0.7) : CalmPalette.autumnLeafLight;
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
  bool shouldRepaint(covariant _CalmTreePainter oldDelegate) {
    return swayValue != oldDelegate.swayValue || 
           isSakura != oldDelegate.isSakura || 
           isAutumn != oldDelegate.isAutumn || 
           isWinter != oldDelegate.isWinter ||
           isNight != oldDelegate.isNight;
  }
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

class AdventureCharacterWidget extends StatelessWidget {
  final bool isFocusing;
  final double size;
  final double walkProgress;
  final bool isFacingLeft;
  final bool isWalking;

  const AdventureCharacterWidget({
    super.key,
    required this.isFocusing,
    required this.size,
    required this.walkProgress,
    required this.isFacingLeft,
    required this.isWalking,
  });

  @override
  Widget build(BuildContext context) {
    if (!isWalking) {
      return SizedBox(
        width: size,
        height: size * 2.2,
        child: CustomPaint(
          painter: _CalmCharacterPainter(
            walkProgress: 0,
            isMoving: false,
            viewMode: CharacterViewMode.front,
            palette: _CharacterPalette.adventurePalette,
          ),
        ),
      );
    }

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..scale(isFacingLeft ? -1.0 : 1.0, 1.0),
      child: SizedBox(
        width: size,
        height: size * 2.2,
        child: CustomPaint(
          painter: _CalmCharacterPainter(
            walkProgress: walkProgress,
            isMoving: true,
            viewMode: CharacterViewMode.side,
            palette: _CharacterPalette.adventurePalette,
          ),
        ),
      ),
    );
  }
}

/* class _AdventureCharacterPainter extends CustomPainter {
  final double walkProgress;
  final bool isMoving;
  final CharacterViewMode viewMode;

  _AdventureCharacterPainter({
    required this.walkProgress,
    required this.isMoving,
    required this.viewMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final Paint p = Paint()..style = PaintingStyle.fill;

    const skinBase = Color(0xFFFFC7B2);
    const skinShadow = Color(0xFFFFB59C);
    const hair = Color(0xFF4F453F);
    const tunic = Color(0xFF8BA58C);
    const tunicShade = Color(0xFF748B76);
    const hat = Color(0xFFC6A27D);
    const hatShade = Color(0xFFB38C69);
    const boot = Color(0xFF6D5A4E);
    const dogBase = Color(0xFFF0D9AA);
    const dogShade = Color(0xFFD7BA85);
    const dogNose = Color(0xFF6D5A4E);

    final kidX = w * 0.38;
    final dogX = w * 0.68;
    final kidLeanX = w * 0.02;
    final kidLeanY = h * 0.01;

    if (viewMode == CharacterViewMode.front) {
      final frontX = kidX + kidLeanX;
      final frontY = kidLeanY;

      // Explorer Kid
      p.color = tunic;
      final torsoRect = Rect.fromLTWH(frontX - w * 0.135, h * 0.53 + frontY, w * 0.27, h * 0.3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(torsoRect, Radius.circular(w * 0.12)),
        p,
      );
      canvas.drawCircle(Offset(frontX - w * 0.12, h * 0.55 + frontY), w * 0.08, p);
      canvas.drawCircle(Offset(frontX + w * 0.12, h * 0.55 + frontY), w * 0.08, p);

      p.color = tunicShade;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(frontX - w * 0.11, h * 0.62 + frontY, w * 0.22, h * 0.1),
          Radius.circular(w * 0.06),
        ),
        p,
      );

      p.color = boot;
      canvas.drawRect(Rect.fromLTWH(frontX - w * 0.085, h * 0.86 + frontY, w * 0.06, h * 0.08), p);
      canvas.drawRect(Rect.fromLTWH(frontX + w * 0.02, h * 0.84 + frontY, w * 0.06, h * 0.08), p);

      p.color = skinBase;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(frontX, h * 0.39 + frontY), width: w * 0.28, height: w * 0.28),
        p,
      );

      p.color = hair;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(frontX, h * 0.35 + frontY), width: w * 0.3, height: w * 0.2),
        p,
      );

      p.color = hat;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(frontX, h * 0.29 + frontY), width: w * 0.24, height: w * 0.11),
          Radius.circular(w * 0.06),
        ),
        p,
      );
      p.color = hatShade;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(frontX, h * 0.315 + frontY), width: w * 0.26, height: w * 0.04),
          Radius.circular(w * 0.03),
        ),
        p,
      );

      p.color = skinShadow;
      canvas.drawOval(Rect.fromCenter(center: Offset(frontX - w * 0.15, h * 0.62 + frontY), width: w * 0.075, height: w * 0.075), p);
      canvas.drawOval(Rect.fromCenter(center: Offset(frontX + w * 0.14, h * 0.6 + frontY), width: w * 0.075, height: w * 0.075), p);
      canvas.drawOval(Rect.fromCenter(center: Offset(frontX - w * 0.12, h * 0.68 + frontY), width: w * 0.06, height: w * 0.06), p);
      canvas.drawOval(Rect.fromCenter(center: Offset(frontX + w * 0.1, h * 0.66 + frontY), width: w * 0.06, height: w * 0.06), p);

      // Elastic Dog
      p.color = dogBase;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(dogX, h * 0.78), width: w * 0.32, height: h * 0.15),
        p,
      );
      p.color = dogShade;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(dogX + w * 0.18, h * 0.73), width: w * 0.14, height: w * 0.14),
        p,
      );
      canvas.drawOval(
        Rect.fromCenter(center: Offset(dogX + w * 0.2, h * 0.68), width: w * 0.06, height: w * 0.08),
        p,
      );
      p.color = dogBase;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(dogX + w * 0.18, h * 0.73), width: w * 0.12, height: w * 0.12),
        p,
      );
      p.color = dogShade;
      canvas.drawRect(Rect.fromLTWH(dogX - w * 0.12, h * 0.84, w * 0.04, h * 0.08), p);
      canvas.drawRect(Rect.fromLTWH(dogX - w * 0.02, h * 0.84, w * 0.04, h * 0.08), p);
      canvas.drawRect(Rect.fromLTWH(dogX + w * 0.06, h * 0.84, w * 0.04, h * 0.08), p);

      p.color = dogNose;
      canvas.drawCircle(Offset(dogX + w * 0.22, h * 0.74), w * 0.02, p);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(dogX - w * 0.18, h * 0.78), width: w * 0.08, height: w * 0.04),
        p,
      );
      return;
    }

    final t = walkProgress * math.pi * 2;
    final legSwing = isMoving ? math.sin(t) * (w * 0.08) : 0.0;
    final armSwing = isMoving ? math.cos(t) * 0.35 : 0.0;
    final armOffset = isMoving ? math.sin(t) * 2.0 : 0.0;
    final dogLegSwing = isMoving ? math.sin(t + math.pi) * (w * 0.05) : 0.0;
    final dogStretch = isMoving ? 1.0 + (math.sin(t) * 0.04) : 1.0;
    final bob = isMoving ? -0.5 * math.sin(t * 2).abs() : 0.0;

    canvas.save();
    canvas.translate(0, bob);

    // Explorer Kid (Side)
    final sideX = kidX + kidLeanX;
    final sideY = kidLeanY;

    // Back arm (behind body)
    canvas.save();
    canvas.translate(sideX + w * 0.02 - armOffset, h * 0.6 + sideY);
    canvas.rotate(-armSwing * 0.6);
    p.color = tunicShade.withOpacity(0.85);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w * 0.07, h * 0.1),
        Radius.circular(w * 0.04),
      ),
      p,
    );
    canvas.rotate(-0.4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.01, h * 0.08, w * 0.07, h * 0.08),
        Radius.circular(w * 0.04),
      ),
      p,
    );
    canvas.restore();

    // Body + head + legs
    p.color = tunic;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(sideX - w * 0.11, h * 0.53 + sideY, w * 0.22, h * 0.3),
        Radius.circular(w * 0.1),
      ),
      p,
    );
    p.color = tunicShade;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(sideX - w * 0.08, h * 0.63 + sideY, w * 0.16, h * 0.08),
        Radius.circular(w * 0.05),
      ),
      p,
    );
    p.color = boot;
    canvas.drawRect(Rect.fromLTWH(sideX - w * 0.02 + legSwing + w * 0.02, h * 0.86 + sideY, w * 0.06, h * 0.08), p);
    p.color = skinBase;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(sideX + w * 0.03, h * 0.39 + sideY), width: w * 0.26, height: w * 0.26),
      p,
    );
    p.color = hair;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(sideX + w * 0.01, h * 0.35 + sideY), width: w * 0.24, height: w * 0.18),
      p,
    );
    p.color = hat;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(sideX + w * 0.03, h * 0.3 + sideY), width: w * 0.22, height: w * 0.1),
        Radius.circular(w * 0.06),
      ),
      p,
    );
    p.color = hatShade;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(sideX + w * 0.05, h * 0.32 + sideY), width: w * 0.24, height: w * 0.035),
        Radius.circular(w * 0.02),
      ),
      p,
    );

    // Front arm (in front of body)
    canvas.save();
    canvas.translate(sideX + w * 0.06 + armOffset, h * 0.6 + sideY);
    canvas.rotate(armSwing * 0.6);
    p.color = tunicShade;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w * 0.07, h * 0.1),
        Radius.circular(w * 0.04),
      ),
      p,
    );
    canvas.rotate(0.5);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.01, h * 0.08, w * 0.07, h * 0.08),
        Radius.circular(w * 0.04),
      ),
      p,
    );
    canvas.restore();

    // Elastic Dog (Side)
    final dogBodyWidth = w * 0.32 * dogStretch;
    p.color = dogBase;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(dogX, h * 0.78), width: dogBodyWidth, height: h * 0.13),
      p,
    );
    p.color = dogShade;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(dogX + w * 0.18, h * 0.74), width: w * 0.12, height: w * 0.12),
      p,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(dogX + w * 0.2, h * 0.69), width: w * 0.05, height: w * 0.07),
      p,
    );
    p.color = dogNose;
    canvas.drawCircle(Offset(dogX + w * 0.24, h * 0.75), w * 0.018, p);
    p.color = dogShade;
    canvas.drawRect(Rect.fromLTWH(dogX - w * 0.12 + dogLegSwing, h * 0.84, w * 0.04, h * 0.08), p);
    canvas.drawRect(Rect.fromLTWH(dogX - w * 0.02 - dogLegSwing, h * 0.84, w * 0.04, h * 0.08), p);
    canvas.drawRect(Rect.fromLTWH(dogX + w * 0.06 + dogLegSwing, h * 0.84, w * 0.04, h * 0.08), p);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(dogX - w * 0.18, h * 0.78), width: w * 0.08, height: w * 0.04),
      p,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

*/
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

class _CharacterPalette {
  final Color skinLight;
  final Color skinDark;
  final Color hairTop;
  final Color hairBottom;
  final Color clothLight;
  final Color clothDark;
  final Color leg;
  final Color blush;
  final Color eyeWhite;
  final Color iris;
  final Color mouth;
  final Color glasses;
  final Color highlight;

  const _CharacterPalette({
    required this.skinLight,
    required this.skinDark,
    required this.hairTop,
    required this.hairBottom,
    required this.clothLight,
    required this.clothDark,
    required this.leg,
    required this.blush,
    required this.eyeWhite,
    required this.iris,
    required this.mouth,
    required this.glasses,
    required this.highlight,
  });

  static const defaultPalette = _CharacterPalette(
    skinLight: Color(0xFFFFCCBC),
    skinDark: Color(0xFFFFAB91),
    hairTop: Color(0xFF4E342E),
    hairBottom: Color(0xFF3E2723),
    clothLight: Color(0xFF8D6E63),
    clothDark: Color(0xFF6D4C41),
    leg: Color(0xFF3E2723),
    blush: Color(0xFFFF8A65),
    eyeWhite: Color(0xFFF5F5F5),
    iris: Color(0xFF5D4037),
    mouth: Color(0xFF8D6E63),
    glasses: Color(0xFF455A64),
    highlight: Colors.white,
  );

  static const adventurePalette = _CharacterPalette(
    skinLight: Color(0xFFFFC9B5),
    skinDark: Color(0xFFFFB59C),
    hairTop: Color(0xFF5A4E45),
    hairBottom: Color(0xFF473C35),
    clothLight: Color(0xFF8BA58C),
    clothDark: Color(0xFF728A75),
    leg: Color(0xFF4A3F38),
    blush: Color(0xFFFF9B82),
    eyeWhite: Color(0xFFF5F2EE),
    iris: Color(0xFF5D4037),
    mouth: Color(0xFF7A6C62),
    glasses: Color(0xFF455A64),
    highlight: Colors.white,
  );
}

class _CalmCharacterPainter extends CustomPainter {
  final double walkProgress;
  final bool isMoving;
  final CharacterViewMode viewMode;
  final _CharacterPalette palette;
  
  _CalmCharacterPainter({
    required this.walkProgress, 
    required this.isMoving,
    required this.viewMode,
    this.palette = _CharacterPalette.defaultPalette,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double centerX = w / 2;
    
    // Missing Paint definition re-added
    final Paint p = Paint()..style = PaintingStyle.fill;
    
    // --- PALETTE (Earth Tones & Softness) ---
    final skinGradient = RadialGradient(
      colors: [palette.skinLight, palette.skinDark], 
      center: Alignment(0.0, -0.2),
      radius: 0.5,
    );
    
    final hairGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [palette.hairTop, palette.hairBottom], 
    );
    
    final clothGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [palette.clothLight, palette.clothDark], 
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
        p.color = palette.leg; 
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
        p.color = palette.skinLight; 
        canvas.drawOval(Rect.fromCenter(center: Offset(centerX - w*0.25, h*0.78), width: w*0.06, height: w*0.06), p);
        canvas.drawOval(Rect.fromCenter(center: Offset(centerX + w*0.25, h*0.78), width: w*0.06, height: w*0.06), p);

       // NECK
       p.shader = null;
        p.color = palette.skinDark; 
        canvas.drawRect(Rect.fromCenter(center: Offset(centerX, h * 0.42), width: w*0.11, height: h*0.08), p);

       // 3. HEAD (Soft Round Oval)
       p.shader = skinGradient.createShader(Rect.fromLTWH(0, 0, w, h));
       final headRect = Rect.fromCenter(center: Offset(centerX, h * 0.29), width: w * 0.36, height: h * 0.27);
       canvas.drawOval(headRect, p);
       
       // 4. FACE DETAILS
       p.shader = null;
       
       // Blush
        p.color = palette.blush.withOpacity(0.15); 
       p.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0); 
       canvas.drawOval(Rect.fromCenter(center: Offset(centerX - w*0.1, h*0.33), width: w*0.08, height: w*0.05), p);
       canvas.drawOval(Rect.fromCenter(center: Offset(centerX + w*0.1, h*0.33), width: w*0.08, height: w*0.05), p);
       p.maskFilter = null;
       
       // EYES
        p.color = palette.eyeWhite; 
       canvas.drawOval(Rect.fromCenter(center: Offset(centerX - w*0.08, h*0.29), width: w*0.07, height: w*0.045), p);
       canvas.drawOval(Rect.fromCenter(center: Offset(centerX + w*0.08, h*0.29), width: w*0.07, height: w*0.045), p);
       
       // Iris
        p.color = palette.iris; 
       canvas.drawCircle(Offset(centerX - w*0.08, h*0.29), w*0.022, p);
       canvas.drawCircle(Offset(centerX + w*0.08, h*0.29), w*0.022, p);
       
       // Highlight
        p.color = palette.highlight.withOpacity(0.6);
       canvas.drawCircle(Offset(centerX - w*0.09, h*0.285), w*0.006, p);
       canvas.drawCircle(Offset(centerX + w*0.07, h*0.285), w*0.006, p);

       // MOUTH
        p.color = palette.mouth;
       p.style = PaintingStyle.stroke;
       p.strokeWidth = 0.7;
       canvas.drawArc(Rect.fromCenter(center: Offset(centerX, h*0.34), width: w*0.035, height: w*0.015), 0, math.pi, false, p);

       // GLASSES (Significant Size Increase)
        p.color = palette.glasses;
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
    p.color = palette.leg;
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
    p.color = palette.skinLight;
    canvas.drawCircle(Offset(-w*0.04, h*0.22), w*0.045, p);
    canvas.restore();
    
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
