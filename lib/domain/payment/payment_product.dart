import 'payment_enums.dart';

/// Payment Product Model
/// Represents a purchasable item in the Island app
/// 
/// NOTE: This is a pure data model. No UI logic, no side effects.
/// Prices are defined in backend, Flutter only displays what backend provides.
class PaymentProduct {
  /// Unique product identifier
  /// Format: 'coin_pack_100', 'premium_theme_stargazer'
  final String id;
  
  /// Display name for the product
  final String name;
  
  /// Product description
  final String description;
  
  /// Type of payment product
  final PaymentType type;
  
  /// Price amount (in smallest currency unit, e.g., cents)
  /// Example: 10000 = Rp 10,000
  final int priceAmount;
  
  /// Currency code (ISO 4217)
  /// Example: 'IDR', 'USD'
  final String currency;
  
  /// For coin packs: how many coins user receives
  /// For premium themes: which theme ID is unlocked
  final String rewardId;
  
  /// Optional metadata for analytics
  final Map<String, dynamic>? metadata;

  const PaymentProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.priceAmount,
    required this.currency,
    required this.rewardId,
    this.metadata,
  });

  /// Get formatted price for display
  /// Example: Rp 10.000
  String get formattedPrice {
    if (currency == 'IDR') {
      // Format Indonesian Rupiah
      final thousands = priceAmount ~/ 1000;
      return 'Rp $thousands.000';
    }
    // Fallback for other currencies
    return '$currency ${priceAmount / 100}';
  }

  /// Get price in main currency unit
  double get priceInMainUnit => priceAmount / 100;

  @override
  String toString() => 
      'PaymentProduct(id: $id, name: $name, type: $type, price: $formattedPrice)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentProduct && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Payment Transaction Model
/// Represents a single payment attempt
class PaymentTransaction {
  /// Unique transaction ID (from backend/Midtrans)
  final String transactionId;
  
  /// Product being purchased
  final PaymentProduct product;
  
  /// Current status of the transaction
  final PaymentStatus status;
  
  /// Midtrans payment URL ( Snap redirect URL)
  final String? paymentUrl;
  
  /// When transaction was created
  final DateTime createdAt;
  
  /// When transaction was last updated
  final DateTime? updatedAt;
  
  /// Error message if failed
  final String? errorMessage;
  
  /// Midtrans order ID (for reconciliation)
  final String? midtransOrderId;

  const PaymentTransaction({
    required this.transactionId,
    required this.product,
    required this.status,
    this.paymentUrl,
    required this.createdAt,
    this.updatedAt,
    this.errorMessage,
    this.midtransOrderId,
  });

  /// Create updated transaction with new status
  PaymentTransaction copyWith({
    PaymentStatus? status,
    String? paymentUrl,
    DateTime? updatedAt,
    String? errorMessage,
    String? midtransOrderId,
  }) {
    return PaymentTransaction(
      transactionId: transactionId,
      product: product,
      status: status ?? this.status,
      paymentUrl: paymentUrl ?? this.paymentUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      errorMessage: errorMessage ?? this.errorMessage,
      midtransOrderId: midtransOrderId ?? this.midtransOrderId,
    );
  }

  @override
  String toString() => 
      'PaymentTransaction(id: $transactionId, product: ${product.id}, status: $status)';
}
