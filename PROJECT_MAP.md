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
