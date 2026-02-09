# Island Monetization Phase 1 - Foundation & State Architecture

## ✅ COMPLETED

Phase 1 berhasil diselesaikan tanpa mengubah UI apapun.

## 📁 Files Created

### Domain Models (`lib/domain/monetization/`)

1. **monetization_types.dart**
   - `AdsType`: trialAd, pointAd
   - `ItemAccessType`: free, trial, pointUnlock, premiumPurchase
   - `TrialDuration`: oneDay (24h), oneWeek (168h)
   - Extension methods for TrialDuration

2. **trial_item.dart**
   - `TrialItem` model class
   - Properties: id, name, accessType, trialDuration, pointCost, etc.
   - Helper methods: supportsTrial, supportsPointUnlock, requiresPurchase

3. **point_transaction.dart**
   - `PointTransaction` model (immutable)
   - Factory constructors: fromFocusSession, fromAdWatch, forUnlock
   - `TransactionSource` enum
   - `PointBalance` class for economy state

4. **ads_policy.dart** (Pure Rules)
   - `TrialAdsPolicy`: max 1/day, requiresRegularItem, cooldownHours
   - `PointAdsPolicy`: unlimited, shopOnly, noPopup
   - `GeneralAdsPolicy`: minInterval, maxPerSession
   - `AdsTrigger` & `AdsResult` enums

5. **point_rules.dart** (Pure Rules)
   - `PointRewards`: perFocusMinute (2), perAdWatch (50), welcomeBonus (100)
   - `PointCosts`: basicTheme (500), premiumTheme (1000), etc.
   - `PointThresholds`: minimumUnlock (300), lowBalance (100)
   - `PointConstraints`: maxBalance (99999), allowNegative (false)

6. **monetization.dart** (Export barrel file)

### Services (`lib/services/`)

7. **trial_service.dart**
   - Manages trial state persistence
   - Methods:
     - `canShowTrialOfferToday()` - Check daily limit
     - `hasActiveTrial()` - Check if trial active
     - `isTrialActiveFor(itemId)` - Check specific item
     - `canStartTrialFor(item)` - Full eligibility check
     - `recordTrialAdShown()` - Persist ad shown
     - `activateTrial(itemId, durationHours)` - Start trial
     - `getRemainingTrialHours()` - Time left
   - SharedPreferences keys:
     - `trial_last_shown_date`
     - `trial_active_until`
     - `trial_item_id`

8. **point_service.dart**
   - Manages point economy state
   - Methods:
     - `getCurrentPoints()` - Current balance
     - `getBalance()` - Full PointBalance object
     - `hasEnoughPoints(cost)` - Check affordability
     - `addPoints(amount)` - Earn points
     - `spendPoints(amount)` - Spend points
     - `awardFocusSessionPoints(minutes)` - Auto-calc focus rewards
     - `awardAdWatchPoints()` - Award ad points
     - `awardWelcomeBonus()` - One-time new user bonus
     - `recordAdWatch()` - Increment counter
     - `getUnlockProgress(cost)` - Progress percentage
   - SharedPreferences keys:
     - `total_points`
     - `total_points_earned`
     - `total_points_spent`
     - `total_ads_watched`
     - `points_last_updated`

## 🔑 SharedPreferences Keys Used

```
trial_last_shown_date      // int (timestamp)
trial_active_until         // int (timestamp)
trial_item_id             // String
total_points              // int
total_points_earned       // int
total_points_spent        // int
total_ads_watched         // int
points_last_updated       // int (timestamp)
welcome_bonus_claimed     // bool
```

## 📊 Business Rules Implemented

### Trial Ads
- ✅ Max 1 per day
- ✅ Only regular items (non-premium)
- ✅ 24-hour cooldown
- ✅ 24-hour trial duration

### Point Ads
- ✅ Unlimited quantity
- ✅ Shop context only
- ✅ No popup (user-initiated)
- ✅ 50 points per ad

### Point Economy
- ✅ 2 points per focus minute
- ✅ Minimum 5 min to earn
- ✅ Max 100 points per session
- ✅ Welcome bonus: 100 points
- ✅ Basic theme: 500 points
- ✅ Premium theme: 1000 points
- ✅ Max balance: 99999

## 🧪 Self-Check Results

- ✅ App compiles without errors
- ✅ No UI changes made
- ✅ No new widgets created
- ✅ No dialogs or popups
- ✅ No ads triggered
- ✅ No theme changes
- ✅ No refactoring of existing code
- ✅ All rules are pure constants
- ✅ Services are stateless (except SharedPreferences)

## 🚫 What Was NOT Changed

- No modifications to existing UI
- No changes to onboarding flow
- No ads SDK installed
- No changes to theme system
- No changes to focus/timer logic
- No splash screen modifications
- No Android/iOS native code changes

## 📝 Usage Examples

```dart
// Initialize services
final trialService = TrialService(prefs);
final pointService = PointService(prefs);

// Check trial eligibility
if (trialService.canShowTrialOfferToday()) {
  // Can offer trial (UI decides to show button)
}

// Check if item on trial
if (trialService.isTrialActiveFor('theme_ocean')) {
  // Grant access
}

// Award focus session points
await pointService.awardFocusSessionPoints(25); // 25 min = 50 points

// Check balance
final balance = pointService.getBalance();
if (pointService.hasEnoughPoints(PointCosts.basicTheme)) {
  // Can unlock
}

// Award ad watch
await pointService.awardAdWatchPoints(); // +50 points, +1 ad counter
```

## 🎯 Ready for Phase 2

Phase 1 foundation is complete and stable. Ready for:
- Phase 2: UI Implementation (Shop, Trial buttons)
- Phase 3: Ads SDK Integration
- Phase 4: Purchase System

## 🏗️ Architecture Notes

- **Pure Functions**: All rule files are pure constants
- **Immutable Models**: Transaction and Item models are immutable
- **Stateless Services**: Services hold no state, only SharedPreferences
- **No Side Effects**: No code triggers ads or UI automatically
- **Testable**: Easy to unit test (inject mock SharedPreferences)
- **Extensible**: Easy to add new item types, rewards, or rules
