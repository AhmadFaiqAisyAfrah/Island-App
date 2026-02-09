/// Ads Policy - Pure Rules & Constants
/// 
/// This file contains ONLY rules and constants for advertisement behavior.
/// NO execution logic, NO side effects, NO UI.
/// 
/// These are the laws that govern when and how ads can be shown.

/// Trial Ads Policy
/// 
/// Rules for trial advertisement offers
class TrialAdsPolicy {
  /// Maximum trial ads per day
  static const int maxPerDay = 1;
  
  /// Trial ads only work on regular (non-premium) items
  static const bool requireRegularItem = true;
  
  /// Cooldown between trial ads (in hours)
  static const int cooldownHours = 24;
  
  /// Default trial duration when unlocked
  static const int trialDurationHours = 24; // oneDay
  
  /// Private constructor - this is a static constants class
  const TrialAdsPolicy._();
}

/// Point Ads Policy
/// 
/// Rules for point-earning advertisements
class PointAdsPolicy {
  /// Point ads have no daily limit
  static const bool unlimited = true;
  
  /// Point ads only available in shop context
  static const String availableContext = 'shop';
  
  /// Point ads should never show as popup
  static const bool allowPopup = false;
  
  /// Points earned per point ad watched
  static const int pointsPerAd = 50;
  
  /// Private constructor - this is a static constants class
  const PointAdsPolicy._();
}

/// General Ads Policy
/// 
/// App-wide advertisement rules
class GeneralAdsPolicy {
  /// Minimum time between any ads (in seconds)
  static const int minimumIntervalSeconds = 30;
  
  /// Maximum ads per session (safety limit)
  static const int maxPerSession = 10;
  
  /// Grace period for new users before seeing ads (in days)
  static const int newUserGracePeriodDays = 1;
  
  /// Private constructor - this is a static constants class
  const GeneralAdsPolicy._();
}

/// Ads Trigger Conditions
/// 
/// When is it appropriate to offer ads?
enum AdsTrigger {
  /// User explicitly requests trial
  /// (e.g., clicks "Try for Free" button)
  userRequestedTrial,
  
  /// User explicitly requests more points
  /// (e.g., clicks "Watch Ad for Points" in shop)
  userRequestedPoints,
}

/// Ads Result Types
/// 
/// Possible outcomes of an ad interaction
enum AdsResult {
  /// Ad completed successfully, reward granted
  completed,
  
  /// Ad dismissed by user
  dismissed,
  
  /// Ad failed to load
  failedToLoad,
  
  /// Ad failed during playback
  failedDuringPlayback,
  
  /// Ad not available (daily limit reached)
  notAvailable,
  
  /// User not eligible (cooldown active)
  userNotEligible,
}
