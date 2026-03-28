/// User-facing copy in Egyptian Arabic (عامية بسيطة) — Manzili spec.
class AppStrings {
  AppStrings._();

  // —— Common ——
  static const String appName = 'منزلي';
  static const String loading = 'جاري التحميل…';
  static const String retry = 'حاول تاني';
  static const String cancel = 'إلغاء';
  static const String confirm = 'أكد';
  static const String save = 'احفظ';
  static const String delete = 'حذف';
  static const String edit = 'تعديل';
  static const String back = 'رجوع';

  // —— Auth ——
  static const String loginSuccess = 'تمام، دخلت 👌';
  static const String fillEmailPassword = 'اكتب الإيميل والباسورد الأول';
  static const String signInCta = 'ادخل';
  static const String signInLoading = 'جاري الدخول…';
  static const String forgotPassword = 'نسيت الباسورد؟';
  static const String rememberMe = 'خليك فاكرني';
  static const String noAccountSignUp = 'معندكش حساب؟ اعمل حساب';
  static const String signUpCta = 'اعمل حساب';
  static const String haveAccountSignIn = 'عندك حساب؟ سجل دخول';
  static const String signupHasAccountPrefix = 'عندك حساب؟ ';
  static const String signupSignInLink = 'سجل دخول';
  static const String signupScreenTitle = 'اعمل حساب جديد';
  static const String signupSocialDivider = 'أو كمل بجوجل / فيسبوك';

  // —— Seller: Create Service ——
  static const String createServiceTitle = 'اعمل خدمة جديدة';
  static const String fieldServiceTitle = 'اسم الخدمة';
  static const String fieldCategory = 'نوع الخدمة';
  static const String fieldDescription = 'الوصف';
  static const String fieldBasePrice = 'السعر الأساسي';
  static const String fieldImages = 'صور الخدمة';
  static const String fieldVariants = 'خيارات / مقاسات';
  static const String fieldExtras = 'مميزات إضافية';
  static const String draftToggle = 'حفظ كمسودة';
  static const String ctaPublishService = 'اعمل الخدمة';
  static const String ctaLeaveWithoutSave = 'ارجع من غير حفظ';

  static const String errTitleLength = 'اكتب اسم خدمة صح';
  static const String errCategory = 'اختار نوع الخدمة';
  static const String errDescription = 'اكتب وصف أوضح شوية';
  static const String errPrice = 'اكتب سعر صحيح';
  static const String errImages = 'لازم تضيف صورة واحدة على الأقل';

  // —— Seller: Edit Service ——
  static const String editServiceTitle = 'عدّل الخدمة';
  static const String ctaSaveEdits = 'احفظ التعديلات';
  static const String errKeepOneImage = 'لازم تسيب صورة واحدة على الأقل';

  // —— Seller: Status ——
  static const String statusSheetTitle = 'حالة الخدمة';
  static const String statusActive = 'نشطة';
  static const String statusPaused = 'موقوفة';
  static const String statusDraft = 'مسودة';
  static const String errStatusChange = 'ماقدرناش نغير الحالة، جرّب تاني';

  // —— Seller: Auto accept ——
  static const String autoAcceptTitle = 'القبول التلقائي';
  static const String autoAcceptSubtitle = 'فعّل القبول التلقائي';
  static const String autoAcceptHint =
      'بيتفعّل بس لما الخدمة تكون شغّالة ومش موقوفة.';
  static const String errAutoAcceptSave =
      'ماقدرناش نحفظ الإعداد ده، جرّب تاني';

  // —— Seller: Earnings ——
  static const String earningsTitle = 'أرباحك وتحليلاتك';
  static const String filterToday = 'اليوم';
  static const String filterWeek = 'الأسبوع';
  static const String filterMonth = 'الشهر';
  static const String cardGross = 'الأرباح الإجمالية';
  static const String cardPending = 'أرباح معلقة';
  static const String cardOrdersCount = 'عدد الطلبات';
  static const String cardAvgOrder = 'متوسط الطلب';
  static const String topServices = 'أقوى الخدمات';
  static const String recentEarnings = 'آخر الأرباح';
  static const String errAnalyticsLoad = 'في مشكلة في تحميل التحليلات';
  static const String errAnalyticsEmpty = 'لسه مفيش بيانات كفاية نعرضها';

  // —— VIP ——
  static const String vipTitle = 'أدوات VIP';
  static const String vipCtaMore = 'اعرف أكتر';
  static const String vipCtaSubscribe = 'اشترك في VIP';
  static const String vipActive = 'اشتراك شغّال';
  static const String vipExpired = 'الاشتراك خلص';
  static const String vipNone = 'مش مشترك';
  static const String vipLocked = 'مقفول';
  static const String vipUnlocked = 'متاح';

  // —— Offers ——
  static const String offersTitle = 'العروض';
  static const String offerEditorTitle = 'عرض جديد';
  static const String offerEditTitle = 'تعديل العرض';
  static const String fieldOfferTitle = 'عنوان العرض';
  static const String fieldLinkedService = 'الخدمة';
  static const String fieldDiscount = 'نسبة الخصم';
  static const String fieldDates = 'من / لحد';
  static const String fieldNotes = 'ملاحظات';

  // —— Posts ——
  static const String composePostTitle = 'اكتب بوست';
  static const String fieldPostTitle = 'العنوان';
  static const String fieldPostBody = 'المحتوى';
  static const String fieldMedia = 'صورة أو فيديو';
  static const String fieldTags = 'هاشتاجات';
  static const String fieldVisibility = 'مين يشوفه؟';
  static const String fieldSchedule = 'جدولة النشر';
  static const String ctaPublish = 'انشر';
  static const String ctaSaveDraft = 'احفظ كمسودة';

  static const String scheduledPostsTitle = 'البوستات المجدولة';

  // —— Templates ——
  static const String templatesTitle = 'قوالب جاهزة';
  static const String templatesSubtitle = 'استخدمها وتعدّل عليها بسرعة';

  // —— Notifications ——
  static const String notificationsTitle = 'الإشعارات';
  static const String notifFilterAll = 'الكل';
  static const String notifFilterOrders = 'الطلبات';
  static const String notifFilterMessages = 'الرسائل';
  static const String notifFilterSystem = 'النظام';

  // —— Support ——
  static const String supportTitle = 'تواصل معانا';
  static const String fieldSupportName = 'الاسم';
  static const String fieldSupportEmail = 'الإيميل';
  static const String fieldIssueType = 'نوع المشكلة';
  static const String fieldSupportDesc = 'اشرح المشكلة';
  static const String fieldAttachment = 'ملف (اختياري)';
  static const String supportSubmit = 'ابعت الطلب';
  static const String supportSuccessTitle = 'تمام، وصلنا طلبك';
  static const String supportTicketLabel = 'رقم التذكرة';
  static const String supportNextSteps =
      'هنرجعلك بالتحديث على الإيميل أو من الإشعارات.';

  // —— Admin ——
  static const String adminHub = 'لوحة التحكم';
  static const String adminUsers = 'المستخدمين';
  static const String adminServices = 'الخدمات';
  static const String adminOrders = 'الطلبات';
  static const String adminFinance = 'المالية';
  static const String adminAnnouncements = 'إعلانات';
  static const String adminReports = 'تقارير';

  // —— Profile hub ——
  static const String sellerTools = 'أدوات البائع';
  static const String buyerSection = 'تسوق';
  static const String exploreSellers = 'اكتشف البائعين';
  static const String cart = 'سلة الخدمات';
  static const String trackOrders = 'تتبع الطلب';
  static const String profileTitle = 'حسابي';
  static const String navAccount = 'حسابي';
  static const String settingsTitle = 'الإعدادات';
  static const String navSettings = 'الإعدادات';

  // —— Bottom nav (spec Section 7) ——
  static const String navHome = 'الرئيسية';
  static const String navServices = 'الخدمات';
  static const String navRequests = 'طلباتي';
  static const String navOrdersPaid = 'أوردراتي';
  static const String navWallet = 'فلوسي';

  // —— Requests (طلباتي) ——
  static const String requestTabPending = 'قيد المراجعة';
  static const String requestTabApproved = 'تم الموافقة';
  static const String requestTabRejected = 'مرفوضة';
  static const String requestsEmptyPending =
      'مافيش طلبات قيد المراجعة. ابعت طلب من السلة والبياع هيرد 👀';
  static const String requestsEmptyApproved = 'لسه مفيش طلبات متأكدة هنا.';
  static const String requestsEmptyRejected = 'مافيش طلبات مرفوضة.';
  static const String browseServicesCta = 'تصفح الخدمات';

  // —— Wallet ——
  static const String walletLedgerHint =
      'هنا سجل التحويلات والمدفوعات. التحويل بإثبات بيتحقق من الإدارة الأول.';
  static const String walletTotalSent = 'إجمالي المدفوع';
  static const String walletTotalReceived = 'إجمالي المستلم';
  static const String walletTransactionHistory = 'سجل العمليات';
  static const String walletHistorySubtitle = 'شوف كل التحويلات والحالات';
  static const String walletEmptyState = 'لسه مفيش عمليات. هتظهر هنا أول ما تتحرك فلوسك.';
  static const String backToHome = 'الرئيسية';

  // —— Cart (request builder) ——
  static const String cartInfoBanner =
      'هتبعت طلبك للبائع الأول، والدفع بيكون بعد ما يوافق 👌';
  static const String cartSubmitRequest = 'إرسال الطلب';
  static const String cartEmptyTitle = 'السلة فاضية 😅';
  static const String cartEmptyCta = 'ابدأ شوف خدمات';

  // —— Home ——
  static const String homeSearchHint = 'بتدور على إيه؟';

  // —— Services list ——
  static const String servicesSearchDialogTitle = 'دور على خدمة';
  static const String servicesSearchFieldHint = 'دور على خدمة…';
  static const String servicesSearchAction = 'بحث';
  static const String servicesFilterLabel = 'فلترة';
  static const String badgeDiscount = 'خصم';
  static const String badgeVip = 'مرشحه';
  static const String badgeTopSold = 'الأكثر طلبًا';

  // —— Service details ——
  static const String serviceRequestHelper =
      'هتطلب الخدمة الأول وبعدين تتأكد من السعر قبل الدفع';
  static const String orderNotesHint = 'اكتب تفاصيل الطلب…';
  static const String favouritesTitle = 'المفضلة';
  static const String navFavourites = 'المفضلة';

  // —— Orders (أوردراتي) ——
  static const String orderTabActive = 'جارية';
  static const String orderTabDone = 'مكتملة';
  static const String orderTabCancelled = 'ملغية';
  static const String orderStatusInProgress = 'قيد التنفيذ';
  static const String orderStatusDelivered = 'تم التسليم';
  static const String orderCardCta = 'تفاصيل الطلب';
  static const String ordersEmptyDone = 'لسه مفيش أوردرات مكتملة هنا.';
  static const String ordersEmptyCancelled = 'مافيش أوردرات ملغية.';
}
