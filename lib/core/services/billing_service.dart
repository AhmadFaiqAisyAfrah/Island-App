import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'coin_service.dart';

/// Production-safe billing service for Island app.
///
/// Products:
///   - island_coins_100  (consumable)
///   - island_coins_500  (consumable)
///   - island_remove_ads (non-consumable)
class BillingService {
  BillingService._();
  static final BillingService _instance = BillingService._();
  factory BillingService() => _instance;

  // ── Product IDs ──────────────────────────────────────────────
  static const Set<String> _productIds = {
    'island_coins_100',
    'island_coins_500',
    'island_coins_1000',
    'island_coins_2500',
    'island_remove_ads',
  };

  static const Set<String> _consumableIds = {
    'island_coins_100',
    'island_coins_500',
    'island_coins_1000',
    'island_coins_2500',
  };

  static const Map<String, int> _coinRewards = {
    'island_coins_100': 100,
    'island_coins_500': 500,
    'island_coins_1000': 1000,
    'island_coins_2500': 2500,
  };

  // ── State ────────────────────────────────────────────────────
  final InAppPurchase _iap = InAppPurchase.instance;
  final CoinService _coinService = CoinService();

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  List<ProductDetails> products = [];
  bool _isAvailable = false;
  bool _initialized = false;

  /// Callback fired after any purchase finishes (success or fail).
  /// UI layers can listen to this for refreshing state.
  VoidCallback? onPurchaseUpdated;

  bool get isAvailable => _isAvailable;

  // ── Lifecycle ────────────────────────────────────────────────

  /// Initialize billing. Call once at app start.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) return;

    // Listen to purchase updates
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: _onStreamDone,
      onError: _onStreamError,
    );

    await loadProducts();
  }

  /// Load product details from the store.
  Future<void> loadProducts() async {
    if (!_isAvailable) return;

    final response = await _iap.queryProductDetails(_productIds);

    if (response.error != null) {
      debugPrint('[Billing] Product query error: ${response.error!.message}');
      return;
    }

    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('[Billing] Products not found: ${response.notFoundIDs}');
    }

    products = response.productDetails;
  }

  /// Clean up resources.
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _initialized = false;
  }

  // ── Purchase Actions ─────────────────────────────────────────

  /// Buy a consumable product (coins).
  Future<bool> buyConsumable(String productId) async {
    assert(_consumableIds.contains(productId));
    final product = _findProduct(productId);
    if (product == null) return false;

    final param = PurchaseParam(productDetails: product);
    return _iap.buyConsumable(purchaseParam: param, autoConsume: true);
  }

  /// Buy a non-consumable product (remove ads).
  Future<bool> buyNonConsumable(String productId) async {
    assert(productId == 'island_remove_ads');
    final product = _findProduct(productId);
    if (product == null) return false;

    final param = PurchaseParam(productDetails: product);
    return _iap.buyNonConsumable(purchaseParam: param);
  }

  /// Restore non-consumable purchases (e.g., remove ads).
  Future<void> restorePurchases() async {
    if (!_isAvailable) return;
    await _iap.restorePurchases();
  }

  // ── Purchase Stream Handler ──────────────────────────────────

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
          await _deliverProduct(purchase);
          break;

        case PurchaseStatus.restored:
          await _deliverProduct(purchase);
          break;

        case PurchaseStatus.error:
          debugPrint('[Billing] Purchase error: ${purchase.error?.message}');
          break;

        case PurchaseStatus.canceled:
          // User cancelled — no action needed
          break;

        case PurchaseStatus.pending:
          // Payment pending (e.g., slow payment methods) — no action yet
          break;
      }

      // Always complete the purchase to avoid stuck transactions
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }

    onPurchaseUpdated?.call();
  }

  /// Deliver the product to the user.
  Future<void> _deliverProduct(PurchaseDetails purchase) async {
    final id = purchase.productID;

    if (_consumableIds.contains(id)) {
      // Consumable: add coins
      final reward = _coinRewards[id] ?? 0;
      if (reward > 0) {
        await _coinService.addCoins(reward);
      }
    } else if (id == 'island_remove_ads') {
      // Non-consumable: remove ads
      await _coinService.setRemoveAds(true);
    }
  }

  // ── Helpers ──────────────────────────────────────────────────

  ProductDetails? _findProduct(String productId) {
    try {
      return products.firstWhere((p) => p.id == productId);
    } catch (_) {
      debugPrint('[Billing] Product not found: $productId');
      return null;
    }
  }

  void _onStreamDone() {
    _subscription?.cancel();
  }

  void _onStreamError(Object error) {
    debugPrint('[Billing] Stream error: $error');
  }
}
