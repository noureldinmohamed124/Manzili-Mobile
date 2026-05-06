# Manzili Integrated APIs

## Fully Integrated and Functional APIs

| API Name | API URL | API Category |
|----------|---------|--------------|
| Register | POST /auth/register | Auth |
| Login | POST /auth/login | Auth |
| Refresh Token | POST /auth/refresh | Auth |
| Get Dashboard Stats | GET /seller/dashboard | Seller |
| Create Service | POST /seller/services | Seller |
| Get All Services | GET /seller/services | Seller |
| Get Specific Service | GET /seller/services/{id} | Seller |
| Update Service | PUT /seller/services/{id} | Seller |
| Delete Service | DELETE /seller/services/{id} | Seller |
| Get All Orders | GET /seller/orders | Seller |
| Get Specific Order | GET /seller/orders/{id} | Seller |
| Approve Order | POST /seller/orders/{id}/approve | Seller |
| Reject Order | POST /seller/orders/{id}/reject | Seller |
| RePrice Order | POST /seller/orders/{id}/reprice | Seller |
| Update Order Status | PUT /seller/orders/{id}/status | Seller |
| Get Dashboard Stats | GET /admin/dashboard | Admin |
| Get All Users | GET /admin/users | Admin |
| Get User Details | GET /admin/users/{id} | Admin |
| Block User | POST /admin/users/{id}/block | Admin |
| Unblock User | POST /admin/users/{id}/unblock | Admin |
| Get All Financials | GET /admin/financials | Admin |
| Get All Orders | GET /admin/orders | Admin |
| Get All Services | GET /admin/services | Admin |
| Get All Categories | GET /categories | Public |
| Request Service | POST /orders/request | Buyer |
| Get All Orders | GET /orders | Buyer |
| Get Payment Summary | GET /order/payment-summary | Buyer |
| Submit Payment Proof | POST /orders/submit-payment | Buyer |
| Get All Services | GET /services | Public |
| Get Service By Id | GET /services/{id} | Public |
| Get Services By Name | GET /services/name/{name} | Public |
| Get Home Section Services | GET /services/home/{no} | Public |

## Other APIs (Not Fully Integrated or Pending UI Wiring)
*(Currently, all endpoints from the core spec have been integrated into the Dart repositories and providers. Any endpoint not listed above is outside the scope of the 32 requested APIs.)*
