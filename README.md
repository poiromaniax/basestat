# BaseStat — Gamified Health RPG iOS App

A SwiftUI iOS 26 app with Apple's **liquid glass** design language that gamifies your health journey with a full RPG system: XP, levels, achievement badges, streaks, and challenges — all powered by Apple HealthKit and synced via CloudKit.

---

## Requirements

| Requirement | Version |
|---|---|
| Xcode | 26.0+ (beta) |
| iOS Deployment Target | 26.0 |
| Swift | 6.0 |
| Apple Developer Account | Required (HealthKit + CloudKit) |

> **Note:** HealthKit requires a **physical iPhone** — the simulator does not provide real health data.

---

## Setup

### 1. Open in Xcode
```
open BaseStat.xcodeproj
```

### 2. Set your Team & Bundle ID
- In Xcode: select the `BaseStat` target → **Signing & Capabilities**
- Set your **Team** to your Apple Developer account
- Change `PRODUCT_BUNDLE_IDENTIFIER` to something unique (e.g. `com.yourname.basestat`)

### 3. Configure CloudKit Container
- In **Signing & Capabilities**, add the **CloudKit** capability
- Set the iCloud container identifier to match: `iCloud.com.basestat.app` (or your custom ID)
- Update `Constants.App.iCloudContainer` in `BaseStat/Utilities/Constants.swift` to match
- Update `BaseStat/BaseStat.entitlements` with the same container identifier

### 4. Build & Run on Device
- Select your iPhone as the run destination
- Build (`⌘R`)
- On first launch, grant HealthKit permissions when prompted

---

## Architecture

```
BaseStat/
├── BaseStatApp.swift              # App entry + ModelContainer + root routing
├── Models/                     # SwiftData @Model classes (CloudKit-synced)
│   ├── UserProfile             # Level, XP, name, weight goal
│   ├── HealthSnapshot          # Daily aggregated health metrics
│   ├── Achievement             # Unlocked badge state
│   ├── AchievementDefinitions  # Static catalog of all 30 badges
│   ├── Streak                  # Daily streak tracking
│   ├── Challenge               # Time-boxed goals
│   └── ActivityLog             # XP event history
├── Services/
│   ├── HealthKitManager        # All HealthKit read/background logic
│   ├── GamificationEngine      # XP award, level-ups, achievement checks
│   └── NotificationManager     # Streak reminders, badge unlocks, deadlines
├── ViewModels/                 # @Observable MVVM layer
├── Views/
│   ├── Dashboard/              # Home screen with glass metric cards
│   ├── Health/                 # Per-metric detail + Swift Charts
│   ├── Achievements/           # Badge gallery + detail sheets
│   ├── Challenges/             # Active/completed challenges
│   ├── Profile/                # Level ring, stats, streak history
│   ├── Onboarding/             # 4-page welcome + HealthKit permissions
│   └── Components/             # Reusable liquid glass components
├── Theme/
│   ├── BaseStatTheme              # Colors, typography, spacing, mesh colors
│   └── GlassModifiers          # .basestatGlassCard(), .basestatGlassButton()
└── Utilities/
    ├── Constants               # App-wide constants
    └── Extensions              # Double, Int, Date, Color, View helpers
```

---

## Gamification System

### XP Sources
| Action | XP |
|---|---|
| Daily login | +10 |
| Log weight | +30 |
| Hit steps goal (10K) | +50 |
| Hit sleep goal (7.5h) | +40 |
| Hit calorie burn goal | +30 |
| Complete workout | +75 |
| Streak milestone | +count×10 |
| Achievement unlock | +50–5000 |
| Challenge complete | +300–800 |

### Level Curve
Level N requires `N × 500` XP to advance. Level 1→2 costs 500 XP, Level 10→11 costs 5,000 XP.

### Achievement Categories
- **Weight** (7 badges) — first weigh-in through 25kg lost
- **Steps** (5 badges) — first 10K through 1 million steps
- **Exercise** (7 badges) — first workout through century club
- **Sleep** (3 badges) — first 8-hour night through 30-day sleep streak
- **Heart** (3 badges) — first reading through athlete-level resting HR
- **Meta** (7 badges) — app streaks and level milestones

---

## Liquid Glass Design

All cards and containers use iOS 26's `.glassEffect()` modifier:
- **`GlassCard`** — primary container for all metric cards, stat sections
- **`GlassProgressRing`** — circular progress with gradient stroke
- **`GradientMeshBackground`** — animated `MeshGradient` backdrop
- **`GlassModifiers`** — `.basestatGlassCard()`, `.basestatGlassPanel()`, `.basestatGlassButton()` convenience modifiers

---

## Known Limitations

- `basedEnergyBurned` (resting energy) identifier is confirmed valid in HealthKit — if Xcode shows a warning, it can be replaced with `.basalEnergyBurned`
- The `GlassEffect.interactive()` modifier on buttons may need adjustment based on the final iOS 26 GM API
- CloudKit sync requires the app to be opened at least once on each device to initialize the schema
