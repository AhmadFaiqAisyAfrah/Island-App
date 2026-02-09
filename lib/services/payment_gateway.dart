import '../domain/payment/payment_enums.dart';
import '../domain/payment/payment_product.dart';
import 'payment_service.dart';

/// Payment Gateway
/// 
/// Backend boundary for Midtrans integration.
/// This is a MOCK implementation for Phase 3A.
/// 
/// ⚠️  BACKEND REQUIRED FOR PRODUCTION ⚠️
/// 
/// In production, this class will be replaced by actual HTTP calls
/// to your backend API. Flutter must NEVER call Midtrans directly
/// or store serverKey/clientKey.
/// 
/// Security Rules:
/// 1. ServerKey must ONLY be stored in backend
/// 2. Flutter only receives Snap token/payment URL from backend
/// 3. Webhooks go from Midtrans → Backend → Flutter
/// 4. Never expose API keys in Flutter code
class PaymentGateway {
  
  /// Create a new transaction
  /// 
  /// PHASE 3A: Mock implementation
  /// PHASE 3B: HTTP POST to backend
  /// 
  /// Backend endpoint: POST /api/payments/create
  /// Backend calls Midtrans API with ServerKey
  /// Backend returns Snap token/redirect URL
  Future<PaymentTransaction> createTransaction({
    required PaymentProduct product,
    required String userId,
  }) async {
    // BACKEND REQUIRED FOR PRODUCTION
    // 
    // This mock simulates what backend will do:
    // 1. Generate unique order ID
    // 2. Call Midtrans Snap API
    // 3. Return transaction details
    //
    // Backend code (for reference):
    // ```
    // const snap = new midtransClient.Snap({
    //   isProduction: false, // SANDBOX
    //   serverKey: process.env.MIDTRANS_SERVER_KEY, // NEVER IN FLUTTER
    //   clientKey: process.env.MIDTRANS_CLIENT_KEY,
    // });
    // 
    // const transaction = await snap.createTransaction({
    //   transaction_details: {
    //     order_id: orderId,
    //     gross_amount: product.priceAmount,
    //   },
    //   customer_details: {
    //     user_id: userId,
    //   },
    // });
    // 
    // return {
    //   transactionId: transaction.id,
    //   paymentUrl: transaction.redirect_url,
    //   status: 'pending',
    // };
    // ```
    
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network
    
    final transactionId = 'mock_txn_${DateTime.now().millisecondsSinceEpoch}';
    final mockOrderId = 'ORDER-${DateTime.now().millisecondsSinceEpoch}';
    
    return PaymentTransaction(
      transactionId: transactionId,
      midtransOrderId: mockOrderId,
      product: product,
      status: PaymentStatus.pending,
      paymentUrl: _generateMockPaymentUrl(transactionId),
      createdAt: DateTime.now(),
    );
  }
  
  /// Check transaction status
  /// 
  /// PHASE 3A: Mock implementation (always returns success after delay)
  /// PHASE 3B: HTTP GET to backend
  /// 
  /// Backend endpoint: GET /api/payments/status/{transactionId}
  /// Backend calls Midtrans API to check status
  Future<PaymentTransaction> checkTransactionStatus(String transactionId) async {
    // BACKEND REQUIRED FOR PRODUCTION
    //
    // Backend code (for reference):
    // ```
    // const snap = new midtransClient.Snap({
    //   isProduction: false,
    //   serverKey: process.env.MIDTRANS_SERVER_KEY,
    // });
    //
    // const status = await snap.transaction.status(transactionId);
    // return {
    //   transaction_id: status.transaction_id,
    //   transaction_status: status.transaction_status, // capture, settlement, pending, deny, etc.
    // };
    // ```
    
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network
    
    // For Phase 3A, always return success (for testing)
    // In real implementation, this would return actual status
    return PaymentTransaction(
      transactionId: transactionId,
      product: PaymentService.getMockProducts().first,
      status: PaymentStatus.success, // Mock: always success for testing
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
  
  /// Get available products
  /// 
  /// PHASE 3A: Returns mock products
  /// PHASE 3B: HTTP GET to backend
  /// 
  /// Backend endpoint: GET /api/payments/products
  /// Prices are defined server-side, never hardcoded in Flutter
  Future<List<PaymentProduct>> getProducts() async {
    // BACKEND REQUIRED FOR PRODUCTION
    //
    // Backend should return products with prices from database
    // This allows dynamic pricing without app updates
    
    await Future.delayed(const Duration(milliseconds: 200));
    
    return PaymentService.getMockProducts();
  }
  
  /// Generate mock payment URL
  /// 
  /// In production, this comes from Midtrans Snap API
  String _generateMockPaymentUrl(String transactionId) {
    // This is a FAKE URL for Phase 3A testing
    // In Phase 3B, backend returns real Midtrans Snap URL
    // 
    // Format: https://app.sandbox.midtrans.com/snap/v2/vtweb/{token}
    return 'https://mock-payment.island.app/pay/$transactionId';
  }
}


