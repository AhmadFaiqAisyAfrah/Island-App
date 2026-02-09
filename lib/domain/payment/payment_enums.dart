/// Payment Type Enum
/// Defines the category of payment product
enum PaymentType {
  /// Coin pack purchase (e.g., 100 coins, 500 coins)
  coinPack,
  
  /// Premium theme unlock (e.g., Stargazer Hut, Tropical Beach)
  premiumTheme,
}

/// Payment Status Enum
/// Tracks the lifecycle of a payment transaction
enum PaymentStatus {
  /// Initial state, transaction created but not started
  init,
  
  /// User is on payment page, waiting for completion
  pending,
  
  /// Payment completed successfully
  success,
  
  /// Payment failed (insufficient funds, error, etc.)
  failed,
  
  /// User canceled the payment
  canceled,
  
  /// Payment expired (user took too long)
  expired,
}

/// Extension for PaymentStatus
extension PaymentStatusExtension on PaymentStatus {
  /// Check if payment is in a final state
  bool get isFinal => 
      this == PaymentStatus.success ||
      this == PaymentStatus.failed ||
      this == PaymentStatus.canceled ||
      this == PaymentStatus.expired;
  
  /// Check if payment completed successfully
  bool get isSuccess => this == PaymentStatus.success;
  
  /// Check if payment is still in progress
  bool get isPending => 
      this == PaymentStatus.init ||
      this == PaymentStatus.pending;
}
