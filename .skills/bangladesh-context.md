---
name: bangladesh-context
description: "Use this skill whenever FitCraft deals with pricing, payments, market assumptions, language, or platform decisions. Triggers: any mention of BDT, bKash, Nagad, pricing, currency, Android, Bangla, or Bangladesh. Prevents Western-market assumptions from creeping into the app."
---

# FitCraft — Bangladesh Market Context

## Core Assumption: Android First

Bangladesh's smartphone market is overwhelmingly Android.

| Rule | Detail |
|------|--------|
| Primary test device | Android (mid-range: 4GB RAM, Android 10+) |
| iOS | Write compatible code, but do NOT test on iOS in Phase 1 |
| Min SDK | Android API 21 (Android 5.0) — covers 99%+ of BD market |
| Target SDK | Android 34 |
| Performance | Optimize for 4GB RAM devices — avoid heavy memory usage |
| APK size | Keep under 50MB — users on limited data plans |

---

## Currency: BDT (Bangladeshi Taka)

- **Never show USD** to Bangladesh users unless they are foreign designers
- All prices stored as `INTEGER` in BDT (no decimals — Taka doesn't use paisa in practice)
- Display format: `৳1,500` or `1,500 BDT`
- Typical garment price range: 500–5,000 BDT

```dart
// core/utils/currency_formatter.dart
class CurrencyFormatter {
  static String format(int amountBdt) {
    if (amountBdt >= 1000) {
      final formatted = amountBdt.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'),
        (m) => '${m[1]},',
      );
      return '৳$formatted';
    }
    return '৳$amountBdt';
  }

  // Example: format(1500) → '৳1,500'
  // Example: format(500)  → '৳500'
}
```

---

## Payment Integrations (Phase 2)

Bangladesh uses mobile financial services (MFS) — not credit cards.

| Provider | Market Share | Priority |
|----------|-------------|----------|
| **bKash** | ~60% | Highest — integrate first |
| **Nagad** | ~30% | Second |
| Rocket | ~5% | Optional |
| Credit/debit card | ~5% | Low priority |

### bKash Integration Notes

- Uses OAuth2 token-based API
- Sandbox: `https://tokenized.sandbox.bka.sh/`
- Production: `https://tokenized.pay.bka.sh/`
- Required: Business registration in Bangladesh
- Docs: `https://developer.bka.sh/`
- Flow: App opens bKash SDK / deep link → user confirms in bKash → callback to your app

```dart
// Placeholder for Phase 2
// core/services/payment_service.dart
class PaymentService {
  // TODO Phase 2: Integrate bKash tokenized payment API
  // Token endpoint: POST /v1.2.0-beta/tokenized/checkout/token/grant
  // Payment endpoint: POST /v1.2.0-beta/tokenized/checkout/create

  Future<String> initiateBkashPayment({
    required int amountBdt,
    required String orderId,
    required String customerPhone, // BD format: 01XXXXXXXXX
  }) async {
    throw UnimplementedError('bKash integration — Phase 2');
  }
}
```

### Phone Number Format
- Bangladesh numbers: `01XXXXXXXXX` (11 digits, starts with 01)
- Validate with: `RegExp(r'^01[3-9]\d{8}$')`
- Do NOT use international format (+880) in bKash/Nagad APIs

---

## Language & Locale

| Setting | Value |
|---------|-------|
| Primary language | English (UI in Phase 1) |
| Secondary language | Bangla (Phase 2 optional) |
| Date format | DD/MM/YYYY (not MM/DD/YYYY) |
| Number format | Bengali numerals optional, ASCII default |

Bangla font if needed: `Hind Siliguri` (Google Fonts, free)

```dart
// If adding Bangla text support
import 'package:google_fonts/google_fonts.dart';
// TextStyle: GoogleFonts.hindSiliguri()
```

---

## Garment Categories (Bangladesh-Relevant)

Always include these categories in the design store:

| Category | Examples |
|----------|---------|
| `traditional` | Saree, Salwar Kameez, Panjabi, Sherwani, Lehenga |
| `western` | Jeans + top, dress, suit, blazer |
| `casual` | T-shirt, kurta, everyday wear |
| `formal` | Office wear, wedding guest, ceremony |

**Traditional is the highest-demand category** for FitCraft's core use case (tailors + custom fitting).

---

## Target Customer Profile (Phase 1)

- **Age:** 18–35
- **Location:** Dhaka, Chittagong, Sylhet (urban)
- **Device:** Android mid-range (Samsung Galaxy A series, Xiaomi, Realme)
- **Internet:** 4G mobile data (not always on WiFi)
- **Expectation:** WhatsApp-level UX simplicity
- **Pain point:** Ordering custom clothes from tailors who can't visualize the design

### UX Implications

- Loading states must show progress — users on mobile data need feedback
- Keep image sizes small — compress all uploads to ≤500KB
- Avoid onboarding friction — sign up with Google in one tap
- Offline capability matters — cache measurements and wishlist in Hive

---

## Pricing Strategy (Phase 1 Revenue)

| Source | Model | Amount |
|--------|-------|--------|
| Designer subscription | Monthly fee to list designs | 200–500 BDT/month |
| Order commission | % cut when tailor fulfills order | 10–15% of order |
| Try-on credits | Free tier: 5 try-ons; then 10 BDT each | Phase 2 |

**Do NOT charge customers for the app or basic try-on in Phase 1.** Growth > revenue early.

---

## Competitor Landscape (Bangladesh)

| Company | Threat Level | Gap FitCraft Fills |
|---------|-------------|-------------------|
| Shajgoj (beauty) | None | Different category |
| Chaldal (grocery) | None | Different category |
| Daraz (marketplace) | Low | No virtual try-on, no custom fit |
| Western try-on apps | Very Low | Not targeting BD, no Bangla, no BDT, no bKash |

**First-mover advantage is real.** No app in Bangladesh does smartphone-based 3D body scanning + AI try-on + tailor fulfillment.

---

## App Store & Distribution

- **Primary:** Google Play Store (Bangladesh users expect APK from Play Store)
- **Phase 1 testing:** Direct APK sideload (common in BD — no Play Store needed for beta)
- **iOS App Store:** Phase 3 only
- App name: **FitCraft** — check availability on Play Store before launch
- Package name: `com.fitcraft.app` (reserve this early)

---

## Server & Infrastructure Choices

| Service | Choice | Reason |
|---------|--------|--------|
| Backend hosting | Railway.app (free tier) | No upfront cost, easy deploy |
| Database | Supabase free tier | 500MB included, no credit card for dev |
| AI inference | Replicate pay-per-use | No server to manage, $0.01/call |
| CDN for images | Firebase Storage | Integrated with Firebase Auth |

No need for Bangladeshi servers in Phase 1 — latency from Railway (US) is acceptable for 20-40s AI calls.
