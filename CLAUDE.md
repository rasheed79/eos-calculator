# CLAUDE.md — حاسبة مكافأة نهاية الخدمة

## Project
Flutter app (Arabic RTL) — حساب مكافأة نهاية الخدمة وفق نظام العمل السعودي.
- **Package:** `com.jamali.app01`
- **Version:** `1.1.0+5`
- **Target:** Android (primary), Web (secondary)

## Stack
- Flutter 3.x + Dart, Material Design 3
- `google_mobile_ads` — banner + interstitial (Android/iOS only, guarded with `kIsWeb`)
- `flutter_localizations` + `intl` — Arabic RTL, locale `ar_SA`

## Architecture
- Single file: `lib/main.dart` — all UI + logic
- Calculation logic in `_performCalculation()` — **do not modify without testing Saudi Labor Law rules**
- Ads guarded by `if (!kIsWeb)` — required to avoid `MissingPluginException` on Chrome

## Key Rules (Saudi Labor Law)
- First 5 years: `0.5 × monthly_salary × years`
- Beyond 5 years: `1 × monthly_salary × years`
- Resignation: `<2y = 0%`, `2–5y = 33%`, `5–10y = 66%`, `10y+ = 100%`

## Build
```bash
# Web (dev)
flutter run -d chrome

# Android release AAB
flutter build appbundle --release
# AAB path: build/app/outputs/bundle/release/app-release.aab
```

## AdMob IDs
- App ID: `ca-app-pub-9928258270334822~4430335257` (AndroidManifest.xml)
- Banner: `ca-app-pub-9928258270334822/3089442375`
- Interstitial: `ca-app-pub-9928258270334822/1975350272`

## Design System (Light Fintech — v1.1.0)
- Style: Light fintech wallet — soft gradients, big numbers, airy cards (radius 24)
- Primary: `#2563EB` | Sky: `#38BDF8` | BG: `#F4F7FE` | Gold (legal chip only): `#F59E0B` | Text: `#0F172A`
- Font: IBM Plex Sans Arabic (bundled in `assets/fonts/`, weights 400/600/700)
- Store assets pipeline: `assets/store/asset_*.html` rendered via Playwright at exact viewport
  (icon 512×512, feature 1024×500, screenshots 1080×1920)

## Pending
- Extract `_performCalculation()` to separate service class
- Add iOS AdMob support
- Remove `security_info.txt` (contains plaintext keystore credentials)
