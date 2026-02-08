#!/bin/bash
# Island App Icon Generator for macOS/Linux
# ==========================================

echo "============================================"
echo "  🏝️  ISLAND APP ICON GENERATOR"
echo "============================================"
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    if ! command -v python &> /dev/null; then
        echo "❌ ERROR: Python tidak ditemukan!"
        echo ""
        echo "Silakan install Python terlebih dahulu:"
        echo "https://www.python.org/downloads/"
        exit 1
    else
        PYTHON_CMD="python"
    fi
else
    PYTHON_CMD="python3"
fi

echo "✅ Python ditemukan: $($PYTHON_CMD --version)"

# Check if Pillow is installed
echo "📦 Checking Pillow (PIL) installation..."
if ! $PYTHON_CMD -c "from PIL import Image" 2>/dev/null; then
    echo "⚠️  Pillow belum terinstall. Menginstall sekarang..."
    echo ""
    $PYTHON_CMD -m pip install Pillow
    if [ $? -ne 0 ]; then
        echo "❌ Gagal menginstall Pillow!"
        echo "Cobalah jalankan manual: $PYTHON_CMD -m pip install Pillow"
        exit 1
    fi
    echo "✅ Pillow berhasil diinstall"
else
    echo "✅ Pillow sudah terinstall"
fi

echo ""
echo "🚀 Menjalankan icon generator..."
echo ""

# Run the Python script
$PYTHON_CMD tools/generate_icons.py

if [ $? -ne 0 ]; then
    echo ""
    echo "❌ Terjadi kesalahan saat generate icons"
    exit 1
fi

echo ""
echo "============================================"
echo "✅ PROSES SELESAI!"
echo "============================================"
echo ""
echo "Langkah selanjutnya:"
echo "  1. flutter pub get"
echo "  2. flutter run"
echo ""
