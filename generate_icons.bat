@echo off
chcp 65001 >nul
echo ============================================
echo   🏝️  ISLAND APP ICON GENERATOR
echo ============================================
echo.

:: Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ ERROR: Python tidak ditemukan!
    echo.
    echo Silakan install Python terlebih dahulu:
    echo https://www.python.org/downloads/
    echo.
    pause
    exit /b 1
)

echo ✅ Python ditemukan

:: Check if Pillow is installed
echo 📦 Checking Pillow (PIL) installation...
python -c "from PIL import Image" >nul 2>&1
if errorlevel 1 (
    echo ⚠️  Pillow belum terinstall. Menginstall sekarang...
    echo.
    pip install Pillow
    if errorlevel 1 (
        echo ❌ Gagal menginstall Pillow!
        echo Cobalah jalankan manual: pip install Pillow
        pause
        exit /b 1
    )
    echo ✅ Pillow berhasil diinstall
) else (
    echo ✅ Pillow sudah terinstall
)

echo.
echo 🚀 Menjalankan icon generator...
echo.

:: Run the Python script
python tools\generate_icons.py

if errorlevel 1 (
    echo.
    echo ❌ Terjadi kesalahan saat generate icons
    pause
    exit /b 1
)

echo.
echo ============================================
echo ✅ PROSES SELESAI!
echo ============================================
echo.
echo Langkah selanjutnya:
echo   1. flutter pub get
echo   2. flutter run
echo.
pause
