# خطة تحسين تطبيق حاسبة مكافأة نهاية الخدمة

## Context
التطبيق يعمل ويحسب المكافأة بشكل صحيح، لكنه يحتاج إلى تحسينات جوهرية في جودة الكود، تجربة المستخدم، الأمان، واختبارات الكود. الهدف: رفع مستوى التطبيق من MVP إلى منتج احترافي قابل للصيانة والتوسع.

---

## الأولويات (مُرتبة حسب الأهمية)

---

## 🔴 P0 — حرجي (أمان)

### 1. حذف `security_info.txt`
- **المشكلة:** يحتوي على كلمات مرور الـ keystore بنص صريح (`Jamali2026!`)
- **الحل:** حذف الملف فوراً، إضافته إلى `.gitignore`
- **ملف:** `security_info.txt` + `.gitignore`

---

## 🟠 P1 — عالي الأهمية (جودة كود + منطق)

### 2. استخراج منطق الحساب إلى كلاس منفصل
- **المشكلة:** `_performCalculation()` مدفون داخل الـ Widget مما يجعله غير قابل للاختبار
- **الحل:** إنشاء `lib/calculator_service.dart`:
  ```dart
  class EndOfServiceCalculator {
    static CalculationResult calculate({
      required double monthlySalary,
      required int years,
      required int months,
      required String reason, // 'termination' | 'resignation'
    })
  }
  class CalculationResult {
    final double baseReward;
    final double finalReward;
    final double totalYears;
  }
  ```
- **الثوابت المستخرجة:**
  ```dart
  const _kFirstPhaseYears = 5.0;
  const _kResignationMin = 2.0;
  const _kResignationMid = 5.0;
  const _kResignationFull = 10.0;
  ```
- **ملفات:** `lib/calculator_service.dart` (جديد)، `lib/main.dart` (تعديل)

### 3. إضافة اختبارات الوحدة للحساب
- **ملف:** `test/calculator_service_test.dart` (جديد)
- **حالات الاختبار:**
  - فصل من صاحب العمل: 3 سنوات → `salary × 3 × 0.5`
  - فصل: 7 سنوات → `(salary × 5 × 0.5) + (salary × 2)`
  - استقالة < 2 سنة → `0`
  - استقالة 2-5 سنوات → `base × 1/3`
  - استقالة 5-10 سنوات → `base × 2/3`
  - استقالة ≥ 10 سنوات → `base × 1`
  - حافة 5 سنوات بالضبط
  - تحويل الأشهر: 6 أشهر = 0.5 سنة

### 4. تحسين التحقق من المدخلات
- **المشكلة:** لا يوجد حد أعلى للراتب، لا `try-catch` على `double.parse()`
- **الحل في `_performCalculation()`:**
  - تغليف بـ `try-catch FormatException`
  - حد أعلى للراتب: `1,000,000 ر.س`
  - رسالة خطأ واضحة بـ SnackBar

---

## 🟡 P2 — متوسط (تجربة المستخدم)

### 5. تخفيف الإعلانات البينية (Interstitial)
- **المشكلة:** إعلان بعد كل حساب → يقتل الاحتفاظ بالمستخدم
- **الحل:** إظهار الإعلان مرة واحدة كل 3 حسابات
  ```dart
  int _calculationCount = 0;
  bool get _shouldShowAd => ++_calculationCount % 3 == 0;
  ```
- **ملف:** `lib/main.dart`

### 6. إضافة زر نسخ النتيجة
- **المشكلة:** المستخدم لا يستطيع نسخ المبلغ
- **الحل:** إضافة `IconButton(Icons.copy)` في `_ResultCard`
  ```dart
  Clipboard.setData(ClipboardData(text: fmt.format(_result)));
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم نسخ المبلغ')));
  ```
- **ملف:** `lib/main.dart` في `_ResultCard` (سطر ~580)

### 7. إضافة زر مشاركة النتيجة
- **المشكلة:** لا يمكن إرسال النتيجة لـ HR أو للواتساب
- **الحل:** استخدام `share_plus` package
  ```dart
  Share.share('مكافأة نهاية الخدمة: ${fmt.format(_result)} ر.س\n(محتسبة وفق نظام العمل السعودي)');
  ```
- **ملف:** `pubspec.yaml` (إضافة `share_plus: ^10.0.0`)، `lib/main.dart`

### 8. إضافة زر "إعادة تعيين"
- **المشكلة:** لا توجد طريقة لمسح الحقول ببساطة
- **الحل:** `TextButton` في أعلى الفورم:
  ```dart
  void _resetForm() {
    _salaryCtr.clear(); _yearsCtr.clear(); _monthsCtr.clear();
    setState(() { _result = null; _reason = 'termination'; });
  }
  ```
- **ملف:** `lib/main.dart`

### 9. تحسين تجربة إدخال الأرقام
- **المشكلة:** لا تغذية راجعة فورية عند الخطأ
- **الحل:**
  - `autovalidateMode: AutovalidateMode.onUserInteraction` بدلاً من onSubmitted
  - حد أدنى لحجم خط رسائل الخطأ: `14px` (من `11px`)

### 10. دعم تقليل الحركة (Reduce Motion)
- **المشكلة:** الأنيميشن قد يزعج بعض المستخدمين
- **الحل:**
  ```dart
  final duration = MediaQuery.of(context).disableAnimations 
    ? Duration.zero 
    : const Duration(milliseconds: 500);
  ```
- **ملف:** `lib/main.dart` في `initState()`

---

## 🟢 P3 — تحسين (جودة الكود)

### 11. استخراج ثوابت الألوان والأنماط
- **المشكلة:** `BorderRadius.circular(12)` + `BoxShadow(...)` متكرران 6+ مرات
- **الحل:** إضافة section `// --- Design Tokens ---` في أعلى الملف:
  ```dart
  const _kCardRadius = 16.0;
  const _kFieldRadius = 12.0;
  const _kCardShadow = [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))];
  InputBorder _fieldBorder(Color color, {double width = 1}) =>
    OutlineInputBorder(borderRadius: BorderRadius.circular(_kFieldRadius), borderSide: BorderSide(color: color, width: width));
  ```
- **ملف:** `lib/main.dart`

### 12. إضافة Semantic Labels للـ Accessibility
- **المشكلة:** قارئات الشاشة لا تعرف الحقول
- **الحل:** تغليف `_AmountField` و `_DurationField` و `_ResultCard` بـ `Semantics`:
  ```dart
  Semantics(label: 'حقل الراتب الأساسي بالريال السعودي', child: _AmountField(...))
  Semantics(liveRegion: true, label: 'نتيجة الحساب', child: _ResultCard(...))
  ```
- **ملف:** `lib/main.dart`

### 13. إصلاح التباين اللوني
- **المشكلة:** `#94A3B8` على خلفية `#0F172A` = تباين 3.5:1 (أقل من WCAG AA)
- **الحل:** تغيير لون العنوان الفرعي من `0xFF94A3B8` إلى `0xFFCBD5E1`
- **ملف:** `lib/main.dart` سطر ~283

### 14. حذف استيراد غير مستخدم
- **المشكلة:** `cupertino_icons` في `pubspec.yaml` غير مستخدم
- **الحل:** حذف السطر من `pubspec.yaml`

### 15. تسمية الثوابت بدلاً من الأرقام السحرية
- **الأرقام المتبقية للاستخراج في منطق الحساب:** `5`, `2`, `10`, `1/3`, `2/3`
- **نُقلت بالفعل** إلى `calculator_service.dart` في P1-2

---

## 📋 ملخص الملفات المتأثرة

| الملف | التغييرات |
|-------|-----------|
| `security_info.txt` | **حذف** |
| `.gitignore` | إضافة `security_info.txt` |
| `pubspec.yaml` | حذف `cupertino_icons`، إضافة `share_plus` |
| `lib/calculator_service.dart` | **جديد** — منطق الحساب |
| `lib/main.dart` | استخدام الـ service، زر نسخ، زر مشاركة، زر reset، تحسين الأنيميشن، Semantics، إصلاح لون |
| `test/calculator_service_test.dart` | **جديد** — 8+ اختبارات وحدة |

---

## التحقق (Verification)

```bash
# 1. تشغيل الاختبارات
flutter test

# 2. تشغيل على Chrome (بدون إعلانات)
flutter run -d chrome

# 3. فحص حالات الحساب يدوياً:
#    - راتب 3000، 3 سنوات، فصل → يجب أن يظهر 4,500.00
#    - راتب 3000، 7 سنوات، فصل → يجب أن يظهر 13,500.00
#    - راتب 3000، 3 سنوات، استقالة → يجب أن يظهر 1,500.00 (33%)
#    - راتب 3000، 1 سنة، استقالة → يجب أن يظهر 0.00

# 4. اختبار إمكانية الوصول
#    flutter run → فعّل TalkBack على المحاكي → تنقل عبر الحقول

# 5. تأكيد حذف الملف الحساس
git status  # security_info.txt يجب ألا يظهر
```

---

## خارج النطاق (لا يُنفّذ الآن)
- تاريخ الحسابات (يحتاج `shared_preferences`)
- الوضع الليلي (Dark Mode) — مشروع كامل
- تعدد اللغات (EN/AR) — يحتاج إعادة هيكلة
- PDF export — يحتاج package جديد
- iOS AdMob setup — خارج نطاق Android-first
