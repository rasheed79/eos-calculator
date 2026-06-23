---
name: حاسبة مكافأة نهاية الخدمة
description: أداة مجانية دقيقة تحسب مكافأة نهاية الخدمة وفق نظام العمل السعودي
colors:
  primary: "#2563EB"
  primary-deep: "#1D4ED8"
  sky: "#38BDF8"
  bg: "#F4F7FE"
  surface: "#FFFFFF"
  ink: "#0F172A"
  muted: "#475569"
  border: "#E3EAF6"
  gold: "#F59E0B"
  gold-light: "#FEF3C7"
  error: "#DC2626"
typography:
  display:
    fontFamily: "Almarai, system-ui, Arial, sans-serif"
    fontSize: "clamp(1.9rem, 5vw, 2.7rem)"
    fontWeight: 800
    lineHeight: 1.25
    letterSpacing: "-0.02em"
  headline:
    fontFamily: "Almarai, system-ui, Arial, sans-serif"
    fontSize: "1.25rem"
    fontWeight: 800
    lineHeight: 1.4
  body:
    fontFamily: "Almarai, system-ui, Arial, sans-serif"
    fontSize: "0.95rem"
    fontWeight: 400
    lineHeight: 1.75
  label:
    fontFamily: "Almarai, system-ui, Arial, sans-serif"
    fontSize: "0.82rem"
    fontWeight: 700
    lineHeight: 1.4
rounded:
  pill: "100px"
  card: "24px"
  result: "20px"
  button: "16px"
  input: "14px"
  chip: "8px"
spacing:
  xs: "6px"
  sm: "12px"
  md: "18px"
  lg: "28px"
  xl: "48px"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.surface}"
    rounded: "{rounded.button}"
    padding: "16px"
  button-primary-hover:
    backgroundColor: "{colors.primary-deep}"
    textColor: "{colors.surface}"
    rounded: "{rounded.button}"
    padding: "16px"
  button-play:
    backgroundColor: "{colors.ink}"
    textColor: "{colors.surface}"
    rounded: "14px"
    padding: "14px 26px"
  input-field:
    backgroundColor: "{colors.bg}"
    textColor: "{colors.ink}"
    rounded: "{rounded.input}"
    padding: "14px 16px"
  calc-card:
    backgroundColor: "{colors.surface}"
    rounded: "{rounded.card}"
    padding: "{spacing.lg} 24px"
  result-box:
    backgroundColor: "{colors.ink}"
    textColor: "{colors.surface}"
    rounded: "{rounded.result}"
    padding: "28px 24px"
---

# Design System: حاسبة مكافأة نهاية الخدمة

## 1. Overview

**Creative North Star: "الدقة المؤتمنة"**

هذا النظام مصمم لموظف يصل من Google في لحظة توتر — يريد رقماً صحيحاً، الآن. ليس لديه وقت لتصميم جذاب ولا صبر على تسويق. يريد أن يثق بالمصدر قبل أن يُدخل راتبه. "الدقة المؤتمنة" تعني أن كل قرار تصميمي يخدم هذه اللحظة: وضوح سريع، مصداقية هادئة، نتيجة واضحة.

النظام يرفض الاتجاهين: لا ثقل حكومي (تصميم 2010، ألوان رمادية، جداول منتفخة)، ولا مبالغة SaaS أمريكية (gradients كثيفة، social proof مصطنع، hero ضخم). الهوية تأتي من الدقة، لا من الأناقة.

**Key Characteristics:**
- اللون الأزرق (#2563EB) هو الصوت الوحيد للعلامة. كل شيء آخر محايد.
- الذهبي (#F59E0B) محجوز لنتيجة الحساب فقط — ظهوره نادر ومقصود.
- RTL عربي كامل مع Almarai — اختيار متعمد لا عشوائي.
- الكارت العائم فوق الـ hero (-36px margin) هو اللمسة التصميمية الوحيدة.

## 2. Colors

لوحة محدودة متعمدة: أزرق واحد + ذهبي للنتيجة + محايدات نظيفة.

### Primary
- **Institutional Blue (#2563EB):** اللون الرئيسي للأزرار والـ CTA والـ hero gradient. يعطي شعور المؤسسة بدون ثقل حكومي.
- **Deep Blue (#1D4ED8):** يُستخدم في hover states ورؤوس الجداول. يضمن contrast ≥ 4.7:1 على الأبيض.
- **Sky (#38BDF8):** نهاية gradient في الـ hero فقط. لا يُستخدم كلون مستقل.

### Secondary
- **Gold (#F59E0B):** محجوز حصرياً لرقم المكافأة المحسوبة ولـ chip القانوني في التطبيق. ظهوره مرتبط بالنتيجة — لا يُستخدم تزيينياً.

### Neutral
- **Background (#F4F7FE):** خلفية الصفحة والـ inputs. مزرق خفيف يوحي بالموثوقية.
- **Surface (#FFFFFF):** خلفية الكروت والنتائج. نقاء مطلق داخل الكروت.
- **Ink (#0F172A):** النص الرئيسي وخلفية result-box. داكن جداً بدون أسود مطلق.
- **Muted (#475569):** النصوص الثانوية والـ labels. Contrast 5.7:1 على البيضاء — يمر WCAG AA.
- **Border (#E3EAF6):** الحدود والفواصل. مزرق خفيف يتناسق مع bg.
- **Error (#DC2626):** حالات الخطأ فقط.

### Named Rules
**The Gold Scarcity Rule.** الذهبي يظهر مرة واحدة في الصفحة: رقم المكافأة. إذا استُخدم في أي مكان آخر، فقد قيمته كإشارة "هذا هو الرقم الذي جئت من أجله".

**The One Voice Rule.** #2563EB هو صوت العلامة. لا يوجد لون ثانٍ يتنافس معه. الـ sky (#38BDF8) هو امتداد في الـ gradient، ليس لوناً مستقلاً.

## 3. Typography

**Display/Body Font:** Almarai (Google Fonts، مجاني، weights 400/700/800)

**Character:** خط عربي هندسي نظيف، يوحي بالدقة دون برود. يعمل بشكل استثنائي في RTL ويقرأ بوضوح على الجوال في الأحجام الصغيرة. اختيار واحد بأوزان متعددة — لا حاجة لزوج ثانٍ.

### Hierarchy
- **Display** (800، clamp 1.9–2.7rem، line-height 1.25، letter-spacing -0.02em): عنوان hero فقط. نقطة التركيز الأولى.
- **Headline** (800، 1.25rem، line-height 1.4): عناوين أقسام SEO. تفصل بين الأقسام دون صراخ.
- **Title** (700، 1.2rem): عنوان CTA ("حمّل التطبيق على هاتفك") وعناوين الكروت.
- **Body** (400، 0.95rem، line-height 1.75): نصوص SEO التفسيرية. Line-height مرتفع للقراءة في RTL.
- **Label** (700، 0.82rem): labels الحقول والـ badges والـ trust bar. وزن 700 ليتميز وإن كان صغيراً.
- **Micro** (400، 0.78rem): footer disclaimer. الحجم الأدنى المسموح.

### Named Rules
**The Single Family Rule.** Almarai فقط في كامل الصفحة. الخط الواحد بأوزان مختلفة أقوى من زوج متخاذل.

**The Arabic Rhythm Rule.** line-height 1.75 في النصوص الطويلة إلزامي في RTL — العربية أكثر كثافة بصرياً من اللاتينية في نفس الحجم.

## 4. Elevation

النظام مسطّح افتراضياً. الظل علامة على "هذا مهم ويرتفع فوق الخلفية"، لا للزخرفة.

### Shadow Vocabulary
- **Card Shadow** (`0 8px 32px rgba(15,23,42,.08), 0 1px 4px rgba(15,23,42,.04)`): يُستخدم في calc-card وkروت النتائج فقط. ظل منتشر + ظل حاد صغير يعطي عمقاً طبيعياً.
- **Button Shadow** (`0 4px 14px rgba(15,23,42,.22)`): للزر الأساسي "احسب الآن" فقط. أثقل لأن الزر هو نقطة التحويل.
- **Result Card Shadow** (`0 12px 30px rgba(37,99,235,.16)`): للـ result card في التطبيق. مزرق لأن النتيجة مرتبطة بلون العلامة.

### Named Rules
**The Flat-By-Default Rule.** الصفحة مسطحة عدا ثلاثة عناصر: calc-card، result-box، الزر الأساسي. كل ظل إضافي يضعّف التأثير الموجود.

## 5. Components

### Buttons
- **الشخصية:** واثق وسريع الاستجابة. لا rounded مبالغ فيها، لا gradients.
- **Primary (احسب الآن):** خلفية #2563EB، نص أبيض، radius 16px، padding 16px كامل العرض، ظل يُضاف. Hover → #1D4ED8، Active → scale(.98). Focus → outline 3px #38BDF8.
- **Play Store Button:** خلفية #0F172A، نص أبيض، radius 14px، padding 14px 26px. Hover → #1e293b.
- **Share Button (WhatsApp):** خلفية rgba(37,211,102,.08)، حد rgba(37,211,102,.4)، نص #065F46، radius 12px. يظهر فقط بعد الحساب.

### Inputs / Fields
- **Style:** border 1.5px solid #E3EAF6، radius 14px، خلفية #F4F7FE، font-size 1.05rem weight 700.
- **Direction:** `direction: ltr; text-align: right` للـ number inputs — الأرقام تُكتب من اليمين لليسار.
- **Focus:** border يتحول لـ #2563EB + box-shadow 3px rgba(37,99,235,.18).
- **Error:** border #DC2626، رسالة خطأ تحت الحقل بـ font-size .8rem.

### Calculator Card
- خلفية بيضاء، radius 24px، shadow card. margin-top: -36px لتطفو فوق الـ hero.
- Padding: 28px 24px (20px 14px على الجوال ≤430px).

### Result Box
- خلفية #0F172A، نص أبيض. Animation: result-in 0.28s cubic-bezier(0.25,0,0,1).
- رقم المكافأة: font-size clamp(2.2rem, 8vw, 3rem)، weight 800، لون #F59E0B.
- الـ chip (نوع المكافأة): خلفية rgba(255,255,255,.10)، radius 100px.

### Trust Bar
- flex wrap، نص #475569، font-size .88rem. ثلاث نقاط فقط، لا أكثر.

### SEO Tables
- رؤوس: خلفية #1D4ED8 (deep blue، لا #2563EB — لضمان contrast 4.7:1).
- خلايا: border-bottom #E3EAF6، صفوف متعاقبة بـ #f8faff.
- Width 100%، font-size .9rem.

### Badge / Chip
- pill radius (100px). في الـ hero: خلفية rgba(255,255,255,.15)، حد rgba(255,255,255,.28)، نص أبيض.
- في التطبيق (gold chip): خلفية #FEF3C7، نص #92400E.

## 6. Do's and Don'ts

### Do:
- **Do** استخدم #1D4ED8 (deep blue) لرؤوس الجداول ونص العناصر على الأبيض التي تحتاج WCAG AA — ليس #2563EB (contrast 3.93:1 فقط).
- **Do** احتفظ بالذهبي (#F59E0B) حصرياً لرقم المكافأة. ظهوره في مكان ثانٍ يُفقده دلالته.
- **Do** استخدم Almarai وحده بأوزان 400/700/800. لا تضف خطاً ثانياً.
- **Do** اعرض نتيجة الحساب بـ animation (result-in) — هي اللحظة الوحيدة التي يُسمح فيها بالحركة.
- **Do** استخدم `text-wrap: balance` على العناوين وHTML RTL في كل حالة.
- **Do** حافظ على `direction: ltr; text-align: right` لحقول الأرقام في RTL.

### Don't:
- **Don't** تضع نصاً بلون مائل للرمادي على خلفية ملونة. استخدم درجة أغمق من لون الخلفية نفسها.
- **Don't** تستخدم الذهبي (#F59E0B) كلون تزيين أو hover أو border — هو محجوز للنتيجة.
- **Don't** تضيف gradient text أو background-clip:text — ممنوع مطلقاً.
- **Don't** تكرر badge/eyebrow فوق كل قسم. الـ badge الوحيد "⚖️ وفق نظام العمل السعودي" في الـ hero يكفي.
- **Don't** تستخدم بطاقات متطابقة بأيقونة + عنوان + نص — هذا ما رفضه PRODUCT.md صراحةً.
- **Don't** تضع border-left ملونة أكثر من 1px كزخرفة. لا side stripes.
- **Don't** تُشغّل أي animation قبل تحميل المحتوى — الـ result-in يُشغّل فقط بعد click لا عند scroll.
- **Don't** تضع نصاً بـ opacity أقل من .7 على الخلفية — ما دون ذلك يفشل WCAG AA.
- **Don't** تستخدم "أوف لاين" أو غيرها من الترجمة الحرفية للإنجليزية — استخدم "بدون إنترنت".
- **Don't** تصمم بثقل حكومي (تصميم 2010) ولا بمبالغة SaaS أمريكية. المنطقة المقصودة: ثقة هادئة.
