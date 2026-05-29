import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
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
        primarySwatch: Colors.green,
        useMaterial3: true,
        fontFamily: 'Roboto', // Default font, RTL will handle Arabic
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF1565C0),
        ),
      ),
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'SA'),
      ],
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
  final _yearsController = TextEditingController();
  final _monthsController = TextEditingController();
  
  String _terminationReason = 'termination'; // 'termination' or 'resignation'
  double? _result;
  
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isBannerLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
    _loadInterstitial();
  }

  void _loadBanner() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-9928258270334822/3089442375', // Fixed publisher ID to 9928
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isBannerLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-9928258270334822/1975350272', // Fixed publisher ID to 9928
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
        },
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
        onAdFailedToShowFullScreenContent: (ad, error) {
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
    final int years = int.tryParse(_yearsController.text) ?? 0;
    final int months = int.tryParse(_monthsController.text) ?? 0;
    
    final double totalPeriod = years + (months / 12.0);
    
    // Logic based on Saudi Labor Law
    double baseReward = 0;
    
    // First 5 years: half salary for each year
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
      } else if (totalPeriod >= 2 && totalPeriod < 5) {
        finalReward = baseReward * (1 / 3);
      } else if (totalPeriod >= 5 && totalPeriod < 10) {
        finalReward = baseReward * (2 / 3);
      } else {
        finalReward = baseReward; // Full reward for 10+ years resignation
      }
    }
    
    setState(() {
      _result = finalReward;
    });
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
    final currencyFormat = NumberFormat.currency(symbol: 'ر.س', decimalDigits: 2);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('حاسبة مكافأة نهاية الخدمة', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInputCard(),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: _calculate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('احسب المكافأة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  if (_result != null) ...[
                    const SizedBox(height: 25),
                    _buildResultCard(currencyFormat),
                  ],
                ],
              ),
            ),
          ),
          if (_isBannerLoaded)
            SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              controller: _salaryController,
              label: 'الراتب الأخير (الأساسي + البدلات)',
              hint: 'مثال: 5000',
              icon: Icons.money,
              isNumber: true,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _yearsController,
                    label: 'سنوات الخدمة',
                    hint: '0',
                    icon: Icons.calendar_today,
                    isNumber: true,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildTextField(
                    controller: _monthsController,
                    label: 'أشهر الخدمة',
                    hint: '0',
                    icon: Icons.calendar_month,
                    isNumber: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('سبب انتهاء العلاقة التعاقدية', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _terminationReason,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'termination', child: Text('إنهاء عقد من جهة العمل')),
                    DropdownMenuItem(value: 'resignation', child: Text('استقالة')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _terminationReason = value!;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(NumberFormat formatter) {
    return Card(
      elevation: 4,
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.green.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            const Text('قيمة المكافأة المستحقة', style: TextStyle(fontSize: 16, color: Colors.green)),
            const SizedBox(height: 10),
            Text(
              formatter.format(_result),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'حسب نظام العمل السعودي',
              style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
