# Phase 3: Midtrans Payment Integration

## Overview

This document explains the Midtrans payment infrastructure for Island app, why certain architectural decisions were made, and how the payment flow works.

## Architecture Principles

### 1. Security First: Flutter Never Stores API Keys

**Why:**
- Flutter code can be decompiled and inspected
- API keys in Flutter = compromised security
- ServerKey especially must be protected at all costs

**Solution:**
- ServerKey stored ONLY in backend environment variables
- Flutter calls backend API, backend calls Midtrans
- Flutter receives only Snap token/redirect URL

### 2. Backend as Proxy

**Flow:**
```
User → Flutter → Backend → Midtrans API
                ↓
User ← Flutter ← Backend ← Midtrans Webhook
```

**Benefits:**
- API keys never exposed to client
- Business logic validated server-side
- Can switch payment providers without Flutter changes
- Transaction audit trail in backend

### 3. Webhook-Based Fulfillment

**Why not instant unlock?**
- Payment might fail after redirect
- User might close app during payment
- Network issues might interrupt flow

**Correct Flow:**
1. User completes payment on Midtrans page
2. Midtrans sends webhook to backend
3. Backend validates payment status
4. Backend unlocks item/adds coins
5. User sees update on next app refresh

## File Structure

```
lib/
├── domain/
│   └── payment/
│       ├── payment_enums.dart       # PaymentType, PaymentStatus
│       └── payment_product.dart     # PaymentProduct, PaymentTransaction
│
├── services/
│   ├── payment_service.dart         # Client-side payment logic
│   ├── payment_gateway.dart         # Backend boundary (MOCK)
│   └── point_service.dart           # Existing coin system
│
└── features/
    └── shop/
        └── presentation/
            └── shop_screen.dart     # UI (no changes in Phase 3A)
```

## Phase 3A: Infrastructure (Current)

### What's Implemented

1. **Domain Models** ✅
   - PaymentProduct (id, name, type, price)
   - PaymentTransaction (id, status, paymentUrl)
   - Enums for type and status

2. **PaymentService** ✅
   - prepareTransaction()
   - checkStatus()
   - getAvailableProducts()
   - Mock implementation for testing

3. **PaymentGateway** ✅
   - Mock backend boundary
   - Simulates API responses
   - Documents real backend requirements

4. **Environment Setup** ✅
   - .env.example with placeholder values
   - NO real keys in repository
   - Clear documentation

### What's NOT Implemented (Phase 3B)

- ❌ Real HTTP calls to backend
- ❌ Deep link handling
- ❌ Webhook listeners
- ❌ UI integration
- ❌ Error handling UI
- ❌ Loading states

## Sandbox Testing Flow

### Step 1: Create Transaction
```dart
final product = PaymentProduct(
  id: 'coin_pack_100',
  name: '100 Island Coins',
  priceAmount: 15000, // Rp 15.000
  currency: 'IDR',
  // ...
);

final transaction = await PaymentService().prepareTransaction(
  product: product,
  userId: 'user_123',
);

// Get paymentUrl: https://app.sandbox.midtrans.com/snap/v2/vtweb/xxxxx
```

### Step 2: Open Payment Page
```dart
// Launch URL in browser or WebView
await launchUrl(Uri.parse(transaction.paymentUrl!));
```

### Step 3: Complete Test Payment
Use Midtrans test credentials:
- Card Number: `4811 1111 1111 1114`
- Expiry: `12/25`
- CVV: `123`
- OTP: `112233`

### Step 4: Handle Return
```dart
// User returns to app via deep link
// Check payment status
final updated = await PaymentService().checkStatus(
  transactionId: transaction.transactionId,
);

if (updated.status.isSuccess) {
  // Backend will unlock via webhook
  // Refresh user data from backend
}
```

## Backend API Specification

### POST /api/payments/create
Create new payment transaction

**Request:**
```json
{
  "productId": "coin_pack_100",
  "userId": "user_123"
}
```

**Response:**
```json
{
  "transactionId": "txn_abc123",
  "midtransOrderId": "ORDER-123456",
  "paymentUrl": "https://app.sandbox.midtrans.com/snap/v2/vtweb/xxxxx",
  "status": "pending",
  "createdAt": "2025-02-08T10:00:00Z"
}
```

### GET /api/payments/status/{transactionId}
Check transaction status

**Response:**
```json
{
  "transactionId": "txn_abc123",
  "status": "success",
  "product": {
    "id": "coin_pack_100",
    "type": "coinPack"
  },
  "updatedAt": "2025-02-08T10:05:00Z"
}
```

### POST /api/payments/webhook (Midtrans → Backend)
Receive payment notifications

**Midtrans Payload:**
```json
{
  "transaction_id": "txn_abc123",
  "order_id": "ORDER-123456",
  "transaction_status": "settlement",
  "gross_amount": "15000.00",
  "payment_type": "credit_card"
}
```

**Backend Actions:**
1. Validate signature
2. Check transaction_status
3. If success: unlock item/add coins
4. Store transaction record

## Security Checklist

- [ ] ServerKey only in backend env
- [ ] ClientKey only for Snap initialization
- [ ] HTTPS only for all API calls
- [ ] Webhook signature verification
- [ ] Transaction amount validation
- [ ] Idempotency checks (prevent double unlock)
- [ ] User authentication on all endpoints

## Environment Variables

### Backend (.env)
```
MIDTRANS_SERVER_KEY=SB-Mid-server-xxxxx
MIDTRANS_CLIENT_KEY=SB-Mid-client-xxxxx
MIDTRANS_IS_PRODUCTION=false
```

### Flutter (.env)
```
# NO API KEYS! Only backend URL
BACKEND_API_URL=https://api.island.app
```

## Common Pitfalls

### ❌ WRONG: Flutter calls Midtrans directly
```dart
// NEVER DO THIS
final response = await http.post(
  Uri.parse('https://api.midtrans.com/v2/charge'),
  headers: {
    'Authorization': 'Basic ${base64Encode('SERVER_KEY:')}',
    // SERVER_KEY EXPOSED! ❌
  },
);
```

### ✅ CORRECT: Flutter calls backend
```dart
// CORRECT APPROACH
final response = await http.post(
  Uri.parse('$backendUrl/api/payments/create'),
  headers: {
    'Authorization': 'Bearer $userToken',
  },
  body: {'productId': product.id},
);
// Backend handles Midtrans communication
```

## Next Steps (Phase 3B)

1. Implement backend API
2. Replace PaymentGateway mock with HTTP client
3. Add deep link handler
4. Integrate with Shop UI
5. Add loading/error states
6. Test with Midtrans sandbox
7. Production deployment

## Resources

- Midtrans Docs: https://docs.midtrans.com
- Snap.js: https://docs.midtrans.com/en/snap/overview
- Security Guide: https://docs.midtrans.com/en/security/overview

---

**Status:** Phase 3A Complete - Infrastructure Ready
**Next:** Phase 3B - Backend Integration
