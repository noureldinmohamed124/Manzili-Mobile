# Showcase Demo Mode — Temporary Workarounds (REMOVE LATER)

This file lists **temporary** changes added to make the app **work for a live showcase even when APIs are missing or failing**.  
After the showcase, replace each item with the real API integration and then remove the demo fallback.

---

## 1) Temporary “Static Admin” login (REMOVE LATER)

- **Email**: `wasfyAdmin@gmail.com`
- **Password**: `wasfy1234`
- **Behavior**: App logs in locally (no API call), sets role = **3 (admin)**, routes to `/admin`.
- **Where implemented**: `lib/presentation/providers/auth_provider.dart`

### To replace later
- Remove the local shortcut.
- Use backend-provided admin account + real `/auth/login` response.

---

## 2) Demo fallback data when APIs fail (REMOVE LATER)

If an API call fails (network/server/404), the app will show **static demo data** so the UI remains usable.

### Seller
- **Seller dashboard**: if `/seller/dashboard` fails, show demo stats.
- **Seller services list**: if `/seller/services` fails, show demo list.

### Orders + payment
- **Orders list**: if `/orders` fails, show demo orders.
- **Payment summary**: if `/order/payment-summary` fails, show demo payment summary.
- **Cart “إرسال الطلب”**: if `/orders/request` fails due to server/connection, allow demo success (clears cart + navigates).

### Services (Home/Services)
- If services endpoints fail, show demo services list so Home/Services screens don’t look empty.

### Where implemented
- Demo generators: `lib/core/constants/demo_data.dart`
- Providers using demo fallback:
  - `lib/presentation/providers/seller_provider.dart`
  - `lib/presentation/providers/orders_provider.dart`
  - `lib/presentation/providers/services_provider.dart`

---

## 3) API gaps still not implemented (needs real work later)

These screens are still mostly UI-only and require real APIs:

- **Admin**: users/services/orders/finance/announcements/reports (API + models + repos + providers)
- **Delivery**: available/my deliveries/details/verification/result
- **Buyer**: wallet, notifications, favourites, explore sellers, track order
- **Seller**: manage orders (accept/reject/reprice), create/edit service (POST/PUT), discounts/offers/posts/templates/VIP

---

## 4) Cleanup checklist after showcase

- Remove static admin login shortcut.
- Remove demo fallback code and replace with real API calls per screen.
- Ensure every screen handles loading/empty/error states without fake data.
- Update `PROJECT_HANDOFF.md` to mark demo mode removed.

