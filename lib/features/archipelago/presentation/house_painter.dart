import 'package:flutter/material.dart';

class HousePainter extends CustomPainter {
  final int level; // 0: Empty, 1: House, 2: House+Tree, 3: House+Garden
  final bool isDay;

  HousePainter({required this.level, required this.isDay});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final centerX = w / 2;
    final centerY = h / 2;

    // Palette
    final grassColor = isDay ? const Color(0xFFD3EBC9) : const Color(0xFF2C3E30); // Soft Sage / Dark Forest
    final earthColor = isDay ? const Color(0xFFBCAAA4) : const Color(0xFF4A403A); // Light Earth / Dark Earth
    final houseColor = isDay ? const Color(0xFFF5F5F5) : const Color(0xFF8D8D8D); // White / Grey
    final roofColor = isDay ? const Color(0xFFFFCCBC) : const Color(0xFF5D4037);  // Soft Peach / Dark Wood
    final treeColor = isDay ? const Color(0xFF81C784) : const Color(0xFF1B5E20);  // Green / Dark Green

    // 1. BASE TILE (Isometric Rhombus)
    // Flattened rhombus
    final path = Path();
    path.moveTo(centerX, h * 0.2); // Top
    path.lineTo(w * 0.9, h * 0.5); // Right
    path.lineTo(centerX, h * 0.8); // Bottom
    path.lineTo(w * 0.1, h * 0.5); // Left
    path.close();

    final paintBase = Paint()..color = grassColor;
    canvas.drawPath(path, paintBase);
    
    // Base Thickness (Soil)
    final pathSoil = Path();
    pathSoil.moveTo(w * 0.9, h * 0.5);
    pathSoil.lineTo( centerX, h * 0.8);
    pathSoil.lineTo(w * 0.1, h * 0.5);
    pathSoil.lineTo(w * 0.1, h * 0.55); // Thickness
    pathSoil.lineTo(centerX, h * 0.85);
    pathSoil.lineTo(w * 0.9, h * 0.55);
    pathSoil.close();
    
    canvas.drawPath(pathSoil, Paint()..color = earthColor);

    // LEVEL 0: JUST TILE (Return early)
    if (level == 0) return;

    // 2. HOUSE (Level 1+)
    // Simple Cube + Roof
    // Center offset
    final houseW = w * 0.35;
    final houseH = h * 0.25;
    final houseX = centerX - houseW/2;
    final houseY = centerY - houseH/1.5;

    // Walls
    canvas.drawRect(
      Rect.fromLTWH(houseX, houseY, houseW, houseH), 
      Paint()..color = houseColor
    );
    
    // Roof (Triangle)
    final pathRoof = Path();
    pathRoof.moveTo(houseX, houseY);
    pathRoof.lineTo(houseX + houseW, houseY);
    pathRoof.lineTo(centerX, houseY - houseH * 0.6);
    pathRoof.close();
    canvas.drawPath(pathRoof, Paint()..color = roofColor);
    
    // Windows/Door (Detail - minimal)
    canvas.drawRect(
      Rect.fromLTWH(centerX - houseW*0.1, houseY + houseH*0.5, houseW*0.2, houseH*0.5),
      Paint()..color = isDay ? Colors.black12 : Colors.black45
    );

    // 3. TREE (Level 2+)
    if (level >= 2) {
      final treeX = centerX + houseW * 0.8;
      final treeY = centerY;
      
      // Trunk
      canvas.drawRect(
         Rect.fromLTWH(treeX - 2, treeY, 4, 10),
         Paint()..color = earthColor
      );
      // Leaves (Circle)
      canvas.drawCircle(
        Offset(treeX, treeY - 5), 
        8, 
        Paint()..color = treeColor
      );
    }

    // 4. GARDEN (Level 3+)
    if (level >= 3) {
      // Small bushes/dots on left
      final gardenX = centerX - houseW * 0.8;
      final gardenY = centerY + 5;
      
      canvas.drawCircle(Offset(gardenX, gardenY), 4, Paint()..color = treeColor.withOpacity(0.8));
      canvas.drawCircle(Offset(gardenX + 8, gardenY - 3), 3, Paint()..color = treeColor.withOpacity(0.9));
      canvas.drawCircle(Offset(gardenX - 6, gardenY + 2), 3, Paint()..color = treeColor.withOpacity(0.7));
    }
  }

  @override
  bool shouldRepaint(covariant HousePainter oldDelegate) {
    return oldDelegate.level != level || oldDelegate.isDay != isDay;
  }
}
