#!/usr/bin/env python3
"""
Island App Icon Generator
==========================
Script ini akan:
1. Menggeser logo ke bawah untuk penempatan yang lebih baik di homescreen
2. Men-generate semua ukuran icon untuk Android, iOS, dan Web
3. Menyesuaikan padding untuk optimal viewing experience

Cara penggunaan:
  python3 generate_icons.py

Atau jika Anda menggunakan Windows:
  python generate_icons.py
"""

import os
import sys
import shutil
from PIL import Image

def shift_logo_down(input_path, output_path, shift_percent=15):
    """
    Menggeser konten logo ke bawah dengan tetap mempertahankan ukuran canvas.
    
    Args:
        input_path: Path ke gambar asli
        output_path: Path output gambar yang sudah digeser
        shift_percent: Persentase pergeseran ke bawah (default 15%)
    """
    # Buka gambar
    img = Image.open(input_path).convert('RGBA')
    width, height = img.size
    
    # Buat canvas baru dengan background transparan
    new_img = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    
    # Hitung jumlah pixel untuk digeser (15% dari tinggi)
    shift_pixels = int(height * (shift_percent / 100))
    
    # Tempel gambar asli yang sudah digeser ke bawah
    new_img.paste(img, (0, shift_pixels), img)
    
    # Simpan hasil
    new_img.save(output_path, 'PNG')
    print(f"✓ Logo digeser ke bawah {shift_percent}% ({shift_pixels}px)")
    print(f"✓ Disimpan ke: {output_path}")
    
    return output_path

def resize_for_platform(input_path, output_path, size, padding_percent=0):
    """
    Resize gambar untuk platform tertentu dengan padding opsional.
    
    Args:
        input_path: Path ke gambar sumber
        output_path: Path output
        size: Ukuran output (width=height)
        padding_percent: Padding dalam persen (untuk adaptive icons)
    """
    img = Image.open(input_path).convert('RGBA')
    
    if padding_percent > 0:
        # Buat canvas dengan padding
        canvas_size = size
        padding = int(size * (padding_percent / 100))
        icon_size = size - (2 * padding)
        
        canvas = Image.new('RGBA', (canvas_size, canvas_size), (0, 0, 0, 0))
        resized = img.resize((icon_size, icon_size), Image.Resampling.LANCZOS)
        canvas.paste(resized, (padding, padding), resized)
        canvas.save(output_path, 'PNG')
    else:
        # Resize langsung tanpa padding
        resized = img.resize((size, size), Image.Resampling.LANCZOS)
        resized.save(output_path, 'PNG')
    
    print(f"  ✓ Created: {output_path} ({size}x{size})")

def generate_android_icons(source_path):
    """Generate semua icon untuk Android"""
    print("\n📱 Generating Android Icons...")
    
    android_base = "android/app/src/main/res"
    sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192
    }
    
    for folder, size in sizes.items():
        output_dir = os.path.join(android_base, folder)
        os.makedirs(output_dir, exist_ok=True)
        output_path = os.path.join(output_dir, "ic_launcher.png")
        resize_for_platform(source_path, output_path, size)
    
    print("✓ Android icons generated!")

def generate_android_adaptive(source_path):
    """Generate adaptive icons untuk Android"""
    print("\n🎨 Generating Android Adaptive Icons...")
    
    drawable_base = "android/app/src/main/res"
    sizes = {
        "drawable-mdpi": 108,
        "drawable-hdpi": 162,
        "drawable-xhdpi": 216,
        "drawable-xxhdpi": 324,
        "drawable-xxxhdpi": 432
    }
    
    for folder, size in sizes.items():
        output_dir = os.path.join(drawable_base, folder)
        os.makedirs(output_dir, exist_ok=True)
        output_path = os.path.join(output_dir, "ic_launcher_foreground.png")
        # Adaptive icons butuh padding 20% untuk safe zone
        resize_for_platform(source_path, output_path, size, padding_percent=20)
    
    print("✓ Android adaptive icons generated!")

def generate_ios_icons(source_path):
    """Generate semua icon untuk iOS"""
    print("\n🍎 Generating iOS Icons...")
    
    ios_base = "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    os.makedirs(ios_base, exist_ok=True)
    
    # iOS icon sizes
    ios_sizes = [
        (20, [1, 2, 3]),
        (29, [1, 2, 3]),
        (40, [1, 2, 3]),
        (60, [2, 3]),
        (76, [1, 2]),
        (83.5, [2]),
        (1024, [1])
    ]
    
    for base_size, scales in ios_sizes:
        for scale in scales:
            pixel_size = int(base_size * scale)
            filename = f"Icon-App-{base_size}x{base_size}@{scale}x.png"
            output_path = os.path.join(ios_base, filename)
            resize_for_platform(source_path, output_path, pixel_size)
    
    print("✓ iOS icons generated!")

def generate_web_icons(source_path):
    """Generate icon untuk Web/PWA"""
    print("\n🌐 Generating Web Icons...")
    
    # Favicon
    resize_for_platform(source_path, "web/favicon.png", 32)
    
    # Web icons
    icons_dir = "web/icons"
    os.makedirs(icons_dir, exist_ok=True)
    
    # Standard icons
    resize_for_platform(source_path, f"{icons_dir}/Icon-192.png", 192)
    resize_for_platform(source_path, f"{icons_dir}/Icon-512.png", 512)
    
    # Maskable icons dengan padding
    resize_for_platform(source_path, f"{icons_dir}/Icon-maskable-192.png", 192, padding_percent=10)
    resize_for_platform(source_path, f"{icons_dir}/Icon-maskable-512.png", 512, padding_percent=10)
    
    print("✓ Web icons generated!")

def generate_macos_icons(source_path):
    """Generate icon untuk macOS"""
    print("\n💻 Generating macOS Icons...")
    
    macos_base = "macos/Runner/Assets.xcassets/AppIcon.appiconset"
    os.makedirs(macos_base, exist_ok=True)
    
    macos_sizes = [16, 32, 64, 128, 256, 512, 1024]
    
    for size in macos_sizes:
        filename = f"app_icon_{size}.png"
        output_path = os.path.join(macos_base, filename)
        resize_for_platform(source_path, output_path, size)
    
    print("✓ macOS icons generated!")

def backup_original():
    """Backup file original"""
    original = "assets/icon/island_logo.png"
    backup = "assets/icon/island_logo_original.png"
    
    if not os.path.exists(backup):
        shutil.copy2(original, backup)
        print(f"✓ Backup dibuat: {backup}")

def main():
    print("=" * 60)
    print("🏝️  ISLAND APP ICON GENERATOR")
    print("=" * 60)
    print("\nScript ini akan mengoptimalkan penempatan logo Anda")
    print("untuk tampilan terbaik di homescreen HP.\n")
    
    # Check apakah PIL/Pillow terinstall
    try:
        from PIL import Image
    except ImportError:
        print("❌ ERROR: PIL/Pillow belum terinstall!")
        print("\nSilakan install terlebih dahulu dengan perintah:")
        print("  pip install Pillow")
        print("\nAtau jika menggunakan Python 3:")
        print("  pip3 install Pillow")
        sys.exit(1)
    
    # Path file
    original_logo = "assets/icon/island_logo.png"
    shifted_logo = "assets/icon/island_logo_shifted.png"
    final_logo = "assets/icon/island_logo.png"
    
    # Check apakah file ada
    if not os.path.exists(original_logo):
        print(f"❌ ERROR: File tidak ditemukan: {original_logo}")
        print("Pastikan file island_logo.png ada di folder assets/icon/")
        sys.exit(1)
    
    # Backup original (hanya sekali)
    backup_original()
    
    # Step 1: Geser logo ke bawah 15%
    print("\n📐 Step 1: Mengoptimalkan posisi logo...")
    shift_logo_down(original_logo, shifted_logo, shift_percent=15)
    
    # Step 2: Replace original dengan shifted
    print("\n📝 Step 2: Mengupdate file logo...")
    shutil.move(shifted_logo, final_logo)
    print("✓ File logo diupdate")
    
    # Step 3: Generate semua platform icons
    print("\n🚀 Step 3: Generating icons untuk semua platform...")
    generate_android_icons(final_logo)
    generate_android_adaptive(final_logo)
    generate_ios_icons(final_logo)
    generate_web_icons(final_logo)
    generate_macos_icons(final_logo)
    
    print("\n" + "=" * 60)
    print("✅ SEMUA ICON BERHASIL DIGENERATE!")
    print("=" * 60)
    print("\n🎯 Logo telah digeser ke bawah 15% untuk:")
    print("   • Penempatan lebih seimbang di homescreen")
    print("   • Visual yang lebih menyenangkan")
    print("   • Experience pengguna yang lebih baik")
    print("\n📝 Langkah selanjutnya:")
    print("   1. flutter pub get")
    print("   2. flutter run")
    print("\n💡 Tips: Jika posisi masih kurang pas,")
    print("   Anda bisa edit shift_percent di script ini")
    print("   (nilai default: 15, coba 20 atau 25)")
    print("=" * 60)

if __name__ == "__main__":
    main()
