import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';

// Design System: Government/HR — Navy + Blue (WCAG AAA)
const _cPrimary    = Color(0xFF0F172A);
const _cSecondary  = Color(0xFF334155);
const _cCTA        = Color(0xFF0369A1);
const _cBackground = Color(0xFFF8FAFC);
const _cText       = Color(0xFF020617);
const _cMuted      = Color(0xFF64748B);
const _cBorder     = Color(0xFFCBD5E1);
const _cSurface    = Color(0xFFFFFFFF);
const _cResultBg   = Color(0xFFEFF6FF);
const _cResultBorder = Color(0xFFBFDBFE);

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: _cCTA,
          primary: _cCTA,
          secondary: _cSecondary,
          surface: _cSurface,
          onSurface: _cText,
        ),
        scaffoldBackgroundColor: _cBackground,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _cSurface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _cBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _cBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _cCTA, width: 2),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _cCTA,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 0.3),
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

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _salaryController = TextEditingController();
  final _yearsController  = TextEditingController();
  final _monthsController = TextEditingController();

  String _terminationReason = 'termination';
  double? _result;

  BannerAd?      _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isBannerLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
    _loadInterstitial();
  }

  void _loadBanner() {
    if (kIsWeb) return;
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
    if (kIsWeb) return;
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-9928258270334822/1975350272',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded:      (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  void _calculate() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitial();
          _performCalculation();
        },
        onAdFailedToShowFullScreenContent: (ad, _) {
          ad.dispose();
          _loadInterstitial();
          _performCalculation();
        },
      );
      _interstitialAd!.show();
    } else {
      _performCalculation();
    }
  }

  void _performCalculation() {
    final double salary = double.tryParse(_salaryController.text) ?? 0;
    final int    years  = int.tryParse(_yearsController.text)  ?? 0;
    final int    months = int.tryParse(_monthsController.text) ?? 0;

    final double totalPeriod = years + (months / 12.0);

    double baseReward = 0;
    if (totalPeriod <= 5) {
      baseReward = totalPeriod * (salary / 2);
    } else {
      baseReward = 5 * (salary / 2);
      baseReward += (totalPeriod - 5) * salary;
    }

    double finalReward = baseReward;
    if (_terminationReason == 'resignation') {
      if (totalPeriod < 2) {
        finalReward = 0;
      } else if (totalPeriod < 5) {
        finalReward = baseReward * (1 / 3);
      } else if (totalPeriod < 10) {
        finalReward = baseReward * (2 / 3);
      }
    }

    setState(() => _result = finalReward);
  }

  @override
  void dispose() {
    _salaryController.dispose();
    _yearsController.dispose();
    _monthsController.dispose();
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'ر.س ', decimalDigits: 2);

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInputCard(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _calculate,
                    child: const Text('احتساب المكافأة'),
                  ),
                  if (_result != null) ...[
                    const SizedBox(height: 24),
                    _buildResultCard(currencyFormat),
                  ],
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

  Widget _buildHeader() {
    return Container(
      color: _cPrimary,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 24,
        right: 20,
        left: 20,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _cCTA,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.calculate_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حاسبة مكافأة نهاية الخدمة',
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 3),
                Text(
                  'وفق نظام العمل السعودي',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      decoration: BoxDecoration(
        color: _cSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel('بيانات الراتب', Icons.payments_outlined),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _salaryController,
            label: 'الراتب الأخير (الأساسي + البدلات)',
            hint: 'مثال: 5000',
            icon: Icons.account_balance_wallet_outlined,
          ),
          const SizedBox(height: 20),
          _buildSectionLabel('مدة الخدمة', Icons.access_time_outlined),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _yearsController,
                  label: 'السنوات',
                  hint: '0',
                  icon: Icons.calendar_today_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _monthsController,
                  label: 'الأشهر',
                  hint: '0',
                  icon: Icons.date_range_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionLabel('سبب انتهاء العلاقة', Icons.info_outline),
          const SizedBox(height: 14),
          _buildDropdown(),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _cCTA),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: _cSecondary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _cMuted),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 16, color: _cText, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: _cMuted.withOpacity(0.6)),
            prefixIcon: Icon(icon, size: 20, color: _cCTA),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: _cSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _cBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _terminationReason,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _cCTA),
          style: const TextStyle(fontSize: 15, color: _cText, fontWeight: FontWeight.w500),
          items: const [
            DropdownMenuItem(
              value: 'termination',
              child: Text('إنهاء عقد من قِبَل جهة العمل'),
            ),
            DropdownMenuItem(
              value: 'resignation',
              child: Text('استقالة'),
            ),
          ],
          onChanged: (value) => setState(() => _terminationReason = value!),
        ),
      ),
    );
  }

  Widget _buildResultCard(NumberFormat formatter) {
    return Container(
      decoration: BoxDecoration(
        color: _cResultBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cResultBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _cCTA.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _cCTA.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline_rounded, color: _cCTA, size: 30),
          ),
          const SizedBox(height: 14),
          const Text(
            'المكافأة المستحقة',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: _cSecondary),
          ),
          const SizedBox(height: 12),
          Text(
            formatter.format(_result),
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: _cPrimary,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _cCTA.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'محتسبة وفق نظام العمل السعودي',
              style: TextStyle(fontSize: 12, color: _cCTA, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
