import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manzili_mobile/presentation/views/admin/admin_announcements_view.dart';
import 'package:manzili_mobile/presentation/views/admin/admin_finance_view.dart';
import 'package:manzili_mobile/presentation/views/admin/admin_hub_view.dart';
import 'package:manzili_mobile/presentation/views/admin/admin_orders_view.dart';
import 'package:manzili_mobile/presentation/views/admin/admin_reports_view.dart';
import 'package:manzili_mobile/presentation/views/admin/admin_services_view.dart';
import 'package:manzili_mobile/presentation/views/admin/admin_users_view.dart';
import 'package:manzili_mobile/presentation/views/buyer/buyer_wallet_view.dart';
import 'package:manzili_mobile/presentation/views/buyer/cart_view.dart';
import 'package:manzili_mobile/presentation/views/buyer/explore_sellers_view.dart';
import 'package:manzili_mobile/presentation/views/buyer/favourites_view.dart';
import 'package:manzili_mobile/presentation/views/buyer/order_placed_view.dart';
import 'package:manzili_mobile/presentation/views/buyer/orders_list_view.dart';
import 'package:manzili_mobile/presentation/views/buyer/requests_list_view.dart';
import 'package:manzili_mobile/presentation/views/buyer/track_order_view.dart';
import 'package:manzili_mobile/presentation/views/home_view.dart';
import 'package:manzili_mobile/presentation/views/main_shell_view.dart';
import 'package:manzili_mobile/presentation/views/reviews_view.dart';
import 'package:manzili_mobile/presentation/views/seller/seller_auto_accept_view.dart';
import 'package:manzili_mobile/presentation/views/seller/seller_compose_post_view.dart';
import 'package:manzili_mobile/presentation/views/seller/seller_create_service_view.dart';
import 'package:manzili_mobile/presentation/views/seller/seller_earnings_view.dart';
import 'package:manzili_mobile/presentation/views/seller/seller_edit_service_view.dart';
import 'package:manzili_mobile/presentation/views/seller/seller_hub_view.dart';
import 'package:manzili_mobile/presentation/views/seller/seller_offer_editor_view.dart';
import 'package:manzili_mobile/presentation/views/seller/seller_offers_list_view.dart';
import 'package:manzili_mobile/presentation/views/seller/seller_scheduled_posts_view.dart';
import 'package:manzili_mobile/presentation/views/seller/seller_templates_view.dart';
import 'package:manzili_mobile/presentation/views/seller/seller_vip_view.dart';
import 'package:manzili_mobile/presentation/views/service_details_view.dart';
import 'package:manzili_mobile/presentation/views/services_view.dart';
import 'package:manzili_mobile/presentation/views/signin_view.dart';
import 'package:manzili_mobile/presentation/views/signup_view.dart';
import 'package:manzili_mobile/presentation/views/support/notifications_inbox_view.dart';
import 'package:manzili_mobile/presentation/views/support/profile_hub_view.dart';
import 'package:manzili_mobile/presentation/views/support/settings_view.dart';
import 'package:manzili_mobile/presentation/views/support/support_confirmation_view.dart';
import 'package:manzili_mobile/presentation/views/support/support_form_view.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/signin',
    routes: [
      GoRoute(
        path: '/signin',
        builder: (context, state) => const SigninView(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupView(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellView(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) =>
                    const NoTransitionPage<void>(child: HomeView()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/services',
                pageBuilder: (context, state) =>
                    const NoTransitionPage<void>(child: ServicesView()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/requests',
                pageBuilder: (context, state) =>
                    const NoTransitionPage<void>(child: RequestsListView()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/my-orders',
                pageBuilder: (context, state) =>
                    const NoTransitionPage<void>(child: OrdersListView()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/wallet',
                pageBuilder: (context, state) =>
                    const NoTransitionPage<void>(child: BuyerWalletView()),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/orders',
        redirect: (context, state) => '/my-orders',
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileHubView(),
      ),
      GoRoute(
        path: '/favourites',
        builder: (context, state) => const FavouritesView(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsView(),
      ),
      GoRoute(
        path: '/service/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return ServiceDetailsView(serviceId: id);
        },
      ),
      GoRoute(
        path: '/reviews/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return ReviewsView(serviceId: id);
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsInboxView(),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartView(),
      ),
      GoRoute(
        path: '/order-placed',
        builder: (context, state) => const OrderPlacedView(),
      ),
      GoRoute(
        path: '/track-order',
        builder: (context, state) => const TrackOrderView(),
      ),
      GoRoute(
        path: '/explore-sellers',
        builder: (context, state) => const ExploreSellersView(),
      ),
      GoRoute(
        path: '/seller',
        builder: (context, state) => const SellerHubView(),
      ),
      GoRoute(
        path: '/seller/create-service',
        builder: (context, state) => const SellerCreateServiceView(),
      ),
      GoRoute(
        path: '/seller/edit-service',
        builder: (context, state) => const SellerEditServiceView(),
      ),
      GoRoute(
        path: '/seller/auto-accept',
        builder: (context, state) => const SellerAutoAcceptView(),
      ),
      GoRoute(
        path: '/seller/earnings',
        builder: (context, state) => const SellerEarningsView(),
      ),
      GoRoute(
        path: '/seller/vip',
        builder: (context, state) => const SellerVipView(),
      ),
      GoRoute(
        path: '/seller/offers',
        builder: (context, state) => const SellerOffersListView(),
      ),
      GoRoute(
        path: '/seller/offers/new',
        builder: (context, state) => const SellerOfferEditorView(),
      ),
      GoRoute(
        path: '/seller/compose',
        builder: (context, state) => const SellerComposePostView(),
      ),
      GoRoute(
        path: '/seller/scheduled',
        builder: (context, state) => const SellerScheduledPostsView(),
      ),
      GoRoute(
        path: '/seller/templates',
        builder: (context, state) => const SellerTemplatesView(),
      ),
      GoRoute(
        path: '/support',
        builder: (context, state) => const SupportFormView(),
      ),
      GoRoute(
        path: '/support/confirmation',
        builder: (context, state) {
          final ticket = state.uri.queryParameters['ticket'] ?? '—';
          return SupportConfirmationView(ticketNumber: ticket);
        },
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminHubView(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const AdminUsersView(),
      ),
      GoRoute(
        path: '/admin/services',
        builder: (context, state) => const AdminServicesView(),
      ),
      GoRoute(
        path: '/admin/orders',
        builder: (context, state) => const AdminOrdersView(),
      ),
      GoRoute(
        path: '/admin/finance',
        builder: (context, state) => const AdminFinanceView(),
      ),
      GoRoute(
        path: '/admin/announcements',
        builder: (context, state) => const AdminAnnouncementsView(),
      ),
      GoRoute(
        path: '/admin/reports',
        builder: (context, state) => const AdminReportsView(),
      ),
    ],
  );
}
