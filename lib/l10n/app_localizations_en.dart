// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Manzili';

  @override
  String get loading => 'Loading…';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get back => 'Back';

  @override
  String get loginSuccess => 'Logged in successfully 👌';

  @override
  String get fillEmailPassword => 'Enter email and password first';

  @override
  String get signInCta => 'Sign In';

  @override
  String get signInLoading => 'Signing in…';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get noAccountSignUp => 'Don\'t have an account? Sign up';

  @override
  String get signUpCta => 'Sign Up';

  @override
  String get haveAccountSignIn => 'Have an account? Sign in';

  @override
  String get signupHasAccountPrefix => 'Have an account? ';

  @override
  String get signupSignInLink => 'Sign in';

  @override
  String get signupScreenTitle => 'Create a new account';

  @override
  String get signupSocialDivider => 'Or continue with Google / Facebook';

  @override
  String get createServiceTitle => 'Create a New Service';

  @override
  String get fieldServiceTitle => 'Service Title';

  @override
  String get fieldCategory => 'Category';

  @override
  String get fieldDescription => 'Description';

  @override
  String get fieldBasePrice => 'Base Price';

  @override
  String get fieldImages => 'Service Images';

  @override
  String get fieldVariants => 'Options / Sizes';

  @override
  String get fieldExtras => 'Extras';

  @override
  String get draftToggle => 'Save as draft';

  @override
  String get ctaPublishService => 'Publish Service';

  @override
  String get ctaLeaveWithoutSave => 'Leave without saving';

  @override
  String get errTitleLength => 'Enter a valid service title';

  @override
  String get errCategory => 'Choose a category';

  @override
  String get errDescription => 'Write a clearer description';

  @override
  String get errPrice => 'Enter a valid price';

  @override
  String get errImages => 'You must add at least one image';

  @override
  String get editServiceTitle => 'Edit Service';

  @override
  String get ctaSaveEdits => 'Save Changes';

  @override
  String get errKeepOneImage => 'You must leave at least one image';

  @override
  String get statusSheetTitle => 'Service Status';

  @override
  String get statusActive => 'Active';

  @override
  String get statusPaused => 'Paused';

  @override
  String get statusDraft => 'Draft';

  @override
  String get errStatusChange => 'Couldn\'t change status, try again';

  @override
  String get autoAcceptTitle => 'Auto Accept';

  @override
  String get autoAcceptSubtitle => 'Enable auto accept';

  @override
  String get autoAcceptHint => 'Only active when service is not paused.';

  @override
  String get errAutoAcceptSave => 'Couldn\'t save this setting, try again';

  @override
  String get earningsTitle => 'Earnings & Analytics';

  @override
  String get filterToday => 'Today';

  @override
  String get filterWeek => 'Week';

  @override
  String get filterMonth => 'Month';

  @override
  String get cardGross => 'Total Earnings';

  @override
  String get cardPending => 'Pending Earnings';

  @override
  String get cardOrdersCount => 'Orders Count';

  @override
  String get cardAvgOrder => 'Average Order';

  @override
  String get topServices => 'Top Services';

  @override
  String get recentEarnings => 'Recent Earnings';

  @override
  String get errAnalyticsLoad => 'Problem loading analytics';

  @override
  String get errAnalyticsEmpty => 'Not enough data yet';

  @override
  String get vipTitle => 'VIP Tools';

  @override
  String get vipCtaMore => 'Learn More';

  @override
  String get vipCtaSubscribe => 'Subscribe to VIP';

  @override
  String get vipActive => 'Active Subscription';

  @override
  String get vipExpired => 'Subscription Expired';

  @override
  String get vipNone => 'Not Subscribed';

  @override
  String get vipLocked => 'Locked';

  @override
  String get vipUnlocked => 'Available';

  @override
  String get offersTitle => 'Offers';

  @override
  String get offerEditorTitle => 'New Offer';

  @override
  String get offerEditTitle => 'Edit Offer';

  @override
  String get fieldOfferTitle => 'Offer Title';

  @override
  String get fieldLinkedService => 'Linked Service';

  @override
  String get fieldDiscount => 'Discount Percentage';

  @override
  String get fieldDates => 'From / To';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get composePostTitle => 'Write a Post';

  @override
  String get fieldPostTitle => 'Title';

  @override
  String get fieldPostBody => 'Content';

  @override
  String get fieldMedia => 'Image or Video';

  @override
  String get fieldTags => 'Tags';

  @override
  String get fieldVisibility => 'Visibility';

  @override
  String get fieldSchedule => 'Schedule';

  @override
  String get ctaPublish => 'Publish';

  @override
  String get ctaSaveDraft => 'Save as Draft';

  @override
  String get scheduledPostsTitle => 'Scheduled Posts';

  @override
  String get templatesTitle => 'Templates';

  @override
  String get templatesSubtitle => 'Use and edit quickly';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notifFilterAll => 'All';

  @override
  String get notifFilterOrders => 'Orders';

  @override
  String get notifFilterMessages => 'Messages';

  @override
  String get notifFilterSystem => 'System';

  @override
  String get supportTitle => 'Contact Us';

  @override
  String get fieldSupportName => 'Name';

  @override
  String get fieldSupportEmail => 'Email';

  @override
  String get fieldIssueType => 'Issue Type';

  @override
  String get fieldSupportDesc => 'Describe the issue';

  @override
  String get fieldAttachment => 'Attachment (Optional)';

  @override
  String get supportSubmit => 'Submit Request';

  @override
  String get supportSuccessTitle => 'Request Received';

  @override
  String get supportTicketLabel => 'Ticket Number';

  @override
  String get supportNextSteps =>
      'We will get back to you via email or notification.';

  @override
  String get adminHub => 'Dashboard';

  @override
  String get adminUsers => 'Users';

  @override
  String get adminServices => 'Services';

  @override
  String get adminOrders => 'Orders';

  @override
  String get adminFinance => 'Finances';

  @override
  String get adminAnnouncements => 'Announcements';

  @override
  String get adminReports => 'Reports';

  @override
  String get sellerTools => 'Seller Tools';

  @override
  String get buyerSection => 'Shop';

  @override
  String get exploreSellers => 'Explore Sellers';

  @override
  String get cart => 'Cart';

  @override
  String get trackOrders => 'Track Orders';

  @override
  String get profileTitle => 'Profile';

  @override
  String get navAccount => 'Account';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get navSettings => 'Settings';

  @override
  String get navHome => 'Home';

  @override
  String get navServices => 'Services';

  @override
  String get navRequests => 'Requests';

  @override
  String get navOrdersPaid => 'Orders';

  @override
  String get navWallet => 'Wallet';

  @override
  String get requestTabPending => 'Pending';

  @override
  String get requestTabApproved => 'Approved';

  @override
  String get requestTabRejected => 'Rejected';

  @override
  String get requestsEmptyPending =>
      'No pending requests. Send a request from cart! 👀';

  @override
  String get requestsEmptyApproved => 'No approved requests yet.';

  @override
  String get requestsEmptyRejected => 'No rejected requests.';

  @override
  String get browseServicesCta => 'Browse Services';

  @override
  String get walletLedgerHint =>
      'Transaction history. Paid transfers are verified first.';

  @override
  String get walletTotalSent => 'Total Sent';

  @override
  String get walletTotalReceived => 'Total Received';

  @override
  String get walletTransactionHistory => 'Transaction History';

  @override
  String get walletHistorySubtitle => 'See all transfers and statuses';

  @override
  String get walletEmptyState => 'No transactions yet.';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get cartInfoBanner => 'Send request to seller, pay after approval 👌';

  @override
  String get cartSubmitRequest => 'Submit Request';

  @override
  String get cartEmptyTitle => 'Cart is empty 😅';

  @override
  String get cartEmptyCta => 'Start browsing services';

  @override
  String get homeSearchHint => 'What are you looking for?';

  @override
  String get servicesSearchDialogTitle => 'Search for a service';

  @override
  String get servicesSearchFieldHint => 'Search...';

  @override
  String get servicesSearchAction => 'Search';

  @override
  String get servicesFilterLabel => 'Filter';

  @override
  String get badgeDiscount => 'Discount';

  @override
  String get badgeVip => 'Recommended';

  @override
  String get badgeTopSold => 'Top Seller';

  @override
  String get serviceRequestHelper =>
      'Request service first, confirm price, then pay';

  @override
  String get orderNotesHint => 'Write order details...';

  @override
  String get favouritesTitle => 'Favorites';

  @override
  String get navFavourites => 'Favorites';

  @override
  String get orderTabActive => 'Active';

  @override
  String get orderTabDone => 'Completed';

  @override
  String get orderTabCancelled => 'Cancelled';

  @override
  String get orderStatusInProgress => 'In Progress';

  @override
  String get orderStatusDelivered => 'Delivered';

  @override
  String get orderCardCta => 'Order Details';

  @override
  String get ordersEmptyDone => 'No completed orders here yet.';

  @override
  String get ordersEmptyCancelled => 'No cancelled orders.';

  @override
  String get homeHeaderSubtitle => 'Handmade and homemade food at its best 👋';
}
