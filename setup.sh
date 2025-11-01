#!/bin/bash

# نظام إدارة المبيعات - Sales Management System
# ملف الإعداد للأنظمة Unix/Linux/Mac

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

clear

echo -e "${CYAN}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                                                                ║"
echo "║          نظام إدارة المبيعات - Sales Management System        ║"
echo "║                      برنامج الإعداد والتثبيت                  ║"
echo "║                                                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

echo -e "${BLUE}[1/5] فحص متطلبات النظام...${NC}"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ خطأ: Flutter غير مثبت!${NC}"
    echo ""
    echo "الرجاء تثبيت Flutter من:"
    echo "https://docs.flutter.dev/get-started/install"
    echo ""
    exit 1
else
    echo -e "${GREEN}✅ Flutter مثبت بنجاح${NC}"
fi

echo ""
echo -e "${BLUE}[2/5] عرض معلومات Flutter...${NC}"
echo "════════════════════════════════════════════════════════════════"
echo ""
flutter --version
echo ""

echo ""
echo -e "${BLUE}[3/5] فحص حالة النظام...${NC}"
echo "════════════════════════════════════════════════════════════════"
echo ""
flutter doctor
echo ""

echo ""
echo -e "${BLUE}[4/5] تنظيف المشروع...${NC}"
echo "════════════════════════════════════════════════════════════════"
echo ""
flutter clean
if [ $? -ne 0 ]; then
    echo -e "${YELLOW}⚠️ تحذير: حدث خطأ أثناء التنظيف${NC}"
    echo ""
fi

echo ""
echo -e "${BLUE}[5/5] تحميل وتثبيت المكتبات المطلوبة...${NC}"
echo "════════════════════════════════════════════════════════════════"
echo ""
flutter pub get
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ خطأ: فشل تحميل المكتبات!${NC}"
    echo ""
    echo "جرب الأوامر التالية يدوياً:"
    echo "  1. flutter clean"
    echo "  2. flutter pub get"
    echo ""
    exit 1
fi

echo ""
echo ""
echo -e "${GREEN}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                                                                ║"
echo "║                ✅ تم الإعداد بنجاح!                          ║"
echo "║                                                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo ""
echo "══════════════════════════════════════════════════════════════"
echo "  الخطوات التالية:"
echo "══════════════════════════════════════════════════════════════"
echo ""
echo "  1️⃣  لتشغيل التطبيق:"
echo "     👉 ./run.sh"
echo "     👉 أو: flutter run"
echo ""
echo "  2️⃣  لبناء التطبيق للإنتاج:"
echo "     👉 ./build.sh"
echo "     👉 أو: flutter build linux --release"
echo ""
echo "  3️⃣  لقراءة دليل الاستخدام:"
echo "     👉 افتح: QUICK_START.md"
echo ""
echo "══════════════════════════════════════════════════════════════"
echo ""

read -p "هل تريد تشغيل التطبيق الآن؟ (y/n): " answer
if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
    echo ""
    echo "جاري تشغيل التطبيق..."
    echo ""
    flutter run
else
    echo ""
    echo "شكراً لك! يمكنك تشغيل التطبيق لاحقاً"
    echo ""
fi
