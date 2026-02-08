# 🏝️ Island App Icon Generator

Script otomatis untuk mengoptimalkan posisi logo di homescreen HP dan generate semua icon untuk Android, iOS, Web, dan macOS.

## 🎯 Fitur

- ✅ **Menggeser logo ke bawah 15%** - Untuk penempatan optimal di homescreen
- ✅ **Generate otomatis** - Semua ukuran icon untuk semua platform
- ✅ **Backup otomatis** - File original disimpan dengan aman
- ✅ **Adaptive icons** - Support adaptive icons untuk Android
- ✅ **Maskable icons** - Support maskable icons untuk PWA Web

## 📋 Prasyarat

Sebelum menjalankan script, pastikan sudah menginstall:

### 1. Python (3.7+)
Download dan install dari: https://www.python.org/downloads/

**Pastikan centang "Add Python to PATH" saat installasi!**

### 2. Flutter SDK
Pastikan Flutter sudah terinstall dan berjalan dengan baik.

## 🚀 Cara Penggunaan

### Windows

**Cara 1: Double-click (Paling Mudah)**
```
Klik 2x file: generate_icons.bat
```

**Cara 2: Via Command Prompt**
```cmd
cd D:\App\Island_clean
generate_icons.bat
```

**Cara 3: Via PowerShell**
```powershell
cd D:\App\Island_clean
.\generate_icons.bat
```

### macOS / Linux

**Cara 1: Double-click**
```
Klik 2x file: generate_icons.sh
```

**Cara 2: Via Terminal**
```bash
cd /path/to/Island_clean
chmod +x generate_icons.sh
./generate_icons.sh
```

### Manual (Jika script tidak berjalan)

```bash
# Install Pillow
pip install Pillow

# Jalankan Python script
python tools/generate_icons.py
```

## 📁 Struktur File

```
Island_clean/
├── assets/
│   └── icon/
│       ├── island_logo.png              # File logo yang akan diproses
│       └── island_logo_original.png     # Backup file original (auto-create)
├── tools/
│   └── generate_icons.py                # Script utama Python
├── generate_icons.bat                   # Script untuk Windows
├── generate_icons.sh                    # Script untuk macOS/Linux
└── README_ICON_GENERATOR.md             # File ini
```

## 🔧 Customization

Jika posisi logo masih kurang pas, Anda bisa mengedit file `tools/generate_icons.py`:

```python
# Ganti nilai ini (default: 15)
shift_logo_down(original_logo, shifted_logo, shift_percent=15)

# Coba nilai lain:
# 20 = Geser 20% ke bawah (lebih rendah)
# 10 = Geser 10% ke bawah (lebih tinggi)
# 25 = Geser 25% ke bawah (paling rendah)
```

## ✅ Setelah Generate

Setelah script berhasil berjalan, langkah selanjutnya:

```bash
# 1. Install dependencies (jika belum)
flutter pub get

# 2. Jalankan aplikasi
flutter run

# Atau build untuk release:
flutter build apk          # Android
flutter build ios          # iOS
flutter build web          # Web
```

## 🎨 Icon yang Digenerate

Script akan otomatis membuat:

### Android
- `mipmap-mdpi` (48x48)
- `mipmap-hdpi` (72x72)
- `mipmap-xhdpi` (96x96)
- `mipmap-xxhdpi` (144x144)
- `mipmap-xxxhdpi` (192x192)
- Adaptive icons dengan safe zone 20%

### iOS
- Semua ukuran AppIcon (20pt-1024pt)
- Semua scale (@1x, @2x, @3x)

### Web
- `favicon.png` (32x32)
- `Icon-192.png` (192x192)
- `Icon-512.png` (512x512)
- `Icon-maskable-192.png` (192x192 with padding)
- `Icon-maskable-512.png` (512x512 with padding)

### macOS
- `app_icon_16.png` - `app_icon_1024.png`

## ❓ Troubleshooting

### Error: "Python tidak ditemukan!"
- Pastikan Python sudah terinstall: https://www.python.org/downloads/
- Pastikan Python ditambahkan ke PATH saat installasi
- Restart terminal/command prompt setelah install Python

### Error: "PIL/Pillow belum terinstall!"
- Script akan otomatis install Pillow
- Jika gagal, jalankan manual: `pip install Pillow`

### Error: "File tidak ditemukan: assets/icon/island_logo.png"
- Pastikan file `island_logo.png` ada di folder `assets/icon/`
- Periksa nama file (case-sensitive)

### Logo masih terlalu tinggi/rendah
- Edit file `tools/generate_icons.py`
- Ubah parameter `shift_percent` (default: 15)
- Jalankan ulang script

## 💡 Tips

1. **Selalu backup** - Script akan otomatis membuat backup, tapi tetap disarankan backup manual
2. **Test di device** - Preview di emulator mungkin berbeda dengan device asli
3. **Adaptive icons** - Android adaptive icons membutuhkan safe zone, script sudah handle ini
4. **Clear cache** - Jika icon tidak berubah, coba clear cache atau uninstall app lalu install ulang

## 📝 Changelog

### v1.0.0
- Initial release
- Support Windows, macOS, Linux
- Auto-generate all platform icons
- Auto-shift logo 15% down
- Backup original file

## 🆘 Butuh Bantuan?

Jika mengalami masalah:
1. Cek bagian Troubleshooting di atas
2. Pastikan semua prasyarat terpenuhi
3. Coba jalankan script Python secara manual
4. Hubungi tim developer

---

**Happy Coding! 🏝️**
