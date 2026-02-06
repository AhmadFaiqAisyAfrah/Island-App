import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/data/feature_discovery_provider.dart';
import '../../../../core/widgets/glass_hint.dart';
import '../../shop/presentation/shop_screen.dart';
import '../../archipelago/presentation/archipelago_screen.dart';
import '../../../../services/auth_service.dart';
import '../../island/presentation/layers/island_base_layer.dart';

class IslandDrawer extends ConsumerWidget {
  const IslandDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    
    return Drawer(
      backgroundColor: AppColors.skyBottom, 
      elevation: 0, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text("Island", style: AppTextStyles.heading.copyWith(fontSize: 28)),
              const SizedBox(height: 8),
              Text("Your quiet place.", style: AppTextStyles.body.copyWith(color: AppColors.textSub, fontSize: 14)),
              const SizedBox(height: 64),
              
              // Menu Items
              _DrawerItem(
                label: "Island",
                isActive: true,
                onTap: () => Navigator.pop(context), 
              ),
              _DrawerItem(
                label: "Journal",
                isActive: false, 
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => const ArchipelagoScreen())
                  );
                },
              ),
              _DrawerItem(
                label: "Themes",
                isActive: false, // Could highlight if currentTheme != day, but let's keep simple
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  _showThemeSelector(context);
                },
              ),
              _DrawerItem(
                label: "Shop",
                isActive: false,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => const ShopScreen())
                  );
                },
              ),
              const Spacer(),
              const _AuthSection(),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const ThemeSelectorDialog(),
    );
  }
}

class ThemeSelectorDialog extends ConsumerStatefulWidget {
  const ThemeSelectorDialog({super.key});

  @override
  ConsumerState<ThemeSelectorDialog> createState() => _ThemeSelectorDialogState();
}

class _ThemeSelectorDialogState extends ConsumerState<ThemeSelectorDialog> {
  bool _showThemeHint = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final discovery = ref.read(featureDiscoveryProvider);
      if (!discovery.hasSeenThemeHint) {
        setState(() => _showThemeHint = true);
        ref.read(featureDiscoveryProvider.notifier).markThemeHintSeen();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(themeProvider);
    
    // Define Theme Data (UI Presentation)
    final seasonalOptions = [
      _ThemeItem(
        label: "Original",
        season: AppSeason.normal,
        color: const Color(0xFFB5D491),
        assetPath: "assets/themes/original_season.png",
      ),
      _ThemeItem(
        label: "Sakura",
        season: AppSeason.sakura,
        color: const Color(0xFFFFC0CB),
        assetPath: "assets/themes/sakura_season.png",
      ),
      _ThemeItem(
        label: "Autumn",
        season: AppSeason.autumn,
        color: const Color(0xFFD48C70),
        assetPath: "assets/themes/autumn_season.png",
      ),
      _ThemeItem(
        label: "Winter",
        season: AppSeason.winter,
        color: const Color(0xFFE3F2FD),
        assetPath: "assets/themes/winter_season.png",
      ),
    ];

    final envOptions = [
      _ThemeItem(
        label: "Default Sky",
        environment: AppEnvironment.defaultSky,
        color: const Color(0xFFC4E0E5),
        assetPath: "assets/themes/default_sky.png",
      ),
      _ThemeItem(
        label: "Mountain",
        environment: AppEnvironment.mountain,
        color: const Color(0xFF7B7D87),
        assetPath: "assets/themes/mountain.png",
      ),
      _ThemeItem(
        label: "Beach",
        environment: AppEnvironment.beach,
        color: const Color(0xFF89F7FE),
        assetPath: "assets/themes/beach.png",
      ),
      _ThemeItem(
        label: "Forest",
        environment: AppEnvironment.forest,
        color: const Color(0xFF237A57),
        assetPath: "assets/themes/forest.png",
      ),
    ];

    final houseOptions = [
      _ThemeItem(
        label: "Default House",
        house: AppHouse.defaultHouse,
        color: const Color(0xFFEADCCB),
        preview: const HousePreview(house: AppHouse.defaultHouse),
      ),
      _ThemeItem(
        label: "Adventure House",
        house: AppHouse.adventureHouse,
        color: const Color(0xFFD6E4D2),
        preview: const HousePreview(house: AppHouse.adventureHouse),
      ),
      _ThemeItem(
        label: "Stargazer Hut",
        house: AppHouse.stargazerHut,
        color: const Color(0xFFD6DEE6),
        preview: const HousePreview(house: AppHouse.stargazerHut),
      ),
      _ThemeItem(
        label: "Forest Cabin",
        house: AppHouse.forestCabin,
        color: const Color(0xFFD4C4B0),
        preview: const HousePreview(house: AppHouse.forestCabin),
      ),
    ];

    return AlertDialog(
      backgroundColor: AppColors.skyBottom,
      contentPadding: const EdgeInsets.all(24),
      title: Text("Select Theme", style: AppTextStyles.heading.copyWith(fontSize: 24)),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_showThemeHint) ...[
                GlassHint(
                  text: 'Choose a place that feels right.',
                  onDismiss: () => setState(() => _showThemeHint = false),
                ),
                const SizedBox(height: 16),
              ],
              // SEASONAL
              Text("Seasonal", style: AppTextStyles.body.copyWith(fontSize: 14, color: AppColors.textSub, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: seasonalOptions.map((item) => _ThemeCard(
                  item: item,
                  isSelected: state.season == item.season,
                  onTap: () => ref.read(themeProvider.notifier).setSeason(item.season!),
                )).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // ENVIRONMENT
              Text("Environment", style: AppTextStyles.body.copyWith(fontSize: 14, color: AppColors.textSub, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: envOptions.map((item) => _ThemeCard(
                  item: item,
                  isSelected: state.environment == item.environment,
                  onTap: () => ref.read(themeProvider.notifier).setEnvironment(item.environment!),
                )).toList(),
              ),

              const SizedBox(height: 24),

              // HOUSE
              Text("House", style: AppTextStyles.body.copyWith(fontSize: 14, color: AppColors.textSub, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: houseOptions.map((item) => _ThemeCard(
                  item: item,
                  isSelected: state.house == item.house,
                  onTap: () => ref.read(themeProvider.notifier).setHouse(item.house!),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Done", style: AppTextStyles.subHeading.copyWith(fontSize: 16)),
        )
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }
}

// Data Helper
class _ThemeItem {
  final String label;
  final AppSeason? season; 
  final AppEnvironment? environment;
  final AppHouse? house;
  final Color color; // Fallback
  final String? assetPath;
  final Widget? preview;

  _ThemeItem({
    required this.label,
    required this.color,
    this.assetPath,
    this.preview,
    this.season,
    this.environment,
    this.house,
  });
}

class _ThemeCard extends StatelessWidget {
  final _ThemeItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Slightly larger for better visibility of images
    const double cardWidth = 110; 
    const double cardHeight = 120;

    final Widget previewChild;
    if (item.preview != null) {
      previewChild = item.preview!;
    } else if (item.assetPath != null && item.assetPath!.isNotEmpty) {
      previewChild = Image.asset(
        item.assetPath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(color: item.color); // Graceful fallback
        },
      );
    } else {
      previewChild = Container(color: item.color);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: isSelected 
              ? Border.all(color: AppColors.islandGrass, width: 3)
              : Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            boxShadow: isSelected 
              ? [BoxShadow(color: AppColors.islandGrass.withOpacity(0.3), blurRadius: 8, offset: const Offset(0,4))] 
              : [],
          ),
          child: ClipRRect(
             borderRadius: BorderRadius.circular(13), 
             child: Column(
               children: [
                 // IMAGE AREA
                 Expanded(
                   flex: 3,
                   child: Stack(
                     fit: StackFit.expand,
                     children: [
                        Container(
                          color: item.color.withOpacity(0.3), // Fallback base
                          child: previewChild,
                        ),
                       if (isSelected) 
                         Container(
                           color: Colors.black.withOpacity(0.1),
                           child: Center(child: Icon(Icons.check_circle_rounded, color: Colors.white.withOpacity(0.9), size: 32)),
                         ),
                     ],
                   ),
                 ),
                 // TEXT AREA
                 Expanded(
                   flex: 2,
                   child: Container(
                     width: double.infinity,
                     alignment: Alignment.center,
                     color: Colors.white.withOpacity(0.9),
                     padding: const EdgeInsets.symmetric(horizontal: 4),
                     child: Text(
                       item.label,
                       textAlign: TextAlign.center,
                       style: AppTextStyles.body.copyWith(
                         fontSize: 12, 
                         fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                         height: 1.1
                       ),
                       maxLines: 2,
                     ),
                   ),
                 ),
               ],
             ),
          ),
        ),
      ),
    );
  }
}

class HousePreview extends StatelessWidget {
  final AppHouse house;

  const HousePreview({super.key, required this.house});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        final houseSize = available * 0.9;
        return Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: houseSize,
            height: houseSize * 0.85,
            child: house == AppHouse.adventureHouse
                ? AdventureHouseWidget(
                    size: houseSize,
                    lightIntensity: 0.0,
                    isNight: false,
                    isSakura: false,
                    isAutumn: false,
                    isWinter: false,
                  )
                : house == AppHouse.stargazerHut
                    ? StargazerHutWidget(
                        size: houseSize,
                        lightIntensity: 0.0,
                        isNight: false,
                        isSakura: false,
                        isAutumn: false,
                        isWinter: false,
                      )
                : house == AppHouse.forestCabin
                    ? ForestCabinWidget(
                        size: houseSize,
                        lightIntensity: 0.0,
                        isNight: false,
                        isFocusing: false,
                        isSakura: false,
                        isAutumn: false,
                        isWinter: false,
                      )
                    : CalmHouseWidget(
                        size: houseSize,
                        lightIntensity: 0.0,
                        isSakura: false,
                        isAutumn: false,
                        isWinter: false,
                        isNight: false,
                      ),
          ),
        );
      },
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: isActive 
            ? BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12)
              )
            : null,
          child: Text(
            label,
            style: AppTextStyles.subHeading.copyWith(
              color: isActive ? AppColors.textMain : AppColors.textMain.withOpacity(0.7),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.skyBottom,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.textMain),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: AppTextStyles.heading),
            const SizedBox(height: 16),
            Text(
              "Coming soon.",
              style: AppTextStyles.body.copyWith(color: AppColors.textSub),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthSection extends ConsumerWidget {
  const _AuthSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Signed in as",
                style: AppTextStyles.body.copyWith(color: AppColors.textSub, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                user.email ?? "User",
                style: AppTextStyles.subHeading.copyWith(fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                   await ref.read(authServiceProvider).signOut();
                },
                child: Text(
                  "Sign out", 
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textMain, 
                    decoration: TextDecoration.underline,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          );
        }
        return const _GoogleSignInButton();
      },
      loading: () => const SizedBox(height: 20),
      error: (_, __) => const _GoogleSignInButton(),
    );
  }
}

class _GoogleSignInButton extends ConsumerWidget {
  const _GoogleSignInButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Save your progress",
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSub,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        Material(
          color: Colors.white.withOpacity(0.9),
          elevation: 0, 
          borderRadius: BorderRadius.circular(30),
          child: InkWell(
            onTap: () async {
              await ref.read(authServiceProvider).signInWithGoogle();
            },
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.textSub.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Minimal G logo representation
                  Container(
                    width: 16, height: 16,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue, 
                    ),
                    alignment: Alignment.center,
                    child: const Text("G", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Continue with Google",
                    style: AppTextStyles.subHeading.copyWith(
                      color: AppColors.textMain,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
