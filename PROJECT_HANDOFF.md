# Manzili Mobile — Full Project Handoff File (Everything)

This file is meant to be a **single, complete handoff artifact** you can send to another AI (or reuse later) to quickly reconstruct:

- What the project is and what you asked for previously
- Current codebase structure and what is already implemented
- **All screens/routes** that exist in the app (by role)
- What is **missing** (features, APIs, wiring, persistence, guards, etc.)
- The **API contract** (endpoints + request/response shapes + error conventions) **as specified by you** and **as currently implemented in code**

---

## 1) Project identity

- **Name (app title)**: منزلي (Manzili)
- **Platform**: Flutter mobile app (Dart)
- **Primary audience**: Egypt, Arabic (ar_EG)
- **Goal**: mobile-first platform supporting **small home-based businesses in Egypt**
  - Solve seller problems: weak marketing, low visibility, difficulty getting customers, lack of business tools

---

## 2) Your prior “FULL CURSOR PROMPT” (verbatim extracted spec)

The following requirements were provided earlier in chat and were used as the main spec:

### Product + feature scope

- Service listings
- Booking/request system
- Communication tools
- Analytics & earnings tracking
- Marketing tools (posts, templates, VIP tools)
- Feedback & ratings
- Secure payments

### Design & UX rules

- Mobile-first, clean, modern, soft, friendly, human
- Vertical scrolling, cards instead of tables, thumb-friendly spacing
- Simple flows, clear actions
- Soft warm colors, light shadows, clear hierarchy, smooth spacing
- Status colors:
  - green = active
  - grey = inactive/draft
  - soft red = errors
  - yellow = pending/warning
- Language: **Egyptian Arabic (عامية مصرية بسيطة)** friendly, simple, encouraging
- Screens must handle: loading, empty, error states
- Match Figma screens you provide; improve visuals professionally
- “Production-ready”: smooth, scalable, user-friendly

### Roles

- Buyer
- Seller
- Admin
- (Delivery role is present in the repo routes/UI)

### API system rules

- Base URL (documentation): `http://manzili-app.runasp.net/`
- Headers:
  - `Authorization: Bearer {token}`
  - `Content-Type: application/json`
- JSON naming: **camelCase**
- Standard response:

```json
{ "success": true, "message": "optional", "data": {} }
```

- Error response:

```json
{ "success": false, "message": "Error Message", "data": null }
```

- Status codes:
  - 400 BadRequest
  - 401 Unauthorized
  - 403 Forbidden
  - 404 NotFound
  - 409 Conflict
  - 500 InternalServerError

### Endpoints (as you specified)

1. **Request Service** — `POST /api/orders/request`

```json
{
  "serviceId": 1,
  "customizationText": "string",
  "customRequestImage": "string",
  "quantity": 1,
  "optionGroups": [
    { "groupId": 1, "items": [ { "optionId": 1, "quantity": 1 } ] }
  ]
}
```

2. **Home Section Services** — `GET /api/services/home/{no}`
   - returns: `topDiscounts`, `recommended`, `mostPurchased`, `regular`

3. **Get Services By Name** — `GET /api/services/name/{name}`
   - params: `keyword`, `pageNumber`, `pageSize`

4. **Get Service By Id** — `GET /api/services/{id}`
   - returns full description (EN+AR), provider info, optionGroups, images

5. **Get All Services** — `GET /api/services`
   - filters: `page`, `pageSize`, `categoryId`, `isRecommended`, `topDiscounts`, `mostPurchased`

6. **Refresh Token** — `POST /auth/refresh`

```json
{ "refreshToken": "string" }
```

7. **Login** — `POST /auth/login`

```json
{ "email": "string", "password": "string" }
```

8. **Register** — `POST /auth/register`

```json
{ "fullName": "string", "email": "string", "password": "string", "role": 1 }
```

- Roles mapping: 1=Buyer, 2=Seller, 3=Admin

---

## 3) Repo tech + dependencies (what exists)

From `pubspec.yaml`:

- **Flutter SDK**: Dart `^3.8.1`
- **State management**: `provider`
- **Networking**: `dio`
- **Routing**: `go_router` (includes `StatefulShellRoute.indexedStack`)
- **Localization**: `flutter_localizations`, `intl`
- **UI utilities**: `flutter_svg`, `animations`

App entry (`lib/main.dart`):

- `MaterialApp.router`
- Forced locale: `ar_EG`
- Providers registered:
  - `AuthProvider`
  - `ServicesProvider`
  - `CartProvider`
  - `OrdersProvider`

---

## 4) Codebase structure (high-level)

Typical layering visible in the repo:

- `lib/core/`
  - `router/` — app routes
  - `network/` — Dio setup + API constants + JSON helpers
  - `theme/` — colors/theme
  - `constants/` — assets, strings, Figma node ids
  - `utils/` — JWT parsing, responsive helpers
- `lib/data/`
  - `models/` — request/response models (auth/services/orders)
  - `repositories/` — Orders repository (API calls)
- `lib/presentation/`
  - `providers/` — app state and orchestration of network calls
  - `views/` — screens (buyer/seller/admin/delivery/support)
  - `widgets/` — reusable UI pieces

---

## 5) Figma linkage (screens you referenced)

The repo contains a Figma mapping file:

- `lib/core/constants/figma_screen_nodes.dart`
- Figma file key: `gJiDAzijtWW1n2JCueEzET` (file name: “New Capstone Manzili”)
- Node ids present:
  - Sign up: `1226:7724`
  - Sign in: `1155:6904`
  - Home: `1099:7193`
  - Services list: `1134:6988` (alt: `1150:6921`)
  - Service details: `1150:7135`
  - Reviews: `1229:8087`
  - Explore sellers: `1150:7134`
  - Favourites: `1227:7919`
  - Notifications: `1229:8262`
  - Orders: `1259:7882`
  - Cart: `1195:7068`
  - Order placed: `1319:7377`
  - Track orders: `1320:7470`

If you want to re-fetch exact UI specs later, use those node ids with the Figma MCP “design context” tools.

---

## 6) Routing map (every screen in the app)

Routes are defined in `lib/core/router/app_router.dart`.

### Auth (public)

- `/signin` → `SigninView`
- `/signup` → `SignupView`

### Main buyer shell tabs (StatefulShellRoute indexed stack)

These routes are tabs:

- `/home` → `HomeView`
- `/services` → `ServicesView`
- `/requests` → `RequestsListView`
- `/my-orders` → `OrdersListView`
- `/wallet` → `BuyerWalletView`

Alias:

- `/orders` redirects → `/my-orders`

### General (shared)

- `/profile` → `ProfileHubView`
- `/favourites` → `FavouritesView`
- `/settings` → `SettingsView`
- `/service/:id` → `ServiceDetailsView(serviceId)`
- `/reviews/:id` → `ReviewsView(serviceId)`
- `/notifications` → `NotificationsInboxView`
- `/cart` → `CartView`
- `/order-placed` → `OrderPlacedView`
- `/payment-summary` → `PaymentSummaryView`
- `/payment-method` → `PaymentMethodView`
- `/track-order` → `TrackOrderView`
- `/explore-sellers` → `ExploreSellersView`

### Seller

- `/seller` → `SellerHubView`
- `/seller/create-service` → `SellerCreateServiceView`
- `/seller/edit-service` → `SellerEditServiceView`
- `/seller/my-services` → `SellerServicesListView`
- `/seller/manage-orders` → `SellerManageOrdersView`
- `/seller/order-details/:id` → `SellerOrderDetailsView(orderId)`
- `/seller/discounts` → `SellerDiscountsListView`
- `/seller/discounts/new` → `SellerDiscountEditorView`
- `/seller/auto-accept` → `SellerAutoAcceptView`
- `/seller/earnings` → `SellerEarningsView`
- `/seller/vip` → `SellerVipView`
- `/seller/offers` → `SellerOffersListView`
- `/seller/offers/new` → `SellerOfferEditorView`
- `/seller/compose` → `SellerComposePostView`
- `/seller/scheduled` → `SellerScheduledPostsView`
- `/seller/templates` → `SellerTemplatesView`

### Support

- `/support` → `SupportFormView`
- `/support/confirmation?ticket=...` → `SupportConfirmationView(ticketNumber)`

### Admin

- `/admin` → `AdminHubView`
- `/admin/users` → `AdminUsersView`
- `/admin/users/details/:id` → `AdminUserDetailsView(userId)`
- `/admin/services` → `AdminServicesView`
- `/admin/services/details/:id` → `AdminServiceDetailsView(serviceId)`
- `/admin/orders` → `AdminOrdersView`
- `/admin/orders/details/:id` → `AdminOrderDetailsView(orderId)`
- `/admin/finance` → `AdminFinanceView`
- `/admin/finance/details/:id` → `AdminTransactionDetailsView(transactionId)`
- `/admin/announcements` → `AdminAnnouncementsView`
- `/admin/announcements/new` → `AdminCreateAnnouncementView`
- `/admin/reports` → `AdminReportsView`

### Delivery

- `/delivery` → `DeliveryHubView`
- `/delivery/available` → `AvailableDeliveriesView`
- `/delivery/my-deliveries` → `MyDeliveriesView`
- `/delivery/details/:id` → `DeliveryDetailsView(deliveryId)`
- `/delivery/verification/:id` → `DeliveryVerificationView(deliveryId)`
- `/delivery/result/:status` → `DeliveryResultView(isSuccess)`

---

## 7) What is implemented vs placeholder (reality check)

### Implemented network integration (present in code today)

Only the following API areas are actually coded with real endpoints:

- **Auth**
  - `POST /auth/register`
  - `POST /auth/login`
  - `POST /auth/refresh`
- **Services**
  - `GET /api/services` (filters)
  - `GET /api/services/name/{name}` (search)
  - `GET /api/services/{id}` (details)
  - `GET /api/services/home/{no}` (supported in app; backend may return 404)
- **Orders**
  - `POST /api/orders/request`
  - `GET /api/orders` (paginated)
  - `GET /api/orders/payment-summary`

These are defined in:

- `lib/core/network/api_constants.dart`
- `lib/core/network/dio_client.dart`
- `lib/presentation/providers/auth_provider.dart`
- `lib/presentation/providers/services_provider.dart`
- `lib/data/repositories/orders_repository.dart`
- Models in `lib/data/models/*.dart`

### Screens with real API data (currently)

- **Home** (`/home`): loads sections from services endpoints.
- **Services list** (`/services`): loads services, supports search.
- **Service details** (`/service/:id`): loads details; can submit order request.
- **Orders list** (`/my-orders`): loads `GET /api/orders`.
- **Payment summary** (`/payment-summary`): loads `GET /api/orders/payment-summary`.
- **Auth screens**: login/register/refresh flows via API.

### Screens that are mostly UI-only (likely not backed by real APIs yet)

These screens exist in the router, but **there are no corresponding API constants or repository calls** in the codebase yet (so they are either static UI, local state only, or placeholders):

- Buyer wallet, requests, favourites, notifications inbox, explore sellers, track order, payment method
- Most seller features: create/edit services, manage orders, earnings, VIP, offers, discounts, posts, templates
- All admin features: users/services/orders/finance/announcements/reports
- Delivery hub/features
- Support/settings/profile details beyond auth

This is the biggest “missing wiring” area.

---

## 8) API contract (code-accurate)

### Base URLs (code)

In `lib/core/network/api_constants.dart`:

- **Production base URL used by the app**: `https://manzili-app.runasp.net/`
  - (HTTPS is used to avoid IIS 307 redirect issues on POST)
- Local base URL (not used by default): `https://localhost:6001`

### Common headers

In `lib/core/network/dio_client.dart`:

- Default headers:
  - `Content-Type: application/json`
  - `Accept: application/json`
- Auth:
  - `Authorization: Bearer <accessToken>` is set/cleared by `DioClient.setAccessToken()`

### Request/response wrapper expectations

The app is written to tolerate:

- Plain shapes (no wrapper)
- Wrapped shapes: `{ success, message, data }`
- Nested token payloads and token keys with multiple naming conventions (auth parsing is defensive)

### Endpoint details

#### Auth

1) `POST /auth/register` (legacy fallbacks: `/Auth/register`, `/api/Auth/register`)

- Body (app sends camelCase):

```json
{
  "fullName": "string",
  "email": "string",
  "password": "string",
  "role": 1
}
```

- Client behavior:
  - Clears any previous Authorization header before calling register
  - Expects wrapper `{ success, message, data }` (but can tolerate odd shapes)
  - Maps 409 → “الإيميل ده مسجل قبل كده”

2) `POST /auth/login` (legacy fallbacks: `/Auth/login`, `/api/Auth/login`)

- Body:

```json
{ "email": "string", "password": "string" }
```

- Client behavior:
  - Clears Authorization header before calling login (critical)
  - Parses tokens defensively (`TokenResponse.tryDecode`)
  - After success:
    - Stores tokens **in memory only** in `AuthProvider`
    - Sets Dio Authorization header for future calls
    - Decodes role from JWT if present (role-based routing)

- Tokens accepted key variants include (examples):
  - `accessToken`, `AccessToken`, `access_token`, `token`, `jwt`, `jwtToken`, `JwtToken`
  - `refreshToken`, `RefreshToken`, `refresh_token`, `refresh`

3) `POST /auth/refresh` (legacy fallbacks: `/Auth/refresh`, `/api/Auth/refresh`)

- Body:

```json
{ "refreshToken": "string" }
```

- Client behavior:
  - Calls when you explicitly invoke `refreshTokens()`
  - If refresh fails (401 etc.) app clears tokens and logs out in memory

#### Services

4) `GET /services` (legacy fallback: `/api/services`)

- Query params supported by app (camelCase):
  - `page` (int)
  - `pageSize` (int)
  - `categoryId` (int?)
  - `isRecommended` (bool?)
  - `topDiscounts` (bool?)
  - `mostPurchased` (bool?)

- Response parsed into `PaginatedServicesResponse`:
  - supports:
    - direct: `{ items, page, pageSize, totalPages }`
    - wrapped: `{ data: { items, page, pageSize, totalPages }, success, message }`

5) `GET /services/name/{name}` (legacy fallback: `/api/services/name/{name}`)

- App uses this for text search.
- Query params used in app:
  - In `fetchServices(searchQuery: ...)` it sends `page` + `pageSize`
  - In `getServiceByName()` it sends:
    - `keyword` (optional)
    - `pageNumber`
    - `pageSize`

Note: your spec says this endpoint supports `keyword, pageNumber, pageSize`. The code currently mixes usage patterns (both variants exist). If the backend expects only one pattern, this should be unified.

6) `GET /services/{id}` (legacy fallback: `/api/services/{id}`)

- Parsed into `ServiceItem` (detailed shape supported):
  - `provider` object supported
  - `options` list supported
  - `images` list supported
  - Optional reviews list supported if API includes `reviews` or `serviceReviews`

7) `GET /services/home/{no}` (legacy fallback: `/api/services/home/{no}`)

- Parsed into `HomeServicesBuckets`:
  - `topDiscounts`
  - `recommended`
  - `mostPurchased`
  - `regular`

- App behavior on 404:
  - Treats it as “not available” and falls back to calling the other list endpoints.

#### Categories
- **GET** `/categories`
  - Fetches all available categories in the system.
  - Returns: `{ "success": true, "data": { "items": [ { "id": 1, "slug": "food", "nameAr": "مأكولات منزلية", "isActive": true, "sortOrder": 1, "createdAt": "..." } ] } }`

#### Orders

8) `POST /orders/request` (legacy fallback: `/api/orders/request`)

- Body (`OrderRequestBody` in `lib/data/models/order_models.dart`):

```json
{
  "serviceId": 1,
  "customizationText": "string",
  "customRequestImage": "string",
  "quantity": 1,
  "optionGroups": [
    { "groupId": 1, "items": [ { "optionId": 1, "quantity": 1 } ] }
  ]
}
```

- Notes:
  - `customRequestImage` is only sent if non-empty (string)
  - `optionGroups` is only sent if non-empty

9) `GET /orders` (legacy fallback: `/api/orders`)

- Query params:
  - `page`, `pageSize`
  - optional `status`

- Response:
  - app tries `raw['data'] ?? raw` then parses `PaginatedOrdersResponse`
  - Items parse into `OrderListItem` with nested `options`

10) `GET /order/payment-summary` (legacy fallback: `/api/orders/payment-summary`)

11) `POST /orders/submit-payment`

- Body (as provided):

```json
{
  "OrderIds": [1, 3],
  "PaymentScreenshot": "string",
  "Notes": "string | null"
}
```

- Response (as provided):

```json
{
  "OrderNo": "string",
  "PaymentDate": "2026-04-28T00:00:00",
  "Total": 0
}
```

Notes:
- The app currently exposes this from **Payment Method** screen for the “تحويل” option, and submits proof for the order ids present in the loaded payment summary.

#### Seller

12) `GET /seller/services`

- Query params:
  - `Status` (Active/Draft/Blocked)
  - `Page` (default 1)
  - `PageSize` (default 10)

13) `GET /seller/services/{id}`

- Returns: seller-specific service details including `images: [string]` and `optionGroups`.

14) `GET /seller/dashboard`

- Returns:

```json
{
  "totalServices": 2,
  "activeOrders": 3,
  "completedOrders": 1,
  "totalRevenue": 2350.14,
  "averageRating": 4.8
}
```

- Response parsed into `PaymentSummaryData`
  - The model accepts both PascalCase keys (e.g. `Services`) and camelCase (`services`)

---

## 9) “No local images” requirement (what it means here)

You explicitly required:

- “I don’t want any data like images or stuff like that from my local. I want them all from the API.”

Current state (in codebase):

- **Catalog/service images** are intended to be loaded from API host via URL resolution (base URL + image folder).
- **UI chrome assets** (icons/gradients/social logos) still exist as bundled assets. Those are not “service data”, but they are local assets.

If you want **literally zero local assets**, that becomes a different requirement:

- You would need:
  - remote-hosted icon set
  - remote-hosted brand assets
  - remote-hosted UI backgrounds
  - a caching strategy
  - a fallback strategy for offline or failed downloads

Most apps keep UI chrome as local assets and only load dynamic catalog/content from the API.

---

## 10) What’s missing (explicit checklist)

This is the “everything missing” section you asked for. It is split into backend vs app.

### A) Missing backend endpoints (needed for existing screens)

The app includes screens for seller/admin/delivery/support/wallet/favourites/notifications/etc., but there are **no API routes implemented in code** for them yet. Therefore the backend likely needs endpoints such as:

- **Buyer**
  - Favourites: add/remove/list favourites
  - Wallet: balance, transactions, top-up/withdraw
  - Requests list: list service requests (if different from orders)
  - Notifications: inbox list + mark read
  - Explore sellers: sellers listing + seller profile + seller services
  - Track order: order tracking timeline/events
  - Payment method: saved cards/payment methods + set default
- **Reviews**
  - Create review, list reviews by service/provider, rating breakdown
- **Seller**
  - CRUD services (create/edit/delete)
  - Upload service images
  - Manage incoming orders (accept/reject, set schedule, update status)
  - Discounts/offers management
  - Posts/templates/VIP tools (marketing)
  - Earnings + payout/settlements
- **Admin**
  - Admin auth/roles
  - User management
  - Service moderation
  - Orders oversight
  - Finance reports and transaction views
  - Announcements (create/list)
  - Analytics/reports
- **Delivery**
  - Available deliveries feed
  - Accept delivery
  - Verification (OTP/QR)
  - Delivery status updates
- **Support**
  - Submit ticket
  - Ticket status

If the backend is not planned yet for these, the UI should either be clearly “coming soon” or the router should hide them.

### B) Missing mobile app wiring (core product readiness)

1) **Auth persistence**
- Tokens are currently stored **in memory only**.
- Missing: saving tokens securely (e.g. secure storage), restoring session on app restart.

2) **Route guards**
- Routes like `/seller`, `/admin`, `/delivery`, `/cart`, `/payment-*` can be opened without a hard guard.
- Missing: centralized route protection based on auth + role.

3) **Automatic refresh-on-401**
- There is a refresh API method, but no Dio interceptor to:
  - detect 401
  - refresh token
  - retry request
  - log out if refresh fails

4) **API coverage**
- Most screens have no repositories/providers calling APIs.
- Missing: repositories + providers for seller/admin/delivery/etc.

5) **Consistency of service search endpoint usage**
- Code uses both:
  - `/api/services/name/{name}` + `page,pageSize`
  - `/api/services/name/{name}` + `keyword,pageNumber,pageSize`
- Missing: choose the correct contract and make it consistent.

6) **Orders “request” vs “cart” behavior clarity**
- Cart submits each item as an independent `POST /api/orders/request`.
- Missing: server-side support or UI copy clarifying “each cart line is a separate request” (or add a batch endpoint later).

7) **Missing app analytics/marketing tools**
- The UI routes exist for seller marketing tools, but no data model/API integration exists yet.

8) **Testing coverage**
- Only basic test scaffolding exists. Missing:
  - integration tests for core flows: login → browse → details → order
  - API mocking strategy

---

## 11) Known issues you reported previously (from the transcript)

These are real issues you encountered earlier and the reasons/fixes that were discussed/implemented:

- Android emulator startup failure on your machine (Vulkan/gfxstream GPU-related)
- Auth failing due to IIS HTTP→HTTPS redirect (307) — solved by using HTTPS base URL in code
- Login parsing failures due to nested/varied token response shapes — solved with defensive token parsing
- Login success message but no navigation — solved by correcting success branch + post-frame navigation
- UI overflow in service cards — layout fix
- “No local images”: resolved service image URLs by building full API URLs, with a neutral placeholder when missing
- Stack bounded-constraints assertion on a decorative stack — fixed by constraining size

If you want to reference the source conversation that contained these, it’s stored as:
- [Manzili prompt + API fixes](68fc6a3e-6d82-42a2-bd4c-a1234e0e20cb)

---

## 12) What to tell the next AI (copy/paste quick bootstrap)

If you’re sending this to another AI, paste this block first:

### Bootstrap block

- You are working on a Flutter app called **Manzili (منزلي)** for Egypt (ar_EG).
- Follow these UX rules: mobile-first, vertical scrolling, cards not tables, warm/soft UI, clear hierarchy, Egyptian Arabic copy, handle loading/empty/error states.
- Roles: buyer/seller/admin (+ delivery).
- Implement API contract with base URL `https://manzili-app.runasp.net/` (avoid IIS 307 redirect).
- Existing implemented endpoints: Auth, Services, Orders only (see this file).
- The router includes many seller/admin/delivery screens but most are UI-only; implement missing repositories/providers + API contracts.
- Requirement: dynamic content (services + images) must come from API (no local catalog images).

---

## 12.1) Rules for ANY AI working on this project (STRICT)

These rules are **mandatory**. If an AI can’t follow them, it should not proceed.

### A) Structure & consistency rules

- **Do not change the project architecture randomly**: keep the current layering pattern:
  - `core/` for router/network/theme/constants/utils
  - `data/models` for JSON models
  - `data/repositories` for API calls
  - `presentation/providers` for state + orchestration
  - `presentation/views` for screens
  - `presentation/widgets` for reusable UI
- **Do not rename routes or move screens** unless the change is required by a real bug or a real API contract change.
- **Do not invent features** that were not requested. If an API is missing, the UI must show a clear “coming soon / missing API” state.
- **All user-facing text must be Egyptian Arabic** (عامية مصرية بسيطة), friendly and clear.
- **Sign-in UX rule:** do **not** ask the user to pick a role on login. The backend account role must be derived from the login response/JWT and routing should follow that automatically.

### B) API integration rules (every time a new API is provided)

Whenever the user gives you a new API endpoint:

- **Integrate it into the correct place/page** (the screen that logically owns it).
- Implement it end-to-end:
  - **`ApiConstants`**: add endpoint constant(s) and any helper `...ById()` builders.
  - **Models**: add/update request/response models to match JSON exactly (case + nesting).
  - **Repository**: add a method calling the endpoint with correct method/query/body/headers.
  - **Provider**: expose loading/error/data state and call the repository.
  - **UI**: wire the screen to the provider and handle:
    - loading state
    - empty state
    - error state + retry
    - success state
- **Do not hardcode mock data** in screens once an API exists for that screen.
- **Images and dynamic content must come from the API**, not local placeholder photos. If missing, show a neutral UI placeholder (not a local photo).
- If backend responses have multiple shapes (legacy/new), you may support both, but **document it in this file** and keep the logic contained (repository/provider), not scattered.

### C) UI responsiveness rules

For every screen you touch:

- Must be **mobile-first** and work on small screens without overflow.
- Avoid fixed heights that cause RenderFlex overflow.
- Use scroll views where needed.
- Keep taps thumb-friendly, consistent spacing, and card-based layout.

### D) Mandatory documentation updates

- **Every time you change the project (API, models, screens, routing, or behavior), you MUST update `PROJECT_HANDOFF.md` in the same work session**.
- Update at minimum:
  - **API contract section** (new endpoints + shapes)
  - **Implemented vs missing** section (what is now wired)
  - **Routes/screens affected** section (what changed and where)

### E) Quality gates (before finishing)

Before saying “done”:

- Ensure there are **no compile errors**.
- Run static checks if available (at least `flutter analyze`) and fix any **new** warnings/errors you introduced (pre-existing ones can remain, but don’t add new ones).
- Make sure the new API call is actually triggered from the intended UI path, and errors are visible to the user in Arabic.

---

## 12.2) Showcase Demo Mode (temporary)

For demos/showcases when the backend is incomplete, the app may enable **temporary demo fallbacks**:

- **Static admin login** (demo-only):
  - `wasfyAdmin@gmail.com` / `wasfy1234`
  - Routes to `/admin`
- **Demo data fallback** when API calls fail:
  - Orders list and payment summary
  - Seller dashboard and seller services list
  - Services list

Tracking file (must be removed later): `SHOWCASE_DEMO_TODOS.md`

---

## 13) Appendix — “single source of truth” file pointers

If you need to quickly reconstruct behavior:

- Routing: `lib/core/router/app_router.dart`
- API constants: `lib/core/network/api_constants.dart`
- Dio configuration: `lib/core/network/dio_client.dart`
- Auth logic + token parsing: `lib/presentation/providers/auth_provider.dart` + `lib/data/models/auth_models.dart`
- Services networking: `lib/presentation/providers/services_provider.dart` + `lib/data/models/service_models.dart`
- Orders networking: `lib/data/repositories/orders_repository.dart` + `lib/data/models/order_models.dart`
- Cart submission behavior: `lib/presentation/providers/cart_provider.dart`
- Figma node ids: `lib/core/constants/figma_screen_nodes.dart`

