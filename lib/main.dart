import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// ui-ux-pro-max: Financial Dashboard + Trust & Authority
// Primary: #0F172A | CTA: #0369A1 | Profit: #22C55E | BG: #F8FAFC
const _navy      = Color(0xFF0F172A);
const _navyLight = Color(0xFF1E3A5F);
const _blue      = Color(0xFF0369A1);
const _blueLight = Color(0xFFEFF6FF);
const _green     = Color(0xFF16A34A);
const _greenBg   = Color(0xFFF0FDF4);
const _greenBorder = Color(0xFFBBF7D0);
const _bg        = Color(0xFFF8FAFC);
const _surface   = Color(0xFFFFFFFF);
const _text      = Color(0xFF0F172A);
const _muted     = Color(0xFF64748B);
const _border    = Color(0xFFE2E8F0);
const _inputBg   = Color(0xFFF8FAFC);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) MobileAds.instance.initialize();
  runApp(const EndOfServiceApp());
}

class EndOfServiceApp extends StatelessWidget {
  const EndOfServiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'حاسبة مكافأة نهاية الخدمة',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Cairo',
        colorScheme: ColorScheme.fromSeed(
          seedColor: _blue,
          primary: _blue,
          surface: _surface,
        ),
        scaffoldBackgroundColor: _bg,
      ),
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar', 'SA')],
      locale: const Locale('ar', 'SA'),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});
  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  final _formKey    = GlobalKey<FormState>();
  final _salaryCtr  = TextEditingController();
  final _yearsCtr   = TextEditingController();
  final _monthsCtr  = TextEditingController();

  String  _reason   = 'termination';
  double? _result;
  double? _baseReward;
  double  _totalYears = 0;

  BannerAd?       _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isBannerLoaded = false;
  int _calcCount = 0;

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    if (!kIsWeb) {
      _loadBanner();
      _loadInterstitial();
    }
  }

  void _loadBanner() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-9928258270334822/3089442375',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isBannerLoaded = true),
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    )..load();
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-9928258270334822/1975350272',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded:       (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_)  => _interstitialAd = null,
      ),
    );
  }

  void _onCalculate() {
    if (!_formKey.currentState!.validate()) return;
    if (_interstitialAd != null && !kIsWeb) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose(); _loadInterstitial(); _performCalculation();
        },
        onAdFailedToShowFullScreenContent: (ad, _) {
          ad.dispose(); _loadInterstitial(); _performCalculation();
        },
      );
      _interstitialAd!.show();
    } else {
      _performCalculation();
    }
  }

  void _performCalculation() {
    final salary = double.parse(_salaryCtr.text);
    final years  = int.parse(_yearsCtr.text.isEmpty  ? '0' : _yearsCtr.text);
    final months = int.parse(_monthsCtr.text.isEmpty ? '0' : _monthsCtr.text);
    final total  = years + (months / 12.0);

    double base = total <= 5
        ? total * (salary / 2)
        : 5 * (salary / 2) + (total - 5) * salary;

    double final_ = base;
    if (_reason == 'resignation') {
      if      (total < 2)  final_ = 0;
      else if (total < 5)  final_ = base * (1 / 3);
      else if (total < 10) final_ = base * (2 / 3);
    }

    setState(() {
      _result     = final_;
      _baseReward = base;
      _totalYears = total;
      _calcCount++;
    });
    _animCtrl.forward(from: 0);
    if (_calcCount == 3 && !kIsWeb) _requestReview();
  }

  Future<void> _requestReview() async {
    final review = InAppReview.instance;
    if (await review.isAvailable()) {
      await review.requestReview();
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _salaryCtr.dispose();
    _yearsCtr.dispose();
    _monthsCtr.dispose();
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'ar');
    return Scaffold(
      body: Column(
        children: [
          _Header(),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                children: [
                  _SectionCard(
                    icon: Icons.payments_rounded,
                    title: 'الراتب الأساسي',
                    child: _AmountField(controller: _salaryCtr),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    icon: Icons.timeline_rounded,
                    title: 'مدة الخدمة',
                    child: Row(
                      children: [
                        Expanded(child: _DurationField(controller: _yearsCtr, label: 'سنوات', max: 50)),
                        const SizedBox(width: 12),
                        Expanded(child: _DurationField(controller: _monthsCtr, label: 'أشهر', max: 11)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    icon: Icons.gavel_rounded,
                    title: 'سبب انتهاء العلاقة',
                    child: _ReasonSelector(
                      value: _reason,
                      onChanged: (v) => setState(() => _reason = v),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _CalcButton(onTap: _onCalculate),
                  if (_result != null) ...[
                    const SizedBox(height: 20),
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: _ResultCard(
                          result: _result!,
                          base: _baseReward!,
                          years: _totalYears,
                          reason: _reason,
                          fmt: fmt,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const _DisclaimerFooter(),
                ],
              ),
            ),
          ),
          if (_isBannerLoaded)
            SizedBox(
              width:  _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child:  AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_navy, _navyLight],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, top + 18, 20, 22),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: _blue,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: _blue.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('حاسبة مكافأة نهاية الخدمة',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, height: 1.3)),
                SizedBox(height: 3),
                Text('وفق نظام العمل السعودي',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Disclaimer + Source ─────────────────────────────────────────────────────

class _DisclaimerFooter extends StatelessWidget {
  const _DisclaimerFooter();

  static const _sourceUrl = 'https://hrsd.gov.sa';

  Future<void> _openSource() async {
    final uri = Uri.parse(_sourceUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFC2410C), size: 16),
              SizedBox(width: 6),
              Text('تنبيه',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFFC2410C))),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'هذا التطبيق غير تابع لأي جهة حكومية ولا يمثل وزارة الموارد البشرية والتنمية الاجتماعية. '
            'النتائج تقديرية للاسترشاد فقط، والمرجع الرسمي هو نظام العمل السعودي.',
            style: TextStyle(fontSize: 12, color: _muted, height: 1.6),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: _openSource,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.link_rounded, color: _blue, size: 16),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'المصدر الرسمي: وزارة الموارد البشرية — hrsd.gov.sa',
                      style: TextStyle(
                        fontSize: 12,
                        color: _blue,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Card ────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _SectionCard({required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _border)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: _blueLight, borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: _blue, size: 17),
                ),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _text)),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}

// ── Fields ──────────────────────────────────────────────────────────────────

class _AmountField extends StatelessWidget {
  final TextEditingController controller;
  const _AmountField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _text),
      decoration: InputDecoration(
        hintText: '0.00',
        hintStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w300, color: _muted.withOpacity(0.5)),
        suffixText: 'ر.س',
        suffixStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _muted),
        filled: true,
        fillColor: _inputBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _blue, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 2)),
      ),
      validator: (v) => (v == null || v.isEmpty || double.tryParse(v) == null || double.parse(v) <= 0)
          ? 'أدخل راتباً صحيحاً'
          : null,
    );
  }
}

class _DurationField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int max;
  const _DurationField({required this.controller, required this.label, required this.max});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _muted)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: _text),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w300, color: _muted.withOpacity(0.4)),
            filled: true,
            fillColor: _inputBg,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _blue, width: 2)),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return null;
            final n = int.tryParse(v);
            if (n == null || n < 0 || n > max) return '0–$max';
            return null;
          },
        ),
      ],
    );
  }
}

// ── Reason Selector ─────────────────────────────────────────────────────────

class _ReasonSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _ReasonSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ReasonTile(
          value: 'termination',
          selected: value == 'termination',
          icon: Icons.business_center_rounded,
          label: 'إنهاء من قِبَل صاحب العمل',
          subtitle: 'المكافأة كاملة بحسب نظام العمل',
          onTap: () => onChanged('termination'),
        ),
        const SizedBox(height: 8),
        _ReasonTile(
          value: 'resignation',
          selected: value == 'resignation',
          icon: Icons.exit_to_app_rounded,
          label: 'استقالة',
          subtitle: 'تُحتسب حسب مدة الخدمة',
          onTap: () => onChanged('resignation'),
        ),
      ],
    );
  }
}

class _ReasonTile extends StatelessWidget {
  final String value, label, subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _ReasonTile({
    required this.value, required this.label, required this.subtitle,
    required this.icon, required this.selected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? _blueLight : _inputBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? _blue : _border, width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: selected ? _blue : _border,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: selected ? Colors.white : _muted, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: selected ? _blue : _text)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: _muted)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20, height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? _blue : Colors.transparent,
                border: Border.all(color: selected ? _blue : _border, width: 2),
              ),
              child: selected ? const Icon(Icons.check, color: Colors.white, size: 12) : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Calculate Button ─────────────────────────────────────────────────────────

class _CalcButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CalcButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [_blue, Color(0xFF0284C7)]),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: _blue.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 5))],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calculate_rounded, color: Colors.white, size: 22),
              SizedBox(width: 10),
              Text('احتساب المكافأة', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Result Card ──────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  final double result, base, totalYears;
  final String reason;
  final NumberFormat fmt;

  const _ResultCard({
    required this.result, required this.base,
    required double years, required this.reason, required this.fmt,
  }) : totalYears = years;

  String get _reductionLabel {
    if (reason == 'termination') return 'مكافأة كاملة';
    if (totalYears < 2)  return 'لا يحق (أقل من سنتين)';
    if (totalYears < 5)  return 'ثلث المكافأة';
    if (totalYears < 10) return 'ثلثا المكافأة';
    return 'مكافأة كاملة';
  }

  @override
  Widget build(BuildContext context) {
    final years = totalYears.floor();
    final months = ((totalYears - years) * 12).round();

    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _greenBorder, width: 1.5),
        boxShadow: [BoxShadow(color: _green.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          // Top green banner
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: _greenBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              border: const Border(bottom: BorderSide(color: _greenBorder)),
            ),
            child: Column(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: _green.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_rounded, color: _green, size: 28),
                ),
                const SizedBox(height: 10),
                const Text('المكافأة المستحقة', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _green)),
                const SizedBox(height: 8),
                _CountUp(target: result, fmt: fmt),
              ],
            ),
          ),
          // Breakdown
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _BreakdownRow(
                  label: 'المكافأة الأساسية',
                  value: '${fmt.format(base)} ر.س',
                  icon: Icons.functions_rounded,
                  color: _blue,
                ),
                const SizedBox(height: 8),
                _BreakdownRow(
                  label: 'تعديل الاستقالة',
                  value: _reductionLabel,
                  icon: Icons.tune_rounded,
                  color: _muted,
                ),
                const SizedBox(height: 8),
                _BreakdownRow(
                  label: 'مدة الخدمة',
                  value: '$years سنة${months > 0 ? " و$months شهر" : ""}',
                  icon: Icons.access_time_rounded,
                  color: _muted,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(color: _border),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _blueLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline_rounded, color: _blue, size: 14),
                      SizedBox(width: 6),
                      Text('محتسبة وفق نظام العمل السعودي',
                          style: TextStyle(fontSize: 11, color: _blue, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _BreakdownRow({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13, color: _muted)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _text)),
      ],
    );
  }
}

// ── Count-Up Animation ───────────────────────────────────────────────────────

class _CountUp extends StatefulWidget {
  final double target;
  final NumberFormat fmt;
  const _CountUp({required this.target, required this.fmt});

  @override
  State<_CountUp> createState() => _CountUpState();
}

class _CountUpState extends State<_CountUp> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _anim = Tween<double>(begin: 0, end: widget.target)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutExpo));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_CountUp old) {
    super.didUpdateWidget(old);
    if (old.target != widget.target) {
      _anim = Tween<double>(begin: old.target, end: widget.target)
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutExpo));
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Text(
        '${widget.fmt.format(_anim.value)} ر.س',
        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: _navy, letterSpacing: -1, height: 1.2),
        textAlign: TextAlign.center,
      ),
    );
  }
}
