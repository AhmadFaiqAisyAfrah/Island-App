import '../domain/payment/payment_enums.dart';
import '../domain/payment/payment_product.dart';
import 'payment_gateway.dart';

/// Payment Service
/// 
/// Client-side service for handling payment flow.
/// This is a STUB for Phase 3A - infrastructure only.
/// 
/// RESPONSIBILITIES:
/// - Prepare transaction via backend
/// - Open payment redirect
/// - Handle payment result
/// 
/// NOT RESPONSIBLE FOR:
/// - Unlocking items (Shop/Theme logic)
/// - Storing API keys
/// - Direct Midtrans API calls
/// 
/// PHASE 3A: Mock implementation
/// PHASE 3B: Connect to real backend
class PaymentService {
  final PaymentGateway _gateway;
  
  // Singleton pattern
  static PaymentService? _instance;
  
  factory PaymentService() {
    _instance ??= PaymentService._internal(
      PaymentGateway(), // Mock gateway for Phase 3A
    );
    return _instance!;
  }
  
  PaymentService._internal(this._gateway);
  
  /// Prepare a payment transaction
  /// 
  /// Returns a PaymentTransaction with payment URL
  /// User must be redirected to paymentUrl to complete payment
  /// 
  /// [product] The product to purchase
  /// [userId] Current user identifier
  /// 
  /// Phase 3A: Returns mock transaction
  /// Phase 3B: Calls real backend API
  Future<PaymentTransaction> prepareTransaction({
    required PaymentProduct product,
    required String userId,
  }) async {
    // PHASE 3A: Mock implementation
    // In Phase 3B, this will call backend API:
    // POST /api/payments/create
    // Body: { productId, userId }
    // Response: { transactionId, paymentUrl, status }
    
    return _gateway.createTransaction(
      product: product,
      userId: userId,
    );
  }
  
  /// Check payment status
  /// 
  /// Should be called when user returns from payment page
  /// or via webhook/deep link
  /// 
  /// Phase 3A: Returns mock status
  /// Phase 3B: Calls real backend API
  Future<PaymentTransaction> checkStatus({
    required String transactionId,
  }) async {
    // PHASE 3A: Mock implementation
    // In Phase 3B, this will call backend API:
    // GET /api/payments/status/{transactionId}
    
    return _gateway.checkTransactionStatus(transactionId);
  }
  
  /// Get available products
  /// 
  /// Returns list of products from backend
  /// Prices are defined server-side, never hardcoded in Flutter
  /// 
  /// Phase 3A: Returns mock products
  /// Phase 3B: Calls real backend API
  Future<List<PaymentProduct>> getAvailableProducts() async {
    // PHASE 3A: Mock products for testing
    // In Phase 3B, this will call backend API:
    // GET /api/payments/products
    
    return _gateway.getProducts();
  }
  
  /// Handle payment completion
  /// 
  /// Called when payment is successful
  /// This only records the success - actual unlocking happens elsewhere
  /// 
  /// NOTE: This is NOT where items get unlocked!
  /// Unlocking happens via:
  /// 1. Webhook from Midtrans to backend
  /// 2. Backend validates payment
  /// 3. Backend calls PointService.addPoints() or unlocks theme
  /// 4. UI refreshes from backend state
  Future<void> handlePaymentSuccess(String transactionId) async {
    // PHASE 3A: No-op (mock)
    // PHASE 3B: Notify backend that user completed payment
    // Backend handles actual unlocking via webhook
    
    // DO NOT unlock anything here!
    // DO NOT call PointService.addPoints() here!
    // Backend is the source of truth for unlocked items
  }
  
  /// Get mock products for Phase 3A testing
  /// These will be replaced by backend API in Phase 3B
  static List<PaymentProduct> getMockProducts() {
    return const [
      PaymentProduct(
        id: 'coin_pack_100',
        name: '100 Island Coins',
        description: 'Small coin pack for beginners',
        type: PaymentType.coinPack,
        priceAmount: 15000, // Rp 15.000
        currency: 'IDR',
        rewardId: '100_coins',
        metadata: {'coin_amount': 100},
      ),
      PaymentProduct(
        id: 'coin_pack_500',
        name: '500 Island Coins',
        description: 'Best value coin pack',
        type: PaymentType.coinPack,
        priceAmount: 49000, // Rp 49.000
        currency: 'IDR',
        rewardId: '500_coins',
        metadata: {'coin_amount': 500},
      ),
      PaymentProduct(
        id: 'coin_pack_1000',
        name: '1000 Island Coins',
        description: 'Ultimate coin pack',
        type: PaymentType.coinPack,
        priceAmount: 89000, // Rp 89.000
        currency: 'IDR',
        rewardId: '1000_coins',
        metadata: {'coin_amount': 1000},
      ),
      PaymentProduct(
        id: 'premium_theme_stargazer',
        name: 'Stargazer Hut',
        description: 'Premium celestial dwelling',
        type: PaymentType.premiumTheme,
        priceAmount: 25000, // Rp 25.000
        currency: 'IDR',
        rewardId: 'house_stargazer',
        metadata: {'theme_id': 'house_stargazer'},
      ),
      PaymentProduct(
        id: 'premium_theme_beach',
        name: 'Tropical Beach',
        description: 'Premium tropical paradise',
        type: PaymentType.premiumTheme,
        priceAmount: 25000, // Rp 25.000
        currency: 'IDR',
        rewardId: 'env_beach',
        metadata: {'theme_id': 'env_beach'},
      ),
    ];
  }
}
