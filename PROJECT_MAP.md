## المشروع
- **التطبيق:** حاسبة مكافأة نهاية الخدمة
- **Package:** `com.jamali.app01`
- **الإصدار الحالي:** `1.0.2+3` (رُفع 7 يونيو 2026، قيد المراجعة)
- **الإصدار السابق المنشور:** `1.0.1+2` — Production، 177 دولة، 81.82% install base
- **Play Store Stats (7 يونيو 2026):** 30 MAU، آخر تنزيل 4 يونيو 2026
- **الهدف:** دخل من AdMob — يحتاج 50,000+ impression/شهر

## سجل الإصدارات
| Version Code | Version Name | التاريخ | الحالة |
|---|---|---|---|
| 3 | 1.0.2 | 7 يونيو 2026 | مرفوع — قيد المراجعة |
| 2 | 1.0.1 | 29 مايو 2026 | Active — Production |
| 1 | 1.0.0 | 10 أبريل 2026 | Active — Alpha/Internal |

## تحديثات 7 يونيو 2026
- ✅ ASO: عنوان + وصف قصير + وصف كامل محدّث في Play Console
- ✅ أضيف `in_app_review` — يطلب تقييم بعد الحساب الثالث
- ✅ حُذف `keepDebugSymbols` من `build.gradle.kts` (كان يمنع البناء)
- ✅ بُني AAB جديد `1.0.2+3` (43.1MB) ورُفع على Production

---

## خطة التسويق — بدون ميزانية

### المرحلة 1: ASO — أسبوع 1 ✅ مكتملة
- [x] تغيير عنوان Play Store → `حاسبة مكافأة نهاية الخدمة`
- [x] تحديث الوصف القصير → `احسب مكافأتك بدقة وفق نظام العمل السعودي في ثوانٍ`
- [x] إضافة كلمات في الوصف الكامل (مكافأة، نظام العمل، حقوق الموظف، وزارة الموارد البشرية...)
- [x] إضافة `in_app_review` — يظهر بعد الحساب الثالث تلقائياً
- [ ] مراجعة Screenshots — العنوان على كل صورة يحتوي كلمة "مكافأة"

### المرحلة 2: صفحة الدومين SEO — أسبوع 2
- الدومين: `daleel-adawat.com` — رابط مقترح: `daleel-adawat.com/maka-fa`
- [ ] إنشاء صفحة HTML على الدومين
- [ ] H1: `كيف تحسب مكافأة نهاية الخدمة في السعودية`
- [ ] محتوى: شرح القانون + مثال حساب + زر تحميل Play Store
- [ ] meta title: `حساب مكافأة نهاية الخدمة 2026 - حاسبة مجانية`
- [ ] meta description: `احسب مكافأتك وفق نظام العمل السعودي. مجاني، دقيق، سريع.`
- [ ] الصفحة تفتح على الجوال بسرعة (لا CDN خارجي)

### المرحلة 3: سوشيال — مرة واحدة فقط
- [ ] بوست LinkedIn (نص محدد في محادثة 7 يونيو 2026)
- [ ] تغريدة X مع الرابط
- [ ] الرد على تغريدات تسأل "كيف أحسب مكافأتي"

### المرحلة 4: مراقبة شهرية (15 دقيقة)
- [ ] Play Console → Statistics → User Acquisition أسبوعياً
- هدف شهر 1: 80 MAU
- هدف 3 أشهر: 200+ MAU
- هدف 6 أشهر: 1,000 MAU → ~$15-25/شهر AdMob
- هدف سنة: 5,000 MAU → ~$75-150/شهر AdMob

---

## Stack
- Flutter (Dart) — multi-platform mobile/desktop/web
- google_mobile_ads — banner + interstitial ads (Android/iOS only)
- flutter_localizations + intl — Arabic RTL localization
- Material Design 3

## Flow
- main.dart → MyApp → EndOfServiceCalculatorPage (StatefulWidget)
- User inputs: basic salary, allowances, years, months, termination reason
- _calculateEndOfService() computes result per Saudi Labor Law
- Result displayed inline; interstitial ad shown on each calculation
- Banner ad loaded on initState, displayed at bottom of screen

## Decisions
- Single-file architecture (lib/main.dart, 362 lines) — all UI + logic together
- Ads initialized only on mobile (web unsupported by google_mobile_ads)
- Calculation logic: first 5 years = 0.5× monthly salary/year; beyond 5 = 1× salary/year
- Resignation reduces entitlement: 0–2y = 0%, 2–5y = 33%, 5–10y = 66%, 10y+ = 100%

## Pending
- Extract calculation logic into separate service/model class
- Move ad unit IDs to constants file (currently hardcoded in main.dart)
- Add input validation (negative values, zero salary)
- Remove security_info.txt (contains plaintext keystore credentials)
- Add web-safe ad stub to eliminate MissingPluginException on Chrome
