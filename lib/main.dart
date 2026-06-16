import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// Light Fintech: Primary #2563EB | Sky #38BDF8 | BG #F4F7FE | Gold (legal) #F59E0B
const _blue        = Color(0xFF2563EB);
const _blueDeep    = Color(0xFF1D4ED8);
const _sky         = Color(0xFF38BDF8);
const _blueLight   = Color(0xFFEFF5FF);
const _gold        = Color(0xFFF59E0B);
const _goldLight   = Color(0xFFFEF3C7);
const _bg          = Color(0xFFF4F7FE);
const _surface     = Color(0xFFFFFFFF);
const _text        = Color(0xFF0F172A);
const _muted       = Color(0xFF64748B);
const _border      = Color(0xFFE3EAF6);
const _inputBg     = Color(0xFFF4F7FE);

const _ctaGradient = LinearGradient(
  colors: [_blue, _sky],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);
const _heroGradient = LinearGradient(
  colors: [_blueDeep, _blue, _sky],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

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
        fontFamily: 'IBMPlexSansArabic',
        colorScheme: ColorScheme.fromSeed(
          seedColor: _blue,
          primary: _blue,
          surface: _surface,
        ),
        scaffoldBackgroundColor: _bg,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _inputBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _blue, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
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
      if (total < 2) {
        final_ = 0;
      } else if (total < 5) {
        final_ = base * (1 / 3);
      } else if (total < 10) {
        final_ = base * (2 / 3);
      }
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_bg, _surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
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
          if (!kIsWeb)
            SizedBox(
              height: 50,
              child: _isBannerLoaded
                  ? Center(
                      child: SizedBox(
                        width:  _bannerAd!.size.width.toDouble(),
                        height: _bannerAd!.size.height.toDouble(),
                        child:  AdWidget(ad: _bannerAd!),
                      ),
                    )
                  : null,
            ),
        ],
        ),
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
      width: double.infinity,
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(20, top + 24, 20, 4),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: _ctaGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: _blue.withValues(alpha: 0.25), blurRadius: 14, offset: const Offset(0, 6)),
              ],
            ),
            child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('احسب مكافأتك',
                    style: TextStyle(color: _text, fontSize: 24, fontWeight: FontWeight.w700, height: 1.2)),
                SizedBox(height: 2),
                Text('وفق نظام العمل السعودي',
                    style: TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w400)),
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
        borderRadius: BorderRadius.circular(20),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF1E3A8A).withValues(alpha: 0.06), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(color: _blueLight, borderRadius: BorderRadius.circular(11)),
                child: Icon(icon, color: _blue, size: 18),
              ),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _text)),
            ],
          ),
          const SizedBox(height: 14),
          child,
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
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: _text),
      decoration: InputDecoration(
        hintText: '0.00',
        hintStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: _muted.withValues(alpha: 0.5)),
        suffixText: 'ر.س',
        suffixStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _blue),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
            hintStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w300, color: _muted.withValues(alpha: 0.4)),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? _blue : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                gradient: selected ? _ctaGradient : null,
                color: selected ? null : _border,
                borderRadius: BorderRadius.circular(12),
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
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 58,
          decoration: BoxDecoration(
            gradient: _ctaGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: _blue.withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 8))],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calculate_rounded, color: Colors.white, size: 22),
              SizedBox(width: 10),
              Text('احسب الآن', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: _blue.withValues(alpha: 0.16), blurRadius: 30, offset: const Offset(0, 12)),
        ],
      ),
      child: Column(
        children: [
          // Wallet-style gradient hero
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
            decoration: const BoxDecoration(
              gradient: _heroGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_balance_wallet_rounded,
                        color: Colors.white.withValues(alpha: 0.8), size: 16),
                    const SizedBox(width: 6),
                    Text('إجمالي مكافأة نهاية الخدمة',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                            fontWeight: FontWeight.w400)),
                  ],
                ),
                const SizedBox(height: 12),
                _CountUp(target: result, fmt: fmt),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(_reductionLabel,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
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
                  label: 'نسبة الاستحقاق',
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
                    color: _goldLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.gavel_rounded, color: _gold, size: 14),
                      SizedBox(width: 6),
                      Text('محتسبة وفق نظام العمل السعودي',
                          style: TextStyle(fontSize: 11, color: Color(0xFF92400E), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _ShareButton(result: result, years: totalYears, fmt: fmt),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  final double result, years;
  final NumberFormat fmt;
  const _ShareButton({required this.result, required this.years, required this.fmt});

  Future<void> _share() async {
    final y = years.floor();
    final m = ((years - y) * 12).round();
    final period = m > 0 ? '$y سنة و$m شهر' : '$y سنة';
    final text = 'مكافأة نهاية خدمتي: ${fmt.format(result)} ر.س\n'
        'مدة الخدمة: $period\n'
        '#مكافأة_نهاية_الخدمة\n\n'
        'احسب مكافأتك:\nhttps://play.google.com/store/apps/details?id=com.jamali.app01';
    final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFECFDF5),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () async { await _share(); },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.3)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.share_rounded, color: Color(0xFF25D366), size: 18),
              SizedBox(width: 8),
              Text('شارك النتيجة عبر واتساب',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF065F46))),
            ],
          ),
        ),
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
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: _inputBg, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 17, color: color),
        ),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 13, color: _muted)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _text)),
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
      builder: (_, __) => FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          '${widget.fmt.format(_anim.value)} ر.س',
          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w700, color: Colors.white, height: 1.2),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
